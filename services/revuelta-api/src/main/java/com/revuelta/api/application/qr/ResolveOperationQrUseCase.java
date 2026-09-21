package com.revuelta.api.application.qr;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.OperationQrTokenRepositoryPort;
import com.revuelta.api.application.port.ParticipantRepositoryPort;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.application.port.ServerClockPort;
import com.revuelta.api.domain.participant.OperationQrPurpose;
import com.revuelta.api.domain.participant.OperationQrToken;
import com.revuelta.api.domain.participant.Participant;
import com.revuelta.api.domain.participant.ParticipantId;

import java.time.Instant;
import java.util.UUID;

public class ResolveOperationQrUseCase {
    private final OperationQrTokenRepositoryPort tokens;
    private final ParticipantRepositoryPort participants;
    private final QrPayloadCodecPort qrCodec;
    private final ServerClockPort clock;

    public ResolveOperationQrUseCase(
            OperationQrTokenRepositoryPort tokens,
            ParticipantRepositoryPort participants,
            QrPayloadCodecPort qrCodec,
            ServerClockPort clock
    ) {
        this.tokens = tokens;
        this.participants = participants;
        this.qrCodec = qrCodec;
        this.clock = clock;
    }

    public Result execute(String payload) {
        QrPayloadCodecPort.OperationClaims claims = qrCodec.decodeOperation(payload);
        OperationQrToken token = tokens.findById(claims.tokenId())
                .orElseThrow(() -> new ApplicationFailureException(
                        FailureCode.PARTICIPANT_NOT_FOUND, "Participant operation QR is unknown"
                ));
        if (token.purpose() != claims.purpose() || !token.expiresAt().equals(claims.expiresAt())) {
            throw new ApplicationFailureException(
                    FailureCode.QR_TAMPERED, "QR claims do not match the issued token"
            );
        }
        if (token.isConsumed()) {
            throw new ApplicationFailureException(
                    FailureCode.QR_ALREADY_USED, "Participant operation QR was already used"
            );
        }
        if (token.isExpiredAt(clock.now())) {
            throw new ApplicationFailureException(
                    FailureCode.QR_EXPIRED, "Participant operation QR has expired"
            );
        }
        Participant participant = participants.findById(token.participantId())
                .orElseThrow(() -> new ApplicationFailureException(
                        FailureCode.PARTICIPANT_NOT_FOUND, "Participant was not found"
                ));
        if (!participant.active()) {
            throw new ApplicationFailureException(
                    FailureCode.PARTICIPANT_INACTIVE, "Participant is inactive"
            );
        }
        return new Result(
                token.id(), participant.id(), token.purpose(), token.expiresAt(), "ELIGIBLE"
        );
    }

    public record Result(
            UUID tokenRef,
            ParticipantId participantRef,
            OperationQrPurpose purpose,
            Instant expiresAt,
            String eligibility
    ) {}
}
