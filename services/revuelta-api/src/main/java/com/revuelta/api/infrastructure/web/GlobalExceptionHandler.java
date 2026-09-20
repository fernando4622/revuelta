package com.revuelta.api.infrastructure.web;

import com.revuelta.api.application.auth.AuthenticationFailureException;
import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCategory;
import com.revuelta.api.domain.container.ContainerTransitionException;
import com.revuelta.api.domain.circulation.CirculationTransitionException;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

import java.time.Instant;
import java.util.List;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ProblemDetail> handleAuthenticationRequired(
            AuthenticationException ex,
            HttpServletRequest request
    ) {
        return buildProblem(
                HttpStatus.UNAUTHORIZED,
                "UNAUTHENTICATED",
                "Authentication is required or the supplied token is invalid",
                request
        );
    }

    @ExceptionHandler(AuthenticationFailureException.class)
    public ResponseEntity<ProblemDetail> handleAuthenticationFailure(
            AuthenticationFailureException ex,
            HttpServletRequest request
    ) {
        return buildProblem(
                HttpStatus.UNAUTHORIZED,
                "INVALID_CREDENTIALS",
                "Invalid username or password",
                request
        );
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ProblemDetail> handleIllegalArgument(IllegalArgumentException ex, HttpServletRequest request) {
        return buildProblem(HttpStatus.BAD_REQUEST, "VALIDATION_ERROR", ex.getMessage(), request);
    }

    @ExceptionHandler(ApplicationFailureException.class)
    public ResponseEntity<ProblemDetail> handleApplicationFailure(
            ApplicationFailureException ex,
            HttpServletRequest request
    ) {
        HttpStatus status = ex.code().category() == FailureCategory.NOT_FOUND
                ? HttpStatus.NOT_FOUND
                : HttpStatus.CONFLICT;
        return buildProblem(status, ex.code().name(), ex.getMessage(), request);
    }

    @ExceptionHandler(ContainerTransitionException.class)
    public ResponseEntity<ProblemDetail> handleContainerTransition(ContainerTransitionException ex, HttpServletRequest request) {
        return buildProblem(HttpStatus.CONFLICT, "INVALID_STATE_TRANSITION", ex.getMessage(), request);
    }

    @ExceptionHandler(CirculationTransitionException.class)
    public ResponseEntity<ProblemDetail> handleCirculationTransition(
            CirculationTransitionException ex,
            HttpServletRequest request
    ) {
        return buildProblem(HttpStatus.CONFLICT, "RETURN_ALREADY_REGISTERED", ex.getMessage(), request);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ProblemDetail> handleAccessDenied(AccessDeniedException ex, HttpServletRequest request) {
        return buildProblem(HttpStatus.FORBIDDEN, "FORBIDDEN_OPERATION", "You are not authorized to perform this operation", request);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ProblemDetail> handleValidation(MethodArgumentNotValidException ex, HttpServletRequest request) {
        List<String> errors = ex.getBindingResult().getFieldErrors().stream()
                .map(err -> err.getField() + ": " + err.getDefaultMessage())
                .toList();

        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .contentType(MediaType.APPLICATION_PROBLEM_JSON)
                .body(new ProblemDetail(
                        "https://revuelta.app/problems/validation-error",
                        "Validation Error",
                        HttpStatus.BAD_REQUEST.value(),
                        "VALIDATION_ERROR",
                        "Request payload validation failed",
                        request.getRequestURI(),
                        CorrelationId.resolve(request),
                        Instant.now(),
                        errors
                ));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ProblemDetail> handleUnreadableRequest(
            HttpMessageNotReadableException ex,
            HttpServletRequest request
    ) {
        return buildProblem(
                HttpStatus.BAD_REQUEST,
                "VALIDATION_ERROR",
                "Request payload is malformed or unreadable",
                request
        );
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ProblemDetail> handleTypeMismatch(
            MethodArgumentTypeMismatchException ex,
            HttpServletRequest request
    ) {
        return buildProblem(
                HttpStatus.BAD_REQUEST,
                "VALIDATION_ERROR",
                "Request parameter has an invalid format",
                request
        );
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ProblemDetail> handleUnexpected(Exception ex, HttpServletRequest request) {
        String traceId = CorrelationId.resolve(request);
        log.error("Unexpected server failure [traceId={}]: ", traceId, ex);

        return buildProblem(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "INTERNAL_SERVER_ERROR",
                "An unexpected internal error occurred. Please reference traceId: " + traceId,
                request
        );
    }

    private ResponseEntity<ProblemDetail> buildProblem(
            HttpStatus status,
            String code,
            String detail,
            HttpServletRequest request
    ) {
        ProblemDetail problem = new ProblemDetail(
                "https://revuelta.app/problems/" + code.toLowerCase().replace('_', '-'),
                status.getReasonPhrase(),
                status.value(),
                code,
                detail,
                request.getRequestURI(),
                CorrelationId.resolve(request),
                Instant.now(),
                List.of()
        );
        return ResponseEntity.status(status)
                .contentType(MediaType.APPLICATION_PROBLEM_JSON)
                .body(problem);
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
