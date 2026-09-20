package com.revuelta.api.infrastructure.config;

import com.revuelta.api.application.auth.LoginUseCase;
import com.revuelta.api.application.port.AccessTokenIssuerPort;
import com.revuelta.api.application.port.AuthenticationAuditPort;
import com.revuelta.api.application.port.PasswordVerifierPort;
import com.revuelta.api.application.port.UserRepositoryPort;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ApplicationConfig {

    @Bean
    public LoginUseCase loginUseCase(
            UserRepositoryPort userRepository,
            PasswordVerifierPort passwordVerifier,
            AccessTokenIssuerPort tokenIssuer,
            AuthenticationAuditPort authenticationAudit
    ) {
        return new LoginUseCase(userRepository, passwordVerifier, tokenIssuer, authenticationAudit);
    }
}
