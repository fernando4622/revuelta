package com.revuelta.api.infrastructure.observability;

public enum CriticalOperation {
    LOGIN("auth.login"),
    REGISTER_CONTAINER("container.register"),
    ACTIVATE_CONTAINER("container.activate"),
    ROTATE_CONTAINER_QR("container.qr.rotate"),
    GENERATE_OPERATION_QR("participant.qr.generate"),
    DELIVER_CONTAINER("circulation.deliver"),
    RETURN_CONTAINER("circulation.return"),
    COMPLETE_WASH("container.wash.complete");

    private final String metricName;

    CriticalOperation(String metricName) {
        this.metricName = metricName;
    }

    public String metricName() {
        return metricName;
    }
}
