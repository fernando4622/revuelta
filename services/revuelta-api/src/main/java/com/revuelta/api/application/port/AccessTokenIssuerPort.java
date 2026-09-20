package com.revuelta.api.application.port;

import com.revuelta.api.domain.user.UserId;

public interface AccessTokenIssuerPort {

    String issue(UserId userId, String username, String role);
}
