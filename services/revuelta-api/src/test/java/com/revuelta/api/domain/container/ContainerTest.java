package com.revuelta.api.domain.container;

import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventType;
import com.revuelta.api.domain.user.UserId;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class ContainerTest {

    private final UserId actor = UserId.generate();
    private final Instant now = Instant.now();
    private final UUID correlationId = UUID.randomUUID();

    @Test
    @DisplayName("Should register container in REGISTERED status")
    void shouldRegisterContainer() {
        ContainerCode code = new ContainerCode("CTR-100");
        Container container = Container.register(code, now);

        assertNotNull(container.id());
        assertEquals(code, container.code());
        assertEquals(ContainerStatus.REGISTERED, container.status());
        assertFalse(container.isEligibleForCirculation());
    }

    @Test
    @DisplayName("Should perform valid transition REGISTERED -> AVAILABLE and emit event")
    void shouldTransitionToAvailable() {
        Container container = Container.register(new ContainerCode("CTR-101"), now);

        ContainerEvent event = container.transition(
                ContainerStatus.AVAILABLE,
                actor,
                "Initial activation",
                now,
                correlationId
        );

        assertEquals(ContainerStatus.AVAILABLE, container.status());
        assertTrue(container.isEligibleForCirculation());
        assertEquals(ContainerEventType.ACTIVATED, event.eventType());
        assertEquals(ContainerStatus.REGISTERED, event.previousStatus());
        assertEquals(ContainerStatus.AVAILABLE, event.newStatus());
        assertEquals(correlationId, event.correlationId());
    }

    @Test
    @DisplayName("Should reject invalid transition REGISTERED -> IN_USE")
    void shouldRejectInvalidTransition() {
        Container container = Container.register(new ContainerCode("CTR-102"), now);

        assertThrows(ContainerTransitionException.class, () ->
                container.transition(ContainerStatus.IN_USE, actor, "Bypass activation", now, correlationId)
        );
        assertEquals(ContainerStatus.REGISTERED, container.status());
    }

    @Test
    @DisplayName("Should handle full cycle AVAILABLE -> IN_USE -> RETURNED -> AVAILABLE")
    void shouldCompleteFullOperationalCycle() {
        Container container = Container.register(new ContainerCode("CTR-103"), now);
        container.transition(ContainerStatus.AVAILABLE, actor, "Activated", now, correlationId);

        // Deliver
        ContainerEvent deliverEvent = container.transition(
                ContainerStatus.IN_USE,
                actor,
                "Delivered",
                now,
                correlationId
        );
        assertEquals(ContainerStatus.IN_USE, container.status());
        assertEquals(ContainerEventType.DELIVERED, deliverEvent.eventType());

        // Return
        ContainerEvent returnEvent = container.transition(
                ContainerStatus.RETURNED,
                actor,
                "Returned",
                now,
                correlationId
        );
        assertEquals(ContainerStatus.RETURNED, container.status());
        assertEquals(ContainerEventType.RETURNED, returnEvent.eventType());

        // Wash completed
        ContainerEvent washEvent = container.transition(
                ContainerStatus.AVAILABLE,
                actor,
                "Wash completed",
                now,
                correlationId
        );
        assertEquals(ContainerStatus.AVAILABLE, container.status());
        assertEquals(ContainerEventType.WASH_COMPLETED, washEvent.eventType());
    }

    @Test
    @DisplayName("RETIRED status should be terminal and reject any transition")
    void retiredStatusShouldBeTerminal() {
        Container container = Container.register(new ContainerCode("CTR-104"), now);
        container.transition(ContainerStatus.AVAILABLE, actor, "Activated", now, correlationId);
        container.transition(ContainerStatus.DAMAGED, actor, "Broken handle", now, correlationId);
        container.transition(ContainerStatus.RETIRED, actor, "Scrapped", now, correlationId);

        assertThrows(ContainerTransitionException.class, () ->
                container.transition(ContainerStatus.AVAILABLE, actor, "Reactivate", now, correlationId)
        );
    }
}
