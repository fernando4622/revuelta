# ReVuelta Data Model Specification

**Status:** BLOCKED FOR FINAL APPROVAL until key identity decisions are resolved.

## 1. Data ownership principles

PostgreSQL is the authoritative persistence boundary for business state.

Business invariants are owned by the domain/application layer; relational invariants are additionally enforced by database constraints where appropriate.

## 2. Core conceptual records

### User
Represents an authenticated or operational actor when the approved identity model uses a local user record.

### Role
Represents a named authorization grouping.

### Permission
Represents an atomic authorization capability.

### Container
Represents one physical reusable container.

### Circulation
Represents one period of controlled possession.

### ContainerEvent / AuditEvent
Represents immutable traceability evidence of significant business operations.

### ReturnPolicy
Represents a versioned rule used to calculate due-at.

Exact relational decomposition MAY differ, but no table should exist without a documented responsibility.

## 3. Identity strategy

The final choice of primary keys MUST consider:

- natural business identity;
- immutability;
- uniqueness scope;
- privacy/exposure;
- API design;
- indexing/lookup;
- operational issuance.

**Decision required:** final PK strategy for users, containers, circulations, events, roles/permissions, and whether database PK differs from external API identifier.

The system MUST NOT introduce synthetic identifiers purely by habit.

## 4. Candidate relationships

Conceptually:

```text
User 1 ─── * Circulation (as actor/recipient depending identity model)
Container 1 ─── * Circulation
Container 1 ─── * ContainerEvent
Role * ─── * Permission
User * ─── * Role
ReturnPolicy 1 ─── * Circulation (effective policy provenance)
```

The exact cardinalities around recipient identity depend on D-002.

## 5. Required relational invariants

- `DR-001`: container identity is unique.
- `DR-002`: foreign keys preserve referential integrity.
- `DR-003`: required business fields are non-null.
- `DR-004`: audit/history records are not casually cascade-deleted.
- `DR-005`: one active circulation per container is enforceable under concurrency.
- `DR-006`: state/domain enumerations cannot silently accept unsupported values.
- `DR-007`: unique constraints exist where a domain identity must be unique.

## 6. Concurrency enforcement

The database MUST participate in enforcing the invariant that one container cannot have more than one active circulation. Exact mechanism is an ADR/data implementation decision: unique partial index, lock, or another verified approach.

The final implementation MUST prove the invariant under concurrent integration testing.

## 7. Audit/history

Audit/event records SHOULD be append-oriented and contain, where applicable:

- event identity;
- event type;
- aggregate/resource identity;
- actor identity;
- occurred-at server timestamp;
- correlation/request identifier;
- relevant outcome/context;
- immutable payload or normalized fields sufficient for audit.

Do not store secrets or unnecessary PII in audit payloads.

## 8. Time model

**Decision required:** one project-wide representation (recommended: UTC instants for timestamps, explicit business time-zone handling only for policy interpretation).

Business time MUST NOT depend on mobile device clock.

## 9. Deletion policy

Normal business operations MUST NOT hard-delete containers with history, circulations with history, or audit records.

Use deactivation/retirement and append-only correction semantics where the domain permits.

## 10. Migration policy

All schema changes MUST be migration-driven and versioned. Manual production edits are not part of the normal deployment workflow.

## 11. Data scenarios

### SC-DATA-001 Duplicate container identity
Given a container identifier already exists, when a second record tries to use it, then persistence rejects the duplicate.

### SC-DATA-002 Concurrent active circulation
Given one container and no active circulation, when two transactions attempt to create an active circulation concurrently, then at most one succeeds.

### SC-DATA-003 Historical integrity
Given completed circulation and audit history, when an administrator performs normal maintenance, then historical facts remain queryable and are not deleted through ordinary entity removal.
