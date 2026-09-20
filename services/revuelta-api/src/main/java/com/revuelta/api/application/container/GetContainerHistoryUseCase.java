package com.revuelta.api.application.container;

import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import java.util.List;

public class GetContainerHistoryUseCase {

    private final ContainerEventRepositoryPort eventRepository;

    public GetContainerHistoryUseCase(ContainerEventRepositoryPort eventRepository) {
        this.eventRepository = eventRepository;
    }

    public List<ContainerEvent> execute(ContainerId containerId, int page, int size) {
        return eventRepository.findByContainerId(containerId, page, size);
    }
}
