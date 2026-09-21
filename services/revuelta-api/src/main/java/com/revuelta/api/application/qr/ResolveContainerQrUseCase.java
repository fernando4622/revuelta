package com.revuelta.api.application.qr;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerStatus;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class ResolveContainerQrUseCase {
    private final ContainerRepositoryPort containers;
    private final CirculationRepositoryPort circulations;
    private final QrPayloadCodecPort qrCodec;

    public ResolveContainerQrUseCase(
            ContainerRepositoryPort containers,
            CirculationRepositoryPort circulations,
            QrPayloadCodecPort qrCodec
    ) {
        this.containers = containers;
        this.circulations = circulations;
        this.qrCodec = qrCodec;
    }

    public Result execute(String payload, String actorRole) {
        QrPayloadCodecPort.ContainerClaims claims = qrCodec.decodeContainer(payload);
        Container container = containers.findById(claims.containerId())
                .orElseThrow(() -> new ApplicationFailureException(
                        FailureCode.CONTAINER_NOT_FOUND, "Container was not found"
                ));
        if (claims.generation() != container.qrGeneration()) {
            throw new ApplicationFailureException(
                    FailureCode.CONTAINER_QR_REVOKED, "Container QR was replaced"
            );
        }
        if (container.status() == ContainerStatus.RETIRED) {
            throw new ApplicationFailureException(
                    FailureCode.INACTIVE_CONTAINER, "Container is retired"
            );
        }

        ActiveCirculation active = circulations.findActiveByContainerId(container.id())
                .map(ActiveCirculation::fromDomain)
                .orElse(null);
        return new Result(
                container.id().value(), container.code().value(), container.status().name(),
                stateLabel(container.status()), container.isEligibleForCirculation(), active,
                allowedActions(actorRole, container.status())
        );
    }

    private List<String> allowedActions(String role, ContainerStatus status) {
        if ("OPERATOR".equals(role)) {
            return switch (status) {
                case AVAILABLE -> List.of("DELIVER");
                case IN_USE -> List.of("RETURN");
                case RETURNED -> List.of("COMPLETE_WASH");
                default -> List.of();
            };
        }
        if ("ADMIN".equals(role)) {
            return status == ContainerStatus.REGISTERED
                    ? List.of("ACTIVATE", "ROTATE_QR", "VIEW_HISTORY")
                    : List.of("ROTATE_QR", "VIEW_HISTORY");
        }
        return List.of();
    }

    private String stateLabel(ContainerStatus status) {
        return switch (status) {
            case REGISTERED -> "Registrado";
            case AVAILABLE -> "Disponible";
            case IN_USE -> "En uso";
            case RETURNED -> "Pendiente de lavado";
            case DAMAGED -> "Dañado";
            case LOST -> "Extraviado";
            case RETIRED -> "Retirado";
        };
    }

    public record Result(
            UUID containerRef,
            String displayCode,
            String state,
            String stateLabel,
            boolean eligibleForCirculation,
            ActiveCirculation activeCirculation,
            List<String> allowedActions
    ) {}

    public record ActiveCirculation(
            UUID circulationRef,
            UUID participantRef,
            Instant deliveredAt,
            Instant dueAt
    ) {
        static ActiveCirculation fromDomain(Circulation circulation) {
            return new ActiveCirculation(
                    circulation.id().value(), circulation.borrowerId().value(),
                    circulation.deliveredAt(), circulation.dueAt()
            );
        }
    }
}
