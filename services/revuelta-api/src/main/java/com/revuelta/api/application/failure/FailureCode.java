package com.revuelta.api.application.failure;

public enum FailureCode {
    INVALID_QR(FailureCategory.VALIDATION),
    UNSUPPORTED_QR_VERSION(FailureCategory.VALIDATION),
    QR_TAMPERED(FailureCategory.VALIDATION),
    QR_EXPIRED(FailureCategory.CONFLICT),
    QR_ALREADY_USED(FailureCategory.CONFLICT),
    QR_PURPOSE_MISMATCH(FailureCategory.CONFLICT),
    CONTAINER_QR_REVOKED(FailureCategory.CONFLICT),
    INACTIVE_CONTAINER(FailureCategory.CONFLICT),
    PARTICIPANT_ACCOUNT_NOT_LINKED(FailureCategory.CONFLICT),
    PARTICIPANT_INACTIVE(FailureCategory.CONFLICT),
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
