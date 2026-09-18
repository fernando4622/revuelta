package com.revuelta.api.domain.circulation;

import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.user.UserId;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.time.Instant;

import static org.junit.jupiter.api.Assertions.*;

class CirculationTest {

    private final ContainerId containerId = ContainerId.generate();
    private final UserId borrowerId = UserId.generate();
    private final UserId operatorId = UserId.generate();
    private final Instant now = Instant.now();
    private final Instant dueAt = now.plus(Duration.ofHours(48));

    @Test
    @DisplayName("Should create active circulation with ON_TIME status pending return")
    void shouldCreateCirculation() {
        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, now, dueAt);

        assertNotNull(circulation.id());
        assertEquals(containerId, circulation.containerId());
        assertEquals(borrowerId, circulation.borrowerId());
        assertEquals(operatorId, circulation.deliveredBy());
        assertEquals(now, circulation.deliveredAt());
        assertEquals(dueAt, circulation.dueAt());
        assertTrue(circulation.isActive());
        assertNull(circulation.returnedAt());
        assertNull(circulation.punctuality());
    }

    @Test
    @DisplayName("Should classify return ON_TIME when returned before or at due timestamp")
    void shouldFinalizeOnTime() {
        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, now, dueAt);
        Instant returnedAt = now.plus(Duration.ofHours(24));

        circulation.finalize(operatorId, returnedAt);

        assertFalse(circulation.isActive());
        assertEquals(CirculationStatus.COMPLETED, circulation.status());
        assertEquals(Punctuality.ON_TIME, circulation.punctuality());
        assertEquals(returnedAt, circulation.returnedAt());
        assertEquals(operatorId, circulation.returnedBy());
    }

    @Test
    @DisplayName("Should classify return LATE when returned after due timestamp")
    void shouldFinalizeLate() {
        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, now, dueAt);
        Instant returnedAt = dueAt.plus(Duration.ofMinutes(1));

        circulation.finalize(operatorId, returnedAt);

        assertFalse(circulation.isActive());
        assertEquals(CirculationStatus.COMPLETED, circulation.status());
        assertEquals(Punctuality.LATE, circulation.punctuality());
    }

    @Test
    @DisplayName("Should reject return timestamp prior to delivery timestamp (BR-CIR-007)")
    void shouldRejectReturnBeforeDelivery() {
        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, now, dueAt);
        Instant invalidReturn = now.minusSeconds(60);

        assertThrows(IllegalArgumentException.class, () ->
                circulation.finalize(operatorId, invalidReturn)
        );
    }

    @Test
    @DisplayName("Should reject duplicate finalization on completed circulation (BR-CIR-008)")
    void shouldRejectDuplicateFinalization() {
        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, now, dueAt);
        circulation.finalize(operatorId, now.plus(Duration.ofHours(1)));

        assertThrows(IllegalStateException.class, () ->
                circulation.finalize(operatorId, now.plus(Duration.ofHours(2)))
        );
    }
}
