package com.revuelta.api.domain.container;

import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventType;
import com.revuelta.api.domain.user.UserId;

import java.time.Instant;
import java.util.UUID;

/**
 * Aggregate root del dominio Container.
 * La identidad del envase es inmutable. El estado solo puede cambiar
 * a través de operaciones de dominio explícitas que validan la transición.
 */
public class Container {

    private final ContainerId id;
    private final ContainerCode code;
    private ContainerStatus status;
    private final Instant createdAt;
    private Instant updatedAt;
    private int qrGeneration;
    private final long version;

    // Constructor de reconstitución (desde persistencia)
    public Container(ContainerId id, ContainerCode code, ContainerStatus status,
                     Instant createdAt, Instant updatedAt, int qrGeneration, long version) {
        if (id == null) throw new IllegalArgumentException("Container id must not be null");
        if (code == null) throw new IllegalArgumentException("Container code must not be null");
        if (status == null) throw new IllegalArgumentException("Container status must not be null");
        this.id = id;
        this.code = code;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        if (qrGeneration <= 0) throw new IllegalArgumentException("QR generation must be positive");
        this.qrGeneration = qrGeneration;
        this.version = version;
    }

    // Factory para registro inicial
    public static Container register(ContainerCode code, Instant now) {
        return new Container(
                new ContainerId(UUID.randomUUID()),
                code,
                ContainerStatus.REGISTERED,
                now,
                now,
                1,
                0
        );
    }

    public ContainerEvent registeredBy(UserId actor, Instant now, UUID correlationId) {
        return new ContainerEvent(
                UUID.randomUUID(), id, ContainerEventType.REGISTERED, actor, now,
                null, ContainerStatus.REGISTERED, "Container registered", correlationId
        );
    }

    public ContainerEvent rotateQr(UserId actor, String reason, Instant now, UUID correlationId) {
        if (reason == null || reason.isBlank()) {
            throw new IllegalArgumentException("QR rotation reason must not be blank");
        }
        qrGeneration++;
        updatedAt = now;
        return new ContainerEvent(
                UUID.randomUUID(), id, ContainerEventType.CONTAINER_QR_ROTATED, actor, now,
                status, status, reason.trim(), correlationId
        );
    }

    /**
     * Realiza una transición de estado validada.
     * Lanza ContainerTransitionException si la transición no es válida.
     * Retorna el evento de dominio generado.
     */
    public ContainerEvent transition(
            ContainerStatus target,
            UserId actor,
            String reason,
            Instant now,
            UUID correlationId
    ) {
        if (!this.status.canTransitionTo(target)) {
            throw new ContainerTransitionException(
                    "Invalid transition from " + this.status + " to " + target
                            + " for container " + this.id.value(),
                    this.status,
                    target
            );
        }
        ContainerStatus previous = this.status;
        this.status = target;
        this.updatedAt = now;

        return new ContainerEvent(
                UUID.randomUUID(),
                this.id,
                ContainerEventType.of(previous, target),
                actor,
                now,
                previous,
                target,
                reason,
                correlationId
        );
    }

    public ContainerId id() { return id; }
    public ContainerCode code() { return code; }
    public ContainerStatus status() { return status; }
    public Instant createdAt() { return createdAt; }
    public Instant updatedAt() { return updatedAt; }
    public int qrGeneration() { return qrGeneration; }
    public long version() { return version; }

    public boolean isEligibleForCirculation() {
        return this.status == ContainerStatus.AVAILABLE;
    }
}
