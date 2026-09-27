package com.revuelta.api.infrastructure.observability;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class OperationalTelemetry {

    private final MeterRegistry registry;

    public void recordOperation(
            CriticalOperation operation,
            String outcome,
            int httpStatus,
            long durationMillis
    ) {
        Counter.builder("revuelta.mutations")
                .description("Critical ReVuelta operations by bounded operation and outcome")
                .tag("operation", operation.metricName())
                .tag("outcome", outcome)
                .tag("status", Integer.toString(httpStatus))
                .register(registry)
                .increment();

        log.atInfo()
                .addKeyValue("service", "revuelta-api")
                .addKeyValue("operation", operation.metricName())
                .addKeyValue("outcome", outcome)
                .addKeyValue("httpStatus", httpStatus)
                .addKeyValue("durationMs", durationMillis)
                .log("critical_operation");
    }

    public void recordFailureCode(Optional<CriticalOperation> operation, String errorCode) {
        operation.ifPresent(value -> Counter.builder("revuelta.mutation.failures")
                .description("Critical mutation failures by stable code")
                .tag("operation", value.metricName())
                .tag("errorCode", errorCode)
                .register(registry)
                .increment());

        if ("INVALID_CREDENTIALS".equals(errorCode) || "UNAUTHENTICATED".equals(errorCode)) {
            Counter.builder("revuelta.authentication.failures")
                    .description("Authentication failures by stable public reason")
                    .tag("reason", errorCode)
                    .register(registry)
                    .increment();
        }
    }

    public void recordLateReturn() {
        Counter.builder("revuelta.returns.late")
                .description("Successful returns classified as late by server time")
                .register(registry)
                .increment();
    }
}
