# Feature Spec — Generate and Resolve Participant Operation QR

**Status:** APPROVED FOR F4 MVP.

## Purpose

Identify an authenticated pilot participant without PII in the QR so Cafetería can associate a delivery or return with a stable participant.

## Actors

- Alumno/maestro generates its own purpose-scoped dynamic QR.
- Cafetería resolves it during delivery or return.

## Generation preconditions

- participant account is authenticated and explicitly associated;
- purpose is `DELIVERY` or `RETURN`;
- secure opaque code generation is available.

## Resolve preconditions

- Cafetería actor is authenticated and authorized;
- payload is syntactically valid, current, unconsumed and identifies the participant-operation type/version.

## Outputs

Generation:

- opaque token reference and scannable payload;
- purpose;
- issued-at;
- expires-at.

Resolve:

- participant reference;
- active/inactive eligibility;
- minimal operational summary;
- no unnecessary PII.

## Rules

- code is short-lived and single-use at successful handoff;
- one participant may have multiple active circulations;
- code possession is not authentication;
- QR carries no name, email, matrícula or role;
- resolution is read-only;
- both participant and container QR values are required for delivery and return.

## Failures

```text
UNAUTHENTICATED
FORBIDDEN_OPERATION
PARTICIPANT_CODE_INVALID
QR_EXPIRED
QR_ALREADY_USED
QR_PURPOSE_MISMATCH
PARTICIPANT_NOT_FOUND
PARTICIPANT_ACCOUNT_NOT_LINKED
PARTICIPANT_INACTIVE
VALIDATION_ERROR
```

## Acceptance

- generation produces one expiring token without creating a participant or circulation;
- valid active code resolves one participant;
- invalid/unknown/inactive code produces a typed result;
- resolving does not create a circulation or consume the token;
- no PII is encoded in the QR.
