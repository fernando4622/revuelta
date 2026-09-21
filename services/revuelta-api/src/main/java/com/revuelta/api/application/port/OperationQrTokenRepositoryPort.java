package com.revuelta.api.application.port;

import com.revuelta.api.domain.participant.OperationQrToken;

import java.util.Optional;
import java.util.UUID;

public interface OperationQrTokenRepositoryPort {
    OperationQrToken save(OperationQrToken token);
    Optional<OperationQrToken> findById(UUID id);
}
