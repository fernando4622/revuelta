# Feature Spec — Return Container

**Status:** PRODUCT BEHAVIOR APPROVED. Authentication, replay, time and concurrency foundations are resolved; container-QR resolution and the complete feature slice remain pending.

## Purpose

Record Cafetería's physical receipt of a container, finalize its active circulation, unlink possession from the participant and place the container in the pending-wash state.

## Actor

Authorized Cafetería actor.

Alumno cannot finalize the return.

## Preconditions

- actor is authenticated and authorized;
- a current `RETURN` participant operation QR was resolved;
- container resolves from valid QR;
- container is active and `IN_USE`;
- exactly one active circulation exists;
- that circulation belongs to the participant resolved by the dynamic QR;
- server time is available;
- circulation is not finalized.

Both QR values are mandatory during return. There is no manual or absent-participant exception.

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
- the `RETURN` token is consumed in that same transaction and cannot be reused.

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
