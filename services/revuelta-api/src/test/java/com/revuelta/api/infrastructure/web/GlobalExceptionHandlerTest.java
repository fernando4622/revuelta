package com.revuelta.api.infrastructure.web;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpInputMessage;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;

class GlobalExceptionHandlerTest {

    @Test
    void shouldMapNotFoundApplicationFailureWithoutLosingItsCode() {
        HttpServletRequest request = mockRequest("/api/v1/containers/missing");

        ResponseEntity<GlobalExceptionHandler.ProblemDetail> response = new GlobalExceptionHandler()
                .handleApplicationFailure(
                        new ApplicationFailureException(FailureCode.CONTAINER_NOT_FOUND, "Container was not found"),
                        request
                );

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("CONTAINER_NOT_FOUND", response.getBody().code());
    }

    @Test
    void shouldMapConflictApplicationFailureWithoutLosingItsCode() {
        HttpServletRequest request = mockRequest("/api/v1/circulations");

        ResponseEntity<GlobalExceptionHandler.ProblemDetail> response = new GlobalExceptionHandler()
                .handleApplicationFailure(
                        new ApplicationFailureException(FailureCode.ACTIVE_CIRCULATION_EXISTS, "Active circulation exists"),
                        request
                );

        assertEquals(HttpStatus.CONFLICT, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("ACTIVE_CIRCULATION_EXISTS", response.getBody().code());
    }

    @Test
    void shouldReturnBadRequestForMalformedJsonWithoutExposingParserDetails() {
        HttpServletRequest request = mockRequest("/api/v1/auth/login");

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

    private HttpServletRequest mockRequest(String uri) {
        HttpServletRequest request = mock(HttpServletRequest.class);
        when(request.getRequestURI()).thenReturn(uri);
        return request;
    }
}
