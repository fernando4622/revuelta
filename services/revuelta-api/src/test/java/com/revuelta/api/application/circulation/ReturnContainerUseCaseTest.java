package com.revuelta.api.application.circulation;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.circulation.CirculationId;
import com.revuelta.api.domain.circulation.Punctuality;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.user.UserId;
import com.revuelta.api.support.ImmediateTransactionRunner;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.function.Executable;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Duration;
import java.time.Instant;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ReturnContainerUseCaseTest {

    @Mock private ContainerRepositoryPort containerRepository;
    @Mock private CirculationRepositoryPort circulationRepository;
    @Mock private ContainerEventRepositoryPort eventRepository;

    private ReturnContainerUseCase returnContainerUseCase;

    private final ContainerId containerId = ContainerId.generate();
    private final CirculationId circulationId = CirculationId.generate();
    private final UserId borrowerId = UserId.generate();
    private final UserId operatorId = UserId.generate();
    private final Instant now = Instant.now();

    @BeforeEach
    void setUp() {
        returnContainerUseCase = new ReturnContainerUseCase(
                containerRepository,
                circulationRepository,
                eventRepository,
                new ImmediateTransactionRunner()
        );
    }

    @Test
    @DisplayName("SC-RET-001: On-time return finalizes circulation as ON_TIME and transitions container to AVAILABLE")
    void shouldFinalizeReturnOnTime() {
        Instant deliveredAt = now.minus(Duration.ofHours(5));
        Instant dueAt = now.plus(Duration.ofHours(43));

        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, deliveredAt, dueAt);
        Container container = Container.register(new ContainerCode("CTR-R1"), deliveredAt);
        container.transition(ContainerStatus.AVAILABLE, operatorId, "Activated", deliveredAt);
        container.transition(ContainerStatus.IN_USE, operatorId, "Delivered", deliveredAt);

        when(circulationRepository.findById(circulation.id())).thenReturn(Optional.of(circulation));
        when(containerRepository.findById(containerId)).thenReturn(Optional.of(container));

        var result = returnContainerUseCase.execute(circulation.id(), operatorId);

        assertFalse(result.circulation().isActive());
        assertEquals(Punctuality.ON_TIME, result.circulation().punctuality());
        assertEquals(ContainerStatus.AVAILABLE, result.container().status());

        verify(circulationRepository, times(1)).save(any());
        verify(containerRepository, times(1)).save(any());
        verify(eventRepository, times(1)).save(any());
    }

    @Test
    @DisplayName("SC-RET-002: Late return finalizes circulation as LATE")
    void shouldFinalizeReturnLate() {
        Instant deliveredAt = now.minus(Duration.ofHours(50));
        Instant dueAt = now.minus(Duration.ofHours(2));

        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, deliveredAt, dueAt);
        Container container = Container.register(new ContainerCode("CTR-R2"), deliveredAt);
        container.transition(ContainerStatus.AVAILABLE, operatorId, "Activated", deliveredAt);
        container.transition(ContainerStatus.IN_USE, operatorId, "Delivered", deliveredAt);

        when(circulationRepository.findById(circulation.id())).thenReturn(Optional.of(circulation));
        when(containerRepository.findById(containerId)).thenReturn(Optional.of(container));

        var result = returnContainerUseCase.execute(circulation.id(), operatorId);

        assertFalse(result.circulation().isActive());
        assertEquals(Punctuality.LATE, result.circulation().punctuality());
    }

    @Test
    @DisplayName("SC-RET-003: Return fails when circulation is not found")
    void shouldFailWhenCirculationNotFound() {
        when(circulationRepository.findById(circulationId)).thenReturn(Optional.empty());

        assertFailure(FailureCode.CIRCULATION_NOT_FOUND, () ->
                returnContainerUseCase.execute(circulationId, operatorId));
    }

    @Test
    void shouldFailWithStableCodeWhenReturnWasAlreadyRegistered() {
        Circulation circulation = Circulation.create(
                containerId,
                borrowerId,
                operatorId,
                now.minus(Duration.ofHours(2)),
                now.plus(Duration.ofHours(46))
        );
        circulation.finalize(operatorId, now);
        when(circulationRepository.findById(circulation.id())).thenReturn(Optional.of(circulation));

        assertFailure(FailureCode.RETURN_ALREADY_REGISTERED, () ->
                returnContainerUseCase.execute(circulation.id(), operatorId));
    }

    @Test
    void shouldFailWithStableCodeWhenContainerDoesNotExist() {
        Circulation circulation = Circulation.create(
                containerId,
                borrowerId,
                operatorId,
                now.minus(Duration.ofHours(2)),
                now.plus(Duration.ofHours(46))
        );
        when(circulationRepository.findById(circulation.id())).thenReturn(Optional.of(circulation));
        when(containerRepository.findById(containerId)).thenReturn(Optional.empty());

        assertFailure(FailureCode.CONTAINER_NOT_FOUND, () ->
                returnContainerUseCase.execute(circulation.id(), operatorId));
    }

    private void assertFailure(FailureCode code, Executable operation) {
        ApplicationFailureException failure = assertThrows(ApplicationFailureException.class, operation);
        assertEquals(code, failure.code());
    }
}
