# REST API Contract Baseline

**Status:** DRAFT / BLOCKING until exact auth model and borrower identity are approved.

## 1. Contract principles

- `API-001`: OpenAPI is the source of truth for HTTP request/response semantics.
- `API-002`: All production endpoints are versioned.
- `API-003`: Every endpoint documents authentication requirements.
- `API-004`: Every endpoint documents authorization requirements.
- `API-005`: Every endpoint documents validation and business failures.
- `API-006`: Every mutating endpoint defines idempotency/deduplication expectations.

## 2. Proposed versioned resource space

The initial contract may be organized under `/api/v1`.

Candidate resources:

```text
POST   /api/v1/auth/...
GET    /api/v1/containers/{containerId}
GET    /api/v1/containers/{containerId}/history
POST   /api/v1/circulations
GET    /api/v1/circulations/{circulationId}
POST   /api/v1/circulations/{circulationId}/return
GET    /api/v1/operations/...
```

These are contract placeholders, not permission to implement endpoints before feature specs exist.

## 3. QR resolution

Preferred semantic operation:

```text
scan payload
→ validate payload shape
→ resolve container identity
→ authorize subsequent operation
```

Do not expose a generic “change state” endpoint.

## 4. Error contract

Every error response SHOULD conform to a stable problem representation:

```json
{
  "type": "https://revuelta.app/problems/container-not-available",
  "title": "Container is not available",
  "status": 409,
  "code": "CONTAINER_NOT_AVAILABLE",
  "detail": "The container cannot be assigned in its current state.",
  "instance": "/api/v1/circulations",
  "traceId": "...",
  "errors": []
}
```

The final public schema belongs in OpenAPI and the error specification.

## 5. HTTP semantic baseline

```text
400 malformed/invalid request
401 unauthenticated
403 authenticated but unauthorized
404 resource absent
409 domain/resource conflict
422 semantic validation failure (only if used consistently)
429 rate limited (if enabled)
500 unexpected server failure
503 unavailable dependency/service
```

## 6. Mutation semantics

### Create circulation
Must guarantee no duplicate active circulation.

### Return circulation
Must guarantee no double finalization.

The exact idempotency key format and persistence strategy are `Decision required` at API/architecture level.

## 7. Pagination/filtering

Any collection endpoint MUST define pagination semantics before implementation. No arbitrary unbounded production list endpoint.

## 8. API acceptance

A contract is accepted only when examples exist for:

- success;
- malformed input;
- authentication failure;
- authorization failure;
- not found;
- business conflict;
- unexpected failure (safe generic response).
