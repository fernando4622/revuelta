package com.revuelta.api.application.container;

import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GetContainerHistoryUseCase {

    private final ContainerEventRepositoryPort eventRepository;

    public List<ContainerEvent> execute(ContainerId containerId, int page, int size) {
        return eventRepository.findByContainerId(containerId, page, size);
    }
}
