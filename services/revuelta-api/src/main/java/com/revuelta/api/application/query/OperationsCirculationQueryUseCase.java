package com.revuelta.api.application.query;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.circulation.CirculationStatus;

import java.time.Instant;

public class OperationsCirculationQueryUseCase {
    private final CirculationRepositoryPort circulations;
    private final ContainerRepositoryPort containers;

    public OperationsCirculationQueryUseCase(CirculationRepositoryPort circulations, ContainerRepositoryPort containers) {
        this.circulations = circulations;
        this.containers = containers;
    }

    public PageResult<Item> execute(CirculationStatus status, int page, int size) {
        PageResult.validate(page, size);
        var rows = circulations.findAll(status, page * size, size + 1);
        var items = rows.stream().map(circulation -> {
            var container = containers.findById(circulation.containerId()).orElseThrow(() ->
                    new ApplicationFailureException(FailureCode.CONTAINER_NOT_FOUND, "Container not found"));
            return new Item(
                    circulation.id().value().toString(),
                    circulation.borrowerId().value().toString(),
                    container.id().value().toString(), container.code().value(),
                    circulation.status().name(), circulation.deliveredAt(), circulation.dueAt(),
                    circulation.returnedAt(),
                    circulation.punctuality() == null ? null : circulation.punctuality().name()
            );
        }).toList();
        return PageResult.fromExtraRow(items, page, size);
    }

    public record Item(
            String circulationId, String participantRef, String containerId, String publicCode,
            String status, Instant deliveredAt, Instant dueAt, Instant returnedAt, String punctuality
    ) {}
}
