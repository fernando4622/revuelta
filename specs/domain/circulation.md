# Circulation Specification

**Status:** BLOCKED FOR FINAL APPROVAL until borrower identity and exact lifecycle semantics are resolved.

## 1. Concept

A `Circulation` represents the controlled possession of one reusable container by one recipient for a bounded operational interval.

A circulation is a business fact, not merely a row linking two identifiers.

## 2. Required semantic fields

The final data specification MUST represent at least:

- circulation identity;
- container identity;
- recipient identity/reference;
- delivery actor;
- delivered-at timestamp;
- due-at timestamp;
- return actor when returned;
- returned-at timestamp when returned;
- punctuality classification;
- current circulation status;
- provenance/correlation needed for traceability.

Exact field names and key strategy belong to `specs/data/data-model.md`.

## 3. Circulation invariants

- `BR-CIR-001`: One container has at most one active circulation.
- `BR-CIR-002`: A circulation must reference an existing container.
- `BR-CIR-003`: A circulation must reference a valid recipient representation.
- `BR-CIR-004`: Delivery must be performed by an authorized actor.
- `BR-CIR-005`: Delivery time is server-authoritative.
- `BR-CIR-006`: Due time derives from the policy effective at delivery unless a later approved rule defines another versioned policy behavior.
- `BR-CIR-007`: Returned-at cannot precede delivered-at.
- `BR-CIR-008`: A finalized circulation cannot be finalized again.
- `BR-CIR-009`: Returning a container without an active circulation is a business failure, not a successful no-op, unless an explicit reconciliation operation is later introduced.

## 4. Delivery use case

```text
resolve actor
→ authorize
→ validate recipient
→ resolve container
→ validate container eligibility
→ resolve effective return policy
→ establish due-at
→ create circulation
→ transition container
→ create trace event
→ commit transaction
→ return result
```

The implementation MUST define one transaction boundary around all state changes that must succeed or fail together.

## 5. Return use case

```text
resolve actor
→ authorize
→ resolve container
→ resolve active circulation
→ validate return eligibility
→ obtain authoritative server time
→ classify punctuality
→ finalize circulation
→ transition container
→ create trace event
→ commit transaction
→ return result
```

## 6. Punctuality classification

The baseline categories are:

- `ON_TIME`: return occurs on or before due-at according to the approved comparison rule.
- `LATE`: return occurs after due-at according to the approved comparison rule.

**Decision required:** whether equality at the exact due timestamp is `ON_TIME` (recommended default), and whether calendar-day or instant comparison is authoritative.

## 7. Return-window policy

The pilot supports a configurable return window of 1–3 days.

The final policy MUST define:

- policy identifier/version;
- duration representation;
- effective time zone or UTC interpretation;
- rounding/boundary behavior;
- effective date/time;
- whether policy changes affect only new circulations or existing open ones.

The system MUST NOT recompute an already active circulation's due date from a later policy version unless explicitly specified.

## 8. Idempotency

### Delivery
Delivery is a mutating operation. The final API spec MUST define the deduplication mechanism for repeated submissions.

### Return
Return MUST be protected against duplicate submissions, network retry after timeout, and double-tap.

A repeated return request for an already finalized circulation MUST produce a deterministic response, ideally an explicit duplicate/conflict outcome, according to the final contract.

## 9. Acceptance scenarios

### SC-CIR-001 Valid delivery
Given an eligible container and authorized operator, when delivery is created, then exactly one active circulation exists, the container reaches the defined delivery state, due-at is derived from the effective policy, and one trace event exists.

### SC-CIR-002 Ineligible container
Given a container in a non-eligible state, when delivery is requested, then no circulation is created and state is unchanged.

### SC-CIR-003 Duplicate delivery
Given an already active circulation for the container, when another delivery is requested, then the second request does not create another active circulation.

### SC-CIR-004 On-time return
Given an active circulation with a due-at in the future or equal to authoritative return time, when return is registered, then the circulation is finalized as `ON_TIME` and the container transitions to the defined post-return state.

### SC-CIR-005 Late return
Given an active circulation whose due-at is before authoritative return time, when return is registered, then the circulation is finalized as `LATE`.

### SC-CIR-006 Return without active circulation
Given no active circulation for the container, when return is requested, then the operation fails and does not fabricate a circulation.

### SC-CIR-007 Concurrent return
Given one active circulation and two near-simultaneous return attempts, when both complete, then one business result finalizes the circulation and the system remains consistent; the second is deterministic and non-destructive.
