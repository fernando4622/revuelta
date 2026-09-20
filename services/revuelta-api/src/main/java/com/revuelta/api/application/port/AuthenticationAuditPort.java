package com.revuelta.api.application.port;

public interface AuthenticationAuditPort {

    void invalidCredentials();

    void invalidRoleConfiguration();
}
