package com.revuelta.api.infrastructure.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;
import java.util.UUID;

@Repository
public interface SpringDataCirculationRepository extends JpaRepository<CirculationJpaEntity, UUID> {
    @Query("SELECT c FROM CirculationJpaEntity c WHERE c.containerId = :containerId AND c.status = 'ACTIVE'")
    Optional<CirculationJpaEntity> findActiveByContainerId(@Param("containerId") UUID containerId);

    @Query("SELECT COUNT(c) > 0 FROM CirculationJpaEntity c WHERE c.containerId = :containerId AND c.status = 'ACTIVE'")
    boolean hasActiveCirculation(@Param("containerId") UUID containerId);

    Optional<CirculationJpaEntity> findByIdAndBorrowerId(UUID id, UUID borrowerId);

    @Query("""
            SELECT c FROM CirculationJpaEntity c
            WHERE c.borrowerId = :borrowerId
              AND (:status IS NULL OR c.status = :status)
            ORDER BY c.deliveredAt DESC
            """)
    List<CirculationJpaEntity> findByBorrower(
            @Param("borrowerId") UUID borrowerId,
            @Param("status") String status,
            Pageable pageable
    );

    @Query("""
            SELECT c FROM CirculationJpaEntity c
            WHERE (:status IS NULL OR c.status = :status)
            ORDER BY c.deliveredAt DESC
            """)
    List<CirculationJpaEntity> search(@Param("status") String status, Pageable pageable);

    long countByStatus(String status);
}
