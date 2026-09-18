package com.revuelta.api.application.port;

import com.revuelta.api.domain.user.UserId;

import java.util.Optional;

public interface UserRepositoryPort {
    Optional<UserRecord> findById(UserId id);
    Optional<UserRecord> findByUsername(String username);
    boolean existsById(UserId id);

    record UserRecord(UserId id, String username, String passwordHash, String email, String roleName) {}
}
