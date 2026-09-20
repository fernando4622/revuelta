package com.revuelta.api.application.container;

import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.container.Container;
import java.util.List;

public class ListContainersUseCase {

    private final ContainerRepositoryPort containerRepository;

    public ListContainersUseCase(ContainerRepositoryPort containerRepository) {
        this.containerRepository = containerRepository;
    }

    public List<Container> execute(int page, int size) {
        return containerRepository.findAll(page, size);
    }
}
