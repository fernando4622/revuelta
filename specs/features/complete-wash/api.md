# Complete Container Washing — API Contract

**Status:** DRAFT TARGET. Product semantics, identifiers, server time and MVP replay behavior are approved; feature authorization remains gated.

## Endpoint

```text
POST /api/v1/containers/{containerId}/wash-completions
Permission: COMPLETE_CONTAINER_WASH
Actor: Cafetería
```

The request contains no client timestamp, target state or client idempotency key.

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

Optimistic locking and the state transition protect the mutation. Repetition or concurrency MUST produce at most one transition and one wash-completed event. A request observed after completion receives `409 WASH_ALREADY_COMPLETED`; it does not replay the original success response.
