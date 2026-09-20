# Feature Spec — Issue and Resolve Participant Code

**Status:** APPROVED BASELINE. Recovery/reissue remains blocked by D-018.

## Purpose

Identify a pilot participant without login or PII in the QR so Cafetería can associate a delivery with a stable participant.

## Actors

- Operación ReVuelta issues the code.
- Cafetería resolves the code during delivery.

## Issue preconditions

- ReVuelta actor is authenticated and authorized;
- request represents a new participant or an approved issuance context;
- secure opaque code generation is available.

## Resolve preconditions

- Cafetería actor is authenticated and authorized;
- payload is syntactically valid and identifies the participant-code type/version.

## Outputs

Issue:

- participant reference;
- opaque public code/scannable payload;
- status;
- issued-at;
- trace reference.

Resolve:

- participant reference;
- active/inactive eligibility;
- minimal operational summary;
- no unnecessary PII.

## Rules

- code is persistent across deliveries;
- one participant may have multiple active circulations;
- code possession is not authentication;
- QR carries no name, email, matrícula or role;
- resolution is read-only;
- replacement/recovery is unavailable until D-018.

## Failures

```text
UNAUTHENTICATED
FORBIDDEN_OPERATION
PARTICIPANT_CODE_INVALID
PARTICIPANT_NOT_FOUND
PARTICIPANT_INACTIVE
PARTICIPANT_CODE_RECOVERY_NOT_SUPPORTED
VALIDATION_ERROR
```

## Acceptance

- issue produces one participant and active opaque code;
- valid active code resolves one participant;
- invalid/unknown/inactive code produces a typed result;
- scanning does not create a circulation;
- no PII is encoded in the QR.
