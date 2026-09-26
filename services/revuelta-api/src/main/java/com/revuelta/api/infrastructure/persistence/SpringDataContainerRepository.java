package com.revuelta.api.infrastructure.persistence;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SpringDataContainerRepository extends JpaRepository<ContainerJpaEntity, UUID> {
    Optional<ContainerJpaEntity> findByCode(String code);
    boolean existsByCode(String code);
    long countByStatus(String status);

    @Query("""
            SELECT c FROM ContainerJpaEntity c
            WHERE (:query IS NULL OR LOWER(c.code) LIKE LOWER(CONCAT('%', :query, '%')))
              AND (:status IS NULL OR c.status = :status)
            ORDER BY c.updatedAt DESC
            """)
    List<ContainerJpaEntity> search(
            @Param("query") String query,
            @Param("status") String status,
            Pageable pageable
    );
}
