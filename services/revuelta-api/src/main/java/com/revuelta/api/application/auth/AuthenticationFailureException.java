package com.revuelta.api.application.auth;

public class AuthenticationFailureException extends RuntimeException {

    public AuthenticationFailureException() {
        super("Invalid username or password");
    }
}
