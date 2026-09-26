package com.revuelta.api.interfaces.rest;

import com.revuelta.api.application.query.OperatorActivityQueryUseCase;
import com.revuelta.api.application.query.OperatorQueueQueryUseCase;
import com.revuelta.api.application.query.OperationsCirculationQueryUseCase;
import com.revuelta.api.application.query.OperationsEventQueryUseCase;
import com.revuelta.api.application.query.OperationsSummaryQueryUseCase;
import com.revuelta.api.application.query.ParticipantCirculationQueryUseCase;
import com.revuelta.api.application.query.ParticipantDirectoryQueryUseCase;
import com.revuelta.api.domain.circulation.CirculationId;
import com.revuelta.api.domain.circulation.CirculationStatus;
import com.revuelta.api.domain.event.ContainerEventType;
import com.revuelta.api.domain.user.UserId;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class RoleExperienceController {
    private final ParticipantCirculationQueryUseCase participantCirculations;
    private final OperatorQueueQueryUseCase operatorQueue;
    private final OperatorActivityQueryUseCase operatorActivity;
    private final OperationsSummaryQueryUseCase operationsSummary;
    private final ParticipantDirectoryQueryUseCase participantDirectory;
    private final OperationsCirculationQueryUseCase operationsCirculations;
    private final OperationsEventQueryUseCase operationsEvents;

    @GetMapping("/me/circulations")
    @PreAuthorize("hasRole('PARTICIPANT')")
    public ResponseEntity<PageResponse<ParticipantCirculationQueryUseCase.Item>> myCirculations(
            @AuthenticationPrincipal String accountId,
            @RequestParam(required = false) CirculationStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(PageResponse.from(
                participantCirculations.list(new UserId(UUID.fromString(accountId)), status, page, size), item -> item
        ));
    }

    @GetMapping("/me/circulations/{circulationId}")
    @PreAuthorize("hasRole('PARTICIPANT')")
    public ResponseEntity<ParticipantCirculationQueryUseCase.Item> myCirculation(
            @AuthenticationPrincipal String accountId,
            @PathVariable UUID circulationId
    ) {
        return ResponseEntity.ok(participantCirculations.get(
                new UserId(UUID.fromString(accountId)), new CirculationId(circulationId)
        ));
    }

    @GetMapping("/operator/pending-washes")
    @PreAuthorize("hasRole('OPERATOR')")
    public ResponseEntity<PageResponse<OperatorQueueQueryUseCase.Item>> pendingWashes(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(PageResponse.from(operatorQueue.execute(page, size), item -> item));
    }

    @GetMapping("/operator/recent-operations")
    @PreAuthorize("hasRole('OPERATOR')")
    public ResponseEntity<PageResponse<OperatorActivityQueryUseCase.Item>> recentOperations(
            @AuthenticationPrincipal String actorId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(PageResponse.from(
                operatorActivity.execute(new UserId(UUID.fromString(actorId)), page, size), item -> item
        ));
    }

    @GetMapping("/operations/summary")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<OperationsSummaryQueryUseCase.Summary> summary() {
        return ResponseEntity.ok(operationsSummary.execute());
    }

    @GetMapping("/operations/participants")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PageResponse<ParticipantDirectoryQueryUseCase.Item>> participants(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(PageResponse.from(participantDirectory.execute(page, size), item -> item));
    }

    @GetMapping("/operations/circulations")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PageResponse<OperationsCirculationQueryUseCase.Item>> circulations(
            @RequestParam(required = false) CirculationStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(PageResponse.from(
                operationsCirculations.execute(status, page, size), item -> item
        ));
    }

    @GetMapping("/operations/events")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PageResponse<OperationsEventQueryUseCase.Item>> events(
            @RequestParam(required = false) ContainerEventType type,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(PageResponse.from(operationsEvents.execute(type, page, size), item -> item));
    }
}
