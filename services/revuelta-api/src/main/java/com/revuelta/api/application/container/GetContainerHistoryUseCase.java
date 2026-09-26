package com.revuelta.api.application.container;

import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.application.query.PageResult;

public class GetContainerHistoryUseCase {

    private final ContainerEventRepositoryPort eventRepository;

    public GetContainerHistoryUseCase(ContainerEventRepositoryPort eventRepository) {
        this.eventRepository = eventRepository;
    }

    public java.util.List<ContainerEvent> execute(ContainerId containerId, int page, int size) {
        return eventRepository.findByContainerId(containerId, page, size);
    }

    public PageResult<ContainerEvent> executePaged(ContainerId containerId, int page, int size) {
        PageResult.validate(page, size);
        return PageResult.fromExtraRow(eventRepository.findByContainerId(containerId, page, size + 1), page, size);
    }
}
