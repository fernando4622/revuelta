package com.revuelta.api.application.qr;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.OperationQrTokenRepositoryPort;
import com.revuelta.api.application.port.ParticipantRepositoryPort;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.application.port.ServerClockPort;
import com.revuelta.api.application.port.TransactionRunnerPort;
import com.revuelta.api.domain.participant.OperationQrPurpose;
import com.revuelta.api.domain.participant.OperationQrToken;
import com.revuelta.api.domain.participant.Participant;
import com.revuelta.api.domain.user.UserId;

import java.time.Duration;

public class GenerateOperationQrUseCase {
    private final ParticipantRepositoryPort participants;
    private final OperationQrTokenRepositoryPort tokens;
    private final QrPayloadCodecPort qrCodec;
    private final TransactionRunnerPort transactions;
    private final ServerClockPort clock;
    private final Duration ttl;

    public GenerateOperationQrUseCase(
            ParticipantRepositoryPort participants,
            OperationQrTokenRepositoryPort tokens,
            QrPayloadCodecPort qrCodec,
            TransactionRunnerPort transactions,
            ServerClockPort clock,
            Duration ttl
    ) {
        this.participants = participants;
        this.tokens = tokens;
        this.qrCodec = qrCodec;
        this.transactions = transactions;
        this.clock = clock;
        if (ttl == null || ttl.isZero() || ttl.isNegative()) {
            throw new IllegalArgumentException("Operation QR TTL must be positive");
        }
        this.ttl = ttl;
    }

    public Result execute(UserId accountId, OperationQrPurpose purpose) {
        return transactions.required(() -> generate(accountId, purpose));
    }

    private Result generate(UserId accountId, OperationQrPurpose purpose) {
        Participant participant = participants.findByAccountId(accountId)
                .orElseThrow(() -> new ApplicationFailureException(
                        FailureCode.PARTICIPANT_ACCOUNT_NOT_LINKED,
                        "The authenticated account is not linked to a participant"
                ));
        if (!participant.active()) {
            throw new ApplicationFailureException(
                    FailureCode.PARTICIPANT_INACTIVE, "Participant is inactive"
            );
        }

        var now = clock.now().truncatedTo(java.time.temporal.ChronoUnit.SECONDS);
        OperationQrToken token = tokens.save(OperationQrToken.issue(
                participant.id(), purpose, now, now.plus(ttl)
        ));
        return new Result(
                token.id(), token.purpose(),
                qrCodec.encodeOperation(token.id(), token.purpose(), token.expiresAt()),
                token.issuedAt(), token.expiresAt()
        );
    }

    public record Result(
            java.util.UUID tokenRef,
            OperationQrPurpose purpose,
            String payload,
            java.time.Instant issuedAt,
            java.time.Instant expiresAt
    ) {}
}
