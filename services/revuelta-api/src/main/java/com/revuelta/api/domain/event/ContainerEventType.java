package com.revuelta.api.domain.event;

import com.revuelta.api.domain.container.ContainerStatus;

public enum ContainerEventType {
    REGISTERED,
    ACTIVATED,
    DELIVERED,
    RETURNED,
    MARKED_DAMAGED,
    MARKED_LOST,
    RECOVERED,
    RETIRED;

    public static ContainerEventType of(ContainerStatus from, ContainerStatus to) {
        if (from == ContainerStatus.REGISTERED && to == ContainerStatus.AVAILABLE) {
            return ACTIVATED;
        }
        if (from == ContainerStatus.AVAILABLE && to == ContainerStatus.IN_USE) {
            return DELIVERED;
        }
        if (from == ContainerStatus.IN_USE && to == ContainerStatus.AVAILABLE) {
            return RETURNED;
        }
        if (to == ContainerStatus.DAMAGED) {
            return MARKED_DAMAGED;
        }
        if (to == ContainerStatus.LOST) {
            return MARKED_LOST;
        }
        if (from == ContainerStatus.DAMAGED && to == ContainerStatus.AVAILABLE) {
            return RECOVERED;
        }
        if (to == ContainerStatus.RETIRED) {
            return RETIRED;
        }
        throw new IllegalArgumentException("No ContainerEventType mapping for transition: " + from + " -> " + to);
    }
}
