package com.revuelta.api.infrastructure.persistence;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface SpringDataOperationQrTokenRepository
        extends JpaRepository<OperationQrTokenJpaEntity, UUID> {
}
