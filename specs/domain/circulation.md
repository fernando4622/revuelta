# Circulation Specification

**Status:** APPROVED FOR PARTICIPANT CARDINALITY AND NORMAL HANDOFF. Policy, authentication, keys, idempotency and concurrency details retain their registered decisions.

## 1. Concept

A `Circulation` represents controlled possession of one reusable container by one participant for a bounded operational interval.

## 2. Required semantic fields

- circulation identity;
- container identity;
- participant identity;
- delivery actor;
- delivered-at;
- due-at;
- applied return-policy identity/version;
- return actor;
- returned-at;
- punctuality;
- circulation status;
- correlation/provenance.

## 3. Invariants

- `BR-CIR-001`: One container has at most one active circulation.
- `BR-CIR-002`: One participant may have multiple active circulations.
- `BR-CIR-003`: A circulation references one existing participant and container.
- `BR-CIR-004`: Cafetería performs normal delivery and return.
- `BR-CIR-005`: Delivery and return times are server-authoritative.
- `BR-CIR-006`: Due-at derives from the policy captured at delivery.
- `BR-CIR-007`: Returned-at cannot precede delivered-at.
- `BR-CIR-008`: A finalized circulation cannot be finalized again.
- `BR-CIR-009`: Return without active circulation is a business failure.
- `BR-CIR-010`: Washing never reopens or changes the completed circulation.

## 4. Delivery use case

```text
resolve authenticated Cafetería actor
→ authorize delivery
→ resolve and lock participant `DELIVERY` operation token
→ validate participant eligibility
→ resolve container QR
→ validate AVAILABLE state
→ resolve effective return policy
→ calculate due-at from server time
→ create circulation
→ transition AVAILABLE → IN_USE
→ append delivery event
→ consume participant operation token
→ commit
```

Scanning a participant QR or container QR alone performs no mutation.

## 5. Return use case

```text
resolve authenticated Cafetería actor
→ authorize return
→ resolve and lock participant `RETURN` operation token
→ resolve container QR
→ resolve active circulation
→ verify circulation participant matches token participant
→ validate IN_USE state
→ obtain server time
→ classify punctuality
→ finalize circulation
→ remove current participant possession
→ transition IN_USE → RETURNED
→ append return event
→ consume participant operation token
→ commit
```

Both participant operation QR and container QR are mandatory for return. The participant token is consumed only if the complete return transaction commits.

## 6. Washing use case

```text
resolve authenticated Cafetería actor
→ authorize wash completion
→ resolve returned container
→ validate RETURNED state
→ transition RETURNED → AVAILABLE
→ append wash-completed event
→ commit
```

## 7. Punctuality and policy

- `ON_TIME`: returned-at is equal to or before due-at.
- `LATE`: returned-at is after due-at.
- Policy version and resulting due-at are preserved on the circulation.
- Later policy changes do not recompute active circulation deadlines.

Exact pilot window remains D-003.

## 8. Idempotency and concurrency

- Duplicate/concurrent delivery cannot create two active circulations for one container.
- Multiple different containers may be delivered to the same participant.
- Duplicate/concurrent return finalizes once.
- Duplicate/concurrent washing transitions once.
- A retry after an uncertain result must query current server state or follow the approved idempotency contract.

## 9. Acceptance scenarios

### SC-CIR-001 — First delivery

Given an eligible participant and available container,
when Cafetería confirms delivery,
then one active circulation exists and the container becomes `IN_USE`.

### SC-CIR-002 — Additional delivery

Given the participant already holds another container,
when a different available container is delivered,
then another active circulation may be created.

### SC-CIR-003 — Duplicate container delivery

Given a container has an active circulation,
when another delivery is attempted for that container,
then no additional active circulation is created.

### SC-CIR-004 — Return

Given an active circulation,
when Cafetería confirms physical return,
then the circulation is finalized,
the participant no longer holds the container,
and the container becomes `RETURNED`.

### SC-CIR-005 — Wash completion

Given a returned container,
when Cafetería confirms washing,
then the container becomes `AVAILABLE`,
without modifying the completed circulation.

### SC-CIR-006 — Concurrent return

Given one active circulation,
when two return commands race,
then only one finalizes it and data remains consistent.
