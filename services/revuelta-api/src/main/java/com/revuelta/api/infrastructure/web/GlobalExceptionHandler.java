package com.revuelta.api.infrastructure.web;

import com.revuelta.api.domain.container.ContainerTransitionException;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ProblemDetail> handleIllegalArgument(IllegalArgumentException ex, HttpServletRequest request) {
        return buildProblem(HttpStatus.BAD_REQUEST, "VALIDATION_ERROR", ex.getMessage(), request.getRequestURI());
    }

    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<ProblemDetail> handleIllegalState(IllegalStateException ex, HttpServletRequest request) {
        return buildProblem(HttpStatus.CONFLICT, "BUSINESS_CONFLICT", ex.getMessage(), request.getRequestURI());
    }

    @ExceptionHandler(ContainerTransitionException.class)
    public ResponseEntity<ProblemDetail> handleContainerTransition(ContainerTransitionException ex, HttpServletRequest request) {
        return buildProblem(HttpStatus.CONFLICT, "INVALID_STATE_TRANSITION", ex.getMessage(), request.getRequestURI());
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ProblemDetail> handleAccessDenied(AccessDeniedException ex, HttpServletRequest request) {
        return buildProblem(HttpStatus.FORBIDDEN, "FORBIDDEN_OPERATION", "You are not authorized to perform this operation", request.getRequestURI());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ProblemDetail> handleValidation(MethodArgumentNotValidException ex, HttpServletRequest request) {
        List<String> errors = ex.getBindingResult().getFieldErrors().stream()
                .map(err -> err.getField() + ": " + err.getDefaultMessage())
                .toList();

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ProblemDetail(
                "https://revuelta.app/problems/validation-error",
                "Validation Error",
                HttpStatus.BAD_REQUEST.value(),
                "VALIDATION_ERROR",
                "Request payload validation failed",
                request.getRequestURI(),
                UUID.randomUUID().toString(),
                Instant.now(),
                errors
        ));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ProblemDetail> handleUnexpected(Exception ex, HttpServletRequest request) {
        String traceId = UUID.randomUUID().toString();
        log.error("Unexpected server failure [traceId={}]: ", traceId, ex);

        return buildProblem(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "INTERNAL_SERVER_ERROR",
                "An unexpected internal error occurred. Please reference traceId: " + traceId,
                request.getRequestURI(),
                traceId
        );
    }

    private ResponseEntity<ProblemDetail> buildProblem(HttpStatus status, String code, String detail, String instance) {
        return buildProblem(status, code, detail, instance, UUID.randomUUID().toString());
    }

    private ResponseEntity<ProblemDetail> buildProblem(HttpStatus status, String code, String detail, String instance, String traceId) {
        ProblemDetail problem = new ProblemDetail(
                "https://revuelta.app/problems/" + code.toLowerCase().replace('_', '-'),
                status.getReasonPhrase(),
                status.value(),
                code,
                detail,
                instance,
                traceId,
                Instant.now(),
                List.of()
        );
        return ResponseEntity.status(status).body(problem);
    }

    public record ProblemDetail(
            String type,
            String title,
            int status,
            String code,
            String detail,
            String instance,
            String traceId,
            Instant timestamp,
            List<String> errors
    ) {}
}
