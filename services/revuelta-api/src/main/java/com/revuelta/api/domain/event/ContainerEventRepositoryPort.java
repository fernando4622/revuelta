package com.revuelta.api.domain.event;

import com.revuelta.api.domain.container.ContainerId;

import java.util.List;

public interface ContainerEventRepositoryPort {
    void save(ContainerEvent event);
    List<ContainerEvent> findByContainerId(ContainerId containerId, int page, int size);
}
