# Feature Spec — Complete Container Washing

**Status:** PRODUCT BEHAVIOR APPROVED. Authentication, idempotency and concurrency details remain required for implementation.

## Purpose

Make a physically returned container eligible for reuse only after Cafetería confirms washing.

## Actor

Authorized Cafetería actor.

Operación ReVuelta may investigate/correct through a separate reasoned support use case, not the normal wash action.

## Preconditions

- actor authenticated and authorized;
- container exists and is active;
- current state is `RETURNED`;
- no active circulation exists.

## Inputs

- container reference/QR;
- request/idempotency metadata.

## Outputs

- container identity/public code;
- resulting `AVAILABLE` state;
- washed-at server timestamp;
- actor;
- trace/correlation reference.

## State change

```text
RETURNED → AVAILABLE
```

## Rules

- washing does not change the completed circulation;
- client time is not authoritative;
- duplicate/concurrent completion creates at most one effective transition/event;
- no generic status endpoint is used.

## Failures

```text
UNAUTHENTICATED
FORBIDDEN_OPERATION
CONTAINER_NOT_FOUND
INACTIVE_CONTAINER
CONTAINER_NOT_RETURNED
WASH_ALREADY_COMPLETED
INVALID_STATE_TRANSITION
CONCURRENCY_CONFLICT
```

## Acceptance

- returned container becomes available after one confirmed wash;
- non-returned container cannot use this operation;
- one wash event exists;
- completed circulation remains immutable.
