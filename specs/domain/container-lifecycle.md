# Container Lifecycle Specification

**Status:** APPROVED FOR NORMAL PILOT FLOW. Exceptional-state evidence and final `ASSIGNED` treatment remain open.

## 1. Concept

A `Container` represents one physical reusable food container that is individually identifiable and operationally tracked.

## 2. Identity invariants

- `BR-CTR-001`: One physical container maps to one container identity.
- `BR-CTR-002`: Container identity is immutable.
- `BR-CTR-003`: Two active records MUST NOT represent the same physical container.
- `BR-CTR-004`: One active container QR resolves to at most one container.

## 3. States

| State | Meaning in V1 |
|---|---|
| `REGISTERED` | Exists in inventory but is not eligible for delivery |
| `AVAILABLE` | Clean and eligible for a new circulation |
| `ASSIGNED` | Reserved state; not used by the current immediate physical-handoff flow |
| `IN_USE` | In a participant's possession through an active circulation |
| `RETURNED` | Received by Cafetería, circulation finalized, pending washing |
| `DAMAGED` | Unavailable because damage was recorded |
| `LOST` | Unavailable because loss was recorded |
| `RETIRED` | Permanently excluded from circulation |

## 4. Approved normal transitions

```text
REGISTERED → AVAILABLE      activate container
AVAILABLE  → IN_USE        cafeteria delivery
IN_USE    → RETURNED       cafeteria physical return
RETURNED  → AVAILABLE      cafeteria wash completion
```

### Delivery

`AVAILABLE → IN_USE` occurs atomically with circulation creation and delivery event.

### Return

`IN_USE → RETURNED` occurs atomically with circulation finalization and return event. The participant no longer holds the container after commit.

### Washing

`RETURNED → AVAILABLE` is a separate explicit operation and event. A `RETURNED` container cannot be delivered.

## 5. Exceptional transitions

Candidate transitions remain:

```text
AVAILABLE → DAMAGED
RETURNED  → DAMAGED
IN_USE    → DAMAGED
AVAILABLE → LOST
IN_USE    → LOST
DAMAGED   → AVAILABLE
DAMAGED   → RETIRED
LOST      → RETIRED
```

Only Operación ReVuelta may perform them, through named use cases with a mandatory reason. Exact evidence requirements remain blocked by D-004.

## 6. Transition contract

Every transition defines:

- current and target state;
- authorized actor/permission;
- preconditions;
- required input;
- invariant checks;
- persistence changes;
- trace event;
- failure codes;
- concurrency strategy;
- idempotency behavior.

No layer may expose a generic `container.status = X` operation.

## 7. Invariants

- `BR-CTR-010`: Only `AVAILABLE` may start a circulation.
- `BR-CTR-011`: `RETURNED` is not available for delivery.
- `BR-CTR-012`: `RETIRED`, `LOST` and `DAMAGED` cannot start a normal circulation.
- `BR-CTR-013`: Invalid transitions do not partially mutate state.
- `BR-CTR-014`: Each accepted transition creates one trace event.
- `BR-CTR-015`: A transition failure leaves the aggregate consistent.
- `BR-CTR-016`: Concurrent operations cannot both succeed when they would violate state.

## 8. Acceptance scenarios

### SC-CTR-001 — Delivery

Given an available container,
when authorized Cafetería completes delivery,
then the container becomes `IN_USE`.

### SC-CTR-002 — Physical return

Given an in-use container with active circulation,
when authorized Cafetería confirms physical receipt,
then the container becomes `RETURNED`,
and is not eligible for delivery.

### SC-CTR-003 — Washing

Given a returned container,
when authorized Cafetería confirms washing,
then the container becomes `AVAILABLE`,
and one washing event exists.

### SC-CTR-004 — Cannot deliver dirty container

Given a returned container pending washing,
when delivery is attempted,
then it fails without mutation.

### SC-CTR-005 — Concurrent assignment

Given one available container,
when two authorized devices attempt delivery concurrently,
then at most one creates an active circulation.
