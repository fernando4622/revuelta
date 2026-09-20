package com.revuelta.api.infrastructure.persistence;

import com.revuelta.api.application.port.UserRepositoryPort;
import com.revuelta.api.domain.user.UserId;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Set;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class UserRepositoryAdapter implements UserRepositoryPort {

    private static final Set<String> RECOGNIZED_ROLES = Set.of("PARTICIPANT", "OPERATOR", "ADMIN");

    private final SpringDataUserRepository repository;

    @Override
    public Optional<UserRecord> findById(UserId id) {
        return repository.findById(id.value()).map(this::toRecord);
    }

    @Override
    public Optional<UserRecord> findByUsername(String username) {
        return repository.findByUsername(username).map(this::toRecord);
    }

    @Override
    public boolean existsById(UserId id) {
        return repository.existsById(id.value());
    }

    private UserRecord toRecord(UserJpaEntity entity) {
        Set<String> roleNames = entity.getRoles().stream()
                .map(RoleJpaEntity::getName)
                .filter(RECOGNIZED_ROLES::contains)
                .collect(java.util.stream.Collectors.toUnmodifiableSet());

        if (roleNames.size() != 1 || entity.getRoles().size() != 1) {
            throw new IllegalStateException("User account must have exactly one recognized role");
        }

        String roleName = roleNames.iterator().next();
        return new UserRecord(
                new UserId(entity.getId()),
                entity.getUsername(),
                entity.getPasswordHash(),
                entity.getEmail(),
                roleName
        );
    }
}
