package com.revuelta.api.interfaces.rest;

import com.revuelta.api.application.container.ActivateContainerUseCase;
import com.revuelta.api.application.container.GetContainerUseCase;
import com.revuelta.api.application.container.ListContainersUseCase;
import com.revuelta.api.application.container.RegisterContainerUseCase;
import com.revuelta.api.application.container.CompleteContainerWashUseCase;
import com.revuelta.api.domain.container.Container;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.user.UserId;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/containers")
@RequiredArgsConstructor
@Validated
public class ContainerController {

    private final RegisterContainerUseCase registerContainerUseCase;
    private final ActivateContainerUseCase activateContainerUseCase;
    private final GetContainerUseCase getContainerUseCase;
    private final ListContainersUseCase listContainersUseCase;
    private final CompleteContainerWashUseCase completeContainerWashUseCase;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RegisteredContainerResponse> register(
            @Valid @RequestBody RegisterContainerRequest request,
            @AuthenticationPrincipal String actorIdString
    ) {
        var result = registerContainerUseCase.execute(
                request.code(), new UserId(UUID.fromString(actorIdString))
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(
                RegisteredContainerResponse.fromResult(result)
        );
    }

    @PostMapping("/{containerId}/activate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ContainerResponse> activate(
            @PathVariable UUID containerId,
            @AuthenticationPrincipal String actorIdString,
            @Valid @RequestBody(required = false) ActivateRequest request
    ) {
        String reason = (request != null && request.reason() != null) ? request.reason() : "Activation";
        UserId actorId = new UserId(UUID.fromString(actorIdString));
        Container container = activateContainerUseCase.execute(new ContainerId(containerId), actorId, reason);
        return ResponseEntity.ok(ContainerResponse.fromDomain(container));
    }

    @GetMapping("/{containerId}")
    @PreAuthorize("hasAnyRole('OPERATOR', 'ADMIN')")
    public ResponseEntity<ContainerResponse> getById(@PathVariable UUID containerId) {
        Container container = getContainerUseCase.execute(new ContainerId(containerId));
        return ResponseEntity.ok(ContainerResponse.fromDomain(container));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PageResponse<ContainerResponse>> list(
            @RequestParam(required = false)
            @Size(max = 64, message = "query must contain at most 64 characters") String query,
            @RequestParam(required = false) com.revuelta.api.domain.container.ContainerStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(PageResponse.from(
                listContainersUseCase.execute(query, status, page, size), ContainerResponse::fromDomain
        ));
    }

    @PostMapping("/{containerId}/wash-completions")
    @PreAuthorize("hasRole('OPERATOR')")
    public ResponseEntity<WashCompletionResponse> completeWash(
            @PathVariable UUID containerId,
            @AuthenticationPrincipal String actorIdString
    ) {
        var result = completeContainerWashUseCase.execute(
                new ContainerId(containerId), new UserId(UUID.fromString(actorIdString))
        );
        return ResponseEntity.ok(WashCompletionResponse.fromResult(result));
    }

    public record RegisterContainerRequest(
            @NotBlank(message = "Code must not be blank")
            @Size(max = 64, message = "Code must contain at most 64 characters") String code
    ) {}
    public record ActivateRequest(
            @Size(max = 500, message = "Reason must contain at most 500 characters") String reason
    ) {}

    public record RegisteredContainerResponse(
            String id,
            String code,
            String status,
            Instant createdAt,
            Instant updatedAt,
            boolean eligibleForCirculation,
            int qrGeneration,
            String qrPayload
    ) {
        public static RegisteredContainerResponse fromResult(RegisterContainerUseCase.Result result) {
            Container c = result.container();
            return new RegisteredContainerResponse(
                    c.id().value().toString(), c.code().value(), c.status().name(),
                    c.createdAt(), c.updatedAt(), c.isEligibleForCirculation(),
                    c.qrGeneration(), result.qrPayload()
            );
        }
    }

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

    public record WashContainerResponse(String id, String publicCode, String state, String stateLabel) {}

    public record WashCompletionResponse(WashContainerResponse container, Instant washedAt, String traceId) {
        static WashCompletionResponse fromResult(CompleteContainerWashUseCase.Result result) {
            var container = result.container();
            return new WashCompletionResponse(
                    new WashContainerResponse(
                            container.id().value().toString(), container.code().value(),
                            container.status().name(), "Disponible"
                    ),
                    result.washedAt(), result.traceId().toString()
            );
        }
    }
}
