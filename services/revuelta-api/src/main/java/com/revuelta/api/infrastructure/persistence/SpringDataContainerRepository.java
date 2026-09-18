package com.revuelta.api.infrastructure.persistence;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SpringDataContainerRepository extends JpaRepository<ContainerJpaEntity, UUID> {
    Optional<ContainerJpaEntity> findByCode(String code);
    boolean existsByCode(String code);
}
