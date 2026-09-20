# Participant Code — API Contract

**Status:** DRAFT. Paths and semantics are approved targets; exact identifiers, authentication and idempotency are gated by D-007, D-008 and D-010.

## Issue participant

```text
POST /api/v1/participants
Permission: ISSUE_PARTICIPANT_CODE
Actor: Operación ReVuelta
```

Request contains only approved issuance metadata and idempotency information. It MUST NOT require PII merely to create a participant.

Success `201`:

```json
{
  "participantRef": "<opaque-reference>",
  "participantCode": {
    "formatVersion": 1,
    "payload": "<opaque-scannable-payload>",
    "status": "ACTIVE"
  },
  "issuedAt": "<server-timestamp>",
  "traceId": "<correlation-reference>"
}
```

The exact payload serialization is frozen before QR printing and cannot silently change.

## Resolve participant code

```text
POST /api/v1/participant-code-resolutions
Permission: RESOLVE_PARTICIPANT_CODE
Actor: Cafetería or Operación ReVuelta
```

Request:

```json
{
  "payload": "<untrusted-scanned-value>"
}
```

Success `200`:

```json
{
  "participantRef": "<opaque-reference>",
  "eligibility": "ELIGIBLE",
  "activeCirculationCount": 2,
  "traceId": "<correlation-reference>"
}
```

The response contains no name, email or matrícula.

## Failures

- `400 PARTICIPANT_CODE_INVALID`;
- `401 UNAUTHENTICATED`;
- `403 FORBIDDEN_OPERATION`;
- `404 PARTICIPANT_NOT_FOUND`;
- `409 PARTICIPANT_INACTIVE`;
- safe `500`.

Resolution is read-only and idempotent. Issuance idempotency remains governed by D-010.
