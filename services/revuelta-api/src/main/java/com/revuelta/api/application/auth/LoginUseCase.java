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
        UserRepositoryPort.UserRecord user;
        try {
            user = userRepository.findByUsername(username)
                    .orElseThrow(AuthenticationFailureException::new);
        } catch (IllegalStateException exception) {
            log.error("Authentication rejected because the account role configuration is invalid");
            throw new AuthenticationFailureException();
        }

        if (!passwordEncoder.matches(password, user.passwordHash())) {
            log.warn("Authentication failed because the supplied credentials are invalid");
            throw new AuthenticationFailureException();
        }

        String token = tokenProvider.generateToken(user.id(), user.username(), user.roleName());

        return new AuthResult(token, user.id().value().toString(), user.username(), user.roleName());
    }

    public record AuthResult(String accessToken, String userId, String username, String role) {}
}
