package com.revuelta.api.application.port;

import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.circulation.CirculationId;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.circulation.CirculationStatus;
import com.revuelta.api.domain.participant.ParticipantId;

import java.util.List;
import java.util.Optional;

public interface CirculationRepositoryPort {
    Circulation save(Circulation circulation);
    Optional<Circulation> findById(CirculationId id);
    Optional<Circulation> findByIdAndBorrowerId(CirculationId id, ParticipantId borrowerId);
    Optional<Circulation> findActiveByContainerId(ContainerId containerId);
    List<Circulation> findByBorrowerId(ParticipantId borrowerId, CirculationStatus status, int page, int size);
    List<Circulation> findAll(CirculationStatus status, int page, int size);
    long countByStatus(CirculationStatus status);
    boolean hasActiveCirculation(ContainerId containerId);
}
