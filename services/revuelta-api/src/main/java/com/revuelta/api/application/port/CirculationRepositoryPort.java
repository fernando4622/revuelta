package com.revuelta.api.application.port;

import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.circulation.CirculationId;
import com.revuelta.api.domain.container.ContainerId;

import java.util.Optional;

public interface CirculationRepositoryPort {
    Circulation save(Circulation circulation);
    Optional<Circulation> findById(CirculationId id);
    Optional<Circulation> findActiveByContainerId(ContainerId containerId);
    boolean hasActiveCirculation(ContainerId containerId);
}
