package com.revuelta.api.application.circulation;

import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.CorrelationIdProviderPort;
import com.revuelta.api.application.port.OperationQrTokenRepositoryPort;
import com.revuelta.api.application.port.TransactionRunnerPort;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.participant.OperationQrToken;
import com.revuelta.api.domain.policy.ReturnPolicy;
import com.revuelta.api.domain.user.UserId;

import java.util.UUID;

public class DeliverContainerUseCase {
    private final DeliveryQrValidationService validator;
    private final ContainerRepositoryPort containers;
    private final CirculationRepositoryPort circulations;
    private final OperationQrTokenRepositoryPort tokens;
    private final ContainerEventRepositoryPort events;
    private final TransactionRunnerPort transactions;
    private final CorrelationIdProviderPort correlationIds;

    public DeliverContainerUseCase(
            DeliveryQrValidationService validator,
            ContainerRepositoryPort containers,
            CirculationRepositoryPort circulations,
            OperationQrTokenRepositoryPort tokens,
            ContainerEventRepositoryPort events,
            TransactionRunnerPort transactions,
            CorrelationIdProviderPort correlationIds
    ) {
        this.validator = validator;
        this.containers = containers;
        this.circulations = circulations;
        this.tokens = tokens;
        this.events = events;
        this.transactions = transactions;
        this.correlationIds = correlationIds;
    }

    public DeliveryResult execute(
            String participantQrPayload,
            String containerQrPayload,
            UserId operatorId
    ) {
        return transactions.required(() -> deliver(participantQrPayload, containerQrPayload, operatorId));
    }

    private DeliveryResult deliver(
            String participantQrPayload,
            String containerQrPayload,
            UserId operatorId
    ) {
        DeliveryQrValidationService.ValidatedDelivery valid =
                validator.validateForCommit(participantQrPayload, containerQrPayload);

        Circulation circulation = Circulation.create(
                valid.container().id(),
                valid.participant().id(),
                operatorId,
                valid.validatedAt(),
                valid.policy()
        );
        UUID traceId = correlationIds.current();
        ContainerEvent event = valid.container().transition(
                ContainerStatus.IN_USE,
                operatorId,
                "Container delivered",
                valid.validatedAt(),
                traceId
        ).withHandoff(valid.participant().id(), circulation.id().value());

        OperationQrToken token = valid.token();
        token.consume(valid.validatedAt(), circulation.id().value());

        circulations.save(circulation);
        containers.save(valid.container());
        events.save(event);
        tokens.save(token);

        return new DeliveryResult(circulation, valid.container(), valid.policy(), traceId);
    }

    public record DeliveryResult(
            Circulation circulation,
            Container container,
            ReturnPolicy policy,
            UUID traceId
    ) {}
}
