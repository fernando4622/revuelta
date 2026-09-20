# Deliver Container — API Contract

**Status:** DRAFT. Product semantics are approved; authentication, identifiers and idempotency remain gated.

## Endpoint

```text
POST /api/v1/circulations
Permission: DELIVER_CONTAINER
Actor: Cafetería
```

## Request

```json
{
  "participantRef": "<reference-from-code-resolution>",
  "containerRef": "<reference-from-container-resolution>"
}
```

Client timestamps and target state are prohibited. Idempotency metadata follows D-010 once approved.

## Success

`201 Created`

```json
{
  "circulationId": "<identifier>",
  "participantRef": "<opaque-reference>",
  "container": {
    "id": "<identifier>",
    "publicCode": "<display-code>",
    "state": "IN_USE"
  },
  "deliveredAt": "<server-timestamp>",
  "dueAt": "<server-timestamp>",
  "policy": {
    "id": "<identifier>",
    "version": "<version>"
  },
  "traceId": "<correlation-reference>"
}
```

## Failures

- `400 VALIDATION_ERROR`;
- `401 UNAUTHENTICATED`;
- `403 FORBIDDEN_OPERATION`;
- `404 PARTICIPANT_NOT_FOUND`;
- `404 CONTAINER_NOT_FOUND`;
- `409 PARTICIPANT_INACTIVE`;
- `409 CONTAINER_NOT_AVAILABLE`;
- `409 ACTIVE_CIRCULATION_EXISTS`;
- `409 CONCURRENCY_CONFLICT`;
- `409 POLICY_NOT_FOUND`;
- safe `500`.

An existing circulation for a different container and the same participant is not a conflict.

## Idempotency

The endpoint is mutating. The final header/key and replay response are blocked by D-010. Database protection for one active circulation per container remains mandatory regardless of client deduplication.
