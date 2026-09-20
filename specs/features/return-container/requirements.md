# Feature Spec — Return Container

**Status:** PRODUCT BEHAVIOR APPROVED. Implementation remains blocked by authentication, idempotency, time and concurrency decisions.

## Purpose

Record Cafetería's physical receipt of a container, finalize its active circulation, unlink possession from the participant and place the container in the pending-wash state.

## Actor

Authorized Cafetería actor.

Alumno cannot finalize the return.

## Preconditions

- actor is authenticated and authorized;
- container resolves from valid QR;
- container is active and `IN_USE`;
- exactly one active circulation exists;
- server time is available;
- circulation is not finalized.

Participant Code is not required during return.

## Outputs

- circulation identity;
- participant reference;
- returned-at server timestamp;
- punctuality;
- resulting `RETURNED` state;
- display meaning “Pendiente de lavado”;
- trace/correlation reference.

## State changes

```text
IN_USE → RETURNED
```

The circulation is completed in the same transaction. The container is no longer in the participant's possession but is not available for another delivery.

## Business rules

- returned-at cannot precede delivered-at;
- punctuality is server-authoritative;
- a finalized circulation cannot be finalized again;
- return does not perform wash completion;
- return finalization, lifecycle transition and event are atomic.

## Failure catalog

```text
UNAUTHENTICATED
FORBIDDEN_OPERATION
INVALID_QR
CONTAINER_NOT_FOUND
INACTIVE_CONTAINER
CIRCULATION_NOT_FOUND
RETURN_ALREADY_REGISTERED
INVALID_STATE_TRANSITION
VALIDATION_ERROR
CONCURRENCY_CONFLICT
```

## Acceptance

- valid return completes one circulation;
- participant possession is removed;
- container persists as `RETURNED`;
- one return event exists;
- duplicate/concurrent return cannot create another completion/event;
- only wash completion may later make the container `AVAILABLE`.
