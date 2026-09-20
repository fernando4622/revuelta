package com.revuelta.api.application.container;

import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.TransactionRunnerPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import java.time.Instant;

public class RegisterContainerUseCase {

    private final ContainerRepositoryPort containerRepository;
    private final TransactionRunnerPort transactionRunner;

    public RegisterContainerUseCase(
            ContainerRepositoryPort containerRepository,
            TransactionRunnerPort transactionRunner
    ) {
        this.containerRepository = containerRepository;
        this.transactionRunner = transactionRunner;
    }

    public Container execute(String code) {
        return transactionRunner.required(() -> register(code));
    }

    private Container register(String code) {
        ContainerCode containerCode = new ContainerCode(code);
        if (containerRepository.existsByCode(containerCode)) {
            throw new IllegalArgumentException("Container code already exists: " + code);
        }

        Container container = Container.register(containerCode, Instant.now());
        return containerRepository.save(container);
    }
}
