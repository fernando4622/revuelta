package com.revuelta.api.application.circulation;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.OperationQrTokenRepositoryPort;
import com.revuelta.api.application.port.ParticipantRepositoryPort;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.circulation.Punctuality;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.participant.OperationQrPurpose;
import com.revuelta.api.domain.participant.OperationQrToken;
import com.revuelta.api.domain.participant.Participant;
import com.revuelta.api.domain.participant.ParticipantId;
import com.revuelta.api.domain.policy.ReturnPolicy;
import com.revuelta.api.domain.user.UserId;
import com.revuelta.api.support.ImmediateTransactionRunner;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.function.Executable;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ReturnContainerUseCaseTest {
    private static final String PARTICIPANT_QR = "signed-return-participant-payload";
    private static final String CONTAINER_QR = "signed-container-payload";

    @Mock private ContainerRepositoryPort containers;
    @Mock private CirculationRepositoryPort circulations;
    @Mock private ParticipantRepositoryPort participants;
    @Mock private OperationQrTokenRepositoryPort tokens;
    @Mock private QrPayloadCodecPort qrCodec;
    @Mock private ContainerEventRepositoryPort events;

    private ReturnContainerUseCase useCase;
    private PreviewReturnUseCase previewUseCase;
    private final ContainerId containerId = ContainerId.generate();
    private final ParticipantId participantId = new ParticipantId(UUID.randomUUID());
    private final UserId operatorId = UserId.generate();
    private final UUID tokenId = UUID.randomUUID();
    private final UUID traceId = UUID.randomUUID();
    private final Instant now = Instant.parse("2026-09-24T18:00:00Z");
    private final Instant expiresAt = now.plusSeconds(120);

    @BeforeEach
    void setUp() {
        ReturnQrValidationService validator = new ReturnQrValidationService(
                tokens, participants, containers, circulations, qrCodec, () -> now
        );
        useCase = new ReturnContainerUseCase(
                validator, containers, circulations, tokens, events,
                new ImmediateTransactionRunner(), () -> traceId
        );
        previewUseCase = new PreviewReturnUseCase(validator, () -> traceId);
    }

    @Test
    void successfulReturnUsesBothQrValuesAndCommitsAllFourMutations() {
        Circulation circulation = arrangeValidReturn(false, now.minusSeconds(3600));

        var result = useCase.execute(PARTICIPANT_QR, CONTAINER_QR, operatorId);

        assertEquals(ContainerStatus.RETURNED, result.container().status());
        assertFalse(result.circulation().isActive());
        assertEquals(Punctuality.ON_TIME, result.circulation().punctuality());
        assertEquals(traceId, result.traceId());
        verify(qrCodec).decodeOperation(PARTICIPANT_QR);
        verify(qrCodec).decodeContainer(CONTAINER_QR);
        verify(circulations).save(circulation);
        verify(containers).save(result.container());

        ArgumentCaptor<ContainerEvent> event = ArgumentCaptor.forClass(ContainerEvent.class);
        verify(events).save(event.capture());
        assertEquals(participantId, event.getValue().participantId());
        assertEquals(circulation.id().value(), event.getValue().circulationId());

        ArgumentCaptor<OperationQrToken> consumed = ArgumentCaptor.forClass(OperationQrToken.class);
        verify(tokens).save(consumed.capture());
        assertEquals(now, consumed.getValue().consumedAt());
        assertEquals(circulation.id().value(), consumed.getValue().circulationId());
    }

    @Test
    void lateReturnIsClassifiedFromServerTimeAndKeepsHistoricalDueAt() {
        Circulation circulation = arrangeValidReturn(false, now.minusSeconds(49 * 3600));
        Instant historicalDueAt = circulation.dueAt();

        var result = useCase.execute(PARTICIPANT_QR, CONTAINER_QR, operatorId);

        assertEquals(Punctuality.LATE, result.circulation().punctuality());
        assertEquals(historicalDueAt, result.circulation().dueAt());
        assertEquals(now, result.circulation().returnedAt());
    }

    @Test
    void previewIsReadOnlyAndIncludesTheActiveCirculation() {
        Circulation circulation = arrangeValidReturn(true, now.minusSeconds(3600));

        var preview = previewUseCase.execute(PARTICIPANT_QR, CONTAINER_QR);

        assertEquals(circulation.id(), preview.returnData().circulation().id());
        assertEquals(participantId, preview.returnData().participant().id());
        assertEquals(now, preview.returnData().validatedAt());
        verify(tokens, never()).save(any());
        verify(circulations, never()).save(any());
        verify(containers, never()).save(any());
        verify(events, never()).save(any());
    }

    @Test
    void deliveryQrCannotBeUsedForReturn() {
        when(qrCodec.decodeOperation(PARTICIPANT_QR)).thenReturn(
                new QrPayloadCodecPort.OperationClaims(tokenId, OperationQrPurpose.DELIVERY, expiresAt)
        );

        assertFailure(FailureCode.QR_PURPOSE_MISMATCH, () ->
                useCase.execute(PARTICIPANT_QR, CONTAINER_QR, operatorId));
        verify(tokens, never()).save(any());
    }

    @Test
    void activeCirculationMustBelongToTheScannedParticipant() {
        arrangeTokenAndParticipant(false);
        arrangeContainerQr(ContainerStatus.IN_USE);
        Circulation circulation = circulation(new ParticipantId(UUID.randomUUID()), now.minusSeconds(3600));
        when(circulations.findActiveByContainerId(containerId)).thenReturn(Optional.of(circulation));

        assertFailure(FailureCode.CIRCULATION_PARTICIPANT_MISMATCH, () ->
                useCase.execute(PARTICIPANT_QR, CONTAINER_QR, operatorId));
        verify(tokens, never()).save(any());
        verify(circulations, never()).save(any());
    }

    @Test
    void freshQrForReturnedContainerReportsAlreadyRegistered() {
        arrangeTokenAndParticipant(false);
        arrangeContainerQr(ContainerStatus.RETURNED);
        when(circulations.findActiveByContainerId(containerId)).thenReturn(Optional.empty());

        assertFailure(FailureCode.RETURN_ALREADY_REGISTERED, () ->
                useCase.execute(PARTICIPANT_QR, CONTAINER_QR, operatorId));
    }

    @Test
    void consumedParticipantQrReturnsStableReplayConflict() {
        arrangeOperationClaims();
        OperationQrToken consumed = new OperationQrToken(
                tokenId, participantId, OperationQrPurpose.RETURN,
                now.minusSeconds(30), expiresAt, now.minusSeconds(10), UUID.randomUUID(), 1
        );
        when(tokens.findByIdForUpdate(tokenId)).thenReturn(Optional.of(consumed));

        assertFailure(FailureCode.QR_ALREADY_USED, () ->
                useCase.execute(PARTICIPANT_QR, CONTAINER_QR, operatorId));
        verify(circulations, never()).save(any());
        verify(events, never()).save(any());
    }

    private Circulation arrangeValidReturn(boolean preview, Instant deliveredAt) {
        arrangeTokenAndParticipant(preview);
        arrangeContainerQr(ContainerStatus.IN_USE);
        Circulation circulation = circulation(participantId, deliveredAt);
        when(circulations.findActiveByContainerId(containerId)).thenReturn(Optional.of(circulation));
        return circulation;
    }

    private void arrangeTokenAndParticipant(boolean preview) {
        arrangeOperationClaims();
        OperationQrToken token = new OperationQrToken(
                tokenId, participantId, OperationQrPurpose.RETURN,
                now.minusSeconds(30), expiresAt, null, null, 0
        );
        if (preview) {
            when(tokens.findById(tokenId)).thenReturn(Optional.of(token));
        } else {
            when(tokens.findByIdForUpdate(tokenId)).thenReturn(Optional.of(token));
        }
        when(participants.findById(participantId)).thenReturn(
                Optional.of(new Participant(participantId, true, now.minusSeconds(3600)))
        );
    }

    private void arrangeOperationClaims() {
        when(qrCodec.decodeOperation(PARTICIPANT_QR)).thenReturn(
                new QrPayloadCodecPort.OperationClaims(tokenId, OperationQrPurpose.RETURN, expiresAt)
        );
    }

    private void arrangeContainerQr(ContainerStatus status) {
        when(qrCodec.decodeContainer(CONTAINER_QR)).thenReturn(
                new QrPayloadCodecPort.ContainerClaims(containerId, 1)
        );
        when(containers.findById(containerId)).thenReturn(Optional.of(new Container(
                containerId, new ContainerCode("CTR-F6"), status,
                now.minusSeconds(100000), now.minusSeconds(60), 1, 0
        )));
    }

    private Circulation circulation(ParticipantId borrower, Instant deliveredAt) {
        ReturnPolicy policy = new ReturnPolicy(
                UUID.randomUUID(), "Captured 48h", 7, 48, true, deliveredAt.minusSeconds(60)
        );
        return Circulation.create(containerId, borrower, operatorId, deliveredAt, policy);
    }

    private void assertFailure(FailureCode code, Executable executable) {
        ApplicationFailureException failure = assertThrows(ApplicationFailureException.class, executable);
        assertEquals(code, failure.code());
    }
}
