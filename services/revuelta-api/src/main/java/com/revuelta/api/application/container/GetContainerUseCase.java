package com.revuelta.api.application.container;

import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class GetContainerUseCase {

    private final ContainerRepositoryPort containerRepository;

    public Optional<Container> findById(ContainerId id) {
        return containerRepository.findById(id);
    }

    public Optional<Container> findByCode(ContainerCode code) {
        return containerRepository.findByCode(code);
    }
}
