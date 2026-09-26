package com.revuelta.api.application.container;

import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.application.query.PageResult;

public class ListContainersUseCase {

    private final ContainerRepositoryPort containerRepository;

    public ListContainersUseCase(ContainerRepositoryPort containerRepository) {
        this.containerRepository = containerRepository;
    }

    public PageResult<Container> execute(String query, ContainerStatus status, int page, int size) {
        PageResult.validate(page, size);
        var rows = containerRepository.search(normalize(query), status, page, size + 1);
        return PageResult.fromExtraRow(rows, page, size);
    }

    private String normalize(String query) {
        return query == null || query.isBlank() ? null : query.trim();
    }
}
