package com.revuelta.api.infrastructure.observability;

import java.util.Optional;

public final class CriticalOperationClassifier {

    private CriticalOperationClassifier() {}

    public static Optional<CriticalOperation> classify(String method, String uri) {
        if (!"POST".equals(method)) {
            return Optional.empty();
        }
        if ("/api/v1/auth/login".equals(uri)) return Optional.of(CriticalOperation.LOGIN);
        if ("/api/v1/containers".equals(uri)) return Optional.of(CriticalOperation.REGISTER_CONTAINER);
        if ("/api/v1/me/operation-qrs".equals(uri)) return Optional.of(CriticalOperation.GENERATE_OPERATION_QR);
        if ("/api/v1/circulations".equals(uri)) return Optional.of(CriticalOperation.DELIVER_CONTAINER);
        if ("/api/v1/circulation-returns".equals(uri)) return Optional.of(CriticalOperation.RETURN_CONTAINER);
        if (uri.matches("/api/v1/containers/[^/]+/activate")) {
            return Optional.of(CriticalOperation.ACTIVATE_CONTAINER);
        }
        if (uri.matches("/api/v1/containers/[^/]+/qr-rotations")) {
            return Optional.of(CriticalOperation.ROTATE_CONTAINER_QR);
        }
        if (uri.matches("/api/v1/containers/[^/]+/wash-completions")) {
            return Optional.of(CriticalOperation.COMPLETE_WASH);
        }
        return Optional.empty();
    }
}
