# Return Container — API Contract

**Status:** DRAFT TARGET. Product semantics, identifiers, server time and MVP replay behavior are approved; QR resolution and feature authorization remain gated.

## Resolution prerequisite

The Cafetería actor resolves a `RETURN` participant operation QR and a container QR. The server verifies that the active circulation belongs to that participant.

## Endpoint

```text
POST /api/v1/circulations/{circulationId}/return
Permission: RECEIVE_CONTAINER_RETURN
Actor: Cafetería
```

Request:

```json
{
  "participantOperationTokenRef": "<reference-from-dynamic-qr-resolution>",
  "containerRef": "<reference-from-container-resolution>"
}
```

The request contains no client return timestamp, target state or client idempotency key.

## Success

`200 OK`

```json
{
  "circulationId": "<identifier>",
  "participantRef": "<opaque-reference>",
  "container": {
    "id": "<identifier>",
    "publicCode": "<display-code>",
    "state": "RETURNED",
    "stateLabel": "Pendiente de lavado"
  },
  "returnedAt": "<server-timestamp>",
  "punctuality": "ON_TIME",
  "traceId": "<correlation-reference>"
}
```

The operation finalizes possession but does not make the container available.

## Failures

- `400 VALIDATION_ERROR`;
- `401 UNAUTHENTICATED`;
- `403 FORBIDDEN_OPERATION`;
- `404 CIRCULATION_NOT_FOUND`;
- `404 CONTAINER_NOT_FOUND`;
- `409 RETURN_ALREADY_REGISTERED`;
- `409 INVALID_STATE_TRANSITION`;
- `409 CONCURRENCY_CONFLICT`;
- safe `500`.

## Idempotency

The active-state check and optimistic version protect the circulation and container updates. Repetition or concurrency MUST produce at most one finalization and one return event. A request observed after the first commit receives `409 RETURN_ALREADY_REGISTERED`; it does not replay the original success response.
