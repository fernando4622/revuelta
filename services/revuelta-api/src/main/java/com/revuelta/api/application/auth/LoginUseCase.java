package com.revuelta.api.application.auth;

import com.revuelta.api.application.port.UserRepositoryPort;
import com.revuelta.api.infrastructure.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class LoginUseCase {

    private final UserRepositoryPort userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;

    public AuthResult execute(String username, String password) {
        var user = userRepository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("Invalid username or password"));

        if (!passwordEncoder.matches(password, user.passwordHash())) {
            log.warn("Authentication failed for user: {}", username);
            throw new IllegalArgumentException("Invalid username or password");
        }

        String token = tokenProvider.generateToken(user.id(), user.username(), user.roleName());

        return new AuthResult(token, user.id().value().toString(), user.username(), user.roleName());
    }

    public record AuthResult(String accessToken, String userId, String username, String role) {}
}
