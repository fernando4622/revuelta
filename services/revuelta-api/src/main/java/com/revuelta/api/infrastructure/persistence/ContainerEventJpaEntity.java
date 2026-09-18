package com.revuelta.api.infrastructure.persistence;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "container_events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ContainerEventJpaEntity {
    @Id
    private UUID id;

    @Column(name = "container_id", nullable = false)
    private UUID containerId;

    @Column(name = "event_type", nullable = false)
    private String eventType;

    @Column(name = "actor_id", nullable = false)
    private UUID actorId;

    @Column(name = "occurred_at", nullable = false)
    private Instant occurredAt;

    @Column(name = "previous_status")
    private String previousStatus;

    @Column(name = "new_status", nullable = false)
    private String newStatus;

    private String reason;
}
