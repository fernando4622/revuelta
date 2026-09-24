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
import com.revuelta.api.domain.user.UserId;

import java.util.UUID;

public class ReturnContainerUseCase {
    private final ReturnQrValidationService validator;
    private final ContainerRepositoryPort containers;
    private final CirculationRepositoryPort circulations;
    private final OperationQrTokenRepositoryPort tokens;
    private final ContainerEventRepositoryPort events;
    private final TransactionRunnerPort transactions;
    private final CorrelationIdProviderPort correlationIds;

    public ReturnContainerUseCase(
            ReturnQrValidationService validator,
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

    public ReturnResult execute(
            String participantQrPayload,
            String containerQrPayload,
            UserId operatorId
    ) {
        return transactions.required(() -> returnContainer(
                participantQrPayload, containerQrPayload, operatorId
        ));
    }

    private ReturnResult returnContainer(
            String participantQrPayload,
            String containerQrPayload,
            UserId operatorId
    ) {
        ReturnQrValidationService.ValidatedReturn valid =
                validator.validateForCommit(participantQrPayload, containerQrPayload);

        Circulation circulation = valid.circulation();
        circulation.finalize(operatorId, valid.validatedAt());
        UUID traceId = correlationIds.current();
        ContainerEvent event = valid.container().transition(
                ContainerStatus.RETURNED,
                operatorId,
                "Container returned",
                valid.validatedAt(),
                traceId
        ).withHandoff(valid.participant().id(), circulation.id().value());

        OperationQrToken token = valid.token();
        token.consume(valid.validatedAt(), circulation.id().value());

        circulations.save(circulation);
        containers.save(valid.container());
        events.save(event);
        tokens.save(token);

        return new ReturnResult(circulation, valid.container(), traceId);
    }

    public record ReturnResult(
            Circulation circulation,
            Container container,
            UUID traceId
    ) {}
}
