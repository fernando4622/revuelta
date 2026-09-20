package com.revuelta.api.interfaces.rest;

import com.revuelta.api.application.circulation.DeliverContainerUseCase;
import com.revuelta.api.application.circulation.ReturnContainerUseCase;
import com.revuelta.api.application.container.GetContainerHistoryUseCase;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.circulation.CirculationId;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.user.UserId;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
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
    private final ReturnContainerUseCase returnContainerUseCase;
    private final GetContainerHistoryUseCase getContainerHistoryUseCase;

    @PostMapping("/circulations")
    @PreAuthorize("hasAnyRole('OPERATOR', 'ADMIN')")
    public ResponseEntity<CirculationResponse> deliver(
            @Valid @RequestBody DeliverRequest request,
            @AuthenticationPrincipal String operatorIdString
    ) {
        UserId operatorId = new UserId(UUID.fromString(operatorIdString));
        var result = deliverContainerUseCase.execute(
                new ContainerId(UUID.fromString(request.containerId())),
                new UserId(UUID.fromString(request.borrowerId())),
                operatorId
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(CirculationResponse.fromDomain(result.circulation()));
    }

    @PostMapping("/circulations/{circulationId}/return")
    @PreAuthorize("hasAnyRole('OPERATOR', 'ADMIN')")
    public ResponseEntity<CirculationResponse> returnByCirculationId(
            @PathVariable UUID circulationId,
            @AuthenticationPrincipal String operatorIdString
    ) {
        UserId operatorId = new UserId(UUID.fromString(operatorIdString));
        var result = returnContainerUseCase.execute(new CirculationId(circulationId), operatorId);
        return ResponseEntity.ok(CirculationResponse.fromDomain(result.circulation()));
    }

    @GetMapping("/containers/{containerId}/events")
    @PreAuthorize("hasAnyRole('OPERATOR', 'ADMIN')")
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
            @NotNull(message = "containerId must not be null") String containerId,
            @NotNull(message = "borrowerId must not be null") String borrowerId
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
            String correlationId
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
                    e.correlationId().toString()
            );
        }
    }
}
