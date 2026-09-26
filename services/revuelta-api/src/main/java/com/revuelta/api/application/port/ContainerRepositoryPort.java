package com.revuelta.api.application.port;

import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;

import java.util.List;
import java.util.Optional;

public interface ContainerRepositoryPort {
    Container save(Container container);
    Optional<Container> findById(ContainerId id);
    Optional<Container> findByCode(ContainerCode code);
    List<Container> findAll(int page, int size);
    List<Container> search(String query, ContainerStatus status, int page, int size);
    long countAll();
    long countByStatus(ContainerStatus status);
    boolean existsByCode(ContainerCode code);
}
