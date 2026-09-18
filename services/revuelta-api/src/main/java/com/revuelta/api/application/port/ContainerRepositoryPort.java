package com.revuelta.api.application.port;

import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;

import java.util.List;
import java.util.Optional;

public interface ContainerRepositoryPort {
    Container save(Container container);
    Optional<Container> findById(ContainerId id);
    Optional<Container> findByCode(ContainerCode code);
    List<Container> findAll(int page, int size);
    boolean existsByCode(ContainerCode code);
}
