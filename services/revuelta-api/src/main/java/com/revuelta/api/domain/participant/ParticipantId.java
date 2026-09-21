package com.revuelta.api.domain.participant;

import java.util.Objects;
import java.util.UUID;

public record ParticipantId(UUID value) {
    public ParticipantId {
        Objects.requireNonNull(value, "Participant id must not be null");
    }
}
