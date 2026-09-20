# ReVuelta Product Specification

**Status:** PARTIALLY APPROVED. Pilot actors, development/MVP authentication, participant identification, return ownership and post-return washing flow are approved. Production identity provisioning, participant-code recovery and remaining technical decisions stay open.

## 1. Product boundary

ReVuelta V1 operates only in the Instituto Tecnológico de Veracruz pilot:

```text
ITVer
→ Cafetería del Instituto
→ Punto ReVuelta — Cafetería del Instituto
→ reusable-container circulation
```

No multi-campus, restaurant-partner or multi-organization behavior belongs to V1.

## 2. Actors and perspectives

### 2.1 Alumno / participante

A member of the participating ITVer community who may hold one or more ReVuelta containers.

Responsibilities:

- present their persistent Participant Code when receiving a container;
- keep and return assigned containers;
- consult their own container state, due information and history when a trusted identity/session becomes available;
- follow instructions for the approved return point.

The Participant Code does not prove institutional status and is not authentication.

### 2.2 Personal de Cafetería

The operational actor performing physical handoffs.

Responsibilities:

- scan/resolve a Participant Code;
- scan/resolve a container QR;
- confirm delivery;
- scan and confirm physical return;
- verify the pending-wash queue;
- confirm washing so a returned container becomes available;
- inspect only the minimum information required for the handoff;
- escalate incidents to Operación ReVuelta.

### 2.3 Operación ReVuelta

The administrative actor for this pilot.

Responsibilities:

- register, activate and retire containers through explicit operations;
- issue Participant Codes;
- reprint/replace container QR;
- search containers and circulations;
- inspect complete traceability;
- manage approved exceptional states;
- resolve operational incidents;
- make approved corrections as append-oriented operations with a reason;
- manage return policy when authorized.

Operation ReVuelta does not use a generic status editor and does not rewrite history.

## 3. Primary journeys

### J-00 Authenticate and resolve experience

The user signs in with a provisioned account. The server-issued role opens exactly one experience: Alumno/maestro participante, Cafetería or Operación ReVuelta. There is no unrestricted perspective selector.

### J-01 Issue Participant Code

An authorized ReVuelta actor creates a persistent participant record and issues an opaque code/QR containing no personal data.

### J-02 Deliver container

Cafetería scans the Participant Code and container QR, reviews eligibility and confirms the physical handoff. One active circulation is created for that container.

### J-03 Student information

Alumno or maestro views their active containers, return instructions and history only when the authenticated account is explicitly associated with the participant record. The development account may use seeded data; real pilot binding remains subject to production identity provisioning.

### J-04 Return container

Cafetería scans the container, resolves the active circulation, confirms physical receipt, finalizes the circulation, unlinks it from the participant and moves the container to `RETURNED`.

### J-05 Complete washing

Cafetería selects a `RETURNED` container and confirms “Lavado completado”. The container moves to `AVAILABLE` and an audit event is recorded.

### J-06 Inspect and administer pilot

Operación ReVuelta searches inventory/circulations, reviews events and executes only explicit authorized operations.

## 4. Functional requirements

### Identity and access

- `FR-001`: Every protected mutation MUST be performed by an authenticated actor before the real pilot.
- `FR-002`: Every protected mutation MUST be authorized server-side.
- `FR-003`: The server-issued authenticated role MUST determine the available UI experience; the client MUST NOT choose or override its role.
- `FR-004`: Participant Code possession MUST NOT authorize a business mutation.

### Participant

- `FR-005`: Each participant MUST have one persistent internal identity.
- `FR-006`: Each active Participant Code MUST resolve to at most one participant.
- `FR-007`: The Participant Code payload MUST contain no name, email, matrícula or institutional role.
- `FR-008`: A participant MAY have more than one active circulation.
- `FR-009`: Lost/replaced Participant Code recovery MUST remain disabled until D-018 is approved.

### Containers

- `FR-010`: The system MUST maintain one logical record per physical container.
- `FR-011`: A container identifier MUST be unique and immutable once issued.
- `FR-012`: A container with history MUST NOT be physically deleted through normal operations.
- `FR-013`: The system MUST expose current operational state.
- `FR-014`: A `RETURNED` container MUST NOT be eligible for delivery.

### QR

- `FR-020`: Cafetería MUST scan a Participant Code and container QR for delivery.
- `FR-021`: Cafetería MUST scan the container QR for return.
- `FR-022`: The backend MUST treat every scanned payload as untrusted.
- `FR-023`: Participant and container QR formats MUST be distinguishable.
- `FR-024`: Unknown, inactive, malformed or unsupported payloads MUST produce explicit failures.

### Circulation and delivery

- `FR-030`: A circulation is created only when actor, participant and container validations pass.
- `FR-031`: A container MUST NOT have more than one active circulation.
- `FR-032`: There is no product-level limit of one active circulation per participant.
- `FR-033`: Delivery time is authoritative server time.
- `FR-034`: Due-at derives from the approved effective policy.
- `FR-035`: Delivery records the Cafetería actor and participant.

### Return

- `FR-040`: Return MUST resolve an active circulation.
- `FR-041`: Cafetería is the actor that confirms physical receipt.
- `FR-042`: Return time and punctuality are server-authoritative.
- `FR-043`: A circulation cannot be finalized twice.
- `FR-044`: A successful return finalizes the circulation and transitions `IN_USE → RETURNED`.
- `FR-045`: Finalizing return removes current possession from the participant.

### Washing

- `FR-046`: `RETURNED` means “Pendiente de lavado”.
- `FR-047`: Only an authorized Cafetería actor may perform the normal “Lavado completado” operation.
- `FR-048`: Washing transitions `RETURNED → AVAILABLE`.
- `FR-049`: Return and washing MUST create separate trace events.

### Traceability

- `FR-050`: Sensitive business actions MUST create an auditable event.
- `FR-051`: Events preserve actor, time, resource, action/result and correlation where defined.
- `FR-052`: Audit records MUST NOT be silently edited or deleted.

### UI demonstration

- `FR-060`: Impact and notifications MAY appear in demo builds only with a visible “Datos de demostración” label.
- `FR-061`: Demo values MUST NOT be sent to or stored as production business facts.
- `FR-062`: The approved prototype logo is `apps/revuelta-mobile/resources/logo.jpeg`.
- `FR-063`: The official return-point label is “Punto ReVuelta — Cafetería del Instituto”.

## 5. Product acceptance boundaries

V1 is not acceptable if:

- one Participant Code resolves to multiple active participants;
- personal information appears in a QR payload;
- two active circulations exist for one container;
- a participant is limited to one container without an approved policy;
- the Alumno perspective can finalize a return;
- return immediately makes a dirty container available;
- a returned container can be delivered before washing completes;
- unauthorized clients can mutate protected operations;
- lifecycle state can be changed through a generic status editor;
- return or washing can be duplicated;
- history can be silently changed or deleted;
- client time becomes business-authoritative.

## 6. Open decisions

- D-003 exact return window;
- D-004 exceptional-state evidence details;
- D-005 final treatment of unused `ASSIGNED`;
- production institutional account provisioning, recovery and token revocation beyond the approved MVP mechanism;
- D-008 final key strategy — resolved for MVP by the decision register;
- D-009 time representation — resolved for MVP by the decision register;
- D-010 idempotency mechanism — resolved for MVP by the decision register;
- D-013 concurrency mechanism — resolved for MVP by the decision register;
- D-017 real environmental methodology;
- D-018 Participant Code recovery/replacement.
