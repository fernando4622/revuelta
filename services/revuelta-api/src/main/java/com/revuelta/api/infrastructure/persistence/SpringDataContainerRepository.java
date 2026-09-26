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
    long countByStatus(String status);
    List<ContainerJpaEntity> findAllByOrderByUpdatedAtDesc(Pageable pageable);
    List<ContainerJpaEntity> findByStatusOrderByUpdatedAtDesc(String status, Pageable pageable);
    List<ContainerJpaEntity> findByCodeContainingIgnoreCaseOrderByUpdatedAtDesc(String code, Pageable pageable);
    List<ContainerJpaEntity> findByCodeContainingIgnoreCaseAndStatusOrderByUpdatedAtDesc(
            String code, String status, Pageable pageable
    );
}
