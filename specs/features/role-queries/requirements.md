# Feature Spec — Role-owned operational queries

**Status:** APPROVED FOR F7 IMPLEMENTATION.

## Purpose

Replace hard-coded mobile business data with server-owned read models for the
three authenticated pilot perspectives.

## Scope and actors

- `PARTICIPANT`: own active and completed circulations only;
- `OPERATOR`: pending-wash queue and the authenticated operator's recent handoff/wash events;
- `ADMIN`: pilot summary, participant references, container inventory/detail,
  circulations and append-only events.

## Preconditions and permissions

- every query requires a valid signed session;
- the server derives account/participant/actor identity from the session;
- participant ownership is enforced server-side and another participant's
  circulation is returned as not found;
- Cafetería queries expose no unnecessary participant personal data;
- only `ADMIN` may use global inventory, circulation and audit queries.

## Inputs

- zero-based `page` and bounded `size`;
- optional documented status/type filters;
- optional case-insensitive container-code search for inventory;
- resource identifier only for a permitted detail query.

Invalid pagination or unsupported filters produce `VALIDATION_ERROR`.

## Outputs

Paged responses contain `items`, `page`, `size` and `hasNext`. Business time is
returned as UTC instants. Container state labels are supplied by the server read
model and the mobile client does not infer allowed mutations from them.

## State changes

Queries are read-only and idempotent. They create no history and mutate no
circulation, container, participant or token.

## Expected errors

```text
UNAUTHENTICATED
FORBIDDEN_OPERATION
PARTICIPANT_ACCOUNT_NOT_LINKED
CIRCULATION_NOT_FOUND
CONTAINER_NOT_FOUND
VALIDATION_ERROR
```

## Acceptance

- a participant sees zero, one or multiple own active circulations;
- personal history is paginated and never contains another participant;
- pending wash contains only `RETURNED` containers and their returned-at time;
- recent Cafetería operations contain only the authenticated actor's delivery,
  return and wash events;
- ReVuelta metrics and lists are derived exclusively from persisted records;
- global audit remains append-only and read-only.

## Non-goals

- notification delivery;
- impact calculations;
- incident creation/resolution;
- exceptional lifecycle corrections;
- editing or deleting history;
- exposing names, email or matrícula in operational query results.
