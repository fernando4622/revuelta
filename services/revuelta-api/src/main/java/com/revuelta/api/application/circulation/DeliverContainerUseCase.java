package com.revuelta.api.application.circulation;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.CorrelationIdProviderPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.ReturnPolicyRepositoryPort;
import com.revuelta.api.application.port.ServerClockPort;
import com.revuelta.api.application.port.TransactionRunnerPort;
import com.revuelta.api.application.port.UserRepositoryPort;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.policy.ReturnPolicy;
import com.revuelta.api.domain.user.UserId;
import java.time.Instant;

public class DeliverContainerUseCase {

    private final ContainerRepositoryPort containerRepository;
    private final CirculationRepositoryPort circulationRepository;
    private final UserRepositoryPort userRepository;
    private final ReturnPolicyRepositoryPort policyRepository;
    private final ContainerEventRepositoryPort eventRepository;
    private final TransactionRunnerPort transactionRunner;
    private final ServerClockPort clock;
    private final CorrelationIdProviderPort correlationIds;

    public DeliverContainerUseCase(
            ContainerRepositoryPort containerRepository,
            CirculationRepositoryPort circulationRepository,
            UserRepositoryPort userRepository,
            ReturnPolicyRepositoryPort policyRepository,
            ContainerEventRepositoryPort eventRepository,
            TransactionRunnerPort transactionRunner,
            ServerClockPort clock,
            CorrelationIdProviderPort correlationIds
    ) {
        this.containerRepository = containerRepository;
        this.circulationRepository = circulationRepository;
        this.userRepository = userRepository;
        this.policyRepository = policyRepository;
        this.eventRepository = eventRepository;
        this.transactionRunner = transactionRunner;
        this.clock = clock;
        this.correlationIds = correlationIds;
    }

    public DeliveryResult execute(ContainerId containerId, UserId borrowerId, UserId operatorId) {
        return transactionRunner.required(() -> deliver(containerId, borrowerId, operatorId));
    }

    private DeliveryResult deliver(ContainerId containerId, UserId borrowerId, UserId operatorId) {
        // 1. Validate Container existence and eligibility
        Container container = containerRepository.findById(containerId)
                .orElseThrow(() -> new ApplicationFailureException(
                        FailureCode.CONTAINER_NOT_FOUND,
                        "Container not found: " + containerId.value()
                ));

        if (!container.isEligibleForCirculation()) {
            throw new ApplicationFailureException(
                    FailureCode.CONTAINER_NOT_AVAILABLE,
                    "Container " + containerId.value()
                            + " is not available for delivery (status: " + container.status() + ")"
            );
        }

        // 2. Validate Borrower user existence (DL-002)
        if (!userRepository.existsById(borrowerId)) {
            throw new ApplicationFailureException(
                    FailureCode.PARTICIPANT_NOT_FOUND,
                    "Participant not found: " + borrowerId.value()
            );
        }

        // 3. Ensure no active circulation exists for container (BR-CIR-001)
        if (circulationRepository.hasActiveCirculation(containerId)) {
            throw new ApplicationFailureException(
                    FailureCode.ACTIVE_CIRCULATION_EXISTS,
                    "Container " + containerId.value() + " already has an active circulation"
            );
        }

        // 4. Resolve effective ReturnPolicy
        ReturnPolicy policy = policyRepository.findActivePolicy()
                .orElseThrow(() -> new ApplicationFailureException(
                        FailureCode.POLICY_NOT_FOUND,
                        "No active return policy is configured"
                ));

        // 5. Server-authoritative time & due-at calculation
        Instant now = clock.now();

        // 6. Create Circulation aggregate
        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, now, policy);

        // 7. Transition Container state (AVAILABLE -> IN_USE) & emit event
        ContainerEvent event = container.transition(
                ContainerStatus.IN_USE,
                operatorId,
                "Container delivered",
                now,
                correlationIds.current()
        );

        // 8. Commit atomic mutations
        circulationRepository.save(circulation);
        containerRepository.save(container);
        eventRepository.save(event);

        return new DeliveryResult(circulation, container);
    }

    public record DeliveryResult(Circulation circulation, Container container) {}
}
