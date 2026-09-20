package com.revuelta.api.infrastructure.persistence;

import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class UserRepositoryAdapterTest {

    private final SpringDataUserRepository repository = mock(SpringDataUserRepository.class);
    private final UserRepositoryAdapter adapter = new UserRepositoryAdapter(repository);

    @Test
    void shouldResolveParticipantRoleWithoutStaffFallback() {
        UserJpaEntity user = userWithRoles(Set.of(role("PARTICIPANT")));
        when(repository.findByUsername("student1")).thenReturn(Optional.of(user));

        var result = adapter.findByUsername("student1").orElseThrow();

        assertEquals("PARTICIPANT", result.roleName());
    }

    @Test
    void shouldRejectAccountWithoutRole() {
        UserJpaEntity user = userWithRoles(Set.of());
        when(repository.findByUsername("student1")).thenReturn(Optional.of(user));

        assertThrows(IllegalStateException.class, () -> adapter.findByUsername("student1"));
    }

    @Test
    void shouldRejectAccountWithMultipleRoles() {
        UserJpaEntity user = userWithRoles(Set.of(role("PARTICIPANT"), role("OPERATOR")));
        when(repository.findByUsername("student1")).thenReturn(Optional.of(user));

        assertThrows(IllegalStateException.class, () -> adapter.findByUsername("student1"));
    }

    @Test
    void shouldRejectUnknownRole() {
        UserJpaEntity user = userWithRoles(Set.of(role("UNKNOWN")));
        when(repository.findByUsername("student1")).thenReturn(Optional.of(user));

        assertThrows(IllegalStateException.class, () -> adapter.findByUsername("student1"));
    }

    private UserJpaEntity userWithRoles(Set<RoleJpaEntity> roles) {
        Instant now = Instant.now();
        return new UserJpaEntity(
                UUID.randomUUID(),
                "student1",
                "hash",
                "student1@university.edu",
                now,
                now,
                new HashSet<>(roles)
        );
    }

    private RoleJpaEntity role(String name) {
        return new RoleJpaEntity(UUID.randomUUID(), name);
    }
}
