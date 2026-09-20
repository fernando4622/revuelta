# ReVuelta Mobile UI Specification

**Status:** PRODUCT NAVIGATION AND ROLE-BASED MVP ROUTING APPROVED. Real participant binding and production identity provisioning remain blocked before pilot use.

## 1. Purpose

Define the mobile and responsive UI contract for the ITVer pilot without turning visual mockups into unstated business rules.

The UI has three distinct perspectives:

1. Alumno;
2. Cafetería;
3. Operación ReVuelta.

They share visual components, but they do not share navigation or responsibilities.

## 2. Sources and precedence

The UI specification is governed in this order:

1. product/domain specifications and approved decisions;
2. `context.md`;
3. this UI specification and its child documents;
4. reference images under `apps/revuelta-mobile/resources/`;
5. existing Flutter implementation.

Reference images define visual intention and proposed navigation. Example names, timestamps, metrics, locations, credentials and lifecycle results are not automatically business truth.

## 3. Specification map

| Document | Responsibility |
|---|---|
| `reference-mockups.md` | Interpretation of the supplied images and visual system |
| `perspectives.md` | Authenticated role routing, responsibility boundaries and navigation by experience |
| `student-experience.md` | Student screens and journeys represented by the mockups |
| `cafeteria-experience.md` | Operational cafeteria screens derived from `context.md` |
| `revuelta-operations-experience.md` | Administrative pilot screens derived from `context.md` |
| `state-machines.md` | Coherent asynchronous and multi-step UI states |

## 4. UI architecture

```text
Page/Widget
→ Controller / State Notifier / ViewModel
→ Use Case
→ Domain
→ Repository interface
→ Remote/local adapter
```

Widgets MUST NOT:

- call HTTP directly;
- parse raw JSON;
- mutate domain objects;
- decide authorization;
- calculate authoritative deadlines or punctuality;
- fabricate a successful delivery or return;
- render sample data as operational truth.

## 5. Authenticated MVP mode

The app starts at login when no valid session exists. After successful authentication, it opens exactly one shell according to the role returned in the signed server session:

```text
PARTICIPANT → Alumno/maestro
OPERATOR → Cafetería
ADMIN → Operación ReVuelta
```

There is no unrestricted perspective selector. To test another experience, the reviewer logs out and authenticates with the corresponding development account.

Public registration, email verification, social login, password recovery and profile-completion screens from the mockups remain reference-only and outside the current implementation scope.

## 6. Global UI rules

- User-facing language is Spanish.
- The pilot refers to “Cafetería” or “Cafetería del Instituto”.
- The return point is “Punto ReVuelta — Cafetería del Instituto”.
- The approved prototype logo source is `apps/revuelta-mobile/resources/logo.jpeg`.
- QR values are untrusted input.
- Every asynchronous interaction has one coherent state.
- Business actions require explicit confirmation when the governing feature spec requires it.
- Server results own lifecycle state, timestamps and punctuality.
- Loading, empty, success, validation, permission, network, conflict and unexpected failure states MUST be represented.
- Information must not rely on color alone.
- Critical controls require meaningful labels and adequate touch targets.
- Logout clears pending scans, drafts, mutation state and locally stored credentials.
- Demo impact/notification screens display “Datos de demostración” and never persist their mock values.

## 7. Responsive behavior

The mobile mockups are the primary reference.

The wide student dashboard in `ejemplo3.png` is a responsive representation of the same student information architecture, not a separate administrative product.

- Mobile uses bottom navigation.
- Wide layout MAY use a left navigation rail/sidebar.
- Destination names and capabilities MUST remain equivalent across breakpoints.
- Cafetería and ReVuelta operations MAY later receive dedicated wide layouts, but none are visually approved by the current references.

## 8. Global acceptance

### SC-UI-001 — Experience separation

Given the user authenticates with one recognized role,
when its shell is displayed,
then only that role's destinations and actions are visible.

### SC-UI-002 — Navigation is not authorization

Given a client exposes a destination outside the authenticated role,
when a protected mutation is attempted without the required server authorization,
then the request is rejected or remains disabled,
and the UI does not present it as successful.

### SC-UI-003 — No fabricated operational data

Given the app has no server data for a metric or circulation,
when the corresponding screen is rendered,
then it shows an empty/unavailable state or is hidden,
and does not display mockup values as real.

### SC-UI-004 — Logout cleanup

Given a scan or form is in progress,
when the user logs out,
then transient state is discarded,
the camera is released,
local credentials are removed,
and no business command is submitted.
