package com.revuelta.api.infrastructure.persistence;

import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Component;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.ObjectOptimisticLockingFailureException;

import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class ContainerRepositoryAdapter implements ContainerRepositoryPort {

    private final SpringDataContainerRepository repository;

    @Override
    public Container save(Container container) {
        ContainerJpaEntity entity = toEntity(container);
        try {
            ContainerJpaEntity saved = repository.saveAndFlush(entity);
            return toDomain(saved);
        } catch (ObjectOptimisticLockingFailureException exception) {
            throw new ApplicationFailureException(
                    FailureCode.INVALID_STATE_TRANSITION,
                    "The container was changed by another operation"
            );
        } catch (DataIntegrityViolationException exception) {
            if (mostSpecificMessage(exception).contains("containers_code_key")) {
                throw new ApplicationFailureException(
                        FailureCode.CONTAINER_CODE_ALREADY_EXISTS,
                        "Container code already exists"
                );
            }
            throw exception;
        }
    }

    @Override
    public Optional<Container> findById(ContainerId id) {
        return repository.findById(id.value()).map(this::toDomain);
    }

    @Override
    public Optional<Container> findByCode(ContainerCode code) {
        return repository.findByCode(code.value()).map(this::toDomain);
    }

    @Override
    public List<Container> findAll(int page, int size) {
        return repository.findAll(PageRequest.of(page, size))
                .getContent()
                .stream()
                .map(this::toDomain)
                .toList();
    }

    @Override
    public boolean existsByCode(ContainerCode code) {
        return repository.existsByCode(code.value());
    }

    private ContainerJpaEntity toEntity(Container domain) {
        return new ContainerJpaEntity(
                domain.id().value(),
                domain.code().value(),
                domain.status().name(),
                domain.createdAt(),
                domain.updatedAt(),
                domain.version()
        );
    }

    private Container toDomain(ContainerJpaEntity entity) {
        return new Container(
                new ContainerId(entity.getId()),
                new ContainerCode(entity.getCode()),
                ContainerStatus.valueOf(entity.getStatus()),
                entity.getCreatedAt(),
                entity.getUpdatedAt(),
                entity.getVersion()
        );
    }

    private String mostSpecificMessage(DataIntegrityViolationException exception) {
        Throwable cause = exception.getMostSpecificCause();
        return cause.getMessage() == null ? "" : cause.getMessage();
    }
}
