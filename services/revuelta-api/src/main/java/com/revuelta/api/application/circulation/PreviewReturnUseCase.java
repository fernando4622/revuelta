package com.revuelta.api.application.circulation;

import com.revuelta.api.application.port.CorrelationIdProviderPort;

import java.util.UUID;

public class PreviewReturnUseCase {
    private final ReturnQrValidationService validator;
    private final CorrelationIdProviderPort correlationIds;

    public PreviewReturnUseCase(
            ReturnQrValidationService validator,
            CorrelationIdProviderPort correlationIds
    ) {
        this.validator = validator;
        this.correlationIds = correlationIds;
    }

    public PreviewResult execute(String participantQrPayload, String containerQrPayload) {
        return new PreviewResult(
                validator.validatePreview(participantQrPayload, containerQrPayload),
                correlationIds.current()
        );
    }

    public record PreviewResult(
            ReturnQrValidationService.ValidatedReturn returnData,
            UUID traceId
    ) {}
}
