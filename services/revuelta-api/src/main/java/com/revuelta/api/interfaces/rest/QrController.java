package com.revuelta.api.interfaces.rest;

import com.revuelta.api.application.qr.GenerateOperationQrUseCase;
import com.revuelta.api.application.qr.GetContainerQrUseCase;
import com.revuelta.api.application.qr.ResolveContainerQrUseCase;
import com.revuelta.api.application.qr.ResolveOperationQrUseCase;
import com.revuelta.api.application.qr.RotateContainerQrUseCase;
import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.participant.OperationQrPurpose;
import com.revuelta.api.domain.user.UserId;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class QrController {
    private final GenerateOperationQrUseCase generateOperationQr;
    private final ResolveOperationQrUseCase resolveOperationQr;
    private final ResolveContainerQrUseCase resolveContainerQr;
    private final GetContainerQrUseCase getContainerQr;
    private final RotateContainerQrUseCase rotateContainerQr;

    @PostMapping("/me/operation-qrs")
    @PreAuthorize("hasRole('PARTICIPANT')")
    public ResponseEntity<OperationQrResponse> generateOperationQr(
            @Valid @RequestBody GenerateOperationQrRequest request,
            @AuthenticationPrincipal String accountId
    ) {
        var result = generateOperationQr.execute(
                new UserId(UUID.fromString(accountId)), request.purpose()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(OperationQrResponse.from(result));
    }

    @PostMapping("/operation-qr-resolutions")
    @PreAuthorize("hasRole('OPERATOR')")
    public ResolveOperationQrResponse resolveOperationQr(@Valid @RequestBody QrPayloadRequest request) {
        return ResolveOperationQrResponse.from(resolveOperationQr.execute(request.payload()));
    }

    @PostMapping("/container-qr-resolutions")
    @PreAuthorize("hasAnyRole('OPERATOR', 'ADMIN')")
    public ResolveContainerQrResponse resolveContainerQr(
            @Valid @RequestBody QrPayloadRequest request,
            Authentication authentication
    ) {
        String role = authentication.getAuthorities().iterator().next().getAuthority().replace("ROLE_", "");
        return ResolveContainerQrResponse.from(resolveContainerQr.execute(request.payload(), role));
    }

    @GetMapping("/containers/{containerId}/qr")
    @PreAuthorize("hasRole('ADMIN')")
    public ContainerQrResponse getContainerQr(@PathVariable UUID containerId) {
        return ContainerQrResponse.from(getContainerQr.execute(new ContainerId(containerId)));
    }

    @PostMapping("/containers/{containerId}/qr-rotations")
    @PreAuthorize("hasRole('ADMIN')")
    public ContainerQrResponse rotateContainerQr(
            @PathVariable UUID containerId,
            @Valid @RequestBody RotateContainerQrRequest request,
            @AuthenticationPrincipal String actorId
    ) {
        return ContainerQrResponse.from(rotateContainerQr.execute(
                new ContainerId(containerId), new UserId(UUID.fromString(actorId)), request.reason()
        ));
    }

    public record GenerateOperationQrRequest(@NotNull OperationQrPurpose purpose) {}
    public record QrPayloadRequest(@NotBlank String payload) {}
    public record RotateContainerQrRequest(@NotBlank String reason) {}

    public record OperationQrResponse(
            UUID tokenRef,
            String purpose,
            String payload,
            Instant issuedAt,
            Instant expiresAt
    ) {
        static OperationQrResponse from(GenerateOperationQrUseCase.Result result) {
            return new OperationQrResponse(
                    result.tokenRef(), result.purpose().name(), result.payload(),
                    result.issuedAt(), result.expiresAt()
            );
        }
    }

    public record ResolveOperationQrResponse(
            UUID tokenRef,
            UUID participantRef,
            String purpose,
            Instant expiresAt,
            String eligibility
    ) {
        static ResolveOperationQrResponse from(ResolveOperationQrUseCase.Result result) {
            return new ResolveOperationQrResponse(
                    result.tokenRef(), result.participantRef().value(), result.purpose().name(),
                    result.expiresAt(), result.eligibility()
            );
        }
    }

    public record ResolveContainerQrResponse(
            UUID containerRef,
            String displayCode,
            String state,
            String stateLabel,
            boolean eligibleForCirculation,
            ActiveCirculationResponse activeCirculation,
            List<String> allowedActions
    ) {
        static ResolveContainerQrResponse from(ResolveContainerQrUseCase.Result result) {
            ActiveCirculationResponse active = result.activeCirculation() == null
                    ? null : ActiveCirculationResponse.from(result.activeCirculation());
            return new ResolveContainerQrResponse(
                    result.containerRef(), result.displayCode(), result.state(), result.stateLabel(),
                    result.eligibleForCirculation(), active, result.allowedActions()
            );
        }
    }

    public record ActiveCirculationResponse(
            UUID circulationRef,
            UUID participantRef,
            Instant deliveredAt,
            Instant dueAt
    ) {
        static ActiveCirculationResponse from(ResolveContainerQrUseCase.ActiveCirculation active) {
            return new ActiveCirculationResponse(
                    active.circulationRef(), active.participantRef(), active.deliveredAt(), active.dueAt()
            );
        }
    }

    public record ContainerQrResponse(UUID containerRef, int generation, String payload) {
        static ContainerQrResponse from(GetContainerQrUseCase.Result result) {
            return new ContainerQrResponse(result.containerRef(), result.generation(), result.payload());
        }
    }
}
