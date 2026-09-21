package com.revuelta.api.infrastructure.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface SpringDataParticipantRepository extends JpaRepository<ParticipantJpaEntity, UUID> {
    @Query(value = """
            SELECT p.*
            FROM participants p
            JOIN participant_accounts pa ON pa.participant_id = p.id
            WHERE pa.user_id = :accountId
            """, nativeQuery = true)
    Optional<ParticipantJpaEntity> findByAccountId(@Param("accountId") UUID accountId);
}
