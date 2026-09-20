package com.revuelta.api.infrastructure.web;

import jakarta.servlet.http.HttpServletRequest;
import java.util.UUID;

final class CorrelationId {

    static final String HEADER_NAME = "X-Correlation-ID";
    static final String MDC_KEY = "correlationId";
    private static final String REQUEST_ATTRIBUTE = CorrelationId.class.getName();

    private CorrelationId() {}

    static String resolve(HttpServletRequest request) {
        Object existing = request.getAttribute(REQUEST_ATTRIBUTE);
        if (existing instanceof String value && !value.isBlank()) {
            return value;
        }

        String generated = UUID.randomUUID().toString();
        request.setAttribute(REQUEST_ATTRIBUTE, generated);
        return generated;
    }
}
