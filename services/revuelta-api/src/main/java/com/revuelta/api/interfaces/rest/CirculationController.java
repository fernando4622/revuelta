package com.revuelta.api.interfaces.rest;

import com.revuelta.api.application.circulation.DeliverContainerUseCase;
import com.revuelta.api.application.circulation.PreviewDeliveryUseCase;
import com.revuelta.api.application.circulation.ReturnContainerUseCase;
import com.revuelta.api.application.container.GetContainerHistoryUseCase;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.circulation.CirculationId;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.user.UserId;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class CirculationController {

    private final DeliverContainerUseCase deliverContainerUseCase;
    private final PreviewDeliveryUseCase previewDeliveryUseCase;
    private final ReturnContainerUseCase returnContainerUseCase;
    private final GetContainerHistoryUseCase getContainerHistoryUseCase;

    @PostMapping("/circulations")
    @PreAuthorize("hasRole('OPERATOR')")
    public ResponseEntity<DeliveryResponse> deliver(
            @Valid @RequestBody DeliverRequest request,
            @AuthenticationPrincipal String operatorIdString
    ) {
        UserId operatorId = new UserId(UUID.fromString(operatorIdString));
        var result = deliverContainerUseCase.execute(
                request.participantQrPayload(),
                request.containerQrPayload(),
                operatorId
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(DeliveryResponse.fromResult(result));
    }

    @PostMapping("/delivery-previews")
    @PreAuthorize("hasRole('OPERATOR')")
    public ResponseEntity<DeliveryPreviewResponse> preview(
            @Valid @RequestBody DeliverRequest request
    ) {
        return ResponseEntity.ok(DeliveryPreviewResponse.fromResult(
                previewDeliveryUseCase.execute(
                        request.participantQrPayload(),
                        request.containerQrPayload()
                )
        ));
    }

    @PostMapping("/circulations/{circulationId}/return")
    @PreAuthorize("hasRole('OPERATOR')")
    public ResponseEntity<CirculationResponse> returnByCirculationId(
            @PathVariable UUID circulationId,
            @AuthenticationPrincipal String operatorIdString
    ) {
        UserId operatorId = new UserId(UUID.fromString(operatorIdString));
        var result = returnContainerUseCase.execute(new CirculationId(circulationId), operatorId);
        return ResponseEntity.ok(CirculationResponse.fromDomain(result.circulation()));
    }

    @GetMapping("/containers/{containerId}/history")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EventResponse>> getHistory(
            @PathVariable UUID containerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        List<EventResponse> events = getContainerHistoryUseCase.execute(new ContainerId(containerId), page, size)
                .stream()
                .map(EventResponse::fromDomain)
                .toList();
        return ResponseEntity.ok(events);
    }

    public record DeliverRequest(
            @NotBlank(message = "participantQrPayload must not be blank")
            @Size(max = 512, message = "participantQrPayload must contain at most 512 characters")
            String participantQrPayload,
            @NotBlank(message = "containerQrPayload must not be blank")
            @Size(max = 512, message = "containerQrPayload must contain at most 512 characters")
            String containerQrPayload
    ) {}

    public record DeliveryResponse(
            String circulationId,
            String participantRef,
            DeliveryContainerResponse container,
            Instant deliveredAt,
            Instant dueAt,
            DeliveryPolicyResponse policy,
            String traceId
    ) {
        static DeliveryResponse fromResult(DeliverContainerUseCase.DeliveryResult result) {
            return new DeliveryResponse(
                    result.circulation().id().value().toString(),
                    result.circulation().borrowerId().value().toString(),
                    new DeliveryContainerResponse(
                            result.container().id().value().toString(),
                            result.container().code().value(),
                            result.container().status().name()
                    ),
                    result.circulation().deliveredAt(),
                    result.circulation().dueAt(),
                    new DeliveryPolicyResponse(
                            result.policy().id().toString(),
                            result.policy().version(),
                            result.policy().name(),
                            result.policy().durationHours()
                    ),
                    result.traceId().toString()
            );
        }
    }

    public record DeliveryPreviewResponse(
            String participantRef,
            DeliveryContainerResponse container,
            DeliveryPolicyResponse policy,
            Instant previewedAt,
            Instant estimatedDueAt,
            String traceId
    ) {
        static DeliveryPreviewResponse fromResult(PreviewDeliveryUseCase.PreviewResult result) {
            var valid = result.delivery();
            return new DeliveryPreviewResponse(
                    valid.participant().id().value().toString(),
                    new DeliveryContainerResponse(
                            valid.container().id().value().toString(),
                            valid.container().code().value(),
                            valid.container().status().name()
                    ),
                    new DeliveryPolicyResponse(
                            valid.policy().id().toString(),
                            valid.policy().version(),
                            valid.policy().name(),
                            valid.policy().durationHours()
                    ),
                    valid.validatedAt(),
                    result.estimatedDueAt(),
                    result.traceId().toString()
            );
        }
    }

    public record DeliveryContainerResponse(String id, String publicCode, String state) {}

    public record DeliveryPolicyResponse(
            String id,
            int version,
            String name,
            int durationHours
    ) {}

    public record CirculationResponse(
            String id,
            String containerId,
            String borrowerId,
            String deliveredBy,
            Instant deliveredAt,
            Instant dueAt,
            String returnPolicyId,
            int returnPolicyVersion,
            String returnedBy,
            Instant returnedAt,
            String punctuality,
            String status
    ) {
        public static CirculationResponse fromDomain(Circulation c) {
            return new CirculationResponse(
                    c.id().value().toString(),
                    c.containerId().value().toString(),
                    c.borrowerId().value().toString(),
                    c.deliveredBy().value().toString(),
                    c.deliveredAt(),
                    c.dueAt(),
                    c.returnPolicyId().toString(),
                    c.returnPolicyVersion(),
                    c.returnedBy() != null ? c.returnedBy().value().toString() : null,
                    c.returnedAt(),
                    c.punctuality() != null ? c.punctuality().name() : null,
                    c.status().name()
            );
        }
    }

    public record EventResponse(
            String id,
            String containerId,
            String eventType,
            String actorId,
            Instant occurredAt,
            String previousStatus,
            String newStatus,
            String reason,
            String correlationId,
            String participantRef,
            String circulationRef
    ) {
        public static EventResponse fromDomain(ContainerEvent e) {
            return new EventResponse(
                    e.id().toString(),
                    e.containerId().value().toString(),
                    e.eventType().name(),
                    e.actorId().value().toString(),
                    e.occurredAt(),
                    e.previousStatus() != null ? e.previousStatus().name() : null,
                    e.newStatus().name(),
                    e.reason(),
                    e.correlationId().toString(),
                    e.participantId() != null ? e.participantId().value().toString() : null,
                    e.circulationId() != null ? e.circulationId().toString() : null
            );
        }
    }
}
