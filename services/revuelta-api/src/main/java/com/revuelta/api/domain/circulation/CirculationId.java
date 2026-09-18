package com.revuelta.api.domain.circulation;

import java.util.Objects;
import java.util.UUID;

public record CirculationId(UUID value) {
    public CirculationId {
        Objects.requireNonNull(value, "CirculationId value must not be null");
    }

    public static CirculationId generate() {
        return new CirculationId(UUID.randomUUID());
    }
}
