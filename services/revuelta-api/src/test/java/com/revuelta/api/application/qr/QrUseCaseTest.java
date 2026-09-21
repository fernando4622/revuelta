package com.revuelta.api.application.qr;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.OperationQrTokenRepositoryPort;
import com.revuelta.api.application.port.ParticipantRepositoryPort;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.participant.OperationQrPurpose;
import com.revuelta.api.domain.participant.OperationQrToken;
import com.revuelta.api.domain.participant.Participant;
import com.revuelta.api.domain.participant.ParticipantId;
import com.revuelta.api.domain.user.UserId;
import com.revuelta.api.support.ImmediateTransactionRunner;
import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class QrUseCaseTest {
    private final Instant now = Instant.parse("2026-09-21T04:00:00Z");

    @Test
    void shouldGenerateTwoMinuteOperationQrForLinkedParticipant() {
        ParticipantRepositoryPort participants = mock(ParticipantRepositoryPort.class);
        OperationQrTokenRepositoryPort tokens = mock(OperationQrTokenRepositoryPort.class);
        QrPayloadCodecPort codec = mock(QrPayloadCodecPort.class);
        UserId accountId = UserId.generate();
        Participant participant = new Participant(new ParticipantId(UUID.randomUUID()), true, now);
        when(participants.findByAccountId(accountId)).thenReturn(Optional.of(participant));
        when(tokens.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        when(codec.encodeOperation(any(), any(), any())).thenReturn("signed-payload");

        var useCase = new GenerateOperationQrUseCase(
                participants, tokens, codec, new ImmediateTransactionRunner(),
                () -> now, Duration.ofMinutes(2)
        );

        var result = useCase.execute(accountId, OperationQrPurpose.DELIVERY);

        assertEquals(OperationQrPurpose.DELIVERY, result.purpose());
        assertEquals(now, result.issuedAt());
        assertEquals(now.plusSeconds(120), result.expiresAt());
        assertEquals("signed-payload", result.payload());
    }

    @Test
    void shouldRejectGenerationWithoutParticipantAssociation() {
        ParticipantRepositoryPort participants = mock(ParticipantRepositoryPort.class);
        when(participants.findByAccountId(any())).thenReturn(Optional.empty());
        var useCase = new GenerateOperationQrUseCase(
                participants, mock(OperationQrTokenRepositoryPort.class), mock(QrPayloadCodecPort.class),
                new ImmediateTransactionRunner(), () -> now, Duration.ofMinutes(2)
        );

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> useCase.execute(UserId.generate(), OperationQrPurpose.RETURN)
        );
        assertEquals(FailureCode.PARTICIPANT_ACCOUNT_NOT_LINKED, failure.code());
    }

    @Test
    void shouldRejectExpiredOperationQrWithoutReturningParticipant() {
        ParticipantId participantId = new ParticipantId(UUID.randomUUID());
        OperationQrToken token = OperationQrToken.issue(
                participantId, OperationQrPurpose.RETURN, now.minusSeconds(180), now.minusSeconds(60)
        );
        OperationQrTokenRepositoryPort tokens = mock(OperationQrTokenRepositoryPort.class);
        ParticipantRepositoryPort participants = mock(ParticipantRepositoryPort.class);
        QrPayloadCodecPort codec = mock(QrPayloadCodecPort.class);
        when(codec.decodeOperation("payload")).thenReturn(new QrPayloadCodecPort.OperationClaims(
                token.id(), token.purpose(), token.expiresAt()
        ));
        when(tokens.findById(token.id())).thenReturn(Optional.of(token));

        var useCase = new ResolveOperationQrUseCase(tokens, participants, codec, () -> now);
        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class, () -> useCase.execute("payload")
        );
        assertEquals(FailureCode.QR_EXPIRED, failure.code());
    }

    @Test
    void shouldReturnServerDerivedOperatorActionForAvailableContainer() {
        ContainerId id = ContainerId.generate();
        Container container = new Container(
                id, new ContainerCode("CTR-QR"), ContainerStatus.AVAILABLE,
                now, now, 2, 0
        );
        ContainerRepositoryPort containers = mock(ContainerRepositoryPort.class);
        CirculationRepositoryPort circulations = mock(CirculationRepositoryPort.class);
        QrPayloadCodecPort codec = mock(QrPayloadCodecPort.class);
        when(codec.decodeContainer("payload"))
                .thenReturn(new QrPayloadCodecPort.ContainerClaims(id, 2));
        when(containers.findById(id)).thenReturn(Optional.of(container));
        when(circulations.findActiveByContainerId(id)).thenReturn(Optional.empty());

        var result = new ResolveContainerQrUseCase(containers, circulations, codec)
                .execute("payload", "OPERATOR");

        assertEquals("AVAILABLE", result.state());
        assertEquals(java.util.List.of("DELIVER"), result.allowedActions());
    }

    @Test
    void shouldRejectRevokedContainerGeneration() {
        ContainerId id = ContainerId.generate();
        Container container = new Container(
                id, new ContainerCode("CTR-OLD"), ContainerStatus.AVAILABLE,
                now, now, 3, 0
        );
        ContainerRepositoryPort containers = mock(ContainerRepositoryPort.class);
        QrPayloadCodecPort codec = mock(QrPayloadCodecPort.class);
        when(codec.decodeContainer("old-payload"))
                .thenReturn(new QrPayloadCodecPort.ContainerClaims(id, 2));
        when(containers.findById(id)).thenReturn(Optional.of(container));

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> new ResolveContainerQrUseCase(
                        containers, mock(CirculationRepositoryPort.class), codec
                ).execute("old-payload", "OPERATOR")
        );
        assertEquals(FailureCode.CONTAINER_QR_REVOKED, failure.code());
    }
}
