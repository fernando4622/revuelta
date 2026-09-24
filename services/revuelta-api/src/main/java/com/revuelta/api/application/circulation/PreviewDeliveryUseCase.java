package com.revuelta.api.application.circulation;

import com.revuelta.api.application.port.CorrelationIdProviderPort;

import java.time.Instant;
import java.util.UUID;

public class PreviewDeliveryUseCase {
    private final DeliveryQrValidationService validator;
    private final CorrelationIdProviderPort correlationIds;

    public PreviewDeliveryUseCase(
            DeliveryQrValidationService validator,
            CorrelationIdProviderPort correlationIds
    ) {
        this.validator = validator;
        this.correlationIds = correlationIds;
    }

    public PreviewResult execute(String participantQrPayload, String containerQrPayload) {
        DeliveryQrValidationService.ValidatedDelivery valid =
                validator.validatePreview(participantQrPayload, containerQrPayload);
        Instant estimatedDueAt = valid.policy().calculateDueAt(valid.validatedAt());
        return new PreviewResult(valid, estimatedDueAt, correlationIds.current());
    }

    public record PreviewResult(
            DeliveryQrValidationService.ValidatedDelivery delivery,
            Instant estimatedDueAt,
            UUID traceId
    ) {}
}
