package com.revuelta.api.application.container;

import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.user.UserId;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
@RequiredArgsConstructor
public class ActivateContainerUseCase {

    private final ContainerRepositoryPort containerRepository;
    private final ContainerEventRepositoryPort eventRepository;

    @Transactional
    public Container execute(ContainerId id, UserId actorId, String reason) {
        Container container = containerRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Container not found: " + id.value()));

        Instant now = Instant.now();
        ContainerEvent event = container.transition(ContainerStatus.AVAILABLE, actorId, reason, now);

        eventRepository.save(event);
        return containerRepository.save(container);
    }
}
