package com.revuelta.api.infrastructure.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface SpringDataReturnPolicyRepository extends JpaRepository<ReturnPolicyJpaEntity, UUID> {
    Optional<ReturnPolicyJpaEntity> findFirstByActiveTrueOrderByCreatedAtDesc();
}
