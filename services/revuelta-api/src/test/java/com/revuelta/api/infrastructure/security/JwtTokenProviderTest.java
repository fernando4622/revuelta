package com.revuelta.api.infrastructure.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.revuelta.api.domain.user.UserId;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class JwtTokenProviderTest {

    private static final String CURRENT_SECRET =
            "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970";
    private static final String PREVIOUS_SECRET =
            "514E635266556A586E3272357538782F413F4428472B4B6250645367566B5970";

    @Test
    void shouldIssueAndValidateRequiredContextClaims() {
        JwtTokenProvider provider = provider("current", CURRENT_SECRET, "");

        String token = provider.issue(UserId.generate(), "operator", "OPERATOR");
        var claims = provider.getClaims(token);

        assertTrue(provider.validateToken(token));
        assertEquals("revuelta-api", claims.getIssuer());
        assertTrue(claims.getAudience().contains("revuelta-mobile"));
        assertEquals("operator", claims.get("username", String.class));
        assertEquals("OPERATOR", claims.get("role", String.class));
    }

    @Test
    void shouldAcceptPreviousKeyOnlyWhileItRemainsInVerificationRing() {
        String previousToken = provider("previous", PREVIOUS_SECRET, "")
                .issue(UserId.generate(), "student1", "PARTICIPANT");

        assertTrue(provider(
                "current", CURRENT_SECRET, "previous=" + PREVIOUS_SECRET
        ).validateToken(previousToken));
        assertFalse(provider("current", CURRENT_SECRET, "").validateToken(previousToken));
    }

    @Test
    void shouldRejectWrongIssuerAudienceUnknownRoleAndMalformedSubject() {
        JwtTokenProvider provider = provider("current", CURRENT_SECRET, "");

        assertFalse(provider.validateToken(signedToken(
                CURRENT_SECRET, "current", "other-api", "revuelta-mobile",
                UUID.randomUUID().toString(), "OPERATOR"
        )));
        assertFalse(provider.validateToken(signedToken(
                CURRENT_SECRET, "current", "revuelta-api", "other-client",
                UUID.randomUUID().toString(), "OPERATOR"
        )));
        assertFalse(provider.validateToken(signedToken(
                CURRENT_SECRET, "current", "revuelta-api", "revuelta-mobile",
                UUID.randomUUID().toString(), "OWNER"
        )));
        assertFalse(provider.validateToken(signedToken(
                CURRENT_SECRET, "current", "revuelta-api", "revuelta-mobile",
                "not-a-uuid", "ADMIN"
        )));
    }

    private JwtTokenProvider provider(String keyId, String secret, String previousKeys) {
        return new JwtTokenProvider(
                keyId, secret, previousKeys, "revuelta-api", "revuelta-mobile", 4, 30
        );
    }

    private String signedToken(
            String secret,
            String keyId,
            String issuer,
            String audience,
            String subject,
            String role
    ) {
        Instant now = Instant.now();
        return Jwts.builder()
                .header().keyId(keyId).and()
                .issuer(issuer)
                .audience().add(audience).and()
                .subject(subject)
                .claim("username", "test-user")
                .claim("role", role)
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusSeconds(300)))
                .signWith(Keys.hmacShaKeyFor(Decoders.BASE64.decode(secret)))
                .compact();
    }
}
