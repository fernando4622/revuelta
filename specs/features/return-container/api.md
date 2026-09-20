# Return Container — API Contract

**Status:** DRAFT. Product semantics are approved; authentication, identifiers, time and idempotency remain gated.

## Resolution prerequisite

Container QR resolution returns the active circulation reference when the Cafetería actor is authorized to receive it.

## Endpoint

```text
POST /api/v1/circulations/{circulationId}/return
Permission: RECEIVE_CONTAINER_RETURN
Actor: Cafetería
```

The request contains no client return timestamp or target state. Idempotency metadata follows D-010.

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

The final replay contract is blocked by D-010. Repetition or concurrency MUST produce at most one finalization and one return event.
