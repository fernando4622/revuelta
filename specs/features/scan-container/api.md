# Dual QR — API Contract

**Status:** APPROVED FOR F4 MVP.

All responses include `X-Correlation-ID`. All errors use the shared problem contract.

## Generate participant operation QR

```text
POST /api/v1/me/operation-qrs
Role: PARTICIPANT
```

Request:

```json
{ "purpose": "DELIVERY" }
```

`purpose` is `DELIVERY` or `RETURN`. Success `201` returns:

```json
{
  "tokenRef": "<uuid>",
  "purpose": "DELIVERY",
  "payload": "RV1:P:DELIVERY:<token-uuid>:<expires-epoch>:<signature>",
  "issuedAt": "<server-time>",
  "expiresAt": "<server-time>"
}
```

The endpoint creates an expiring token only. It does not create or return a circulation. A new request creates a new token; older unconsumed tokens simply expire.

## Resolve participant operation QR

```text
POST /api/v1/operation-qr-resolutions
Role: OPERATOR
```

Request: `{ "payload": "<untrusted-value>" }`.

Success `200` returns token reference, opaque participant reference, purpose, expiry and `ELIGIBLE`. It contains no PII and does not consume the token.

## Resolve container QR

```text
POST /api/v1/container-qr-resolutions
Roles: OPERATOR, ADMIN
```

Request: `{ "payload": "<untrusted-value>" }`.

Success `200` returns:

```json
{
  "containerRef": "<uuid>",
  "displayCode": "RV-0001",
  "state": "AVAILABLE",
  "stateLabel": "Disponible",
  "activeCirculation": null,
  "allowedActions": ["DELIVER"]
}
```

For `IN_USE`, an `OPERATOR` receives only the active circulation reference, opaque participant reference, delivered-at and due-at required for return. Full history remains `ADMIN`-only.

## Retrieve and rotate container QR

```text
GET  /api/v1/containers/{containerId}/qr
POST /api/v1/containers/{containerId}/qr-rotations
Role: ADMIN
```

Retrieval is read-only. Rotation requires `{ "reason": "<non-empty>" }`, increments generation, appends `CONTAINER_QR_ROTATED`, and returns the new payload. An old correctly signed generation returns `409 CONTAINER_QR_REVOKED`.

Container registration returns its initial QR payload and appends `REGISTERED` with the authenticated actor and server time.

## Failure mapping

- `400 INVALID_QR`, `UNSUPPORTED_QR_VERSION`, `QR_TAMPERED`, `VALIDATION_ERROR`;
- `401 UNAUTHENTICATED`;
- `403 FORBIDDEN_OPERATION`;
- `404 CONTAINER_NOT_FOUND`, `PARTICIPANT_NOT_FOUND`;
- `409 CONTAINER_QR_REVOKED`, `INACTIVE_CONTAINER`, `QR_EXPIRED`, `QR_ALREADY_USED`, `QR_PURPOSE_MISMATCH`, `PARTICIPANT_ACCOUNT_NOT_LINKED`, `PARTICIPANT_INACTIVE`;
- safe `500`.

Resolution endpoints are read-only and idempotent. Issuance and rotation are non-idempotent explicit commands; retries create a new token or generation and are always audit-visible where applicable.
