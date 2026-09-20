# REST API Contract Baseline

**Status:** DRAFT / BLOCKING until exact key strategy, idempotency, production identity binding and remaining feature contracts are approved. Development/MVP login is approved.

## 1. Contract principles

- `API-001`: OpenAPI is the source of truth for HTTP semantics.
- `API-002`: Production endpoints are versioned under `/api/v1`.
- `API-003`: Every endpoint states authentication and authorization.
- `API-004`: Every endpoint documents validation/business failures.
- `API-005`: Every mutation defines idempotency/deduplication.
- `API-006`: Collection endpoints define pagination/filtering.
- `API-007`: Responses expose only actor-necessary data.
- `API-008`: No endpoint generically sets container status.
- `API-009`: Every HTTP response exposes the server-generated `X-Correlation-ID`; problem bodies use the same value as `traceId`.

## 2. Proposed resource space

```text
POST /api/v1/auth/...

POST /api/v1/participants
POST /api/v1/participant-code-resolutions

POST /api/v1/container-code-resolutions
GET  /api/v1/containers/{containerId}
GET  /api/v1/containers/{containerId}/history

POST /api/v1/circulations
GET  /api/v1/circulations/{circulationId}
GET  /api/v1/circulations
POST /api/v1/circulations/{circulationId}/return

POST /api/v1/containers/{containerId}/wash-completions

GET  /api/v1/operations/containers
GET  /api/v1/operations/circulations
GET  /api/v1/operations/events
```

These are semantic contract targets, not permission to implement before their feature/API specs are approved.

## 3. Participant-code resolution

Resolution:

- accepts a type/versioned opaque payload;
- treats input as untrusted;
- requires authorized Cafetería/ReVuelta context;
- returns minimal participant reference and eligibility;
- performs no business mutation;
- never treats possession as staff authorization.

## 4. Delivery

Create circulation consumes references resulting from:

- Participant Code resolution;
- container QR resolution;
- authorized Cafetería actor context.

Success returns:

- circulation identity;
- participant reference;
- container identity/public code;
- `IN_USE` state;
- delivered-at;
- due-at;
- policy reference/version;
- trace/correlation reference.

It must not reject merely because the participant has another active circulation.

## 5. Return

Return is initiated by authorized Cafetería using the container/active circulation.

Success returns:

- circulation identity;
- participant reference;
- returned-at;
- punctuality;
- resulting `RETURNED` state;
- display label “Pendiente de lavado”;
- trace/correlation reference.

It does not make the container available.

## 6. Wash completion

The named operation `POST /containers/{containerId}/wash-completions`:

- requires authorized Cafetería actor;
- accepts no target-state field;
- requires current `RETURNED` state;
- uses server time;
- transitions to `AVAILABLE`;
- appends a wash event;
- defines duplicate/concurrent behavior.

## 7. Student queries

Real “my containers/history” endpoints require an explicit trusted association between the authenticated `PARTICIPANT` account and the participant record. The login mechanism is approved for MVP demonstration, but this resource binding remains unimplemented.

The Participant Code MUST NOT be accepted as an unauthenticated bearer credential for unrestricted history queries.

## 8. Error additions

Feature contracts may use:

```text
PARTICIPANT_CODE_INVALID
PARTICIPANT_NOT_FOUND
PARTICIPANT_INACTIVE
PARTICIPANT_CODE_RECOVERY_NOT_SUPPORTED
CONTAINER_NOT_RETURNED
WASH_ALREADY_COMPLETED
```

All errors follow `specs/api/errors.md`.

## 9. HTTP semantics

```text
400 malformed/invalid request
401 unauthenticated
403 unauthorized
404 resource absent
409 domain/resource conflict
422 semantic validation failure if consistently adopted
429 rate limited if enabled
500 safe unexpected failure
503 unavailable dependency
```

## 10. Contract acceptance

Each endpoint requires examples/tests for:

- success;
- malformed input;
- authentication/authorization failure;
- not found;
- conflict/duplicate;
- concurrency outcome;
- safe unexpected failure.
