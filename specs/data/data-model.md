# ReVuelta Data Model Specification

**Status:** APPROVED BASELINE. Participant relationships, lifecycle persistence, identifiers, time and concurrency are defined. Participant-code recovery remains open under D-018.

## 1. Data ownership

PostgreSQL is authoritative for persisted business state. Domain/application owns business semantics; database constraints protect relational invariants and races.

Application-generated UUID v4 values are both PostgreSQL primary keys and public API identifiers for the MVP. Business timestamps use Java `Instant`, ISO 8601 UTC values in the API and PostgreSQL `TIMESTAMP WITH TIME ZONE` in storage.

## 2. Core conceptual records

### AuthenticatedAccount

A provisioned login identity with credentials and exactly one recognized MVP role: `PARTICIPANT`, `OPERATOR` or `ADMIN`.

An authenticated account is not interchangeable with a Participant Code. Personal participant queries require an explicit account-to-participant association.

### StaffActor

Authenticated Cafetería or ReVuelta operations identity.

### Role / Permission

Authorization grouping and atomic capabilities.

### Participant

Stable pilot identity for a recipient. Contains no required personal profile fields.

### ParticipantCode

Opaque, scannable public identifier associated with one participant. Has active/inactive status, version and issuance audit fields.

### Container

One physical reusable container and its lifecycle state.

### Circulation

One period in which one participant holds one container.

### ContainerEvent / AuditEvent

Append-oriented evidence for issuance, delivery, return, wash completion, exceptions and corrections.

### ReturnPolicy

Versioned rule captured by each circulation to establish due-at.

## 3. Conceptual relationships

```text
Participant 1 ─── * ParticipantCode
Participant 1 ─── * Circulation
Container   1 ─── * Circulation
Container   1 ─── * ContainerEvent
AuthenticatedAccount * ─── 1 Role (MVP)
AuthenticatedAccount 0..1 ─── 1 Participant
StaffActor  1 ─── 1 AuthenticatedAccount
Role        * ─── * Permission
ReturnPolicy 1 ── * Circulation
```

A participant may have multiple active circulations. A container may have at most one.

## 4. Required ParticipantCode fields

- internal identity;
- participant foreign key;
- opaque public code/hash representation;
- payload format version;
- active flag/status;
- issued-at;
- issued-by;
- deactivated-at/by/reason where applicable.

The raw QR payload MUST NOT contain PII. Secrets/tokens MUST not be logged.

## 5. Required relational invariants

- `DR-001`: container identity and active QR are unique.
- `DR-002`: active Participant Code is unique and resolves to one participant.
- `DR-003`: circulation references existing participant and container.
- `DR-004`: one active circulation per container is enforced under concurrency.
- `DR-005`: no uniqueness constraint limits active circulations per participant.
- `DR-006`: `RETURNED` is persisted until wash completion.
- `DR-007`: audit/history cannot be cascade-deleted through normal maintenance.
- `DR-008`: required fields are non-null.
- `DR-009`: unsupported state values are rejected.
- `DR-010`: circulation preserves policy identity/version and due-at.
- `DR-011`: every enabled MVP account has exactly one recognized role; missing or ambiguous roles fail closed.
- `DR-012`: a `PARTICIPANT` account may read personal data only through an explicit account-to-participant association.
- `DR-013`: circulation lifecycle fields are internally consistent: active rows have no return fields, completed rows have all return fields, and return/due instants cannot precede delivery.
- `DR-014`: aggregate updates use optimistic locking so two stale writers cannot both commit state transitions and audit events.

## 6. Normal transaction boundaries

### Delivery transaction

- create circulation;
- update container `AVAILABLE → IN_USE`;
- append delivery event.

### Return transaction

- finalize circulation;
- update container `IN_USE → RETURNED`;
- append return event.

### Wash transaction

- update container `RETURNED → AVAILABLE`;
- append wash-completed event.

Each boundary commits all changes or none.

## 7. Audit fields

Events contain, where applicable:

- event identity/type;
- resource identity;
- actor identity;
- participant/circulation reference when relevant;
- previous and resulting state;
- server occurred-at;
- correlation/request identifier;
- reason for correction/exception;
- safe structured metadata.

No unnecessary PII, secrets or full QR payloads are stored in logs.

## 8. Time

Business time is server-authoritative and represented as UTC `Instant`. Clients never supply authoritative delivery, return or audit timestamps. Equality with `due_at` is `ON_TIME`; only a later instant is `LATE`.

## 9. Concurrency and replay policy

- Delivery uses the partial unique index `idx_circulations_active_container`; at most one active circulation for a container can commit.
- Mutable container and circulation aggregates use optimistic version columns. A stale competing transition rolls back as a typed conflict.
- A participant has no equivalent active-circulation uniqueness restriction and may hold multiple different containers.
- MVP mutation retries do not use a client idempotency key. A replay after a committed transition receives the stable conflict for the resulting state.
- Database uniqueness and optimistic-lock failures are translated at the persistence boundary; raw SQL details never cross the API.

## 10. Deletion and recovery

Containers, participants, circulations and events with history are not hard-deleted through normal operations.

Participant-code replacement remains blocked by D-018. Schema implementation must not assume that code replacement changes participant identity.

## 11. Data scenarios

### SC-DATA-001 — Participant code uniqueness

Given an active Participant Code exists,
when another active code record attempts to reuse its public value,
then persistence rejects it.

### SC-DATA-002 — Multiple participant circulations

Given one participant holds one container,
when a second different container is delivered,
then persistence permits both active circulations.

### SC-DATA-003 — Concurrent container delivery

Given one available container,
when two transactions deliver it concurrently,
then at most one active circulation commits.

### SC-DATA-004 — Persistent pending wash

Given a circulation is returned,
when the return transaction commits,
then the circulation is completed and the container remains `RETURNED` until a later wash transaction.

### SC-DATA-005 — Historical integrity

Given completed history,
when normal maintenance occurs,
then historical facts remain queryable.
