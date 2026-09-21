package com.revuelta.api.application.port;

import com.revuelta.api.domain.participant.Participant;
import com.revuelta.api.domain.participant.ParticipantId;
import com.revuelta.api.domain.user.UserId;

import java.util.Optional;

public interface ParticipantRepositoryPort {
    Optional<Participant> findById(ParticipantId id);
    Optional<Participant> findByAccountId(UserId accountId);
}
