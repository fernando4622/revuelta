# Student UI Experience Specification

**Status:** PRODUCT FLOW APPROVED FOR ROLE-BASED MVP. Visual structure is based on `ejemplo1.png`, `ejemplo2.png` and `ejemplo3.png`. Real participant-record binding remains incomplete.

## 1. Purpose

Help an ITVer student understand:

- whether a container is currently assigned to them;
- when and where it must be returned;
- the current server-confirmed status;
- their real return history;
- what action to take next.

## 2. In scope

- student shell and navigation;
- home;
- active-container summary;
- scan for return information;
- return-point instructions;
- waiting/validation/result feedback;
- history;
- profile/help/legal links;
- notifications backed by real data;
- impact metrics only when their data source is approved.

## 3. Out of scope for this cycle

- public registration;
- social login;
- email verification;
- profile completion onboarding;
- rewards;
- payments;
- multiple campuses or cafeterias;
- authoritative return mutation initiated by the student;
- invented impact figures.

The splash and onboarding compositions may be reused later, but their navigation and copy are not currently approved.

## 4. Navigation

Primary mobile destinations:

```text
Inicio | Historial | Escanear | Impacto | Perfil
```

- `Escanear` is the emphasized center action.
- Notifications open from the Inicio header and are not a sixth primary destination.
- On wide layouts, the same destinations appear in a left navigation rail.
- Back navigation from a multi-step return journey returns to the previous safe step and never submits implicitly.

## 5. Screen contracts

### STU-01 — Inicio

**Purpose:** show personal container state and the single most relevant next step.

**Required data:**

- display name or neutral greeting;
- zero, one or multiple active containers;
- public container code;
- server-confirmed state;
- delivered-at/due-at or an approved human-readable summary;
- approved return-point name;
- last successful refresh.

**Content:**

- ReVuelta identity;
- greeting;
- notification affordance;
- primary container card;
- next-step card;
- scan action;
- bottom navigation.

**States:**

- loading;
- no active container;
- one active container;
- multiple active containers;
- stale/offline data;
- session/identity unavailable;
- failure with retry.

**Rules:**

- “Hace 42 min”, container codes and names from the mockups are placeholders;
- the UI does not calculate business due time;
- cafeteria delivery/return buttons are not displayed in this perspective;
- each active container is rendered as an individually selectable item; more than one is valid.

### STU-02 — Escanear QR

**Purpose:** identify the student's container and obtain return instructions.

**Entry:** central scan button or the next-step action on Inicio.

**Content/actions:**

- camera viewport;
- clear instruction;
- close/back;
- flashlight where supported;
- permission explanation;
- manual entry only if separately approved.

**States:** use the scan state machine.

**Rules:**

- scanning does not authorize or register a return;
- only one payload is resolved at a time;
- malformed, unknown and inactive containers have distinct user-safe feedback where policy permits;
- a container not associated with the current student produces no personal data disclosure.

### STU-03 — Container/return information

**Purpose:** confirm which container was resolved and explain where to take it.

**Required data:**

- public container code;
- current server state;
- approved return-point name;
- plain-language directions;
- eligibility/instruction result;
- optional due-at.

**Primary action:** “Ver punto de retorno” or “Continuar”.

The mockup label “Confirmar devolución” is replaced by “Ver punto de retorno” or “Continuar”. Only Cafetería finalizes the return.

### STU-04 — Punto de retorno

**Purpose:** guide the student to the approved ReVuelta return point.

**Content:**

- “Punto ReVuelta — Cafetería del Instituto”;
- textual directions;
- accessibility-relevant information if supplied;
- optional static/map representation only when location data is approved.

**Rules:**

- do not show invented locations such as “Cafetería Central” or “Biblioteca”;
- exact-distance claims require a real location source;
- the journey can continue to `AwaitingOperationalReceipt`, not to business success.

### STU-05 — Esperando recepción / Validando

**Purpose:** communicate that the physical return has not yet reached its final server-confirmed result.

**Content:**

- container code;
- progress labels such as `Identificado`, `Recibido`, `Validando`, `Disponible` only when they match the approved lifecycle;
- refresh/status check;
- help guidance after a reasonable timeout.

**Rules:**

- animation is not evidence of success;
- “Disponible” can be shown only from the resulting server state;
- a timeout becomes `ResultUncertain`, not failure or success.

### STU-06 — Devolución registrada

**Purpose:** show the result after the server confirms an authorized operational return.

**Required data:**

- public container code;
- returned-at;
- resulting state;
- punctuality classification when permitted;
- correlation/reference for support where appropriate.

**Actions:**

- return to Inicio;
- view history/detail.

Environmental impact is omitted unless backed by an approved methodology and stored result.

### STU-07 — Historial

**Purpose:** show the student's immutable circulation history.

**Content:**

- filters `Todos`, `En uso`, `Devueltos`;
- public container code;
- localized timestamp;
- user-facing status;
- pagination/loading;
- selectable detail.

**States:** loading, empty, success, filtering, failure, offline/stale.

**Rules:**

- data comes from the server;
- no hard-coded entries;
- history is read-only;
- filters do not alter business state.

### STU-08 — Impacto

**Purpose:** explain verified personal impact.

**Status:** APPROVED AS DEMO/MOCKUP ONLY. Real metrics remain blocked by D-017.

Demo builds may show values such as “3 contenedores”, “-300 g” and “-1.2 kg” only while a persistent “Datos de demostración” label is visible. Production builds hide the destination or show “Próximamente” until real methodology/data exist.

### STU-09 — Perfil

**Purpose:** show personal account/help options that are actually supported.

Candidate destinations:

- Mis contenedores;
- Configuración;
- Centro de ayuda;
- Términos y privacidad.

Identity and edit actions not backed by the authenticated participant association remain deferred. Unsupported entries MUST be hidden rather than dead links.

### STU-10 — Notificaciones

**Purpose:** show real, relevant updates about the student's containers.

Candidate types:

- return registered;
- due reminder;
- approved return-point change;
- operational notice.

**Rules:**

- demo notifications display “Datos de demostración”;
- real notifications require a real source and timestamp;
- mock weekly-impact messages are not presented as real;
- tapping navigates to an existing relevant destination;
- an empty state is required.

## 6. Error translation

| Failure category | Student behavior |
|---|---|
| Invalid QR | Explain that the code cannot be read; allow rescan |
| Container not found | Explain that the container is not recognized; offer help |
| Container inactive | Explain that it cannot follow the normal flow |
| Not associated/forbidden | Do not reveal another student's data |
| No active circulation | Explain that no pending return was found |
| Network failure | Preserve safe context and offer retry |
| Conflict | Refresh server state and explain the current result |
| Unexpected | Show safe message and support correlation reference |

## 7. Acceptance scenarios

### SC-STU-001 — No active container

Given the student has no active circulation,
when Inicio loads,
then an empty state is shown,
and no fabricated container or deadline appears.

### SC-STU-002 — Active container

Given one active circulation exists,
when Inicio loads,
then the container, status, due information and next step come from the server.

### SC-STU-003 — Scan is identification only

Given the student scans a valid QR,
when resolution succeeds,
then return information is displayed,
and no circulation is finalized by scanning.

### SC-STU-004 — Operational receipt observed

Given cafeteria staff has registered the return,
when the student status refreshes,
then the UI shows the server-confirmed result and history entry.

### SC-STU-005 — Impact unavailable

Given no approved impact methodology/data exists,
when the student opens Impacto,
then no numerical environmental claim is displayed.
