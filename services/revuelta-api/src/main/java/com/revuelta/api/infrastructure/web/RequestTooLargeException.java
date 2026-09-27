package com.revuelta.api.infrastructure.web;

public class RequestTooLargeException extends RuntimeException {
    public RequestTooLargeException() {
        super("Request body exceeds the permitted size");
    }
}
