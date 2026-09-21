-- F4 dual-QR foundation: versioned container labels and short-lived
-- participant operation tokens. No participant or credential seed belongs here.

ALTER TABLE containers
    ADD COLUMN qr_generation INTEGER NOT NULL DEFAULT 1,
    ADD CONSTRAINT containers_qr_generation_positive CHECK (qr_generation > 0);

CREATE TABLE participants (
    id UUID PRIMARY KEY,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE participant_accounts (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE RESTRICT,
    participant_id UUID NOT NULL UNIQUE REFERENCES participants(id) ON DELETE RESTRICT
);

CREATE TABLE operation_qr_tokens (
    id UUID PRIMARY KEY,
    participant_id UUID NOT NULL REFERENCES participants(id) ON DELETE RESTRICT,
    purpose VARCHAR(20) NOT NULL CHECK (purpose IN ('DELIVERY', 'RETURN')),
    issued_at TIMESTAMP WITH TIME ZONE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    consumed_at TIMESTAMP WITH TIME ZONE,
    circulation_id UUID REFERENCES circulations(id) ON DELETE RESTRICT,
    lock_version BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT operation_qr_expiration_after_issuance CHECK (expires_at > issued_at),
    CONSTRAINT operation_qr_consumption_consistent CHECK (
        (consumed_at IS NULL AND circulation_id IS NULL)
        OR (consumed_at IS NOT NULL AND circulation_id IS NOT NULL)
    )
);

CREATE INDEX idx_operation_qr_tokens_participant
    ON operation_qr_tokens(participant_id, expires_at DESC);
