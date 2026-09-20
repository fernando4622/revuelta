package com.revuelta.api.application.container;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.CorrelationIdProviderPort;
import com.revuelta.api.application.port.ServerClockPort;
import com.revuelta.api.application.port.TransactionRunnerPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.user.UserId;
import java.time.Instant;

public class ActivateContainerUseCase {

    private final ContainerRepositoryPort containerRepository;
    private final ContainerEventRepositoryPort eventRepository;
    private final TransactionRunnerPort transactionRunner;
    private final ServerClockPort clock;
    private final CorrelationIdProviderPort correlationIds;

    public ActivateContainerUseCase(
            ContainerRepositoryPort containerRepository,
            ContainerEventRepositoryPort eventRepository,
            TransactionRunnerPort transactionRunner,
            ServerClockPort clock,
            CorrelationIdProviderPort correlationIds
    ) {
        this.containerRepository = containerRepository;
        this.eventRepository = eventRepository;
        this.transactionRunner = transactionRunner;
        this.clock = clock;
        this.correlationIds = correlationIds;
    }

    public Container execute(ContainerId id, UserId actorId, String reason) {
        return transactionRunner.required(() -> activate(id, actorId, reason));
    }

    private Container activate(ContainerId id, UserId actorId, String reason) {
        Container container = containerRepository.findById(id)
                .orElseThrow(() -> new ApplicationFailureException(
                        FailureCode.CONTAINER_NOT_FOUND,
                        "Container not found: " + id.value()
                ));

        Instant now = clock.now();
        ContainerEvent event = container.transition(
                ContainerStatus.AVAILABLE,
                actorId,
                reason,
                now,
                correlationIds.current()
        );

        eventRepository.save(event);
        return containerRepository.save(container);
    }
}
