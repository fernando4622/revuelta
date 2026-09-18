package com.revuelta.api.application.container;

import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
@RequiredArgsConstructor
public class RegisterContainerUseCase {

    private final ContainerRepositoryPort containerRepository;

    @Transactional
    public Container execute(String code) {
        ContainerCode containerCode = new ContainerCode(code);
        if (containerRepository.existsByCode(containerCode)) {
            throw new IllegalArgumentException("Container code already exists: " + code);
        }

        Container container = Container.register(containerCode, Instant.now());
        return containerRepository.save(container);
    }
}
