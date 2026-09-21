package com.revuelta.api.domain.participant;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

public class OperationQrToken {
    private final UUID id;
    private final ParticipantId participantId;
    private final OperationQrPurpose purpose;
    private final Instant issuedAt;
    private final Instant expiresAt;
    private Instant consumedAt;
    private UUID circulationId;
    private final long version;

    public OperationQrToken(
            UUID id,
            ParticipantId participantId,
            OperationQrPurpose purpose,
            Instant issuedAt,
            Instant expiresAt,
            Instant consumedAt,
            UUID circulationId,
            long version
    ) {
        this.id = Objects.requireNonNull(id, "Token id must not be null");
        this.participantId = Objects.requireNonNull(participantId, "Participant id must not be null");
        this.purpose = Objects.requireNonNull(purpose, "Purpose must not be null");
        this.issuedAt = Objects.requireNonNull(issuedAt, "IssuedAt must not be null");
        this.expiresAt = Objects.requireNonNull(expiresAt, "ExpiresAt must not be null");
        if (!expiresAt.isAfter(issuedAt)) {
            throw new IllegalArgumentException("Operation QR expiration must be after issuance");
        }
        if ((consumedAt == null) != (circulationId == null)) {
            throw new IllegalArgumentException("Consumed token requires both consumedAt and circulationId");
        }
        this.consumedAt = consumedAt;
        this.circulationId = circulationId;
        this.version = version;
    }

    public static OperationQrToken issue(
            ParticipantId participantId,
            OperationQrPurpose purpose,
            Instant issuedAt,
            Instant expiresAt
    ) {
        return new OperationQrToken(
                UUID.randomUUID(), participantId, purpose, issuedAt, expiresAt, null, null, 0
        );
    }

    public boolean isExpiredAt(Instant now) {
        return !now.isBefore(expiresAt);
    }

    public boolean isConsumed() {
        return consumedAt != null;
    }

    public UUID id() { return id; }
    public ParticipantId participantId() { return participantId; }
    public OperationQrPurpose purpose() { return purpose; }
    public Instant issuedAt() { return issuedAt; }
    public Instant expiresAt() { return expiresAt; }
    public Instant consumedAt() { return consumedAt; }
    public UUID circulationId() { return circulationId; }
    public long version() { return version; }
}
