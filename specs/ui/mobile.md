# ReVuelta Mobile UI Specification

**Status:** BLOCKED FOR FINAL APPROVAL until role matrix and lifecycle semantics are approved.

## 1. UI architecture

```text
Page/Widget
→ Controller / State Notifier / ViewModel
→ Use Case
→ Domain
→ Repository interface
→ Remote/local adapter
```

Widgets MUST NOT call HTTP directly, mutate domain objects directly, or contain authoritative business rules.

## 2. Global asynchronous state model

Do not use contradictory boolean combinations. Use a discriminated state model such as:

```text
Initial
Loading
Success(data)
Failure(failure)
```

Multi-step screens use explicit state machines.

## 3. Required screens/journeys for V1

### Authentication
- login;
- session restoration where applicable;
- logout;
- authentication failure.

### Operator home
- operational entry points based on permission;
- no security decision is made client-side.

### Scan
States MUST include at least:

```text
Idle
RequestingCameraPermission
ReadyToScan
Scanning
Resolving
Resolved
InvalidQr
ContainerNotFound
ContainerInactive
NetworkFailure
```

Exact UI states can be collapsed only if behavior remains unambiguous.

### Container detail
Must render, where permitted:

- identifier;
- current state;
- active circulation information;
- actionable operations for current actor;
- relevant recent history.

### Delivery flow
Must prevent accidental duplicate submit and reflect server result explicitly.

### Return flow
Must clearly show the resulting classification (`ON_TIME` / `LATE`) only after the server confirms the operation.

### History
Read-only presentation of immutable operational history.

## 4. Offline/network policy

**Decision required:** whether V1 supports any offline mutation. Default recommendation: no offline business mutation in V1; scan/UI may gracefully recover from network failures but must not fabricate successful deliveries/returns offline.

## 5. User feedback

The UI MUST distinguish:

- validation errors;
- authentication errors;
- permission denial;
- resource not found;
- business conflict;
- network/dependency failure;
- unknown/unexpected failure.

## 6. Navigation rules

Navigation should derive from authenticated application state and permissions, not from hard-coded assumptions about roles.

## 7. Accessibility baseline

Critical operational controls MUST have:

- meaningful labels;
- sufficient touch target size;
- readable error feedback;
- non-color-only state indication;
- loading and failure states understandable without timing assumptions.
