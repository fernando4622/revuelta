package com.revuelta.api.application.container;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.CorrelationIdProviderPort;
import com.revuelta.api.application.port.ServerClockPort;
import com.revuelta.api.application.port.TransactionRunnerPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.event.ContainerEventType;
import com.revuelta.api.domain.user.UserId;

import java.time.Instant;
import java.util.UUID;

public class CompleteContainerWashUseCase {
    private final ContainerRepositoryPort containers;
    private final CirculationRepositoryPort circulations;
    private final ContainerEventRepositoryPort events;
    private final TransactionRunnerPort transactions;
    private final ServerClockPort clock;
    private final CorrelationIdProviderPort correlationIds;

    public CompleteContainerWashUseCase(
            ContainerRepositoryPort containers,
            CirculationRepositoryPort circulations,
            ContainerEventRepositoryPort events,
            TransactionRunnerPort transactions,
            ServerClockPort clock,
            CorrelationIdProviderPort correlationIds
    ) {
        this.containers = containers;
        this.circulations = circulations;
        this.events = events;
        this.transactions = transactions;
        this.clock = clock;
        this.correlationIds = correlationIds;
    }

    public Result execute(ContainerId containerId, UserId actorId) {
        return transactions.required(() -> complete(containerId, actorId));
    }

    private Result complete(ContainerId containerId, UserId actorId) {
        Container container = containers.findById(containerId).orElseThrow(() ->
                new ApplicationFailureException(FailureCode.CONTAINER_NOT_FOUND, "Container not found"));

        if (container.status() != ContainerStatus.RETURNED) {
            if (container.status() == ContainerStatus.AVAILABLE
                    && events.existsByContainerIdAndType(containerId, ContainerEventType.WASH_COMPLETED)) {
                throw new ApplicationFailureException(FailureCode.WASH_ALREADY_COMPLETED, "Container washing was already completed");
            }
            throw new ApplicationFailureException(FailureCode.CONTAINER_NOT_RETURNED, "Container is not pending washing");
        }
        if (circulations.hasActiveCirculation(containerId)) {
            throw new ApplicationFailureException(FailureCode.ACTIVE_CIRCULATION_EXISTS, "Container still has an active circulation");
        }

        Instant now = clock.now();
        UUID traceId = correlationIds.current();
        ContainerEvent event = container.transition(
                ContainerStatus.AVAILABLE, actorId, "Washing completed", now, traceId
        );
        Container saved = containers.save(container);
        events.save(event);
        return new Result(saved, now, traceId);
    }

    public record Result(Container container, Instant washedAt, UUID traceId) {}
}
