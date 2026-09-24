package com.revuelta.api.application.circulation;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.OperationQrTokenRepositoryPort;
import com.revuelta.api.application.port.ParticipantRepositoryPort;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.application.port.ServerClockPort;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.participant.OperationQrPurpose;
import com.revuelta.api.domain.participant.OperationQrToken;
import com.revuelta.api.domain.participant.Participant;

import java.time.Instant;

public class ReturnQrValidationService {
    private final OperationQrTokenRepositoryPort tokens;
    private final ParticipantRepositoryPort participants;
    private final ContainerRepositoryPort containers;
    private final CirculationRepositoryPort circulations;
    private final QrPayloadCodecPort qrCodec;
    private final ServerClockPort clock;

    public ReturnQrValidationService(
            OperationQrTokenRepositoryPort tokens,
            ParticipantRepositoryPort participants,
            ContainerRepositoryPort containers,
            CirculationRepositoryPort circulations,
            QrPayloadCodecPort qrCodec,
            ServerClockPort clock
    ) {
        this.tokens = tokens;
        this.participants = participants;
        this.containers = containers;
        this.circulations = circulations;
        this.qrCodec = qrCodec;
        this.clock = clock;
    }

    public ValidatedReturn validatePreview(String participantPayload, String containerPayload) {
        return validate(participantPayload, containerPayload, false);
    }

    public ValidatedReturn validateForCommit(String participantPayload, String containerPayload) {
        return validate(participantPayload, containerPayload, true);
    }

    private ValidatedReturn validate(String participantPayload, String containerPayload, boolean lockToken) {
        Instant now = clock.now();
        QrPayloadCodecPort.OperationClaims operationClaims = qrCodec.decodeOperation(participantPayload);
        if (operationClaims.purpose() != OperationQrPurpose.RETURN) {
            throw failure(FailureCode.QR_PURPOSE_MISMATCH, "A RETURN participant QR is required");
        }

        OperationQrToken token = (lockToken
                ? tokens.findByIdForUpdate(operationClaims.tokenId())
                : tokens.findById(operationClaims.tokenId()))
                .orElseThrow(() -> failure(
                        FailureCode.PARTICIPANT_NOT_FOUND,
                        "Participant operation QR is unknown"
                ));
        if (token.purpose() != operationClaims.purpose()
                || !token.expiresAt().equals(operationClaims.expiresAt())) {
            throw failure(FailureCode.QR_TAMPERED, "QR claims do not match the issued token");
        }
        if (token.isConsumed()) {
            throw failure(FailureCode.QR_ALREADY_USED, "Participant operation QR was already used");
        }
        if (token.isExpiredAt(now)) {
            throw failure(FailureCode.QR_EXPIRED, "Participant operation QR has expired");
        }

        Participant participant = participants.findById(token.participantId())
                .orElseThrow(() -> failure(FailureCode.PARTICIPANT_NOT_FOUND, "Participant was not found"));
        if (!participant.active()) {
            throw failure(FailureCode.PARTICIPANT_INACTIVE, "Participant is inactive");
        }

        QrPayloadCodecPort.ContainerClaims containerClaims = qrCodec.decodeContainer(containerPayload);
        Container container = containers.findById(containerClaims.containerId())
                .orElseThrow(() -> failure(FailureCode.CONTAINER_NOT_FOUND, "Container was not found"));
        if (containerClaims.generation() != container.qrGeneration()) {
            throw failure(FailureCode.CONTAINER_QR_REVOKED, "Container QR was replaced");
        }
        if (container.status() == ContainerStatus.RETIRED) {
            throw failure(FailureCode.INACTIVE_CONTAINER, "Container is retired");
        }

        Circulation circulation = circulations.findActiveByContainerId(container.id())
                .orElseThrow(() -> container.status() == ContainerStatus.RETURNED
                        ? failure(FailureCode.RETURN_ALREADY_REGISTERED, "Container return was already registered")
                        : failure(FailureCode.CIRCULATION_NOT_FOUND, "Container has no active circulation"));
        if (!circulation.borrowerId().equals(participant.id())) {
            throw failure(
                    FailureCode.CIRCULATION_PARTICIPANT_MISMATCH,
                    "The scanned participant does not hold this container"
            );
        }
        if (container.status() != ContainerStatus.IN_USE) {
            throw failure(FailureCode.INVALID_STATE_TRANSITION, "Container is not in use");
        }

        return new ValidatedReturn(token, participant, container, circulation, now);
    }

    private ApplicationFailureException failure(FailureCode code, String message) {
        return new ApplicationFailureException(code, message);
    }

    public record ValidatedReturn(
            OperationQrToken token,
            Participant participant,
            Container container,
            Circulation circulation,
            Instant validatedAt
    ) {}
}
