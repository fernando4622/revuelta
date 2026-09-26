package com.revuelta.api.application.query;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.event.ContainerEventType;

import java.time.Instant;

public class OperationsEventQueryUseCase {
    private final ContainerEventRepositoryPort events;
    private final ContainerRepositoryPort containers;

    public OperationsEventQueryUseCase(ContainerEventRepositoryPort events, ContainerRepositoryPort containers) {
        this.events = events;
        this.containers = containers;
    }

    public PageResult<Item> execute(ContainerEventType type, int page, int size) {
        PageResult.validate(page, size);
        var rows = events.findAll(type, page * size, size + 1);
        var items = rows.stream().map(event -> {
            var container = containers.findById(event.containerId()).orElseThrow(() ->
                    new ApplicationFailureException(FailureCode.CONTAINER_NOT_FOUND, "Container not found"));
            return new Item(
                    event.id().toString(), event.eventType().name(),
                    container.id().value().toString(), container.code().value(),
                    event.actorId().value().toString(), event.occurredAt(),
                    event.previousStatus() == null ? null : event.previousStatus().name(),
                    event.newStatus().name(), event.reason(), event.correlationId().toString(),
                    event.participantId() == null ? null : event.participantId().value().toString(),
                    event.circulationId() == null ? null : event.circulationId().toString()
            );
        }).toList();
        return PageResult.fromExtraRow(items, page, size);
    }

    public record Item(
            String eventId, String eventType, String containerId, String publicCode,
            String actorId, Instant occurredAt, String previousStatus, String newStatus,
            String reason, String traceId, String participantRef, String circulationRef
    ) {}
}
