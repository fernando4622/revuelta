package com.revuelta.api.interfaces.rest;

import com.revuelta.api.application.auth.LoginUseCase;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final LoginUseCase loginUseCase;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        var result = loginUseCase.execute(request.username(), request.password());
        return ResponseEntity.ok(new LoginResponse(
                result.accessToken(),
                "Bearer",
                result.userId(),
                result.username(),
                result.role()
        ));
    }

    public record LoginRequest(
            @NotBlank(message = "Username must not be blank") String username,
            @NotBlank(message = "Password must not be blank") String password
    ) {}

    public record LoginResponse(
            String token,
            String tokenType,
            String userId,
            String username,
            String role
    ) {}
}
