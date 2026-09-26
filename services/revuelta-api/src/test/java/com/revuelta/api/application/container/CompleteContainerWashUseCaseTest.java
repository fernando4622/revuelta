package com.revuelta.api.application.container;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.event.ContainerEventType;
import com.revuelta.api.domain.user.UserId;
import com.revuelta.api.support.ImmediateTransactionRunner;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.*;

class CompleteContainerWashUseCaseTest {
    private final ContainerRepositoryPort containers = mock(ContainerRepositoryPort.class);
    private final CirculationRepositoryPort circulations = mock(CirculationRepositoryPort.class);
    private final ContainerEventRepositoryPort events = mock(ContainerEventRepositoryPort.class);
    private final Instant now = Instant.parse("2026-09-26T18:00:00Z");
    private final UUID traceId = UUID.randomUUID();
    private final UserId actorId = UserId.generate();

    @Test
    void shouldMakeReturnedContainerAvailableAndRecordOneWashEvent() {
        Container container = container(ContainerStatus.RETURNED);
        when(containers.findById(container.id())).thenReturn(Optional.of(container));
        when(circulations.hasActiveCirculation(container.id())).thenReturn(false);
        when(containers.save(container)).thenReturn(container);

        var result = useCase().execute(container.id(), actorId);

        assertEquals(ContainerStatus.AVAILABLE, result.container().status());
        assertEquals(now, result.washedAt());
        assertEquals(traceId, result.traceId());
        verify(events, times(1)).save(argThat(event ->
                event.eventType() == ContainerEventType.WASH_COMPLETED
                        && event.actorId().equals(actorId)
                        && event.occurredAt().equals(now)
        ));
    }

    @Test
    void shouldRejectSequentialReplayWithStableFailure() {
        Container container = container(ContainerStatus.AVAILABLE);
        when(containers.findById(container.id())).thenReturn(Optional.of(container));
        when(events.existsByContainerIdAndType(container.id(), ContainerEventType.WASH_COMPLETED))
                .thenReturn(true);

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> useCase().execute(container.id(), actorId)
        );

        assertEquals(FailureCode.WASH_ALREADY_COMPLETED, failure.code());
        verify(containers, never()).save(any());
        verify(events, never()).save(any());
    }

    @Test
    void shouldRejectContainerThatIsNotPendingWashing() {
        Container container = container(ContainerStatus.IN_USE);
        when(containers.findById(container.id())).thenReturn(Optional.of(container));

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> useCase().execute(container.id(), actorId)
        );

        assertEquals(FailureCode.CONTAINER_NOT_RETURNED, failure.code());
    }

    private CompleteContainerWashUseCase useCase() {
        return new CompleteContainerWashUseCase(
                containers, circulations, events, new ImmediateTransactionRunner(),
                () -> now, () -> traceId
        );
    }

    private Container container(ContainerStatus status) {
        return new Container(
                ContainerId.generate(), new ContainerCode("CTR-WASH"), status,
                now.minusSeconds(3600), now.minusSeconds(60), 1, 0
        );
    }
}
