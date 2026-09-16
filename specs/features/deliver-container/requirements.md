# Feature Spec — Deliver Container

**Status:** BLOCKED until D-001, D-002, D-005, D-007, D-008, D-010 and D-013 are resolved.

## Purpose

Record the delivery of one eligible reusable container to one recipient as one atomic business operation.

## Actor
Authorized operational actor defined by the final role matrix.

## Preconditions

- actor is authenticated;
- actor is authorized;
- container resolves from valid QR/identifier;
- container is active and eligible;
- recipient identity is valid;
- effective return policy exists;
- no active circulation exists for container.

## Inputs

- container identifier resolved from QR;
- recipient reference;
- client request/idempotency metadata as defined by API contract.

Client-provided timestamps are not authoritative.

## Outputs

Success MUST provide enough data for client to render:

- circulation identity;
- container identity;
- effective state;
- delivered-at authoritative timestamp;
- due-at timestamp;
- trace identifier/correlation reference where appropriate.

## Business rules

- no duplicate active circulation;
- due-at derives from effective policy;
- one transaction covers circulation creation, lifecycle transition, and trace event;
- failure means no partial mutation.

## Failure catalog

At minimum:

```text
UNAUTHENTICATED
FORBIDDEN_OPERATION
INVALID_QR
CONTAINER_NOT_FOUND
INACTIVE_CONTAINER
CONTAINER_NOT_AVAILABLE
ACTIVE_CIRCULATION_EXISTS
RECIPIENT_INVALID
POLICY_NOT_FOUND
VALIDATION_ERROR
CONCURRENCY_CONFLICT
```

## Acceptance

- valid delivery creates exactly one active circulation;
- container reaches defined delivery state;
- due-at is reproducible from policy/version;
- trace event exists;
- duplicate/concurrent requests cannot create two active circulations.
