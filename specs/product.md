# ReVuelta Product Specification

**Status:** BLOCKED FOR FINAL APPROVAL until all `Decision required` items are resolved.

## 1. Actors

### 1.1 Operator
An authenticated staff/operator role that performs operational container actions.

Responsibilities expected by V1:

- identify containers;
- inspect container state;
- register delivery/assignment;
- register return;
- inspect circulation/history as permitted.

**Decision required:** final name, exact permissions, and whether there is more than one operational role.

### 1.2 Administrator
A privileged role for system configuration and operational administration.

Expected responsibilities:

- manage users/roles;
- manage containers;
- manage return policy;
- access audit information;
- perform authorized exceptional operations.

**Decision required:** exact administrative scope.

### 1.3 Borrower / recipient
A person who receives a container through a circulation. V1 needs a stable identity reference for the recipient.

**Decision required:** whether borrower is represented as an authenticated ReVuelta user, an institutional identifier, an external student/employee record, or another bounded representation. Do not infer from the current UI or prior prototype.

## 2. Primary journeys

### J-01 Login
Actor authenticates and receives an authorized application session.

### J-02 Scan container
Operator scans QR. App resolves the QR to a container or returns a safe identification failure.

### J-03 Inspect container
Operator sees current state and relevant operational information without mutating it.

### J-04 Deliver container
Authorized operator creates a circulation. The system validates container eligibility, recipient identity, authorization, return policy, performs one transaction, changes container state, and records traceability.

### J-05 Return container
Authorized operator resolves the container and active circulation, validates return eligibility, records return time from server authority, classifies punctuality, transitions the container, and records traceability.

### J-06 Inspect history
Authorized actor can inspect immutable lifecycle/circulation history according to access policy.

## 3. Functional requirements

### Identity/access

- `FR-001`: The system MUST authenticate protected users before protected operations.
- `FR-002`: The system MUST authorize every protected mutation server-side.
- `FR-003`: Logout/session invalidation behavior MUST follow the approved security spec.

### Containers

- `FR-010`: The system MUST maintain one logical record per physical container.
- `FR-011`: A container identifier MUST be unique and immutable once issued.
- `FR-012`: A container with business history MUST NOT be physically deleted through normal operations.
- `FR-013`: The system MUST expose current operational state.

### QR

- `FR-020`: The mobile app MUST scan a QR payload.
- `FR-021`: The backend MUST resolve the payload as untrusted input.
- `FR-022`: Unknown, inactive, malformed, or unsupported QR payloads MUST produce explicit failures.

### Circulation

- `FR-030`: The system MUST create a circulation only when all eligibility rules pass.
- `FR-031`: A container MUST NOT have more than one active circulation.
- `FR-032`: Delivery time MUST be authoritative server time.
- `FR-033`: Due date MUST be derived from the approved policy and effective context.
- `FR-034`: The system MUST record the operator/actor responsible for delivery.

### Returns

- `FR-040`: A return MUST resolve an active circulation before finalizing.
- `FR-041`: Return time MUST be authoritative server time.
- `FR-042`: A completed return MUST NOT be recorded twice for the same circulation.
- `FR-043`: The system MUST classify whether the return was within the applicable window.
- `FR-044`: The return operation MUST record traceability.

### Traceability

- `FR-050`: Sensitive business actions MUST create an auditable event.
- `FR-051`: Audit history MUST preserve actor, time, affected aggregate/resource, action/result, and correlation information where defined.
- `FR-052`: Audit records MUST NOT be silently edited or deleted to correct business history.

## 4. Success metrics

### Operational metric

`return_rate = qualifying_returns_within_defined_window / eligible_deliveries`

Historical project target: ≥85% return within the defined window.

This is a pilot/business metric, not a software correctness criterion.

## 5. Product acceptance boundaries

A V1 release is not acceptable if:

- container identity can collide;
- two active circulations can exist for one container;
- unauthorized clients can mutate a protected operation;
- lifecycle state can be changed without validation;
- return can be duplicated;
- audit history can be destroyed through normal business flows;
- client time is treated as authoritative business time;
- critical concurrent operations can violate invariants.

## 6. Decision register

### D-001 — Actor/role model
**Status:** BLOCKING.

Resolve exact roles and permissions.

### D-002 — Borrower identity
**Status:** BLOCKING.

Resolve how a recipient is identified and whether they authenticate.

### D-003 — Exact pilot return-window value
**Status:** BLOCKING for pilot configuration, not architecture.

Resolve initial value within 1–3 days.

### D-004 — Exceptional state authority
**Status:** BLOCKING for lifecycle approval.

Resolve exact permissions and evidence required to mark `DAMAGED`, `LOST`, `RETIRED`, or recover from exceptional states.
