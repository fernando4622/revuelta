package com.revuelta.api.interfaces.rest;

import com.revuelta.api.application.container.ActivateContainerUseCase;
import com.revuelta.api.application.container.GetContainerUseCase;
import com.revuelta.api.application.container.ListContainersUseCase;
import com.revuelta.api.application.container.RegisterContainerUseCase;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerCode;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.user.UserId;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/containers")
@RequiredArgsConstructor
public class ContainerController {

    private final RegisterContainerUseCase registerContainerUseCase;
    private final ActivateContainerUseCase activateContainerUseCase;
    private final GetContainerUseCase getContainerUseCase;
    private final ListContainersUseCase listContainersUseCase;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ContainerResponse> register(@Valid @RequestBody RegisterContainerRequest request) {
        Container container = registerContainerUseCase.execute(request.code());
        return ResponseEntity.status(HttpStatus.CREATED).body(ContainerResponse.fromDomain(container));
    }

    @PostMapping("/{containerId}/activate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ContainerResponse> activate(
            @PathVariable UUID containerId,
            @AuthenticationPrincipal String actorIdString,
            @RequestBody(required = false) ActivateRequest request
    ) {
        String reason = (request != null && request.reason() != null) ? request.reason() : "Activation";
        UserId actorId = new UserId(UUID.fromString(actorIdString));
        Container container = activateContainerUseCase.execute(new ContainerId(containerId), actorId, reason);
        return ResponseEntity.ok(ContainerResponse.fromDomain(container));
    }

    @GetMapping("/{containerId}")
    @PreAuthorize("hasAnyRole('OPERATOR', 'ADMIN')")
    public ResponseEntity<ContainerResponse> getById(@PathVariable UUID containerId) {
        return getContainerUseCase.findById(new ContainerId(containerId))
                .map(ContainerResponse::fromDomain)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("hasAnyRole('OPERATOR', 'ADMIN')")
    public ResponseEntity<ContainerResponse> getByCode(@PathVariable String code) {
        return getContainerUseCase.findByCode(new ContainerCode(code))
                .map(ContainerResponse::fromDomain)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('OPERATOR', 'ADMIN')")
    public ResponseEntity<List<ContainerResponse>> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        List<ContainerResponse> containers = listContainersUseCase.execute(page, size)
                .stream()
                .map(ContainerResponse::fromDomain)
                .toList();
        return ResponseEntity.ok(containers);
    }

    public record RegisterContainerRequest(@NotBlank(message = "Code must not be blank") String code) {}
    public record ActivateRequest(String reason) {}

    public record ContainerResponse(
            String id,
            String code,
            String status,
            Instant createdAt,
            Instant updatedAt,
            boolean eligibleForCirculation
    ) {
        public static ContainerResponse fromDomain(Container c) {
            return new ContainerResponse(
                    c.id().value().toString(),
                    c.code().value(),
                    c.status().name(),
                    c.createdAt(),
                    c.updatedAt(),
                    c.isEligibleForCirculation()
            );
        }
    }
}
