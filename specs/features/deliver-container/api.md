# Deliver Container — API Contract

**Status:** DRAFT TARGET. Product semantics, identifiers, time and MVP replay behavior are approved; participant resolution and feature authorization remain gated.

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

Client timestamps, target state and client idempotency headers are prohibited in the MVP contract.

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

The endpoint is mutating and uses no client idempotency key in the MVP. A partial unique index permits at most one active circulation for a container under concurrency. A replay observed after the first commit receives `409 ACTIVE_CIRCULATION_EXISTS`; it does not replay the original success response. A participant may still hold active circulations for other containers.
