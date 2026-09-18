package com.revuelta.api;

import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import static org.junit.jupiter.api.Assertions.assertTrue;

class PasswordHashTest {

    @Test
    void testPasswordHash() {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String encoded = encoder.encode("password123");
        System.out.println("GENERATED_BCRYPT_HASH: " + encoded);

        assertTrue(encoder.matches("password123", encoded));
    }
}
