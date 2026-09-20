package com.revuelta.api.application.container;

import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import java.util.Optional;

public class GetContainerUseCase {

    private final ContainerRepositoryPort containerRepository;

    public GetContainerUseCase(ContainerRepositoryPort containerRepository) {
        this.containerRepository = containerRepository;
    }

    public Optional<Container> findById(ContainerId id) {
        return containerRepository.findById(id);
    }

    public Optional<Container> findByCode(ContainerCode code) {
        return containerRepository.findByCode(code);
    }
}
