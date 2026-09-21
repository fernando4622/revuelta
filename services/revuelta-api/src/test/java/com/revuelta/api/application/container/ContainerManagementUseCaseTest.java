package com.revuelta.api.application.container;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.user.UserId;
import com.revuelta.api.support.ImmediateTransactionRunner;
import java.util.Optional;
import java.time.Instant;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class ContainerManagementUseCaseTest {

    private final ContainerRepositoryPort containers = mock(ContainerRepositoryPort.class);
    private final ContainerEventRepositoryPort events = mock(ContainerEventRepositoryPort.class);
    private final Instant now = Instant.parse("2026-09-20T18:00:00Z");
    private final UUID correlationId = UUID.randomUUID();

    @Test
    void shouldRejectDuplicateContainerCodeWithStableConflict() {
        when(containers.existsByCode(new ContainerCode("CTR-DUP"))).thenReturn(true);
        RegisterContainerUseCase useCase = new RegisterContainerUseCase(
                containers,
                new ImmediateTransactionRunner(),
                () -> now,
                events,
                () -> correlationId,
                mock(QrPayloadCodecPort.class)
        );

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> useCase.execute("CTR-DUP", UserId.generate())
        );

        assertEquals(FailureCode.CONTAINER_CODE_ALREADY_EXISTS, failure.code());
    }

    @Test
    void shouldRejectActivationOfUnknownContainerWithStableNotFoundFailure() {
        ContainerId id = ContainerId.generate();
        when(containers.findById(id)).thenReturn(Optional.empty());
        ActivateContainerUseCase useCase = new ActivateContainerUseCase(
                containers,
                events,
                new ImmediateTransactionRunner(),
                () -> now,
                () -> correlationId
        );

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> useCase.execute(id, UserId.generate(), "Activation")
        );

        assertEquals(FailureCode.CONTAINER_NOT_FOUND, failure.code());
    }

    @Test
    void shouldRejectLookupOfUnknownContainerWithStableNotFoundFailure() {
        ContainerId id = ContainerId.generate();
        when(containers.findById(id)).thenReturn(Optional.empty());

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> new GetContainerUseCase(containers).execute(id)
        );

        assertEquals(FailureCode.CONTAINER_NOT_FOUND, failure.code());
    }
}
