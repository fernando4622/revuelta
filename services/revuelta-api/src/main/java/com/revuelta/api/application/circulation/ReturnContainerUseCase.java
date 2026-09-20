package com.revuelta.api.application.circulation;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.CorrelationIdProviderPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.TransactionRunnerPort;
import com.revuelta.api.application.port.ServerClockPort;
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
    private final ServerClockPort clock;
    private final CorrelationIdProviderPort correlationIds;

    public ReturnContainerUseCase(
            ContainerRepositoryPort containerRepository,
            CirculationRepositoryPort circulationRepository,
            ContainerEventRepositoryPort eventRepository,
            TransactionRunnerPort transactionRunner,
            ServerClockPort clock,
            CorrelationIdProviderPort correlationIds
    ) {
        this.containerRepository = containerRepository;
        this.circulationRepository = circulationRepository;
        this.eventRepository = eventRepository;
        this.transactionRunner = transactionRunner;
        this.clock = clock;
        this.correlationIds = correlationIds;
    }

    public ReturnResult execute(CirculationId circulationId, UserId operatorId) {
        return transactionRunner.required(() -> returnByCirculationId(circulationId, operatorId));
    }

    private ReturnResult returnByCirculationId(CirculationId circulationId, UserId operatorId) {
        // 1. Resolve Circulation
        Circulation circulation = circulationRepository.findById(circulationId)
                .orElseThrow(() -> new ApplicationFailureException(
                        FailureCode.CIRCULATION_NOT_FOUND,
                        "Circulation not found: " + circulationId.value()
                ));

        if (!circulation.isActive()) {
            throw new ApplicationFailureException(
                    FailureCode.RETURN_ALREADY_REGISTERED,
                    "Circulation " + circulationId.value() + " is already finalized"
            );
        }

        // 2. Resolve Container
        Container container = containerRepository.findById(circulation.containerId())
                .orElseThrow(() -> new ApplicationFailureException(
                        FailureCode.CONTAINER_NOT_FOUND,
                        "Container not found: " + circulation.containerId().value()
                ));

        // 3. Server-authoritative return time
        Instant returnedAt = clock.now();

        // 4. Finalize circulation (classifies ON_TIME / LATE)
        circulation.finalize(operatorId, returnedAt);

        // 5. Persist pending-wash state (DL-006)
        ContainerEvent event = container.transition(
                ContainerStatus.RETURNED,
                operatorId,
                "Container returned",
                returnedAt,
                correlationIds.current()
        );

        // 6. Commit atomic transaction
        circulationRepository.save(circulation);
        containerRepository.save(container);
        eventRepository.save(event);

        return new ReturnResult(circulation, container);
    }

    public record ReturnResult(Circulation circulation, Container container) {}
}
