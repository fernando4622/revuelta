package com.revuelta.api.infrastructure.security;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.participant.OperationQrPurpose;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.Base64;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class HmacQrPayloadCodecAdapterTest {
    private final HmacQrPayloadCodecAdapter codec = new HmacQrPayloadCodecAdapter(
            Base64.getEncoder().encodeToString("test-qr-signing-secret-32-bytes!".getBytes())
    );

    @Test
    void shouldRoundTripContainerAndOperationPayloads() {
        ContainerId containerId = ContainerId.generate();
        var container = codec.decodeContainer(codec.encodeContainer(containerId, 3));
        assertEquals(containerId, container.containerId());
        assertEquals(3, container.generation());

        UUID tokenId = UUID.randomUUID();
        Instant expiresAt = Instant.parse("2026-09-21T04:02:00Z");
        var operation = codec.decodeOperation(
                codec.encodeOperation(tokenId, OperationQrPurpose.RETURN, expiresAt)
        );
        assertEquals(tokenId, operation.tokenId());
        assertEquals(OperationQrPurpose.RETURN, operation.purpose());
        assertEquals(expiresAt, operation.expiresAt());
    }

    @Test
    void shouldRejectTamperedPayload() {
        String payload = codec.encodeContainer(ContainerId.generate(), 1);
        String tampered = payload.replace(":1:", ":2:");

        ApplicationFailureException failure = assertThrows(
                ApplicationFailureException.class,
                () -> codec.decodeContainer(tampered)
        );

        assertEquals(FailureCode.QR_TAMPERED, failure.code());
    }

    @Test
    void shouldRejectUnsupportedVersionAndWrongQrType() {
        ApplicationFailureException versionFailure = assertThrows(
                ApplicationFailureException.class,
                () -> codec.decodeContainer("RV2:C:value:1:signature")
        );
        assertEquals(FailureCode.UNSUPPORTED_QR_VERSION, versionFailure.code());

        String operation = codec.encodeOperation(
                UUID.randomUUID(), OperationQrPurpose.DELIVERY, Instant.now().plusSeconds(120)
        );
        ApplicationFailureException typeFailure = assertThrows(
                ApplicationFailureException.class,
                () -> codec.decodeContainer(operation)
        );
        assertEquals(FailureCode.INVALID_QR, typeFailure.code());
    }
}
