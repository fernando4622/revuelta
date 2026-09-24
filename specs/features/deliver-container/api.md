# Deliver Container — API Contract

**Status:** APPROVED FOR F5 IMPLEMENTATION.

## Preview endpoint

```text
POST /api/v1/delivery-previews
Permission: DELIVER_CONTAINER
Actor: Cafetería
Mutation: none
```

The preview request contains the same two untrusted signed payloads as the
delivery command. It validates current eligibility and returns a server-supplied
policy summary for the confirmation screen. It does not reserve the container,
consume the participant token or guarantee that a later delivery will still be
eligible.

`200 OK`

```json
{
  "participantRef": "<opaque-reference>",
  "container": {
    "id": "<identifier>",
    "publicCode": "<display-code>",
    "state": "AVAILABLE"
  },
  "policy": {
    "id": "<identifier>",
    "version": 1,
    "name": "<display-name>",
    "durationHours": 48
  },
  "previewedAt": "<server-timestamp>",
  "estimatedDueAt": "<server-timestamp>",
  "traceId": "<correlation-reference>"
}
```

The UI labels `estimatedDueAt` as an estimate. Only the delivery response has
the authoritative `dueAt` captured in the circulation.

## Endpoint

```text
POST /api/v1/circulations
Permission: DELIVER_CONTAINER
Actor: Cafetería
```

## Request

```json
{
  "participantQrPayload": "<signed-dynamic-qr-payload>",
  "containerQrPayload": "<signed-static-container-qr-payload>"
}
```

Both fields are required and have a maximum length of 512 characters. Client
timestamps, resolved identifiers, target state and client idempotency headers
are prohibited in the MVP contract.

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
- `400 INVALID_QR`;
- `400 QR_TAMPERED`;
- `400 UNSUPPORTED_QR_VERSION`;
- `401 UNAUTHENTICATED`;
- `403 FORBIDDEN_OPERATION`;
- `404 PARTICIPANT_NOT_FOUND`;
- `404 CONTAINER_NOT_FOUND`;
- `409 PARTICIPANT_INACTIVE`;
- `409 QR_EXPIRED`;
- `409 QR_ALREADY_USED`;
- `409 QR_PURPOSE_MISMATCH`;
- `409 CONTAINER_QR_REVOKED`;
- `409 INACTIVE_CONTAINER`;
- `409 CONTAINER_NOT_AVAILABLE`;
- `409 ACTIVE_CIRCULATION_EXISTS`;
- `409 CONCURRENCY_CONFLICT`;
- `409 POLICY_NOT_FOUND`;
- safe `500`.

An existing circulation for a different container and the same participant is not a conflict.

## Idempotency

The endpoint is mutating and uses no client idempotency key in the MVP. The
operation token row is locked and consumed in the successful transaction. A
partial unique index permits at most one active circulation for a container
under concurrency. A replay observed after the first commit receives
`409 QR_ALREADY_USED`; it does not replay the original success response. A
participant may still hold active circulations for other containers.

## Transaction and validation order

The command decodes both signed payloads, locks the operation token, validates
its signed claims and `DELIVERY` purpose, validates the active participant,
validates the current container QR generation and state, selects the active
policy, creates the circulation, transitions the container, appends the event
and consumes the token in one transaction. Any failure rolls back every write.
