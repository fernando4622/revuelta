# Identity and Access Control Specification

**Status:** PRODUCT PERMISSIONS, MVP ROLE BINDING AND DUAL-QR ACCESS APPROVED. Production institutional provisioning remains blocked.

## 1. Security principles

- `SEC-001`: Every protected mutation is authenticated before real-pilot use.
- `SEC-002`: Every sensitive operation is authorized server-side.
- `SEC-003`: UI visibility is never authorization; the server-issued role is the only role claim accepted by the application.
- `SEC-004`: Default authorization posture is deny-by-default.
- `SEC-005`: Participant and container QR data never grant staff authorization.
- `SEC-006`: Tokens, QR payloads, secrets and passwords MUST NOT be logged.
- `SEC-007`: Responses expose only the minimum data required by the actor.

## 2. Identity types

### Participant

The authenticated `PARTICIPANT` account opens the Alumno/maestro experience. Its access to personal data requires an explicit server-side association with the participant record.

The participant's dynamic operation QR is generated from an authenticated account explicitly associated with the participant. It is not a staff session or standalone authorization.

### Cafetería actor

An authenticated staff identity authorized for physical handoff operations.

### ReVuelta operations actor

An authenticated privileged identity authorized for pilot administration.

## 3. Authenticated role routing

The development/MVP application uses provisioned accounts and signed server tokens:

- `PARTICIPANT` routes to Alumno/maestro;
- `OPERATOR` routes to Cafetería;
- `ADMIN` routes to Operación ReVuelta.

There is no unrestricted selector or trusted client-supplied role. Missing or unknown roles fail closed. Development seed credentials are forbidden in production.

## 4. Permission matrix

| Permission | Alumno | Cafetería | Operación ReVuelta |
|---|:---:|:---:|:---:|
| View own active containers/history | Yes, after trusted identity binding | No | Yes, for operational purpose |
| Generate own operation QR | Yes, after trusted identity binding | No | No |
| Resolve participant operation QR | No | Yes | No normal flow |
| Resolve container QR | Own informational flow only | Yes | Yes |
| Create circulation/deliver | No | Yes | No |
| Register physical return | No | Yes | No |
| Complete washing | No | Yes | No normal flow |
| View recent own operational actions | No | Yes | Yes |
| Register/activate container | No | No | Yes |
| Reprint/replace container QR | No | No | Yes |
| Search all containers/circulations | No | Limited to active handoff | Yes |
| Mark damaged/lost/retired/recovered | No | No | Yes, with reason and approved evidence |
| Resolve incidents/corrections | No | Escalate only | Yes, through explicit use case with reason |
| Manage return policy | No | No | Yes, when separately authorized |
| View full audit | No | No | Yes |
| Edit/delete audit history | No | No | No |

## 5. Resource authorization

Authorization evaluates:

```text
authenticated actor
+ permission
+ target resource
+ current domain state
+ operation context
```

A permitted role cannot bypass domain state. Direct API calls receive the same decision as UI calls.

## 6. Participant operation QR controls

- QR contains type/version, purpose, opaque token reference, expiry and integrity signature only.
- Cafetería may resolve only the data needed to complete the handoff.
- Resolution MUST NOT return unnecessary personal data.
- A copied operation QR cannot authorize a staff operation and expires after two configurable minutes.
- A token is consumed by at most one successful matching handoff.
- Delivery and return always require this QR plus the static container QR.

## 7. Security acceptance scenarios

### SC-SEC-001 — Role bypass

Given a participant modifies the client to display a Cafetería screen,
when they call a protected Cafetería endpoint with a `PARTICIPANT` token,
then the server rejects the request without mutation.

### SC-SEC-002 — Participant QR is not authorization

Given a valid participant operation QR,
when an unauthenticated client submits a delivery,
then the request is rejected.

### SC-SEC-003 — Minimum participant exposure

Given Cafetería resolves a participant operation QR,
when the response is returned,
then it contains the participant reference and operational eligibility only,
without name, email or matrícula unless a later approved spec requires them.

### SC-SEC-004 — Student isolation

Given a trusted participant session is explicitly associated with one participant,
when it queries active containers/history,
then only records for that participant are returned.

### SC-SEC-005 — Correction requires reason

Given Operación ReVuelta performs an approved correction,
when it is submitted,
then a non-empty reason and actor are recorded in append-oriented history.

## 8. Enabled MVP endpoint enforcement

For the currently enabled API surface:

- `ADMIN` registers/activates containers, lists the complete inventory and reads full container history;
- `OPERATOR` inspects a specific container and performs normal delivery/return;
- `ADMIN` may inspect a specific container but may not perform the normal Cafetería delivery/return workflow;
- `PARTICIPANT` has no access to these operational endpoints until participant-owned resources and binding are implemented;
- absent, malformed, expired or unknown-role credentials fail closed.

Automated HTTP tests exercise every enabled sensitive endpoint against this matrix. Productive account lifecycle and early token revocation remain blocked by the authentication spec's production boundary.
