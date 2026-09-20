package com.revuelta.api.infrastructure.web;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpInputMessage;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;

class GlobalExceptionHandlerTest {

    @Test
    void shouldReturnBadRequestForMalformedJsonWithoutExposingParserDetails() {
        HttpServletRequest request = mock(HttpServletRequest.class);
        when(request.getRequestURI()).thenReturn("/api/v1/auth/login");

        ResponseEntity<GlobalExceptionHandler.ProblemDetail> response = new GlobalExceptionHandler()
                .handleUnreadableRequest(
                        new HttpMessageNotReadableException(
                                "unexpected parser details",
                                mock(HttpInputMessage.class)
                        ),
                        request
                );

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("VALIDATION_ERROR", response.getBody().code());
        assertEquals("Request payload is malformed or unreadable", response.getBody().detail());
    }
}
