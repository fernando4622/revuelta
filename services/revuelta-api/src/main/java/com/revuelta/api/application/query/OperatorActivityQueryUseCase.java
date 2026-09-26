package com.revuelta.api.application.query;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.event.ContainerEventType;
import com.revuelta.api.domain.user.UserId;

import java.time.Instant;
import java.util.Set;

public class OperatorActivityQueryUseCase {
    private static final Set<ContainerEventType> OPERATOR_EVENTS = Set.of(
            ContainerEventType.DELIVERED, ContainerEventType.RETURNED, ContainerEventType.WASH_COMPLETED
    );

    private final ContainerEventRepositoryPort events;
    private final ContainerRepositoryPort containers;

    public OperatorActivityQueryUseCase(ContainerEventRepositoryPort events, ContainerRepositoryPort containers) {
        this.events = events;
        this.containers = containers;
    }

    public PageResult<Item> execute(UserId actorId, int page, int size) {
        PageResult.validate(page, size);
        var rows = events.findByActorIdAndTypes(actorId, OPERATOR_EVENTS, page, size + 1);
        var items = rows.stream().map(event -> {
            var container = containers.findById(event.containerId()).orElseThrow(() ->
                    new ApplicationFailureException(FailureCode.CONTAINER_NOT_FOUND, "Container not found"));
            return new Item(
                    event.id().toString(), event.eventType().name(),
                    container.id().value().toString(), container.code().value(),
                    event.occurredAt(), event.newStatus().name(), event.correlationId().toString()
            );
        }).toList();
        return PageResult.fromExtraRow(items, page, size);
    }

    public record Item(
            String eventId, String eventType, String containerId, String publicCode,
            Instant occurredAt, String resultingState, String traceId
    ) {}
}
