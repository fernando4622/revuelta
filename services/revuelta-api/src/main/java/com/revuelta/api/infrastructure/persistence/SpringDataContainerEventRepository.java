package com.revuelta.api.infrastructure.persistence;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface SpringDataContainerEventRepository extends JpaRepository<ContainerEventJpaEntity, UUID> {
    List<ContainerEventJpaEntity> findByContainerIdOrderByOccurredAtDesc(UUID containerId, Pageable pageable);
}
