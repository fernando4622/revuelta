package com.revuelta.api.domain.participant;

import java.time.Instant;
import java.util.Objects;

public record Participant(ParticipantId id, boolean active, Instant createdAt) {
    public Participant {
        Objects.requireNonNull(id, "Participant id must not be null");
        Objects.requireNonNull(createdAt, "Participant createdAt must not be null");
    }
}
