package com.revuelta.api.application.circulation;

import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.TransactionRunnerPort;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.circulation.CirculationId;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.user.UserId;
import java.time.Instant;

public class ReturnContainerUseCase {

    private final ContainerRepositoryPort containerRepository;
    private final CirculationRepositoryPort circulationRepository;
    private final ContainerEventRepositoryPort eventRepository;
    private final TransactionRunnerPort transactionRunner;

    public ReturnContainerUseCase(
            ContainerRepositoryPort containerRepository,
            CirculationRepositoryPort circulationRepository,
            ContainerEventRepositoryPort eventRepository,
            TransactionRunnerPort transactionRunner
    ) {
        this.containerRepository = containerRepository;
        this.circulationRepository = circulationRepository;
        this.eventRepository = eventRepository;
        this.transactionRunner = transactionRunner;
    }

    public ReturnResult execute(CirculationId circulationId, UserId operatorId) {
        return transactionRunner.required(() -> returnByCirculationId(circulationId, operatorId));
    }

    private ReturnResult returnByCirculationId(CirculationId circulationId, UserId operatorId) {
        // 1. Resolve Circulation
        Circulation circulation = circulationRepository.findById(circulationId)
                .orElseThrow(() -> new IllegalArgumentException("Circulation not found: " + circulationId.value()));

        if (!circulation.isActive()) {
            throw new IllegalStateException("Circulation " + circulationId.value() + " is already finalized");
        }

        // 2. Resolve Container
        Container container = containerRepository.findById(circulation.containerId())
                .orElseThrow(() -> new IllegalArgumentException("Container not found: " + circulation.containerId().value()));

        // 3. Server-authoritative return time
        Instant returnedAt = Instant.now();

        // 4. Finalize circulation (classifies ON_TIME / LATE)
        circulation.finalize(operatorId, returnedAt);

        // 5. Transition container back to AVAILABLE (DL-006)
        ContainerEvent event = container.transition(ContainerStatus.AVAILABLE, operatorId, "Container returned", returnedAt);

        // 6. Commit atomic transaction
        circulationRepository.save(circulation);
        containerRepository.save(container);
        eventRepository.save(event);

        return new ReturnResult(circulation, container);
    }

    public record ReturnResult(Circulation circulation, Container container) {}
}
