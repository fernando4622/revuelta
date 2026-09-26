package com.revuelta.api.application.query;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.event.ContainerEventType;

import java.time.Instant;

public class OperatorQueueQueryUseCase {
    private final ContainerRepositoryPort containers;
    private final ContainerEventRepositoryPort events;

    public OperatorQueueQueryUseCase(ContainerRepositoryPort containers, ContainerEventRepositoryPort events) {
        this.containers = containers;
        this.events = events;
    }

    public PageResult<Item> execute(int page, int size) {
        PageResult.validate(page, size);
        var rows = containers.search(null, ContainerStatus.RETURNED, page, size + 1);
        var items = rows.stream().map(container -> {
            Instant returnedAt = events.findLatestByContainerIdAndType(container.id(), ContainerEventType.RETURNED)
                    .map(event -> event.occurredAt())
                    .orElseThrow(() -> new ApplicationFailureException(
                            FailureCode.INVALID_STATE_TRANSITION,
                            "Returned container has no return event"
                    ));
            return new Item(
                    container.id().value().toString(), container.code().value(),
                    container.status().name(), "Pendiente de lavado", returnedAt
            );
        }).toList();
        return PageResult.fromExtraRow(items, page, size);
    }

    public record Item(String containerId, String publicCode, String state, String stateLabel, Instant returnedAt) {}
}
