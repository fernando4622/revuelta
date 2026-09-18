package com.revuelta.api.infrastructure.persistence;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "circulations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CirculationJpaEntity {
    @Id
    private UUID id;

    @Column(name = "container_id", nullable = false)
    private UUID containerId;

    @Column(name = "borrower_id", nullable = false)
    private UUID borrowerId;

    @Column(name = "delivered_by", nullable = false)
    private UUID deliveredBy;

    @Column(name = "delivered_at", nullable = false)
    private Instant deliveredAt;

    @Column(name = "due_at", nullable = false)
    private Instant dueAt;

    @Column(name = "returned_by")
    private UUID returnedBy;

    @Column(name = "returned_at")
    private Instant returnedAt;

    private String punctuality;

    @Column(nullable = false)
    private String status;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;
}
