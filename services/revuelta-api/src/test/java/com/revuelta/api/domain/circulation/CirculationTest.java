package com.revuelta.api.domain.circulation;

import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.policy.ReturnPolicy;
import com.revuelta.api.domain.participant.ParticipantId;
import com.revuelta.api.domain.user.UserId;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class CirculationTest {

    private final ContainerId containerId = ContainerId.generate();
    private final ParticipantId borrowerId = new ParticipantId(UUID.randomUUID());
    private final UserId operatorId = UserId.generate();
    private final Instant now = Instant.now();
    private final ReturnPolicy policy = ReturnPolicy.defaultPolicy(now);
    private final Instant dueAt = policy.calculateDueAt(now);

    @Test
    @DisplayName("Should create active circulation with ON_TIME status pending return")
    void shouldCreateCirculation() {
        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, now, policy);

        assertNotNull(circulation.id());
        assertEquals(containerId, circulation.containerId());
        assertEquals(borrowerId, circulation.borrowerId());
        assertEquals(operatorId, circulation.deliveredBy());
        assertEquals(now, circulation.deliveredAt());
        assertEquals(dueAt, circulation.dueAt());
        assertEquals(policy.id(), circulation.returnPolicyId());
        assertEquals(policy.version(), circulation.returnPolicyVersion());
        assertTrue(circulation.isActive());
        assertNull(circulation.returnedAt());
        assertNull(circulation.punctuality());
    }

    @Test
    @DisplayName("Should classify return ON_TIME when returned before or at due timestamp")
    void shouldFinalizeOnTime() {
        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, now, policy);
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
        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, now, policy);
        Instant returnedAt = dueAt.plus(Duration.ofMinutes(1));

        circulation.finalize(operatorId, returnedAt);

        assertFalse(circulation.isActive());
        assertEquals(CirculationStatus.COMPLETED, circulation.status());
        assertEquals(Punctuality.LATE, circulation.punctuality());
    }

    @Test
    @DisplayName("Should reject return timestamp prior to delivery timestamp (BR-CIR-007)")
    void shouldRejectReturnBeforeDelivery() {
        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, now, policy);
        Instant invalidReturn = now.minusSeconds(60);

        assertThrows(IllegalArgumentException.class, () ->
                circulation.finalize(operatorId, invalidReturn)
        );
    }

    @Test
    @DisplayName("Should reject duplicate finalization on completed circulation (BR-CIR-008)")
    void shouldRejectDuplicateFinalization() {
        Circulation circulation = Circulation.create(containerId, borrowerId, operatorId, now, policy);
        circulation.finalize(operatorId, now.plus(Duration.ofHours(1)));

        assertThrows(CirculationTransitionException.class, () ->
                circulation.finalize(operatorId, now.plus(Duration.ofHours(2)))
        );
    }
}
