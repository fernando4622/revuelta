package com.revuelta.api.infrastructure.security;

import com.revuelta.api.domain.user.UserId;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;

@Component
public class JwtTokenProvider {

    private final SecretKey secretKey;
    private final Duration expiration;

    public JwtTokenProvider(
            @Value("${jwt.secret:404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970}") String secretHex,
            @Value("${jwt.expiration-hours:4}") int expirationHours
    ) {
        byte[] keyBytes = Decoders.BASE64.decode(secretHex);
        this.secretKey = Keys.hmacShaKeyFor(keyBytes);
        this.expiration = Duration.ofHours(expirationHours);
    }

    public String generateToken(UserId userId, String username, String role) {
        Instant now = Instant.now();
        Instant exp = now.plus(expiration);

        return Jwts.builder()
                .subject(userId.value().toString())
                .claim("username", username)
                .claim("role", role)
                .issuedAt(Date.from(now))
                .expiration(Date.from(exp))
                .signWith(secretKey)
                .compact();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    public Claims getClaims(String token) {
        return Jwts.parser()
                .verifyWith(secretKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public UserId getUserId(String token) {
        String sub = getClaims(token).getSubject();
        return new UserId(UUID.fromString(sub));
    }

    public String getRole(String token) {
        return getClaims(token).get("role", String.class);
    }
}
