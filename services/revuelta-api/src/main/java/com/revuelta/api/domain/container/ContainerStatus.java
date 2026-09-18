package com.revuelta.api.domain.container;

import java.util.Set;

/**
 * Estados permitidos en la máquina de estados simplificada para V1 (DL-005, DL-006):
 * REGISTERED → AVAILABLE → IN_USE → AVAILABLE (ciclo operativo)
 * AVAILABLE/IN_USE → DAMAGED → AVAILABLE/RETIRED
 * AVAILABLE/IN_USE → LOST → RETIRED
 */
public enum ContainerStatus {
    REGISTERED,
    AVAILABLE,
    IN_USE,
    DAMAGED,
    LOST,
    RETIRED;

    public boolean canTransitionTo(ContainerStatus target) {
        if (target == null || this == target) {
            return false;
        }

        return switch (this) {
            case REGISTERED -> target == AVAILABLE;
            case AVAILABLE -> target == IN_USE || target == DAMAGED || target == LOST;
            case IN_USE -> target == AVAILABLE || target == DAMAGED || target == LOST;
            case DAMAGED -> target == AVAILABLE || target == RETIRED;
            case LOST -> target == RETIRED;
            case RETIRED -> false; // Estado terminal
        };
    }
}
