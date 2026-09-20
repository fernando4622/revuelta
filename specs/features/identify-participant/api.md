# Participant Code — API Contract

**Status:** DRAFT. Paths and semantics are approved targets; UUID identifiers are resolved. Authentication, recovery and issuance replay semantics must be completed with D-007 and D-018 before implementation.

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

Resolution is read-only and idempotent. Participant issuance has no natural pre-existing resource identity, so its feature spec MUST define a deduplication input before that mutating endpoint is implemented; the core state-conflict policy alone is insufficient for issuance.
