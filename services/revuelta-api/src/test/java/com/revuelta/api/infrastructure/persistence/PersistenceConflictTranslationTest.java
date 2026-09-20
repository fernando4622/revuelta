package com.revuelta.api.infrastructure.persistence;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.policy.ReturnPolicy;
import com.revuelta.api.domain.user.UserId;
import java.sql.SQLException;
import java.time.Instant;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.ObjectOptimisticLockingFailureException;

class PersistenceConflictTranslationTest {

    private final Instant now = Instant.parse("2026-09-20T18:00:00Z");

    @Test
    void shouldTranslateConcurrentActiveCirculationConstraintToStableConflict() {
        SpringDataCirculationRepository repository = mock(SpringDataCirculationRepository.class);
        when(repository.saveAndFlush(any())).thenThrow(new DataIntegrityViolationException(
                "constraint",
                new SQLException("duplicate key violates idx_circulations_active_container")
        ));
        Circulation circulation = Circulation.create(
                ContainerId.generate(),
                UserId.generate(),
                UserId.generate(),
                now,
                ReturnPolicy.defaultPolicy(now)
        );

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> new CirculationRepositoryAdapter(repository).save(circulation)
        );

        assertEquals(FailureCode.ACTIVE_CIRCULATION_EXISTS, failure.code());
    }

    @Test
    void shouldTranslateStaleCirculationWriteToAlreadyReturnedConflict() {
        SpringDataCirculationRepository repository = mock(SpringDataCirculationRepository.class);
        when(repository.saveAndFlush(any())).thenThrow(new ObjectOptimisticLockingFailureException(
                CirculationJpaEntity.class,
                UUID.randomUUID()
        ));
        Circulation circulation = Circulation.create(
                ContainerId.generate(),
                UserId.generate(),
                UserId.generate(),
                now,
                ReturnPolicy.defaultPolicy(now)
        );

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> new CirculationRepositoryAdapter(repository).save(circulation)
        );

        assertEquals(FailureCode.RETURN_ALREADY_REGISTERED, failure.code());
    }

    @Test
    void shouldTranslateContainerCodeConstraintToStableConflict() {
        SpringDataContainerRepository repository = mock(SpringDataContainerRepository.class);
        when(repository.saveAndFlush(any())).thenThrow(new DataIntegrityViolationException(
                "constraint",
                new SQLException("duplicate key violates containers_code_key")
        ));
        Container container = Container.register(new ContainerCode("CTR-DUP"), now);

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> new ContainerRepositoryAdapter(repository).save(container)
        );

        assertEquals(FailureCode.CONTAINER_CODE_ALREADY_EXISTS, failure.code());
    }
}
