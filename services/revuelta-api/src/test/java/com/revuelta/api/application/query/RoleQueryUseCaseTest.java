package com.revuelta.api.application.query;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.ParticipantRepositoryPort;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.circulation.CirculationId;
import com.revuelta.api.domain.circulation.CirculationStatus;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.event.ContainerEventType;
import com.revuelta.api.domain.participant.Participant;
import com.revuelta.api.domain.participant.ParticipantId;
import com.revuelta.api.domain.user.UserId;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class RoleQueryUseCaseTest {
    private final Instant now = Instant.parse("2026-09-26T18:00:00Z");

    @Test
    void shouldResolveParticipantFromSessionAndReturnOnlyOwnedCirculations() {
        var participants = mock(ParticipantRepositoryPort.class);
        var circulations = mock(CirculationRepositoryPort.class);
        var containers = mock(ContainerRepositoryPort.class);
        UserId accountId = UserId.generate();
        Participant participant = new Participant(new ParticipantId(UUID.randomUUID()), true, now.minusSeconds(3600));
        Circulation circulation = circulation(participant.id());
        Container container = container(circulation.containerId(), ContainerStatus.IN_USE);
        when(participants.findByAccountId(accountId)).thenReturn(Optional.of(participant));
        when(circulations.findByBorrowerId(participant.id(), CirculationStatus.ACTIVE, 0, 21))
                .thenReturn(List.of(circulation));
        when(containers.findById(container.id())).thenReturn(Optional.of(container));

        var result = new ParticipantCirculationQueryUseCase(participants, circulations, containers)
                .list(accountId, CirculationStatus.ACTIVE, 0, 20);

        assertEquals(1, result.items().size());
        assertEquals(participant.id().value(), circulation.borrowerId().value());
        assertEquals("En uso", result.items().get(0).stateLabel());
        verify(circulations).findByBorrowerId(participant.id(), CirculationStatus.ACTIVE, 0, 21);
    }

    @Test
    void shouldHideAnotherParticipantsCirculationAsNotFound() {
        var participants = mock(ParticipantRepositoryPort.class);
        var circulations = mock(CirculationRepositoryPort.class);
        UserId accountId = UserId.generate();
        Participant participant = new Participant(new ParticipantId(UUID.randomUUID()), true, now);
        CirculationId requested = CirculationId.generate();
        when(participants.findByAccountId(accountId)).thenReturn(Optional.of(participant));
        when(circulations.findByIdAndBorrowerId(requested, participant.id())).thenReturn(Optional.empty());

        var query = new ParticipantCirculationQueryUseCase(
                participants, circulations, mock(ContainerRepositoryPort.class)
        );
        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class, () -> query.get(accountId, requested)
        );

        assertEquals(FailureCode.CIRCULATION_NOT_FOUND, failure.code());
        verify(circulations, never()).findById(any());
    }

    @Test
    void shouldListOnlyReturnedContainersInPendingWashQueue() {
        var containers = mock(ContainerRepositoryPort.class);
        var events = mock(ContainerEventRepositoryPort.class);
        Container returned = container(ContainerId.generate(), ContainerStatus.RETURNED);
        ContainerEvent event = new ContainerEvent(
                UUID.randomUUID(), returned.id(), ContainerEventType.RETURNED, UserId.generate(), now,
                ContainerStatus.IN_USE, ContainerStatus.RETURNED, "Returned", UUID.randomUUID(), null, null
        );
        when(containers.search(null, ContainerStatus.RETURNED, 0, 21)).thenReturn(List.of(returned));
        when(events.findLatestByContainerIdAndType(returned.id(), ContainerEventType.RETURNED))
                .thenReturn(Optional.of(event));

        var result = new OperatorQueueQueryUseCase(containers, events).execute(0, 20);

        assertEquals(1, result.items().size());
        assertEquals("Pendiente de lavado", result.items().get(0).stateLabel());
        assertEquals(now, result.items().get(0).returnedAt());
    }

    @Test
    void shouldDeriveOperationsSummaryFromPersistedCounts() {
        var containers = mock(ContainerRepositoryPort.class);
        var circulations = mock(CirculationRepositoryPort.class);
        when(containers.countAll()).thenReturn(9L);
        for (ContainerStatus status : ContainerStatus.values()) {
            when(containers.countByStatus(status)).thenReturn(status == ContainerStatus.AVAILABLE ? 4L : 0L);
        }
        when(circulations.countByStatus(CirculationStatus.ACTIVE)).thenReturn(2L);

        var summary = new OperationsSummaryQueryUseCase(containers, circulations).execute();

        assertEquals(9, summary.totalContainers());
        assertEquals(4, summary.available());
        assertEquals(2, summary.activeCirculations());
    }

    private Circulation circulation(ParticipantId borrowerId) {
        return new Circulation(
                CirculationId.generate(), ContainerId.generate(), borrowerId, UserId.generate(),
                now.minusSeconds(1800), now.plusSeconds(3600), UUID.randomUUID(), 1,
                null, null, null, CirculationStatus.ACTIVE, 0
        );
    }

    private Container container(ContainerId id, ContainerStatus status) {
        return new Container(
                id, new ContainerCode("CTR-QUERY"), status,
                now.minusSeconds(3600), now, 1, 0
        );
    }
}
