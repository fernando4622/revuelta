package com.revuelta.api.application.circulation;

import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.ReturnPolicyRepositoryPort;
import com.revuelta.api.application.port.UserRepositoryPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.policy.ReturnPolicy;
import com.revuelta.api.domain.user.UserId;
import com.revuelta.api.support.ImmediateTransactionRunner;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DeliverContainerUseCaseTest {

    @Mock private ContainerRepositoryPort containerRepository;
    @Mock private CirculationRepositoryPort circulationRepository;
    @Mock private UserRepositoryPort userRepository;
    @Mock private ReturnPolicyRepositoryPort policyRepository;
    @Mock private ContainerEventRepositoryPort eventRepository;

    private DeliverContainerUseCase deliverContainerUseCase;

    private final ContainerId containerId = ContainerId.generate();
    private final UserId borrowerId = UserId.generate();
    private final UserId operatorId = UserId.generate();
    private final Instant now = Instant.now();

    @BeforeEach
    void setUp() {
        deliverContainerUseCase = new DeliverContainerUseCase(
                containerRepository,
                circulationRepository,
                userRepository,
                policyRepository,
                eventRepository,
                new ImmediateTransactionRunner()
        );
    }

    @Test
    @DisplayName("SC-DEL-001: Successful delivery transitions container to IN_USE and creates active circulation")
    void shouldDeliverContainerSuccessfully() {
        Container container = Container.register(new ContainerCode("CTR-001"), now);
        container.transition(ContainerStatus.AVAILABLE, operatorId, "Activated", now);

        when(containerRepository.findById(containerId)).thenReturn(Optional.of(container));
        when(userRepository.existsById(borrowerId)).thenReturn(true);
        when(circulationRepository.hasActiveCirculation(containerId)).thenReturn(false);
        when(policyRepository.findActivePolicy()).thenReturn(Optional.of(ReturnPolicy.defaultPolicy(now)));

        var result = deliverContainerUseCase.execute(containerId, borrowerId, operatorId);

        assertNotNull(result.circulation());
        assertEquals(ContainerStatus.IN_USE, result.container().status());
        assertEquals(borrowerId, result.circulation().borrowerId());
        assertEquals(operatorId, result.circulation().deliveredBy());
        assertTrue(result.circulation().isActive());

        verify(circulationRepository, times(1)).save(any());
        verify(containerRepository, times(1)).save(any());
        verify(eventRepository, times(1)).save(any());
    }

    @Test
    @DisplayName("SC-DEL-003: Deliver fails when container is not in AVAILABLE status")
    void shouldFailWhenContainerNotAvailable() {
        Container container = Container.register(new ContainerCode("CTR-002"), now);

        when(containerRepository.findById(containerId)).thenReturn(Optional.of(container));

        assertThrows(IllegalStateException.class, () ->
                deliverContainerUseCase.execute(containerId, borrowerId, operatorId)
        );

        verify(circulationRepository, never()).save(any());
    }

    @Test
    @DisplayName("SC-DEL-004: Deliver fails when active circulation already exists for container")
    void shouldFailWhenActiveCirculationExists() {
        Container container = Container.register(new ContainerCode("CTR-003"), now);
        container.transition(ContainerStatus.AVAILABLE, operatorId, "Activated", now);

        when(containerRepository.findById(containerId)).thenReturn(Optional.of(container));
        when(userRepository.existsById(borrowerId)).thenReturn(true);
        when(circulationRepository.hasActiveCirculation(containerId)).thenReturn(true);

        assertThrows(IllegalStateException.class, () ->
                deliverContainerUseCase.execute(containerId, borrowerId, operatorId)
        );

        verify(circulationRepository, never()).save(any());
    }
}
