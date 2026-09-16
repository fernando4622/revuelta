# ADR-003 — Explicit Container State Machine

**Status:** ACCEPTED BASELINE; transition matrix itself remains domain-spec controlled.

## Decision

Container lifecycle is modeled as an explicit state machine. State cannot be mutated through generic setters from external layers.

Every transition is a domain/application operation that validates preconditions and produces traceability.

## Consequences

- impossible transitions are rejected;
- tests can enumerate transition behavior;
- UI cannot bypass domain semantics;
- database state remains interpretable.

## Open semantic decision

Whether `ASSIGNED`, `IN_USE`, and `RETURNED` are all independently meaningful states must be settled in the lifecycle spec before implementation.
