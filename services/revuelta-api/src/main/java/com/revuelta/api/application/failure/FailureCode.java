package com.revuelta.api.application.failure;

public enum FailureCode {
    CONTAINER_NOT_FOUND(FailureCategory.NOT_FOUND),
    CONTAINER_NOT_AVAILABLE(FailureCategory.CONFLICT),
    CONTAINER_CODE_ALREADY_EXISTS(FailureCategory.CONFLICT),
    INVALID_STATE_TRANSITION(FailureCategory.CONFLICT),
    ACTIVE_CIRCULATION_EXISTS(FailureCategory.CONFLICT),
    CIRCULATION_NOT_FOUND(FailureCategory.NOT_FOUND),
    RETURN_ALREADY_REGISTERED(FailureCategory.CONFLICT),
    POLICY_NOT_FOUND(FailureCategory.CONFLICT),
    PARTICIPANT_NOT_FOUND(FailureCategory.NOT_FOUND);

    private final FailureCategory category;

    FailureCode(FailureCategory category) {
        this.category = category;
    }

    public FailureCategory category() {
        return category;
    }
}
