package com.revuelta.api.domain.container;

import java.util.Objects;

public record ContainerCode(String value) {
    public ContainerCode {
        Objects.requireNonNull(value, "ContainerCode value must not be null");
        if (value.trim().isEmpty()) {
            throw new IllegalArgumentException("ContainerCode value must not be empty");
        }
    }
}
