package com.revuelta.api.infrastructure.persistence;

import com.revuelta.api.application.port.ParticipantRepositoryPort;
import com.revuelta.api.domain.participant.Participant;
import com.revuelta.api.domain.participant.ParticipantId;
import com.revuelta.api.domain.user.UserId;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class ParticipantRepositoryAdapter implements ParticipantRepositoryPort {
    private final SpringDataParticipantRepository repository;

    @Override
    public Optional<Participant> findById(ParticipantId id) {
        return repository.findById(id.value()).map(this::toDomain);
    }

    @Override
    public Optional<Participant> findByAccountId(UserId accountId) {
        return repository.findByAccountId(accountId.value()).map(this::toDomain);
    }

    private Participant toDomain(ParticipantJpaEntity entity) {
        return new Participant(
                new ParticipantId(entity.getId()), entity.isActive(), entity.getCreatedAt()
        );
    }
}
