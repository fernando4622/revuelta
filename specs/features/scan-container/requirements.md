# Feature Spec — Scan and Resolve Container

**Status:** APPROVED FOR F4 MVP. Physical-device acceptance remains required.

## Purpose

Generate and resolve the QR references required for a later authorized handoff without mutating circulation state.

## Scope

- signed, static and generation-versioned container QR;
- short-lived participant operation QR for `DELIVERY` or `RETURN`;
- read-only resolution of both QR types;
- individual container-QR rotation by `ADMIN`;
- camera scanning in the Cafetería UI and QR rendering in the participant UI.

## Actors and permissions

- `PARTICIPANT`: generate an operation QR only for its associated participant;
- `OPERATOR`: resolve participant and container QR values;
- `ADMIN`: register containers, retrieve/rotate their QR and resolve container QR for inspection;
- scanning never supplies actor permission.

## Preconditions and inputs

- all endpoints require a signed session and the documented role;
- a participant account must have an explicit active participant association;
- QR input is an untrusted string;
- container QR format is `RV1:C:<container UUID>:<generation>:<HMAC>`;
- participant QR format is `RV1:P:<purpose>:<token UUID>:<expiry epoch seconds>:<HMAC>`.

## Rules

- QR is identification, not authorization.
- malformed payloads fail before business mutation;
- unknown identifiers produce a stable not-found outcome;
- inactive containers are distinguishable from unknown containers where policy permits;
- no mutation occurs during pure resolution.
- container signatures use a server-only secret and constant-time comparison;
- rotating a container QR increments its generation and invalidates older labels;
- participant QR duration defaults to 120 seconds and is configurable;
- participant QR resolution does not consume it; F5/F6 consume it atomically with a successful matching handoff;
- both QR values are mandatory in delivery and return;
- manual entry is not supported.

## Outputs

Container resolution returns identity, display code, state, operational availability, minimal active-circulation data permitted to the actor and server-derived allowed actions.

Participant operation resolution returns opaque participant reference, purpose, expiry and eligibility without PII.

## State changes

- resolution: none;
- participant QR issuance: creates an expiring token, not a circulation;
- container QR rotation: increments generation and appends an audit event without changing lifecycle state.

## Failures

```text
INVALID_QR
UNSUPPORTED_QR_VERSION
QR_TAMPERED
QR_EXPIRED
QR_ALREADY_USED
QR_PURPOSE_MISMATCH
CONTAINER_NOT_FOUND
CONTAINER_QR_REVOKED
INACTIVE_CONTAINER
PARTICIPANT_NOT_FOUND
PARTICIPANT_ACCOUNT_NOT_LINKED
PARTICIPANT_INACTIVE
UNAUTHENTICATED
FORBIDDEN_OPERATION
VALIDATION_ERROR
```

## Non-goals

- delivery/return mutation (F5/F6);
- manual lookup fallback;
- offline token issuance;
- production account provisioning;
- retirement/exceptional lifecycle transitions blocked by D-004.

## Acceptance

- valid QR resolves one container;
- invalid QR resolves none;
- unknown QR resolves none;
- scan failure does not change business state.
- altered and unsupported payloads are distinguishable;
- repeated camera frames issue one in-flight resolution;
- an expired/consumed participant QR cannot authorize a handoff;
- old container labels fail after rotation;
- a participant can generate distinct delivery and return QR values.
