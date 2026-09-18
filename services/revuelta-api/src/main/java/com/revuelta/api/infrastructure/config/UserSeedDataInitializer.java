package com.revuelta.api.infrastructure.config;

import com.revuelta.api.infrastructure.persistence.SpringDataUserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Component
@RequiredArgsConstructor
public class UserSeedDataInitializer implements CommandLineRunner {

    private final SpringDataUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) {
        String defaultPasswordHash = passwordEncoder.encode("password123");

        userRepository.findAll().forEach(user -> {
            if (!passwordEncoder.matches("password123", user.getPasswordHash())) {
                user.setPasswordHash(defaultPasswordHash);
                userRepository.save(user);
                log.info("Initialized valid BCrypt password hash for seed user: {}", user.getUsername());
            }
        });
    }
}
