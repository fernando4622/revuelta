package com.revuelta.api.application.qr;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.CorrelationIdProviderPort;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.application.port.ServerClockPort;
import com.revuelta.api.application.port.TransactionRunnerPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.user.UserId;

public class RotateContainerQrUseCase {
    private final ContainerRepositoryPort containers;
    private final ContainerEventRepositoryPort events;
    private final QrPayloadCodecPort qrCodec;
    private final TransactionRunnerPort transactions;
    private final ServerClockPort clock;
    private final CorrelationIdProviderPort correlationIds;

    public RotateContainerQrUseCase(
            ContainerRepositoryPort containers,
            ContainerEventRepositoryPort events,
            QrPayloadCodecPort qrCodec,
            TransactionRunnerPort transactions,
            ServerClockPort clock,
            CorrelationIdProviderPort correlationIds
    ) {
        this.containers = containers;
        this.events = events;
        this.qrCodec = qrCodec;
        this.transactions = transactions;
        this.clock = clock;
        this.correlationIds = correlationIds;
    }

    public GetContainerQrUseCase.Result execute(ContainerId id, UserId actor, String reason) {
        return transactions.required(() -> rotate(id, actor, reason));
    }

    private GetContainerQrUseCase.Result rotate(ContainerId id, UserId actor, String reason) {
        Container container = containers.findById(id)
                .orElseThrow(() -> new ApplicationFailureException(
                        FailureCode.CONTAINER_NOT_FOUND, "Container was not found"
                ));
        var event = container.rotateQr(actor, reason, clock.now(), correlationIds.current());
        Container saved = containers.save(container);
        events.save(event);
        return new GetContainerQrUseCase.Result(
                saved.id().value(), saved.qrGeneration(),
                qrCodec.encodeContainer(saved.id(), saved.qrGeneration())
        );
    }
}
