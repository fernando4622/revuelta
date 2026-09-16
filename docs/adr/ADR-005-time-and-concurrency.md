# ADR-005 — Server-Authoritative Time and Explicit Concurrency Control

**Status:** ACCEPTED BASELINE

## Decision

Business timestamps are authoritative from the server/database, not the mobile device.

Critical invariants must survive concurrent requests through a deliberate combination of application transactions, database constraints, and an explicitly selected locking/conditional-update strategy.

## Consequences

- manipulated device clocks cannot alter due/return semantics;
- race conditions become testable requirements;
- persistence schema participates in business integrity where appropriate.

## Open decisions

Exact time representation/time zone policy and exact concurrency mechanism are finalized in data/feature specs and ADRs when implementation requires them.
