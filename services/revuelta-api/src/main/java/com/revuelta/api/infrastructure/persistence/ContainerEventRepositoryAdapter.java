package com.revuelta.api.infrastructure.persistence;

import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.event.ContainerEventType;
import com.revuelta.api.domain.participant.ParticipantId;
import com.revuelta.api.domain.user.UserId;
import lombok.RequiredArgsConstructor;
import jakarta.persistence.EntityManager;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;
import java.util.Set;

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
                event.correlationId(),
                event.participantId() != null ? event.participantId().value() : null,
                event.circulationId()
        );
        entityManager.persist(entity);
        entityManager.flush();
    }

    @Override
    public List<ContainerEvent> findByContainerId(ContainerId containerId, int offset, int size) {
        return repository.findByContainerIdOrderByOccurredAtDesc(containerId.value(), new OffsetPageRequest(offset, size))
                .stream()
                .map(this::toDomain)
                .toList();
    }

    @Override
    public Optional<ContainerEvent> findLatestByContainerIdAndType(ContainerId containerId, ContainerEventType type) {
        return repository.findFirstByContainerIdAndEventTypeOrderByOccurredAtDesc(
                containerId.value(), type.name()
        ).map(this::toDomain);
    }

    @Override
    public boolean existsByContainerIdAndType(ContainerId containerId, ContainerEventType type) {
        return repository.existsByContainerIdAndEventType(containerId.value(), type.name());
    }

    @Override
    public List<ContainerEvent> findByActorIdAndTypes(
            UserId actorId, Set<ContainerEventType> types, int offset, int size
    ) {
        Set<String> names = types.stream().map(Enum::name).collect(java.util.stream.Collectors.toSet());
        return repository.findByActorIdAndEventTypeInOrderByOccurredAtDesc(
                        actorId.value(), names, new OffsetPageRequest(offset, size)
                ).stream()
                .map(this::toDomain)
                .toList();
    }

    @Override
    public List<ContainerEvent> findAll(ContainerEventType type, int offset, int size) {
        var rows = type == null
                ? repository.findAll(new OffsetPageRequest(offset, size, org.springframework.data.domain.Sort.by("occurredAt").descending())).getContent()
                : repository.findByEventTypeOrderByOccurredAtDesc(type.name(), new OffsetPageRequest(offset, size));
        return rows.stream().map(this::toDomain).toList();
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
                entity.getCorrelationId(),
                entity.getParticipantId() != null ? new ParticipantId(entity.getParticipantId()) : null,
                entity.getCirculationId()
        );
    }
}
