# Participant Operation QR — API Contract

**Status:** SUPERSEDED BY `../scan-container/api.md` FOR F4.

## Generate operation QR

```text
POST /api/v1/me/operation-qrs
Permission: GENERATE_OWN_OPERATION_QR
Actor: PARTICIPANT
```

Request selects `DELIVERY` or `RETURN`. The authenticated account association supplies participant identity.

Success `201`:

```json
{
  "tokenRef": "<opaque-reference>",
  "purpose": "DELIVERY",
  "payload": "<signed-scannable-payload>",
  "issuedAt": "<server-timestamp>",
  "expiresAt": "<server-timestamp>"
}
```

The exact payload serialization is frozen before QR printing and cannot silently change.

## Resolve participant operation QR

```text
POST /api/v1/operation-qr-resolutions
Permission: RESOLVE_PARTICIPANT_OPERATION_QR
Actor: Cafetería
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
  "purpose": "DELIVERY",
  "expiresAt": "<server-timestamp>"
}
```

The response contains no name, email or matrícula.

## Failures

- `400 INVALID_QR`, `UNSUPPORTED_QR_VERSION` or `QR_TAMPERED`;
- `401 UNAUTHENTICATED`;
- `403 FORBIDDEN_OPERATION`;
- `404 PARTICIPANT_NOT_FOUND`;
- `409 PARTICIPANT_ACCOUNT_NOT_LINKED`, `PARTICIPANT_INACTIVE`, `QR_EXPIRED` or `QR_ALREADY_USED`;
- safe `500`.

Resolution is read-only and idempotent. Generation intentionally creates a fresh short-lived token; only F5/F6 consume it atomically with the matching successful operation.
