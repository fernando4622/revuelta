# Cafeteria UI Experience Specification

**Status:** PRODUCT RESPONSIBILITIES APPROVED; visual composition remains DRAFT because no cafeteria-specific mockup has been supplied.

## 1. Purpose

Provide a fast operational tool for Cafetería del Instituto staff to hand out and receive ReVuelta containers with minimal interaction and unambiguous outcomes.

## 2. In scope

- scan and resolve container;
- inspect current operational eligibility;
- identify the recipient/holder using the approved identity model;
- confirm delivery;
- receive/finalize return;
- complete washing and release returned containers as available;
- display deterministic conflicts and uncertain results;
- review the current device/operator's recent operations;
- access concise help.

## 3. Out of scope

- student impact/profile;
- broad personal-data access;
- user/role/policy administration;
- changing or deleting history;
- generic container status editing;
- multi-campus or partner management;
- unsupported exceptional-state handling.

## 4. Navigation

```text
Escanear | Pendientes de lavado | Operaciones recientes | Ayuda
```

`Escanear` is always the default destination.

## 5. Screen contracts

### CAF-01 — Escáner operativo

**Purpose:** start delivery or return from a physical QR.

**Content/actions:**

- large camera viewport;
- instruction matching the step: “Escanea el Código ReVuelta” for delivery identification or “Escanea el QR del contenedor” for container operations;
- explicit `Entregar` path that scans Participant Code before container QR;
- container-first path for return and washing;
- flashlight;
- permission/error feedback;
- approved manual fallback, if defined;
- visible current operating context “Cafetería del Instituto”.

No delivery or return occurs at this step.

### CAF-02 — Resultado de identificación

**Purpose:** answer what the container is and which operation is valid.

**Required data:**

- public container code;
- current state;
- active/inactive;
- active circulation summary where permitted;
- minimum borrower identity required for physical handoff;
- allowed actions returned by the application layer;
- reason when no action is allowed.

**Actions:**

- `Entregar` only when eligible;
- `Recibir devolución` only when eligible;
- `Marcar lavado completado` only when current state is `RETURNED`;
- cancel/rescan.

The UI MUST NOT infer allowed actions solely from a status string.

### CAF-03 — Preparar entrega

**Purpose:** verify recipient and review the delivery command.

**Required data/input:**

- container code/state;
- opaque participant reference resolved from Participant Code;
- safe recipient confirmation;
- return policy summary/due-at preview supplied by the server when available.

**Actions:** review, confirm once, cancel.

**Rules:**

- no raw UUID entry unless explicitly approved;
- do not display unnecessary personal data;
- confirming sends one application command;
- server response owns delivered-at, due-at and resulting state.

### CAF-04 — Recibir devolución

**Purpose:** review the active circulation and register physical receipt.

**Required data:**

- container code;
- active circulation;
- minimal holder identity;
- delivered-at/due-at;
- current eligibility;
- inspection instruction if later approved.

**Actions:** confirm receipt once, cancel.

**Rules:**

- punctuality is not calculated on device;
- a missing active circulation is a failure, not a new record;
- the final state follows the lifecycle spec;
- successful return shows `RETURNED` / “Pendiente de lavado”;
- repeated taps are suppressed.

### CAF-05 — Resultado operativo

**Purpose:** communicate a server-confirmed result.

**Success content:**

- operation type;
- container code;
- resulting state;
- timestamp;
- due-at for delivery or punctuality for return;
- next physical step;
- optional correlation reference.

**Failure content:**

- plain-language reason;
- safe retry/rescan action;
- escalation guidance for conflicts that staff cannot resolve.

A timeout enters `ResultUncertain`; it does not show success.

### CAF-06 — Pendientes de lavado

**Purpose:** show physically returned containers that cannot yet be delivered.

**Content/actions:**

- public container code;
- returned-at;
- “Pendiente de lavado” status;
- open detail;
- explicit “Marcar lavado completado”.

Only server-confirmed success changes the label to `Disponible`.

### CAF-07 — Operaciones recientes

**Purpose:** help staff verify recent work on the current operating context.

**Content:**

- recent delivery/return/wash type;
- container code;
- timestamp;
- result;
- correlation/reference.

This is not a full administrative audit and must respect personal-data minimization.

### CAF-08 — Ayuda

**Purpose:** provide short operational instructions for:

- unreadable QR;
- unknown/inactive container;
- recipient mismatch;
- already delivered/returned conflict;
- loss of connectivity;
- uncertain result;
- escalation to ReVuelta operations.

## 6. Acceptance scenarios

### SC-CAF-001 — Eligible delivery

Given an authorized cafeteria actor, eligible container and valid recipient,
when delivery is reviewed and confirmed,
then one command is submitted,
and only the server-confirmed result is displayed.

### SC-CAF-002 — Eligible return

Given an authorized cafeteria actor and a container with an active circulation,
when physical receipt is confirmed,
then one return command is submitted,
and the server-confirmed result and next physical step are displayed.

### SC-CAF-003 — Invalid operation

Given the resolved container is not eligible,
when its detail is displayed,
then the invalid action is unavailable,
and the reason and safe next step are shown.

### SC-CAF-004 — Duplicate tap

Given an operation is submitting,
when the confirm control is pressed again,
then no second client command is issued.

### SC-CAF-005 — Uncertain result

Given the network times out after submission,
when no definitive response is available,
then the UI shows an uncertain result,
and checks server state before allowing a safe retry.

### SC-CAF-006 — Complete washing

Given a container is `RETURNED`,
when Cafetería confirms washing,
then the server-confirmed result shows `AVAILABLE`,
and the item leaves the pending-wash list.
