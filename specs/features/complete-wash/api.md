# Complete Container Washing — API Contract

**Status:** DRAFT. Product semantics are approved; authentication, identifiers and idempotency remain gated.

## Endpoint

```text
POST /api/v1/containers/{containerId}/wash-completions
Permission: COMPLETE_CONTAINER_WASH
Actor: Cafetería
```

The request contains no client timestamp or target state. Idempotency metadata follows D-010.

## Success

`200 OK`

```json
{
  "container": {
    "id": "<identifier>",
    "publicCode": "<display-code>",
    "state": "AVAILABLE",
    "stateLabel": "Disponible"
  },
  "washedAt": "<server-timestamp>",
  "traceId": "<correlation-reference>"
}
```

## Failures

- `400 VALIDATION_ERROR`;
- `401 UNAUTHENTICATED`;
- `403 FORBIDDEN_OPERATION`;
- `404 CONTAINER_NOT_FOUND`;
- `409 CONTAINER_NOT_RETURNED`;
- `409 WASH_ALREADY_COMPLETED`;
- `409 CONCURRENCY_CONFLICT`;
- safe `500`.

## Idempotency

The final replay contract is blocked by D-010. Repetition or concurrency MUST produce at most one transition and one wash-completed event.
