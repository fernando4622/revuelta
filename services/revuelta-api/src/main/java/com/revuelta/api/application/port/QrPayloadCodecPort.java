package com.revuelta.api.application.port;

import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.participant.OperationQrPurpose;

import java.time.Instant;
import java.util.UUID;

public interface QrPayloadCodecPort {
    String encodeContainer(ContainerId containerId, int generation);
    ContainerClaims decodeContainer(String payload);
    String encodeOperation(UUID tokenId, OperationQrPurpose purpose, Instant expiresAt);
    OperationClaims decodeOperation(String payload);

    record ContainerClaims(ContainerId containerId, int generation) {}
    record OperationClaims(UUID tokenId, OperationQrPurpose purpose, Instant expiresAt) {}
}
