package com.revuelta.api.application.auth;

import com.revuelta.api.application.port.AccessTokenIssuerPort;
import com.revuelta.api.application.port.AuthenticationAuditPort;
import com.revuelta.api.application.port.PasswordVerifierPort;
import com.revuelta.api.application.port.UserRepositoryPort;
import com.revuelta.api.domain.user.UserId;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LoginUseCaseTest {

    @Mock private UserRepositoryPort userRepository;
    @Mock private PasswordVerifierPort passwordVerifier;
    @Mock private AccessTokenIssuerPort tokenIssuer;
    @Mock private AuthenticationAuditPort authenticationAudit;

    private LoginUseCase loginUseCase;

    @BeforeEach
    void setUp() {
        loginUseCase = new LoginUseCase(userRepository, passwordVerifier, tokenIssuer, authenticationAudit);
    }

    @Test
    void shouldIssueParticipantTokenForParticipantAccount() {
        UserRepositoryPort.UserRecord user = new UserRepositoryPort.UserRecord(
                UserId.generate(),
                "student1",
                "hash",
                "student1@university.edu",
                "PARTICIPANT"
        );
        when(userRepository.findByUsername("student1")).thenReturn(Optional.of(user));
        when(passwordVerifier.matches("password123", "hash")).thenReturn(true);
        when(tokenIssuer.issue(user.id(), user.username(), "PARTICIPANT")).thenReturn("token");

        LoginUseCase.AuthResult result = loginUseCase.execute("student1", "password123");

        assertEquals("student1", result.username());
        assertEquals("PARTICIPANT", result.role());
        assertEquals("token", result.accessToken());
    }

    @Test
    void shouldRejectInvalidCredentialsWithoutIssuingToken() {
        UserRepositoryPort.UserRecord user = new UserRepositoryPort.UserRecord(
                UserId.generate(),
                "student1",
                "hash",
                "student1@university.edu",
                "PARTICIPANT"
        );
        when(userRepository.findByUsername("student1")).thenReturn(Optional.of(user));
        when(passwordVerifier.matches("wrong", "hash")).thenReturn(false);

        assertThrows(AuthenticationFailureException.class,
                () -> loginUseCase.execute("student1", "wrong"));

        verify(authenticationAudit).invalidCredentials();
        verify(tokenIssuer, never()).issue(user.id(), user.username(), user.roleName());
    }

    @Test
    void shouldFailClosedWhenAccountRoleConfigurationIsInvalid() {
        when(userRepository.findByUsername("student1"))
                .thenThrow(new IllegalStateException("User account must have exactly one recognized role"));

        assertThrows(AuthenticationFailureException.class,
                () -> loginUseCase.execute("student1", "password123"));

        verify(authenticationAudit).invalidRoleConfiguration();
        verify(tokenIssuer, never()).issue(
                org.mockito.ArgumentMatchers.any(),
                org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyString()
        );
    }

    @Test
    void shouldRejectUnknownAccountWithoutVerifyingPasswordOrIssuingToken() {
        when(userRepository.findByUsername("unknown")).thenReturn(Optional.empty());

        assertThrows(AuthenticationFailureException.class,
                () -> loginUseCase.execute("unknown", "password123"));

        verify(authenticationAudit).invalidCredentials();
        verify(passwordVerifier, never()).matches(
                org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyString()
        );
        verify(tokenIssuer, never()).issue(
                org.mockito.ArgumentMatchers.any(),
                org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyString()
        );
    }
}
