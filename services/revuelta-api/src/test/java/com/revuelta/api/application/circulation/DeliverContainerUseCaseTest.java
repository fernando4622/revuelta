package com.revuelta.api.application.circulation;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.OperationQrTokenRepositoryPort;
import com.revuelta.api.application.port.ParticipantRepositoryPort;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.application.port.ReturnPolicyRepositoryPort;
import com.revuelta.api.domain.circulation.Circulation;
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
class DeliverContainerUseCaseTest {
    private static final String PARTICIPANT_QR = "signed-participant-payload";
    private static final String CONTAINER_QR = "signed-container-payload";

    @Mock private ContainerRepositoryPort containers;
    @Mock private CirculationRepositoryPort circulations;
    @Mock private ParticipantRepositoryPort participants;
    @Mock private OperationQrTokenRepositoryPort tokens;
    @Mock private ReturnPolicyRepositoryPort policies;
    @Mock private QrPayloadCodecPort qrCodec;
    @Mock private ContainerEventRepositoryPort events;

    private DeliverContainerUseCase useCase;
    private PreviewDeliveryUseCase previewUseCase;
    private final ContainerId containerId = ContainerId.generate();
    private final ParticipantId participantId = new ParticipantId(UUID.randomUUID());
    private final UserId operatorId = UserId.generate();
    private final UUID tokenId = UUID.randomUUID();
    private final UUID traceId = UUID.randomUUID();
    private final Instant now = Instant.parse("2026-09-23T18:00:00Z");
    private final Instant expiresAt = now.plusSeconds(120);
    private final ReturnPolicy policy = new ReturnPolicy(
            UUID.randomUUID(), "Pilot 48h", 3, 48, true, now.minusSeconds(60)
    );

    @BeforeEach
    void setUp() {
        DeliveryQrValidationService validator = new DeliveryQrValidationService(
                tokens, participants, containers, circulations, policies, qrCodec, () -> now
        );
        useCase = new DeliverContainerUseCase(
                validator, containers, circulations, tokens, events,
                new ImmediateTransactionRunner(), () -> traceId
        );
        previewUseCase = new PreviewDeliveryUseCase(validator, () -> traceId);
    }

    @Test
    void successfulDeliveryUsesBothQrValuesAndCommitsAllFourMutations() {
        arrangeValidDelivery(false);

        var result = useCase.execute(PARTICIPANT_QR, CONTAINER_QR, operatorId);

        assertEquals(ContainerStatus.IN_USE, result.container().status());
        assertEquals(participantId, result.circulation().borrowerId());
        assertEquals(now, result.circulation().deliveredAt());
        assertEquals(now.plusSeconds(48 * 60 * 60), result.circulation().dueAt());
        assertEquals(policy.id(), result.circulation().returnPolicyId());
        assertEquals(3, result.circulation().returnPolicyVersion());
        assertEquals(traceId, result.traceId());

        verify(qrCodec).decodeOperation(PARTICIPANT_QR);
        verify(qrCodec).decodeContainer(CONTAINER_QR);
        verify(circulations).save(result.circulation());
        verify(containers).save(result.container());

        ArgumentCaptor<ContainerEvent> event = ArgumentCaptor.forClass(ContainerEvent.class);
        verify(events).save(event.capture());
        assertEquals(participantId, event.getValue().participantId());
        assertEquals(result.circulation().id().value(), event.getValue().circulationId());
        assertEquals(traceId, event.getValue().correlationId());

        ArgumentCaptor<OperationQrToken> consumed = ArgumentCaptor.forClass(OperationQrToken.class);
        verify(tokens).save(consumed.capture());
        assertEquals(now, consumed.getValue().consumedAt());
        assertEquals(result.circulation().id().value(), consumed.getValue().circulationId());
    }

    @Test
    void previewIsReadOnlyAndUsesServerTimeForEstimatedDueAt() {
        arrangeValidDelivery(true);

        var preview = previewUseCase.execute(PARTICIPANT_QR, CONTAINER_QR);

        assertEquals(now.plusSeconds(48 * 60 * 60), preview.estimatedDueAt());
        assertEquals(participantId, preview.delivery().participant().id());
        verify(tokens, never()).save(any());
        verify(circulations, never()).save(any());
        verify(containers, never()).save(any());
        verify(events, never()).save(any());
    }

