# Participant Domain Specification

**Status:** APPROVED BASELINE. Recovery/reissue remains blocked by D-018.

## 1. Concept

A `Participant` is a person taking part in the ITVer ReVuelta pilot who may possess one or more containers.

The domain does not require login to represent a participant.

## 2. Identity

- `BR-PAR-001`: Participant identity is stable and internal to ReVuelta.
- `BR-PAR-002`: An active Participant Code resolves to at most one participant.
- `BR-PAR-003`: The public code is opaque and carries no PII.
- `BR-PAR-004`: A Participant Code is not authentication or authorization.
- `BR-PAR-005`: One participant may have zero, one or many active circulations.
- `BR-PAR-006`: Deactivating a code does not delete participant or circulation history.

## 3. Participant Code

The code/QR contains:

- a type discriminator identifying it as a participant code;
- a payload version;
- an opaque public identifier.

It MUST NOT contain:

- name;
- email;
- matrícula;
- staff/student classification;
- active container IDs;
- authorization claims.

## 4. Issuance

An authorized ReVuelta operations actor issues the first Participant Code.

Issuance:

1. creates one participant;
2. creates one active opaque public code;
3. records actor, server time and correlation;
4. produces a scannable representation.

Duplicate physical printing of the same active code does not create another participant.

## 5. Resolution

Cafetería scans the code during delivery. Successful resolution returns only:

- stable internal/public participant reference appropriate for the application command;
- active/inactive eligibility;
- count or summary needed to warn about current active circulations, if approved;
- no unnecessary personal data.

Resolution does not mutate participant or circulation state.

## 6. Recovery and replacement

Lost-code recovery, replacement and reassociation are prohibited in the normal UI until D-018 defines:

- how the person is verified;
- whether the participant identity is preserved;
- how the old code is invalidated;
- how existing active circulations remain associated;
- what audit evidence is recorded.

## 7. Acceptance scenarios

### SC-PAR-001 — Issue participant

Given an authorized ReVuelta actor,
when a Participant Code is issued,
then one participant and one active opaque code exist,
and an issuance event is recorded.

### SC-PAR-002 — Resolve participant

Given an active valid Participant Code,
when Cafetería resolves it,
then exactly one participant reference and eligibility result are returned,
without PII in the QR payload.

### SC-PAR-003 — Multiple active containers

Given a participant already has an active circulation,
when another eligible container is delivered,
then a second active circulation may be created,
provided the second container has no active circulation.

### SC-PAR-004 — Code is not authorization

Given a client possesses a valid Participant Code,
when it attempts a protected mutation without an authorized staff actor,
then the mutation is rejected.
