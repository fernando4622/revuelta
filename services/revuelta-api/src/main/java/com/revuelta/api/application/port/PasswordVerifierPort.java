package com.revuelta.api.application.port;

public interface PasswordVerifierPort {

    boolean matches(String rawPassword, String encodedPassword);
}
