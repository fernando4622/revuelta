# Feature Spec — Return Container

**Status:** BLOCKED until D-001, D-005, D-006, D-007, D-008, D-009 and D-010 are resolved.

## Purpose

Record the effective return of a container from an active circulation, classify punctuality, transition lifecycle state, and preserve traceability.

## Actor
Authorized operational actor defined by the final role matrix.

## Preconditions

- actor authenticated and authorized;
- container exists and is active;
- active circulation exists;
- return operation is permitted for current state;
- server time can be obtained;
- circulation is not already finalized.

## Outputs

Success MUST provide:

- circulation identity;
- returned-at authoritative timestamp;
- punctuality classification;
- resulting container state;
- trace/correlation identifier as appropriate.

## Business rules

- returned-at cannot precede delivered-at;
- `ON_TIME`/`LATE` classification is server-authoritative;
- finalized circulation cannot be finalized again;
- transition + circulation finalization + trace event are atomic.

## Failures

```text
UNAUTHENTICATED
FORBIDDEN_OPERATION
INVALID_QR
CONTAINER_NOT_FOUND
CIRCULATION_NOT_FOUND
RETURN_ALREADY_REGISTERED
INVALID_STATE_TRANSITION
CONCURRENCY_CONFLICT
```
