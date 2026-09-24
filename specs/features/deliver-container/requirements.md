# Feature Spec — Deliver Container

**Status:** APPROVED FOR F5 IMPLEMENTATION. Dual-QR proof, authorization, replay, concurrency and participant identity are resolved.

## Purpose

Record the physical delivery of one available reusable container to one participant as one atomic operation.

## Actor

Authorized Cafetería actor.

## Preconditions

- actor is authenticated and authorized;
- a current `DELIVERY` participant operation QR is presented and participant is active;
- the current signed container QR is presented;
- container is active and `AVAILABLE`;
- effective return policy exists;
- container has no active circulation.

The participant MAY already have other active circulations.

## Inputs

- complete signed participant operation QR payload;
- complete signed container QR payload.

Both payloads are untrusted input and MUST be decoded and validated again by the
delivery transaction. A client-provided participant or container identifier is
not accepted as proof that either QR was scanned. Client timestamps and target
state are prohibited.

## Outputs

- circulation identity;
- participant reference;
- container identity/public code;
- effective `IN_USE` state;
- delivered-at server timestamp;
- due-at;
- policy identity/version;
- trace/correlation reference.

## State changes

```text
AVAILABLE → IN_USE
```

One transaction creates the circulation, transitions the container and appends one delivery event.

## Business rules

- one active circulation per container;
- multiple active circulations per participant are allowed;
- both participant and container QR values are mandatory;
- possession of either QR never authorizes delivery;
- the `DELIVERY` token is consumed atomically only on successful delivery;
- due-at derives from captured effective policy;
- failure produces no partial mutation.

## Failure catalog

```text
UNAUTHENTICATED
FORBIDDEN_OPERATION
QR_EXPIRED
QR_ALREADY_USED
QR_PURPOSE_MISMATCH
QR_TAMPERED
UNSUPPORTED_QR_VERSION
PARTICIPANT_NOT_FOUND
PARTICIPANT_INACTIVE
INVALID_QR
CONTAINER_NOT_FOUND
CONTAINER_QR_REVOKED
INACTIVE_CONTAINER
CONTAINER_NOT_AVAILABLE
ACTIVE_CIRCULATION_EXISTS
POLICY_NOT_FOUND
VALIDATION_ERROR
CONCURRENCY_CONFLICT
```

## Acceptance

- valid delivery creates one active circulation;
- a participant with another container may receive an additional eligible container;
- the delivered container becomes `IN_USE`;
- due-at and policy provenance are stored;
- exactly one delivery event exists;
- duplicate/concurrent requests cannot create two active circulations for the same container.
