package com.revuelta.api.application.query;

import com.revuelta.api.application.port.ParticipantRepositoryPort;

import java.time.Instant;

public class ParticipantDirectoryQueryUseCase {
    private final ParticipantRepositoryPort participants;

    public ParticipantDirectoryQueryUseCase(ParticipantRepositoryPort participants) {
        this.participants = participants;
    }

    public PageResult<Item> execute(int page, int size) {
        PageResult.validate(page, size);
        var rows = participants.findAll(page, size + 1);
        return PageResult.fromExtraRow(rows.stream()
                .map(participant -> new Item(
                        participant.id().value().toString(), participant.active(), participant.createdAt()
                ))
                .toList(), page, size);
    }

    public record Item(String participantRef, boolean active, Instant createdAt) {}
}
