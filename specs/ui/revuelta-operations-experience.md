# ReVuelta Operations UI Experience Specification

**Status:** PRODUCT RESPONSIBILITIES APPROVED; visual composition remains DRAFT because no operations-specific mockup has been supplied.

## 1. Purpose

Allow the ReVuelta team to supervise and administer only the ITVer pilot.

The interface answers:

> ¿Qué está ocurriendo con los contenedores ReVuelta en el ITVer?

## 2. In scope

- real pilot summary;
- participant/account association inspection;
- container inventory;
- container registration and detail;
- active/completed circulations;
- traceability;
- approved exception handling;
- operational incident review;
- support for cafeteria operations.
- container QR reprint/replacement;
- reasoned append-oriented corrections.

## 3. Out of scope

- organization/campus switching;
- restaurant or partner network;
- billing;
- rewards;
- marketing analytics;
- generic CRUD that bypasses lifecycle operations;
- rewriting or deleting audit history.

## 4. Navigation

```text
Resumen | Participantes | Recipientes | Circulaciones | Incidencias | Auditoría
```

The responsive form may use a navigation rail/sidebar. There is no institution selector.

## 5. Screen contracts

### OPS-01 — Resumen del piloto

**Purpose:** show current, actionable ITVer operational state.

Candidate metrics, only when derived from server data:

- total/available/in-use containers;
- active circulations;
- returns due/late;
- unresolved incidents;
- recent return activity.

Every metric links to its filtered source list. No estimated impact metric is shown without approved methodology.

### OPS-02 — Participantes

**Purpose:** inspect participant/account association and operation-token status for support without exposing PII.

Operation QR generation remains in the authenticated participant experience. Operations cannot impersonate a participant to generate a handoff token.

### OPS-03 — Recipientes

**Purpose:** search and filter pilot inventory.

**Content:**

- public code;
- state;
- active flag;
- active circulation indicator;
- last event time;
- pagination/filter/search.

**Actions:**

- open detail;
- register new container;
- invoke an approved lifecycle operation.

There is no generic status editor.

### OPS-04 — Registrar recipiente

**Purpose:** create one identifiable physical container.

**Inputs and validation** are governed by the identity/data specs.

Success displays:

- generated/approved public identifier;
- resulting initial state;
- QR generation/printing next step if supported;
- trace reference.

### OPS-05 — Detalle del recipiente

**Content:**

- immutable identity;
- public code/QR status;
- lifecycle state;
- current circulation;
- recent/full event history based on permission;
- explicitly permitted operations.

Exceptional actions require reason/evidence rules from D-004 and a separate confirmation.

### OPS-06 — Circulaciones

**Purpose:** investigate active and completed possession records.

**Content:**

- circulation/container identity;
- recipient reference with privacy controls;
- delivery/due/return times;
- status and punctuality;
- actors;
- correlation;
- filters and pagination.

Records are read-only except through an approved correction/reconciliation use case.

### OPS-07 — Incidencias

**Purpose:** track operational exceptions requiring action.

Candidate categories:

- unknown/damaged/lost container;
- identity mismatch;
- repeated conflict;
- uncertain operation result;
- QR replacement;
- connectivity/operational issue.

Creation and resolution workflows remain blocked until ownership, evidence and resolution states are specified.

### OPS-08 — Auditoría

**Purpose:** inspect append-oriented trace events.

**Content:**

- time;
- actor;
- operation;
- resource;
- previous/resulting state where applicable;
- result/error code;
- correlation identifier.

Audit data cannot be edited or deleted from this screen.

## 6. Acceptance scenarios

### SC-OPS-001 — Single-pilot scope

Given the operations shell loads,
when navigation is rendered,
then all information is scoped to the ITVer pilot,
and no organization, campus or partner selector exists.

### SC-OPS-002 — Real metrics only

Given a summary metric has no supported server query,
when Resumen loads,
then the metric is omitted or marked unavailable,
and no mock value is displayed.

### SC-OPS-003 — Explicit transition

Given an operator opens a container,
when actions are rendered,
then only named lifecycle operations permitted by the application layer appear,
and no free-form status control exists.

### SC-OPS-004 — Immutable history

Given a trace event is displayed,
when the user opens its detail,
then no edit/delete control is available.

### SC-OPS-005 — Missing exception policy

Given an exceptional action requires an unresolved permission/evidence rule,
when the container detail loads,
then that action remains disabled,
and the UI identifies it as unavailable rather than inventing a workflow.
