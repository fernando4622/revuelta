package com.revuelta.api.application.auth;

import com.revuelta.api.application.port.AccessTokenIssuerPort;
import com.revuelta.api.application.port.AuthenticationAuditPort;
import com.revuelta.api.application.port.PasswordVerifierPort;
import com.revuelta.api.application.port.UserRepositoryPort;

public class LoginUseCase {

    private final UserRepositoryPort userRepository;
    private final PasswordVerifierPort passwordVerifier;
    private final AccessTokenIssuerPort tokenIssuer;
    private final AuthenticationAuditPort authenticationAudit;

    public LoginUseCase(
            UserRepositoryPort userRepository,
            PasswordVerifierPort passwordVerifier,
            AccessTokenIssuerPort tokenIssuer,
            AuthenticationAuditPort authenticationAudit
    ) {
        this.userRepository = userRepository;
        this.passwordVerifier = passwordVerifier;
        this.tokenIssuer = tokenIssuer;
        this.authenticationAudit = authenticationAudit;
    }

    public AuthResult execute(String username, String password) {
        UserRepositoryPort.UserRecord user;
        try {
            user = userRepository.findByUsername(username).orElse(null);
        } catch (IllegalStateException exception) {
            authenticationAudit.invalidRoleConfiguration();
            throw new AuthenticationFailureException();
        }

        if (user == null || !passwordVerifier.matches(password, user.passwordHash())) {
            authenticationAudit.invalidCredentials();
            throw new AuthenticationFailureException();
        }

        String token = tokenIssuer.issue(user.id(), user.username(), user.roleName());

        return new AuthResult(token, user.id().value().toString(), user.username(), user.roleName());
    }

    public record AuthResult(String accessToken, String userId, String username, String role) {}
}
