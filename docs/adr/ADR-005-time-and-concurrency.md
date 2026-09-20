# ADR-005 — Server-Authoritative Time and Explicit Concurrency Control

**Status:** ACCEPTED

## Decision

Business timestamps are authoritative from the server, not the mobile device. Java uses `Instant`, PostgreSQL uses `TIMESTAMP WITH TIME ZONE`, and the API emits ISO 8601 UTC values.

Critical invariants survive concurrent requests through application transactions and the smallest database mechanisms that protect each invariant:

- a partial unique index allows at most one `ACTIVE` circulation per container;
- optimistic version columns protect container and circulation state updates;
- state-consistency checks reject incomplete return data;
- foreign keys use restrictive deletion for operational history.

For the MVP, a replay after a successful mutation is reported as the stable conflict associated with the resulting state. No client `Idempotency-Key` is accepted or stored.

## Consequences

- manipulated device clocks cannot alter due/return semantics;
- race conditions become testable requirements;
- persistence schema participates in business integrity where appropriate.
- two concurrent deliveries cannot both create active circulation rows;
- two stale state transitions cannot both commit their aggregate update and event;
- a participant remains free to hold several different containers;
- replaying a mutation does not reproduce the original response; this tradeoff must be revisited if pilot evidence requires stored idempotency keys.
