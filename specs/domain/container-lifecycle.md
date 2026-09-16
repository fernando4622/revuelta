# Container Lifecycle Specification

**Status:** BLOCKED FOR FINAL APPROVAL. Baseline semantics are defined below; final transition authorization still requires D-004.

## 1. Concept

A `Container` represents one physical reusable food container that is individually identifiable and operationally tracked.

## 2. Identity invariants

- `BR-CTR-001`: One physical container maps to one container identity.
- `BR-CTR-002`: Container identity is immutable.
- `BR-CTR-003`: Two active records MUST NOT represent the same physical container.
- `BR-CTR-004`: QR identification MUST resolve to at most one active container.

## 3. Baseline states

```text
REGISTERED
AVAILABLE
ASSIGNED
IN_USE
RETURNED
DAMAGED
LOST
RETIRED
```

### State meanings

`REGISTERED`: Container exists in the registry but is not yet operationally available for circulation.

`AVAILABLE`: Container is eligible for a new circulation, subject to policy and authorization.

`ASSIGNED`: Operational assignment to a circulation/recipient exists, but the product needs to define whether physical possession has begun.

`IN_USE`: Container is considered physically in the recipient's custody/use phase.

`RETURNED`: A return operation has been accepted; this state is transient or persistent depending on the final state-machine decision below.

`DAMAGED`: Container is known to be damaged and cannot follow normal circulation rules until recovered or retired.

`LOST`: Container is believed lost and cannot follow normal circulation rules.

`RETIRED`: Container is permanently excluded from circulation.

## 4. State-machine issue requiring explicit resolution

The current project history contains both assignment and use semantics. The following question MUST be resolved before implementation:

> Is `ASSIGNED` materially different from `IN_USE`, and is `RETURNED` a persistent state or merely an intermediate event before `AVAILABLE`?

Do not implement both states as cosmetic UI labels. A state exists only if it changes valid operations, invariants, permissions, reporting, or persistence semantics.

## 5. Baseline transition candidates

```text
REGISTERED → AVAILABLE
AVAILABLE → ASSIGNED
ASSIGNED → IN_USE
IN_USE → RETURNED
RETURNED → AVAILABLE

AVAILABLE → DAMAGED
RETURNED → DAMAGED

AVAILABLE → LOST
RETURNED → LOST

DAMAGED → AVAILABLE
DAMAGED → RETIRED
LOST → RETIRED
```

These are candidates, not final authorization rules.

## 6. Transition contract

Every transition MUST define:

- current state;
- target state;
- actor type;
- required permission;
- preconditions;
- required input;
- invariants checked;
- persistence changes;
- emitted trace event;
- possible failure codes;
- concurrency strategy;
- whether operation is idempotent.

## 7. Prohibited mutations

No caller may perform generic state mutation such as:

```text
container.status = X
```

outside the domain operation that owns the transition.

## 8. Exceptional states

### DAMAGED
Must have an authorized actor and a defined reason/evidence policy.

**Decision required:** reason taxonomy and whether evidence/photo/notes are mandatory.

### LOST
Must have an authorized actor and a defined reason/report policy.

**Decision required:** reason/evidence and recovery policy.

### RETIRED
Must be terminal unless a future approved spec explicitly introduces reactivation.

## 9. Invariants

- `BR-CTR-010`: A retired container cannot start a new circulation.
- `BR-CTR-011`: A lost container cannot start a new circulation.
- `BR-CTR-012`: A damaged container cannot start a new circulation unless explicitly recovered to an eligible state.
- `BR-CTR-013`: Invalid transitions MUST not partially mutate state.
- `BR-CTR-014`: Each accepted transition MUST create traceability evidence.
- `BR-CTR-015`: A transition failure MUST leave the aggregate in a consistent state.

## 10. Concurrency

For any transition whose precondition depends on current state, the implementation MUST guarantee that concurrent requests cannot both succeed when that would violate an invariant.

## 11. Acceptance scenarios

### SC-CTR-001 Valid availability transition
Given a registered container and an authorized transition operation, when the transition is performed, then the target state is stored and one trace event exists.

### SC-CTR-002 Invalid transition
Given a container in an incompatible state, when an invalid transition is requested, then the operation fails with a typed business error and no state mutation occurs.

### SC-CTR-003 Concurrent assignment
Given one available container and two authorized devices attempting assignment concurrently, when both requests complete, then at most one creates the active circulation.
