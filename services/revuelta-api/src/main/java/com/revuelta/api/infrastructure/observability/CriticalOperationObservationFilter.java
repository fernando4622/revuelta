package com.revuelta.api.infrastructure.observability;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Optional;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 2)
public class CriticalOperationObservationFilter extends OncePerRequestFilter {

    private final OperationalTelemetry telemetry;

    public CriticalOperationObservationFilter(OperationalTelemetry telemetry) {
        this.telemetry = telemetry;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        Optional<CriticalOperation> operation = CriticalOperationClassifier.classify(
                request.getMethod(), request.getRequestURI()
        );
        if (operation.isEmpty()) {
            filterChain.doFilter(request, response);
            return;
        }

        long started = System.nanoTime();
        try {
            filterChain.doFilter(request, response);
        } finally {
            long durationMillis = (System.nanoTime() - started) / 1_000_000L;
            int status = response.getStatus();
            telemetry.recordOperation(
                    operation.orElseThrow(), status < 400 ? "success" : "failure", status, durationMillis
            );
        }
    }
}
