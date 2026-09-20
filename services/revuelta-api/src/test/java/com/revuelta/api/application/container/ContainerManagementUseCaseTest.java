package com.revuelta.api.application.container;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.user.UserId;
import com.revuelta.api.support.ImmediateTransactionRunner;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class ContainerManagementUseCaseTest {

    private final ContainerRepositoryPort containers = mock(ContainerRepositoryPort.class);
    private final ContainerEventRepositoryPort events = mock(ContainerEventRepositoryPort.class);

    @Test
    void shouldRejectDuplicateContainerCodeWithStableConflict() {
        when(containers.existsByCode(new ContainerCode("CTR-DUP"))).thenReturn(true);
        RegisterContainerUseCase useCase = new RegisterContainerUseCase(containers, new ImmediateTransactionRunner());

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> useCase.execute("CTR-DUP")
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
                new ImmediateTransactionRunner()
        );

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> useCase.execute(id, UserId.generate(), "Activation")
        );

        assertEquals(FailureCode.CONTAINER_NOT_FOUND, failure.code());
    }
}
