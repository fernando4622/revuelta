# ADR-001 — Clean Architecture + Hexagonal Boundaries

**Status:** ACCEPTED BASELINE

## Context

ReVuelta must maintain business correctness independently from Spring, PostgreSQL, HTTP, Flutter widgets, QR hardware APIs, and external services.

## Decision

Use Clean Architecture with DDD tactical modeling and ports/adapters boundaries.

Backend conceptual layers:

```text
interfaces → application → domain
infrastructure → implements ports
```

Flutter conceptual layers:

```text
presentation → application → domain ← data/infrastructure adapters
```

## Consequences

### Positive

- business rules are testable without frameworks;
- transport and persistence can evolve independently;
- AI-generated changes have explicit dependency boundaries;
- domain state transitions become enforceable.

### Negative

- more explicit mapping code;
- more up-front modeling;
- some small features cross multiple layers.

## Rejected alternatives

- controller-driven business logic;
- active-record domain model;
- generic CRUD service/repository architecture.
