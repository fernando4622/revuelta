package com.revuelta.api.infrastructure.security;

import com.revuelta.api.application.port.AuthenticationAuditPort;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class Slf4jAuthenticationAuditAdapter implements AuthenticationAuditPort {

    @Override
    public void invalidCredentials() {
        log.warn("Authentication failed because the supplied credentials are invalid");
    }

    @Override
    public void invalidRoleConfiguration() {
        log.error("Authentication rejected because the account role configuration is invalid");
    }
}
