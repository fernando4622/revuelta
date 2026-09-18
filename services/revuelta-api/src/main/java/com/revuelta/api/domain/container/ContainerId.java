package com.revuelta.api.domain.container;

import java.util.Objects;
import java.util.UUID;

public record ContainerId(UUID value) {
    public ContainerId {
        Objects.requireNonNull(value, "ContainerId value must not be null");
    }

    public static ContainerId generate() {
        return new ContainerId(UUID.randomUUID());
    }
}
