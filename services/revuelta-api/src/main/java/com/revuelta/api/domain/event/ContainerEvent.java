package com.revuelta.api.domain.event;

import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.user.UserId;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

public record ContainerEvent(
        UUID id,
        ContainerId containerId,
        ContainerEventType eventType,
        UserId actorId,
        Instant occurredAt,
        ContainerStatus previousStatus,
        ContainerStatus newStatus,
        String reason
) {
    public ContainerEvent {
        Objects.requireNonNull(id, "Event id must not be null");
        Objects.requireNonNull(containerId, "ContainerId must not be null");
        Objects.requireNonNull(eventType, "ContainerEventType must not be null");
        Objects.requireNonNull(actorId, "ActorId must not be null");
        Objects.requireNonNull(occurredAt, "OccurredAt must not be null");
        Objects.requireNonNull(newStatus, "NewStatus must not be null");
    }
}
