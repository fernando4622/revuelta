package com.revuelta.api.application.qr;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerId;

public class GetContainerQrUseCase {
    private final ContainerRepositoryPort containers;
    private final QrPayloadCodecPort qrCodec;

    public GetContainerQrUseCase(ContainerRepositoryPort containers, QrPayloadCodecPort qrCodec) {
        this.containers = containers;
        this.qrCodec = qrCodec;
    }

    public Result execute(ContainerId id) {
        Container container = containers.findById(id)
                .orElseThrow(() -> new ApplicationFailureException(
                        FailureCode.CONTAINER_NOT_FOUND, "Container was not found"
                ));
        return result(container);
    }

    Result result(Container container) {
        return new Result(
                container.id().value(), container.qrGeneration(),
                qrCodec.encodeContainer(container.id(), container.qrGeneration())
        );
    }

    public record Result(java.util.UUID containerRef, int generation, String payload) {}
}
