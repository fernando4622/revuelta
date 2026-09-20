package com.revuelta.api.infrastructure.web;

import com.revuelta.api.application.port.CorrelationIdProviderPort;
import java.util.UUID;
import org.slf4j.MDC;
import org.springframework.stereotype.Component;

@Component
public class MdcCorrelationIdProviderAdapter implements CorrelationIdProviderPort {

    @Override
    public UUID current() {
        String value = MDC.get(CorrelationId.MDC_KEY);
        if (value == null) {
            return UUID.randomUUID();
        }
        try {
            return UUID.fromString(value);
        } catch (IllegalArgumentException ignored) {
            return UUID.randomUUID();
        }
    }
}
