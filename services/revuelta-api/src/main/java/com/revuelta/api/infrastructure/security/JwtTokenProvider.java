package com.revuelta.api.infrastructure.security;

import com.revuelta.api.application.port.AccessTokenIssuerPort;
import com.revuelta.api.domain.user.UserId;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.JwtParser;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.ProtectedHeader;
import io.jsonwebtoken.UnsupportedJwtException;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import java.security.Key;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Pattern;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class JwtTokenProvider implements AccessTokenIssuerPort {

    private static final Pattern KEY_ID = Pattern.compile("[A-Za-z0-9._-]{1,64}");
    private static final Set<String> RECOGNIZED_ROLES = Set.of("PARTICIPANT", "OPERATOR", "ADMIN");

    private final String activeKeyId;
    private final SecretKey activeKey;
    private final Duration expiration;
    private final String issuer;
    private final String audience;
    private final JwtParser parser;

    public JwtTokenProvider(
            @Value("${jwt.active-key-id}") String activeKeyId,
            @Value("${jwt.active-secret}") String activeSecret,
            @Value("${jwt.previous-keys:}") String previousKeys,
            @Value("${jwt.issuer}") String issuer,
            @Value("${jwt.audience}") String audience,
            @Value("${jwt.expiration-hours:4}") int expirationHours,
            @Value("${jwt.clock-skew-seconds:30}") int clockSkewSeconds
    ) {
        this.activeKeyId = validateKeyId(activeKeyId);
        this.activeKey = decodeKey(activeSecret);
        this.issuer = requireText(issuer, "JWT issuer");
        this.audience = requireText(audience, "JWT audience");
        if (expirationHours < 1) {
            throw new IllegalArgumentException("JWT expiration hours must be positive");
        }
        if (clockSkewSeconds < 0 || clockSkewSeconds > 60) {
            throw new IllegalArgumentException("JWT clock skew must be between 0 and 60 seconds");
        }
        this.expiration = Duration.ofHours(expirationHours);

        Map<String, SecretKey> verificationKeys = new LinkedHashMap<>();
        verificationKeys.put(this.activeKeyId, this.activeKey);
        parsePreviousKeys(previousKeys, verificationKeys);
        Map<String, SecretKey> immutableKeys = Map.copyOf(verificationKeys);

        this.parser = Jwts.parser()
                .keyLocator(header -> locateKey(header, immutableKeys))
                .requireIssuer(this.issuer)
                .requireAudience(this.audience)
                .clockSkewSeconds(clockSkewSeconds)
                .build();
    }

    @Override
    public String issue(UserId userId, String username, String role) {
        String safeUsername = requireText(username, "JWT username");
        if (!RECOGNIZED_ROLES.contains(role)) {
            throw new IllegalArgumentException("JWT role is not recognized");
        }

        Instant now = Instant.now();
        Instant exp = now.plus(expiration);
        return Jwts.builder()
                .header().keyId(activeKeyId).and()
                .issuer(issuer)
                .audience().add(audience).and()
                .subject(userId.value().toString())
                .claim("username", safeUsername)
                .claim("role", role)
                .issuedAt(Date.from(now))
                .expiration(Date.from(exp))
                .signWith(activeKey)
                .compact();
    }

    public boolean validateToken(String token) {
        try {
            getClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException exception) {
            return false;
        }
    }

    public Claims getClaims(String token) {
        Claims claims = parser.parseSignedClaims(token).getPayload();
        validateClaims(claims);
        return claims;
    }

    public UserId getUserId(String token) {
        return new UserId(UUID.fromString(getClaims(token).getSubject()));
    }

    public String getRole(String token) {
        return getClaims(token).get("role", String.class);
    }

    private void validateClaims(Claims claims) {
        try {
            UUID.fromString(claims.getSubject());
        } catch (RuntimeException exception) {
            throw new MalformedJwtException("JWT subject must be a UUID");
        }
        String username = claims.get("username", String.class);
        String role = claims.get("role", String.class);
        if (username == null || username.isBlank()
                || !RECOGNIZED_ROLES.contains(role)
                || claims.getIssuedAt() == null
                || claims.getExpiration() == null) {
            throw new MalformedJwtException("JWT required claims are invalid");
        }
    }

    private static Key locateKey(io.jsonwebtoken.Header header, Map<String, SecretKey> keys) {
        String keyId = header instanceof ProtectedHeader protectedHeader
                ? protectedHeader.getKeyId()
                : null;
        SecretKey key = keyId == null ? null : keys.get(keyId);
        if (key == null) {
            throw new UnsupportedJwtException("JWT signing key is not recognized");
        }
        return key;
    }

    private static void parsePreviousKeys(String configured, Map<String, SecretKey> keys) {
        if (configured == null || configured.isBlank()) {
            return;
        }
        for (String entry : configured.split(",")) {
            String[] pair = entry.trim().split("=", 2);
            if (pair.length != 2 || pair[1].isBlank()) {
                throw new IllegalArgumentException("JWT previous key configuration is malformed");
            }
            String keyId = validateKeyId(pair[0]);
            if (keys.putIfAbsent(keyId, decodeKey(pair[1])) != null) {
                throw new IllegalArgumentException("JWT key IDs must be unique");
            }
        }
    }

    private static String validateKeyId(String value) {
        String keyId = requireText(value, "JWT key ID");
        if (!KEY_ID.matcher(keyId).matches()) {
            throw new IllegalArgumentException("JWT key ID has an invalid format");
        }
        return keyId;
    }

    private static SecretKey decodeKey(String encoded) {
        return Keys.hmacShaKeyFor(Decoders.BASE64.decode(requireText(encoded, "JWT secret")));
    }

    private static String requireText(String value, String label) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(label + " must not be blank");
        }
        return value.trim();
    }
}
