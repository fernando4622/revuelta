package com.revuelta.api.domain.policy;

import java.time.Duration;
import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

public class ReturnPolicy {
    private final UUID id;
    private final String name;
    private final int durationHours;
    private final boolean active;
    private final Instant createdAt;

    public ReturnPolicy(UUID id, String name, int durationHours, boolean active, Instant createdAt) {
        if (durationHours <= 0) {
            throw new IllegalArgumentException("Duration hours must be positive");
        }
        this.id = Objects.requireNonNull(id, "Id must not be null");
        this.name = Objects.requireNonNull(name, "Name must not be null");
        this.durationHours = durationHours;
        this.active = active;
        this.createdAt = Objects.requireNonNull(createdAt, "CreatedAt must not be null");
    }

    public static ReturnPolicy defaultPolicy(Instant now) {
        return new ReturnPolicy(
                UUID.randomUUID(),
                "Default Pilot 48h Policy",
                48,
                true,
                now
        );
    }

    public Instant calculateDueAt(Instant deliveredAt) {
        return deliveredAt.plus(Duration.ofHours(durationHours));
    }

    public UUID id() { return id; }
    public String name() { return name; }
    public int durationHours() { return durationHours; }
    public boolean active() { return active; }
    public Instant createdAt() { return createdAt; }
}
