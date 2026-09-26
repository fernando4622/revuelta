package com.revuelta.api.infrastructure.persistence;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;
import java.util.Optional;
import java.util.Set;

@Repository
public interface SpringDataContainerEventRepository extends JpaRepository<ContainerEventJpaEntity, UUID> {
    List<ContainerEventJpaEntity> findByContainerIdOrderByOccurredAtDesc(UUID containerId, Pageable pageable);
    Optional<ContainerEventJpaEntity> findFirstByContainerIdAndEventTypeOrderByOccurredAtDesc(UUID containerId, String eventType);
    boolean existsByContainerIdAndEventType(UUID containerId, String eventType);
    List<ContainerEventJpaEntity> findByActorIdAndEventTypeInOrderByOccurredAtDesc(UUID actorId, Set<String> eventTypes, Pageable pageable);
    List<ContainerEventJpaEntity> findByEventTypeOrderByOccurredAtDesc(String eventType, Pageable pageable);
}
