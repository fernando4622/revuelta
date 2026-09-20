# UI Perspectives and Responsibility Boundaries

**Status:** APPROVED FOR ROLE-BASED MVP NAVIGATION AND PRODUCT RESPONSIBILITIES. Real participant binding and production identity provisioning remain blocked.

## 1. Purpose

Present the three ITVer pilot experiences according to the authenticated server-issued role while preserving clear responsibility boundaries.

## 2. Perspectives

```text
PARTICIPANT → STUDENT
OPERATOR    → CAFETERIA
ADMIN       → REVUELTA_OPERATIONS
```

Alumno and maestro share the `PARTICIPANT` role and the same experience in V1. The app does not ask the user to select an experience.

## 3. Capability matrix

Legend:

- `V`: may view when data access is authorized;
- `A`: may initiate an application action when authorized;
- `—`: must not be offered.

| Capability | Alumno | Cafetería | Operación ReVuelta |
|---|:---:|:---:|:---:|
| View own active circulation | V | — | V |
| View own history | V | — | V |
| Scan own container for return information | A | — | — |
| Resolve any operational container QR | — | A | A |
| Deliver container | — | A | A only for approved support |
| Receive/finalize return | — | A | — |
| Complete washing | — | A | — |
| View minimal borrower information | — | V | V |
| Issue Participant Code | — | — | A |
| Register/activate container | — | — | A |
| Change exceptional container state | — | — | A, subject to D-004 |
| View full pilot traceability | — | Limited to own operations | V |
| Configure return policy | — | — | A when separately authorized |
| View real pilot indicators | Own metrics only | Operational summary only | V |

The matrix describes UI responsibility. The server remains the authority for every permission.

## 4. Shell navigation

### 4.1 Alumno

```text
Inicio
Historial
Escanear
Impacto
Perfil
```

Notifications are opened from the header. `Impacto` is hidden or unavailable until real data and methodology exist.

### 4.2 Cafetería

```text
Escanear
Pendientes de lavado
Operaciones recientes
Ayuda
```

The default destination is `Escanear`.

### 4.3 Operación ReVuelta

```text
Resumen
Participantes
Recipientes
Circulaciones
Incidencias
Auditoría
```

No campus, institution or partner selector is present in V1.

## 5. Session routing

- The login screen appears before every protected shell when no valid session exists.
- A successful login routes according to the role returned by the backend.
- Logging out clears camera sessions, forms, pending commands, selected records and local credentials.
- Testing another experience requires logging out and authenticating with an account for that role.
- An unknown or missing role displays a safe access error and no protected shell.
- Client navigation state is never authorization evidence.

## 6. Responsibility rules

### Alumno

The student experience explains personal state and next steps. It does not perform cafeteria inventory work or administrative corrections.

### Cafetería

The cafeteria experience optimizes physical handoff. It shows only the information required to answer:

- which container;
- which recipient/holder;
- whether the action is permitted;
- what to do next.

### Operación ReVuelta

The operations experience supervises this ITVer pilot. It issues Participant Codes, manages inventory, circulation investigation, exceptions and traceability without exposing future multi-tenant concepts.

## 7. Acceptance scenarios

### SC-PER-001 — Participant session

Given a valid `PARTICIPANT` session,
when authentication completes,
then the student shell opens on Inicio,
and cafeteria/operations destinations are absent.

### SC-PER-002 — Cafetería session

Given a valid `OPERATOR` session,
when authentication completes,
then the cafeteria shell opens on Escanear,
and student metrics and administrative inventory actions are absent.

### SC-PER-003 — ReVuelta operations session

Given a valid `ADMIN` session,
when authentication completes,
then the pilot operations shell opens,
and no campus or organization selector is displayed.

### SC-PER-004 — Role cannot be changed in the client

Given a valid `PARTICIPANT` session,
when the client attempts to navigate directly to a Cafetería action,
then the action remains forbidden by the server,
and no business state changes.