    @Test
    void returnQrCannotBeUsedForDeliveryAndRemainsUnconsumed() {
        when(qrCodec.decodeOperation(PARTICIPANT_QR)).thenReturn(
                new QrPayloadCodecPort.OperationClaims(tokenId, OperationQrPurpose.RETURN, expiresAt)
        );

        assertFailure(FailureCode.QR_PURPOSE_MISMATCH, () ->
                useCase.execute(PARTICIPANT_QR, CONTAINER_QR, operatorId));

        verify(tokens, never()).findByIdForUpdate(any());
        verify(tokens, never()).save(any());
    }

    @Test
    void consumedParticipantQrReturnsStableReplayConflict() {
        Circulation prior = Circulation.create(containerId, participantId, operatorId, now.minusSeconds(60), policy);
        OperationQrToken consumed = new OperationQrToken(
                tokenId, participantId, OperationQrPurpose.DELIVERY,
                now.minusSeconds(30), expiresAt, now.minusSeconds(10), prior.id().value(), 1
        );
        arrangeOperationClaims();
        when(tokens.findByIdForUpdate(tokenId)).thenReturn(Optional.of(consumed));

        assertFailure(FailureCode.QR_ALREADY_USED, () ->
                useCase.execute(PARTICIPANT_QR, CONTAINER_QR, operatorId));

        verify(circulations, never()).save(any());
        verify(events, never()).save(any());
    }

    @Test
    void revokedContainerQrFailsWithoutConsumingParticipantQr() {
        arrangeOperationAndParticipant(false);
        when(qrCodec.decodeContainer(CONTAINER_QR)).thenReturn(
                new QrPayloadCodecPort.ContainerClaims(containerId, 1)
        );
        when(containers.findById(containerId)).thenReturn(Optional.of(container(2, ContainerStatus.AVAILABLE)));

        assertFailure(FailureCode.CONTAINER_QR_REVOKED, () ->
                useCase.execute(PARTICIPANT_QR, CONTAINER_QR, operatorId));

        verify(tokens, never()).save(any());
        verify(circulations, never()).save(any());
    }

    @Test
    void missingPolicyFailsBeforeAnyMutation() {
        arrangeOperationAndParticipant(false);
        arrangeContainer(ContainerStatus.AVAILABLE);
        when(policies.findActivePolicy()).thenReturn(Optional.empty());

        assertFailure(FailureCode.POLICY_NOT_FOUND, () ->
                useCase.execute(PARTICIPANT_QR, CONTAINER_QR, operatorId));

        verify(tokens, never()).save(any());
        verify(circulations, never()).save(any());
        verify(containers, never()).save(any());
    }

    private void arrangeValidDelivery(boolean preview) {
        arrangeOperationAndParticipant(preview);
        arrangeContainer(ContainerStatus.AVAILABLE);
        when(policies.findActivePolicy()).thenReturn(Optional.of(policy));
    }

    private void arrangeOperationAndParticipant(boolean preview) {
        arrangeOperationClaims();
        OperationQrToken token = new OperationQrToken(
                tokenId, participantId, OperationQrPurpose.DELIVERY,
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
                new QrPayloadCodecPort.OperationClaims(tokenId, OperationQrPurpose.DELIVERY, expiresAt)
        );
    }

    private void arrangeContainer(ContainerStatus status) {
        when(qrCodec.decodeContainer(CONTAINER_QR)).thenReturn(
                new QrPayloadCodecPort.ContainerClaims(containerId, 1)
        );
        when(containers.findById(containerId)).thenReturn(Optional.of(container(1, status)));
        when(circulations.hasActiveCirculation(containerId)).thenReturn(false);
    }

    private Container container(int generation, ContainerStatus status) {
        return new Container(
                containerId, new ContainerCode("CTR-F5"), status,
                now.minusSeconds(3600), now.minusSeconds(60), generation, 0
        );
    }

    private void assertFailure(FailureCode code, Executable executable) {
        ApplicationFailureException failure = assertThrows(ApplicationFailureException.class, executable);
        assertEquals(code, failure.code());
    }
}
