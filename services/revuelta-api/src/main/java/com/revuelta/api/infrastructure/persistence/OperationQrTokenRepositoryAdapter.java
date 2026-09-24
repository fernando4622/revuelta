package com.revuelta.api.infrastructure.persistence;

import com.revuelta.api.application.port.OperationQrTokenRepositoryPort;
import com.revuelta.api.domain.participant.OperationQrPurpose;
import com.revuelta.api.domain.participant.OperationQrToken;
import com.revuelta.api.domain.participant.ParticipantId;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.orm.ObjectOptimisticLockingFailureException;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;

import java.util.Optional;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class OperationQrTokenRepositoryAdapter implements OperationQrTokenRepositoryPort {
    private final SpringDataOperationQrTokenRepository repository;

    @Override
    public OperationQrToken save(OperationQrToken token) {
        try {
            return toDomain(repository.saveAndFlush(toEntity(token)));
        } catch (ObjectOptimisticLockingFailureException exception) {
            throw new ApplicationFailureException(
                    FailureCode.QR_ALREADY_USED,
                    "Participant operation QR was consumed concurrently"
            );
        }
    }

    @Override
    public Optional<OperationQrToken> findById(UUID id) {
        return repository.findById(id).map(this::toDomain);
    }

    @Override
    public Optional<OperationQrToken> findByIdForUpdate(UUID id) {
        return repository.findByIdForUpdate(id).map(this::toDomain);
    }

    private OperationQrTokenJpaEntity toEntity(OperationQrToken token) {
        return new OperationQrTokenJpaEntity(
                token.id(), token.participantId().value(), token.purpose().name(),
                token.issuedAt(), token.expiresAt(), token.consumedAt(),
                token.circulationId(), token.version()
        );
    }

    private OperationQrToken toDomain(OperationQrTokenJpaEntity entity) {
        return new OperationQrToken(
                entity.getId(), new ParticipantId(entity.getParticipantId()),
                OperationQrPurpose.valueOf(entity.getPurpose()), entity.getIssuedAt(),
                entity.getExpiresAt(), entity.getConsumedAt(), entity.getCirculationId(),
                entity.getVersion()
        );
    }
}
