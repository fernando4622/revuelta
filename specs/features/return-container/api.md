# Return Container — API Contract

**Status:** APPROVED F6 CONTRACT.

## Resolution prerequisite

The Cafetería actor scans a `RETURN` participant operation QR and a container QR.
Both complete signed payloads are retained only for the active handoff and are
revalidated by the server for preview and again inside the commit transaction.

## Endpoint

```text
POST /api/v1/return-previews
Permission: RECEIVE_CONTAINER_RETURN
Actor: Cafetería
```

Request:

```json
{
  "participantQrPayload": "<complete-signed-dynamic-payload>",
  "containerQrPayload": "<complete-signed-static-payload>"
}
```

Success: `200 OK`. The response contains the participant reference, circulation
identity, container code/current state, delivered-at, due-at, previewed-at and
trace reference. It performs no mutation and consumes no token.

## Commit endpoint

```text
POST /api/v1/circulation-returns
Permission: RECEIVE_CONTAINER_RETURN
Actor: Cafetería
```

The request uses the same two required payload fields as the preview. It contains
no circulation identifier, client return timestamp, target state or client
idempotency key. The active circulation is derived from the verified container
and must belong to the verified participant.

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
- `409 CIRCULATION_PARTICIPANT_MISMATCH`;
- `409 QR_ALREADY_USED`;
- `409 RETURN_ALREADY_REGISTERED`;
- `409 INVALID_STATE_TRANSITION`;
- `409 CONCURRENCY_CONFLICT`;
- safe `500`.

## Idempotency

The participant token lock, active-state check and optimistic versions protect the
token, circulation and container updates. Repetition or concurrency MUST produce
at most one finalization and one return event. Replaying the consumed QR pair
receives `409 QR_ALREADY_USED`. A fresh valid `RETURN` QR submitted for the same
already-returned container receives `409 RETURN_ALREADY_REGISTERED`. Neither
conflict replays the original success response.
