package com.revuelta.api.infrastructure.persistence;

import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.circulation.CirculationId;
import com.revuelta.api.domain.circulation.CirculationStatus;
import com.revuelta.api.domain.circulation.Punctuality;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.user.UserId;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class CirculationRepositoryAdapter implements CirculationRepositoryPort {

    private final SpringDataCirculationRepository repository;

    @Override
    public Circulation save(Circulation circulation) {
        CirculationJpaEntity entity = toEntity(circulation);
        CirculationJpaEntity saved = repository.save(entity);
        return toDomain(saved);
    }

    @Override
    public Optional<Circulation> findById(CirculationId id) {
        return repository.findById(id.value()).map(this::toDomain);
    }

    @Override
    public Optional<Circulation> findActiveByContainerId(ContainerId containerId) {
        return repository.findActiveByContainerId(containerId.value()).map(this::toDomain);
    }

    @Override
    public boolean hasActiveCirculation(ContainerId containerId) {
        return repository.hasActiveCirculation(containerId.value());
    }

    private CirculationJpaEntity toEntity(Circulation domain) {
        return new CirculationJpaEntity(
                domain.id().value(),
                domain.containerId().value(),
                domain.borrowerId().value(),
                domain.deliveredBy().value(),
                domain.deliveredAt(),
                domain.dueAt(),
                domain.returnedBy() != null ? domain.returnedBy().value() : null,
                domain.returnedAt(),
                domain.punctuality() != null ? domain.punctuality().name() : null,
                domain.status().name(),
                domain.deliveredAt()
        );
    }

    private Circulation toDomain(CirculationJpaEntity entity) {
        return new Circulation(
                new CirculationId(entity.getId()),
                new ContainerId(entity.getContainerId()),
                new UserId(entity.getBorrowerId()),
                new UserId(entity.getDeliveredBy()),
                entity.getDeliveredAt(),
                entity.getDueAt(),
                entity.getReturnedBy() != null ? new UserId(entity.getReturnedBy()) : null,
                entity.getReturnedAt(),
                entity.getPunctuality() != null ? Punctuality.valueOf(entity.getPunctuality()) : null,
                CirculationStatus.valueOf(entity.getStatus())
        );
    }
}
