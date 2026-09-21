# Participant Domain Specification

**Status:** APPROVED FOR AUTHENTICATED MVP OPERATION QR. Production account association remains gated by identity provisioning.

## 1. Concept

A `Participant` is a person taking part in the ITVer ReVuelta pilot who may possess one or more containers.

The participant exists independently from login, but generating a handoff QR requires an authenticated account explicitly associated with that participant.

## 2. Identity

- `BR-PAR-001`: Participant identity is stable and internal to ReVuelta.
- `BR-PAR-002`: An active operation QR resolves to one participant and one purpose.
- `BR-PAR-003`: The QR carries no PII.
- `BR-PAR-004`: An operation QR is not staff authentication or authorization.
- `BR-PAR-005`: One participant may have zero, one or many active circulations.
- `BR-PAR-006`: Expiring or consuming an operation QR does not delete participant or circulation history.

## 3. Participant operation QR

The code/QR contains:

- a participant-operation type discriminator;
- a payload version;
- the `DELIVERY` or `RETURN` purpose;
- an opaque token identifier;
- server expiration and an integrity signature.

It MUST NOT contain:

- name;
- email;
- matrícula;
- staff/student classification;
- active container IDs;
- authorization claims.

## 4. Issuance

An authenticated `PARTICIPANT` account requests an operation QR after the server resolves its explicit participant association.

Issuance:

1. creates one opaque operation-token record;
2. binds it to exactly one participant and purpose;
3. sets expiration from server time (two minutes by default, configurable);
4. produces a signed scannable representation.

Issuance does not create a participant or circulation. A token is consumed only by the successful matching delivery/return transaction.

## 5. Resolution

Cafetería scans the dynamic QR during delivery or return. Successful resolution returns only:

- stable internal/public participant reference appropriate for the application command;
- token reference and purpose;
- active/inactive eligibility;
- expiration;
- count or summary needed to warn about current active circulations, if approved;
- no unnecessary personal data.

Resolution does not mutate participant or circulation state.

## 6. Expiration and replay

- expiration uses authoritative server time;
- resolving is read-only and may be repeated while current;
- only a matching successful handoff consumes the token;
- expired, consumed, tampered and wrong-purpose tokens fail distinctly;
- no manual fallback exists.

## 7. Acceptance scenarios

### SC-PAR-001 — Issue operation QR

Given an authenticated participant account with an explicit association,
when an operation QR is requested,
then one short-lived token for the selected purpose exists,
without creating a circulation.

### SC-PAR-002 — Resolve participant

Given a current valid operation QR,
when Cafetería resolves it,
then exactly one participant reference, purpose and eligibility result are returned,
without PII in the QR payload.

### SC-PAR-003 — Multiple active containers

Given a participant already has an active circulation,
when another eligible container is delivered using a new `DELIVERY` QR,
then a second active circulation may be created,
provided the second container has no active circulation.

### SC-PAR-004 — QR is not authorization

Given a client possesses a valid participant operation QR,
when it attempts a protected mutation without an authorized staff actor,
then the mutation is rejected.

### SC-PAR-005 — Both QR values required

Given Cafetería has only the participant QR or only the container QR,
when delivery or return is attempted,
then the operation is rejected without mutation.
