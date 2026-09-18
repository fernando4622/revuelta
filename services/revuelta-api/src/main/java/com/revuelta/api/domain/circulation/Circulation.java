package com.revuelta.api.domain.circulation;

import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.user.UserId;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

/**
 * Aggregate root del dominio Circulation.
 * Representa la posesión controlada de un envase por parte de un alumno (DL-002).
 */
public class Circulation {

    private final CirculationId id;
    private final ContainerId containerId;
    private final UserId borrowerId;
    private final UserId deliveredBy;
    private final Instant deliveredAt;
    private final Instant dueAt;
    private UserId returnedBy;
    private Instant returnedAt;
    private Punctuality punctuality;
    private CirculationStatus status;

    // Reconstitución desde infraestructura
    public Circulation(CirculationId id, ContainerId containerId, UserId borrowerId,
                       UserId deliveredBy, Instant deliveredAt, Instant dueAt,
                       UserId returnedBy, Instant returnedAt, Punctuality punctuality,
                       CirculationStatus status) {
        this.id = Objects.requireNonNull(id, "Circulation id must not be null");
        this.containerId = Objects.requireNonNull(containerId, "ContainerId must not be null");
        this.borrowerId = Objects.requireNonNull(borrowerId, "BorrowerId must not be null");
        this.deliveredBy = Objects.requireNonNull(deliveredBy, "DeliveredBy must not be null");
        this.deliveredAt = Objects.requireNonNull(deliveredAt, "DeliveredAt must not be null");
        this.dueAt = Objects.requireNonNull(dueAt, "DueAt must not be null");
        this.returnedBy = returnedBy;
        this.returnedAt = returnedAt;
        this.punctuality = punctuality;
        this.status = Objects.requireNonNull(status, "Status must not be null");
    }

    // Factory para creación de nueva circulación
    public static Circulation create(ContainerId containerId, UserId borrowerId,
                                      UserId deliveredBy, Instant deliveredAt, Instant dueAt) {
        if (dueAt.isBefore(deliveredAt)) {
            throw new IllegalArgumentException("Due date cannot be before delivery date");
        }
        return new Circulation(
                new CirculationId(UUID.randomUUID()),
                containerId,
                borrowerId,
                deliveredBy,
                deliveredAt,
                dueAt,
                null,
                null,
                null,
                CirculationStatus.ACTIVE
        );
    }

    /**
     * Finaliza la circulación al registrar la devolución del envase.
     * Enforma las reglas BR-CIR-007 y BR-CIR-008.
     */
    public void finalize(UserId returnedBy, Instant returnedAt) {
        if (this.status == CirculationStatus.COMPLETED) {
            throw new IllegalStateException("Circulation is already finalized");
        }
        if (returnedAt.isBefore(this.deliveredAt)) {
            throw new IllegalArgumentException("Return timestamp cannot be before delivery timestamp");
        }

        this.returnedBy = Objects.requireNonNull(returnedBy, "ReturnedBy must not be null");
        this.returnedAt = Objects.requireNonNull(returnedAt, "ReturnedAt must not be null");
        this.punctuality = returnedAt.isAfter(this.dueAt) ? Punctuality.LATE : Punctuality.ON_TIME;
        this.status = CirculationStatus.COMPLETED;
    }

    public CirculationId id() { return id; }
    public ContainerId containerId() { return containerId; }
    public UserId borrowerId() { return borrowerId; }
    public UserId deliveredBy() { return deliveredBy; }
    public Instant deliveredAt() { return deliveredAt; }
    public Instant dueAt() { return dueAt; }
    public UserId returnedBy() { return returnedBy; }
    public Instant returnedAt() { return returnedAt; }
    public Punctuality punctuality() { return punctuality; }
    public CirculationStatus status() { return status; }

    public boolean isActive() {
        return this.status == CirculationStatus.ACTIVE;
    }
}
