package com.revuelta.api.application.query;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.ParticipantRepositoryPort;
import com.revuelta.api.domain.circulation.Circulation;
import com.revuelta.api.domain.circulation.CirculationId;
import com.revuelta.api.domain.circulation.CirculationStatus;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.participant.Participant;
import com.revuelta.api.domain.user.UserId;

import java.time.Instant;

public class ParticipantCirculationQueryUseCase {
    private final ParticipantRepositoryPort participants;
    private final CirculationRepositoryPort circulations;
    private final ContainerRepositoryPort containers;

    public ParticipantCirculationQueryUseCase(
            ParticipantRepositoryPort participants,
            CirculationRepositoryPort circulations,
            ContainerRepositoryPort containers
    ) {
        this.participants = participants;
        this.circulations = circulations;
        this.containers = containers;
    }

    public PageResult<Item> list(UserId accountId, CirculationStatus status, int page, int size) {
        PageResult.validate(page, size);
        Participant participant = participantFor(accountId);
        var rows = circulations.findByBorrowerId(participant.id(), status, page, size + 1);
        return PageResult.fromExtraRow(rows.stream().map(this::toItem).toList(), page, size);
    }

    public Item get(UserId accountId, CirculationId circulationId) {
        Participant participant = participantFor(accountId);
        Circulation circulation = circulations.findByIdAndBorrowerId(circulationId, participant.id())
                .orElseThrow(() -> new ApplicationFailureException(
                        FailureCode.CIRCULATION_NOT_FOUND, "Circulation not found"));
        return toItem(circulation);
    }

    private Participant participantFor(UserId accountId) {
        return participants.findByAccountId(accountId).orElseThrow(() ->
                new ApplicationFailureException(
                        FailureCode.PARTICIPANT_ACCOUNT_NOT_LINKED,
                        "Authenticated account is not linked to a participant"
                ));
    }

    private Item toItem(Circulation circulation) {
        Container container = containers.findById(circulation.containerId()).orElseThrow(() ->
                new ApplicationFailureException(FailureCode.CONTAINER_NOT_FOUND, "Container not found"));
        return new Item(
                circulation.id().value().toString(),
                container.id().value().toString(),
                container.code().value(),
                container.status().name(),
                stateLabel(container.status().name()),
                circulation.deliveredAt(),
                circulation.dueAt(),
                circulation.returnedAt(),
                circulation.status().name(),
                circulation.punctuality() == null ? null : circulation.punctuality().name()
        );
    }

    private String stateLabel(String status) {
        return switch (status) {
            case "REGISTERED" -> "Registrado";
            case "AVAILABLE" -> "Disponible";
            case "IN_USE" -> "En uso";
            case "RETURNED" -> "Pendiente de lavado";
            case "DAMAGED" -> "Dañado";
            case "LOST" -> "Extraviado";
            case "RETIRED" -> "Retirado";
            default -> status;
        };
    }

    public record Item(
            String circulationId,
            String containerId,
            String publicCode,
            String containerState,
            String stateLabel,
            Instant deliveredAt,
            Instant dueAt,
            Instant returnedAt,
            String status,
            String punctuality
    ) {}
}
