package com.revuelta.api.application.container;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.CorrelationIdProviderPort;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.application.port.ServerClockPort;
import com.revuelta.api.application.port.TransactionRunnerPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.user.UserId;

public class RegisterContainerUseCase {

    private final ContainerRepositoryPort containerRepository;
    private final TransactionRunnerPort transactionRunner;
    private final ServerClockPort clock;
    private final ContainerEventRepositoryPort eventRepository;
    private final CorrelationIdProviderPort correlationIds;
    private final QrPayloadCodecPort qrCodec;

    public RegisterContainerUseCase(
            ContainerRepositoryPort containerRepository,
            TransactionRunnerPort transactionRunner,
            ServerClockPort clock,
            ContainerEventRepositoryPort eventRepository,
            CorrelationIdProviderPort correlationIds,
            QrPayloadCodecPort qrCodec
    ) {
        this.containerRepository = containerRepository;
        this.transactionRunner = transactionRunner;
        this.clock = clock;
        this.eventRepository = eventRepository;
        this.correlationIds = correlationIds;
        this.qrCodec = qrCodec;
    }

    public Result execute(String code, UserId actor) {
        return transactionRunner.required(() -> register(code, actor));
    }

    private Result register(String code, UserId actor) {
        ContainerCode containerCode = new ContainerCode(code);
        if (containerRepository.existsByCode(containerCode)) {
            throw new ApplicationFailureException(
                    FailureCode.CONTAINER_CODE_ALREADY_EXISTS,
                    "Container code already exists: " + code
            );
        }

        var now = clock.now();
        Container container = Container.register(containerCode, now);
        Container saved = containerRepository.save(container);
        eventRepository.save(saved.registeredBy(actor, now, correlationIds.current()));
        return new Result(
                saved,
                qrCodec.encodeContainer(saved.id(), saved.qrGeneration())
        );
    }

    public record Result(Container container, String qrPayload) {}
}
