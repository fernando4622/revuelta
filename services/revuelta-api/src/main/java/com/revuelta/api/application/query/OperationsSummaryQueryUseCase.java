package com.revuelta.api.application.query;

import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.circulation.CirculationStatus;
import com.revuelta.api.domain.container.ContainerStatus;

public class OperationsSummaryQueryUseCase {
    private final ContainerRepositoryPort containers;
    private final CirculationRepositoryPort circulations;

    public OperationsSummaryQueryUseCase(ContainerRepositoryPort containers, CirculationRepositoryPort circulations) {
        this.containers = containers;
        this.circulations = circulations;
    }

    public Summary execute() {
        return new Summary(
                containers.countAll(),
                containers.countByStatus(ContainerStatus.REGISTERED),
                containers.countByStatus(ContainerStatus.AVAILABLE),
                containers.countByStatus(ContainerStatus.IN_USE),
                containers.countByStatus(ContainerStatus.RETURNED),
                containers.countByStatus(ContainerStatus.DAMAGED),
                containers.countByStatus(ContainerStatus.LOST),
                containers.countByStatus(ContainerStatus.RETIRED),
                circulations.countByStatus(CirculationStatus.ACTIVE)
        );
    }

    public record Summary(
            long totalContainers, long registered, long available, long inUse,
            long returned, long damaged, long lost, long retired, long activeCirculations
    ) {}
}
