package com.revuelta.api.infrastructure.persistence;

import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.event.ContainerEventType;
import com.revuelta.api.domain.user.UserId;
import lombok.RequiredArgsConstructor;
import jakarta.persistence.EntityManager;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class ContainerEventRepositoryAdapter implements ContainerEventRepositoryPort {

    private final SpringDataContainerEventRepository repository;
    private final EntityManager entityManager;

    @Override
    public void save(ContainerEvent event) {
        ContainerEventJpaEntity entity = new ContainerEventJpaEntity(
                event.id(),
                event.containerId().value(),
                event.eventType().name(),
                event.actorId().value(),
                event.occurredAt(),
                event.previousStatus() != null ? event.previousStatus().name() : null,
                event.newStatus().name(),
                event.reason(),
                event.correlationId()
        );
        entityManager.persist(entity);
        entityManager.flush();
    }

    @Override
    public List<ContainerEvent> findByContainerId(ContainerId containerId, int page, int size) {
        return repository.findByContainerIdOrderByOccurredAtDesc(containerId.value(), PageRequest.of(page, size))
                .stream()
                .map(this::toDomain)
                .toList();
    }

    private ContainerEvent toDomain(ContainerEventJpaEntity entity) {
        return new ContainerEvent(
                entity.getId(),
                new ContainerId(entity.getContainerId()),
                ContainerEventType.valueOf(entity.getEventType()),
                new UserId(entity.getActorId()),
                entity.getOccurredAt(),
                entity.getPreviousStatus() != null ? ContainerStatus.valueOf(entity.getPreviousStatus()) : null,
                ContainerStatus.valueOf(entity.getNewStatus()),
                entity.getReason(),
                entity.getCorrelationId()
        );
    }
}
