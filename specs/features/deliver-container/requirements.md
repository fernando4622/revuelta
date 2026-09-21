# Feature Spec — Deliver Container

**Status:** PRODUCT BEHAVIOR APPROVED. Authentication, identifiers, replay and concurrency foundations are resolved; participant/QR resolution and the complete feature slice remain pending.

## Purpose

Record the physical delivery of one available reusable container to one participant as one atomic operation.

## Actor

Authorized Cafetería actor.

## Preconditions

- actor is authenticated and authorized;
- a current `DELIVERY` participant operation QR was resolved and participant is active;
- container QR was resolved;
- container is active and `AVAILABLE`;
- effective return policy exists;
- container has no active circulation.

The participant MAY already have other active circulations.

## Inputs

- participant operation token/reference from dynamic QR resolution;
- container reference from container QR resolution;
- idempotency/request metadata defined by API contract.

QR payloads and client timestamps are not authoritative.

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
PARTICIPANT_CODE_INVALID
PARTICIPANT_NOT_FOUND
PARTICIPANT_INACTIVE
INVALID_QR
CONTAINER_NOT_FOUND
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
