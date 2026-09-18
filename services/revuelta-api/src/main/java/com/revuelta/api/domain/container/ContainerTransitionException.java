package com.revuelta.api.domain.container;

public class ContainerTransitionException extends RuntimeException {
    private final ContainerStatus currentStatus;
    private final ContainerStatus targetStatus;

    public ContainerTransitionException(String message, ContainerStatus currentStatus, ContainerStatus targetStatus) {
        super(message);
        this.currentStatus = currentStatus;
        this.targetStatus = targetStatus;
    }

    public ContainerStatus getCurrentStatus() {
        return currentStatus;
    }

    public ContainerStatus getTargetStatus() {
        return targetStatus;
    }
}
