package com.revuelta.api.application.failure;

import java.util.Objects;

public class ApplicationFailureException extends RuntimeException {

    private final FailureCode code;

    public ApplicationFailureException(FailureCode code, String detail) {
        super(detail);
        this.code = Objects.requireNonNull(code, "code must not be null");
    }

    public FailureCode code() {
        return code;
    }
}
