package com.revuelta.api.infrastructure.security;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.port.QrPayloadCodecPort;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.participant.OperationQrPurpose;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.Base64;
import java.util.UUID;

@Component
public class HmacQrPayloadCodecAdapter implements QrPayloadCodecPort {
    private static final String VERSION = "RV1";
    private static final String ALGORITHM = "HmacSHA256";

    private final SecretKeySpec key;

    public HmacQrPayloadCodecAdapter(@Value("${qr.signing-secret}") String encodedSecret) {
        byte[] secret;
        try {
            secret = Base64.getDecoder().decode(encodedSecret);
        } catch (IllegalArgumentException exception) {
            throw new IllegalArgumentException("QR signing secret must be valid Base64", exception);
        }
        if (secret.length < 32) {
            throw new IllegalArgumentException("QR signing secret must contain at least 32 bytes");
        }
        this.key = new SecretKeySpec(secret, ALGORITHM);
    }

    @Override
    public String encodeContainer(ContainerId containerId, int generation) {
        if (generation <= 0) throw invalidQr();
        return signed(VERSION + ":C:" + containerId.value() + ":" + generation);
    }

    @Override
    public ContainerClaims decodeContainer(String payload) {
        String[] parts = checkedParts(payload, 5, "C");
        try {
            int generation = Integer.parseInt(parts[3]);
            if (generation <= 0) throw invalidQr();
            return new ContainerClaims(new ContainerId(UUID.fromString(parts[2])), generation);
        } catch (IllegalArgumentException exception) {
            throw invalidQr();
        }
    }

    @Override
    public String encodeOperation(UUID tokenId, OperationQrPurpose purpose, Instant expiresAt) {
        return signed(VERSION + ":P:" + purpose.name() + ":" + tokenId + ":" + expiresAt.getEpochSecond());
    }

    @Override
    public OperationClaims decodeOperation(String payload) {
        String[] parts = checkedParts(payload, 6, "P");
        try {
            return new OperationClaims(
                    UUID.fromString(parts[3]),
                    OperationQrPurpose.valueOf(parts[2]),
                    Instant.ofEpochSecond(Long.parseLong(parts[4]))
            );
        } catch (IllegalArgumentException exception) {
            throw invalidQr();
        }
    }

    private String signed(String unsigned) {
        return unsigned + ":" + Base64.getUrlEncoder().withoutPadding().encodeToString(mac(unsigned));
    }

    private String[] checkedParts(String payload, int expectedLength, String expectedType) {
        if (payload == null || payload.isBlank() || payload.length() > 512) throw invalidQr();
        String[] parts = payload.split(":", -1);
        if (parts.length == 0 || !VERSION.equals(parts[0])) {
            if (parts.length > 0 && parts[0].startsWith("RV")) {
                throw new ApplicationFailureException(
                        FailureCode.UNSUPPORTED_QR_VERSION, "QR version is not supported"
                );
            }
            throw invalidQr();
        }
        if (parts.length != expectedLength || !expectedType.equals(parts[1])) throw invalidQr();

        int lastSeparator = payload.lastIndexOf(':');
        String unsigned = payload.substring(0, lastSeparator);
        byte[] supplied;
        try {
            supplied = Base64.getUrlDecoder().decode(parts[parts.length - 1]);
        } catch (IllegalArgumentException exception) {
            throw tamperedQr();
        }
        if (!MessageDigest.isEqual(mac(unsigned), supplied)) throw tamperedQr();
        return parts;
    }

    private byte[] mac(String value) {
        try {
            Mac mac = Mac.getInstance(ALGORITHM);
            mac.init(key);
            return mac.doFinal(value.getBytes(StandardCharsets.UTF_8));
        } catch (GeneralSecurityException exception) {
            throw new IllegalStateException("QR signing is unavailable", exception);
        }
    }

    private ApplicationFailureException invalidQr() {
        return new ApplicationFailureException(FailureCode.INVALID_QR, "QR payload is malformed");
    }

    private ApplicationFailureException tamperedQr() {
        return new ApplicationFailureException(FailureCode.QR_TAMPERED, "QR integrity validation failed");
    }
}
