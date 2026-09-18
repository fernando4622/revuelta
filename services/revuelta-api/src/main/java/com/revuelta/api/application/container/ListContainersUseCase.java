package com.revuelta.api.application.container;

import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.container.Container;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ListContainersUseCase {

    private final ContainerRepositoryPort containerRepository;

    public List<Container> execute(int page, int size) {
        return containerRepository.findAll(page, size);
    }
}
