package com.revuelta.api.infrastructure.observability;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import io.micrometer.core.instrument.simple.SimpleMeterRegistry;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class OperationalTelemetryTest {

    @Test
    void shouldRecordBoundedOperationFailureAuthenticationAndLateReturnMetrics() {
        SimpleMeterRegistry registry = new SimpleMeterRegistry();
        OperationalTelemetry telemetry = new OperationalTelemetry(registry);

        telemetry.recordOperation(CriticalOperation.DELIVER_CONTAINER, "failure", 409, 12);
        telemetry.recordFailureCode(
                Optional.of(CriticalOperation.DELIVER_CONTAINER), "ACTIVE_CIRCULATION_EXISTS"
        );
        telemetry.recordFailureCode(Optional.of(CriticalOperation.LOGIN), "INVALID_CREDENTIALS");
        telemetry.recordLateReturn();

        assertEquals(1.0, registry.get("revuelta.mutations")
                .tag("operation", "circulation.deliver").tag("outcome", "failure")
                .tag("status", "409")
                .counter().count());
        assertEquals(1.0, registry.get("revuelta.mutation.failures")
                .tag("errorCode", "ACTIVE_CIRCULATION_EXISTS").counter().count());
        assertEquals(1.0, registry.get("revuelta.authentication.failures")
                .tag("reason", "INVALID_CREDENTIALS").counter().count());
        assertEquals(1.0, registry.get("revuelta.returns.late").counter().count());
        assertTrue(registry.getMeters().stream().noneMatch(meter -> meter.getId().getTags().stream()
                .anyMatch(tag -> tag.getKey().contains("container") || tag.getKey().contains("actor"))));
    }

    @Test
    void shouldClassifyOnlyKnownCriticalMutationRoutes() {
        assertEquals(
                CriticalOperation.COMPLETE_WASH,
                CriticalOperationClassifier.classify(
                        "POST", "/api/v1/containers/abc/wash-completions"
                ).orElseThrow()
        );
        assertTrue(CriticalOperationClassifier.classify(
                "GET", "/api/v1/containers/abc"
        ).isEmpty());
    }
}
