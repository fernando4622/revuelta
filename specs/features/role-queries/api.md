# Role-owned operational queries — API contract

**Status:** APPROVED FOR F7 IMPLEMENTATION.

All paths are relative to `/api/v1`, require bearer authentication and return
the common problem response on failure.

## Participant

```text
GET /me/circulations?status=ACTIVE|COMPLETED&page=0&size=20
GET /me/circulations/{circulationId}
Role: PARTICIPANT
```

Each item contains circulation reference, public container identity/state,
delivery/due/return instants, status and optional punctuality. Ownership is
resolved from the signed account; no participant identifier is accepted from
the client.

## Cafetería

```text
GET  /operator/pending-washes?page=0&size=20
GET  /operator/recent-operations?page=0&size=20
POST /containers/{containerId}/wash-completions
Role: OPERATOR
```

Pending-wash items contain container reference, public code, `RETURNED`,
“Pendiente de lavado” and returned-at. Recent operations contain event type,
container identity, occurred-at, resulting state and correlation reference.

Wash success is `200` and returns container identity/public code,
`AVAILABLE`/“Disponible”, server `washedAt` and `traceId`. The request has no
body, timestamp or target state.

## Operación ReVuelta

```text
GET /operations/summary
GET /operations/participants?page=0&size=20
GET /operations/circulations?status=ACTIVE|COMPLETED&page=0&size=20
GET /operations/events?type=<event-type>&page=0&size=20
GET /containers?query=<code>&status=<state>&page=0&size=20
GET /containers/{containerId}
GET /containers/{containerId}/history?page=0&size=20
Role: ADMIN
```

The summary contains counts for total, registered, available, in-use, returned,
damaged, lost and retired containers plus active circulations. Participant
results expose opaque reference, active flag and created-at only. Container
detail may include an active circulation summary; it never exposes participant
PII. Events and circulation records are read-only.

## Pagination

`page >= 0`, `1 <= size <= 100`. Implementations fetch one additional row to
derive `hasNext` without fabricating a total. Invalid values return `400
VALIDATION_ERROR`.

## Idempotency

Every GET is read-only/idempotent. Wash completion follows the replay and
concurrency contract in `../complete-wash/api.md`.
