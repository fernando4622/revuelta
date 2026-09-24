# Error Taxonomy and Error Contract

**Status:** APPROVED BASELINE; exact public catalog is extended per feature.

## 1. Failure categories

```text
ValidationFailure
AuthenticationFailure
AuthorizationFailure
NotFoundFailure
ConflictFailure
BusinessRuleFailure
InfrastructureFailure
UnexpectedFailure
```

## 2. Machine-readable code rules

Expected failures MUST use stable codes. Codes are API contract, not UI copy.

Baseline examples:

```text
CONTAINER_NOT_FOUND
CONTAINER_NOT_AVAILABLE
CONTAINER_CODE_ALREADY_EXISTS
INVALID_STATE_TRANSITION
ACTIVE_CIRCULATION_EXISTS
CIRCULATION_NOT_FOUND
CIRCULATION_PARTICIPANT_MISMATCH
RETURN_ALREADY_REGISTERED
FORBIDDEN_OPERATION
VALIDATION_ERROR
INVALID_CREDENTIALS
UNAUTHENTICATED
INVALID_QR
UNSUPPORTED_QR_VERSION
QR_TAMPERED
QR_EXPIRED
QR_ALREADY_USED
QR_PURPOSE_MISMATCH
CONTAINER_QR_REVOKED
INACTIVE_CONTAINER
POLICY_NOT_FOUND
PARTICIPANT_CODE_INVALID
PARTICIPANT_NOT_FOUND
PARTICIPANT_ACCOUNT_NOT_LINKED
PARTICIPANT_INACTIVE
PARTICIPANT_CODE_RECOVERY_NOT_SUPPORTED
CONTAINER_NOT_RETURNED
WASH_ALREADY_COMPLETED
```

A feature may add a code only when its spec explains the exact condition.

`CONTAINER_CODE_ALREADY_EXISTS` is returned when container registration receives a
normalized code that is already owned by another container. It is a conflict and
MUST map to HTTP `409`, including when the database uniqueness constraint wins a
registration race.

`CIRCULATION_PARTICIPANT_MISMATCH` is returned when both QR values are valid but
the active circulation for the scanned container belongs to a different
participant. It MUST map to HTTP `409` without exposing that other participant.

## 3. Ownership

```text
transport syntax        → interface adapter
business semantics      → domain/application
relational constraints  → database/persistence adapter
UI wording              → presentation
```

## 4. Mapping rules

- Expected domain failures MUST NOT become generic HTTP 500.
- Unexpected exceptions MUST be logged internally with correlation data and mapped to a safe generic 500.
- `traceId` MUST equal the server-generated `X-Correlation-ID` response header.
- SQL statements, stack traces, secrets, token values, internal class/package names, or connection details MUST NOT reach clients.

## 5. Client mapping

Flutter translates stable machine-readable failures into presentation states/messages. Widgets MUST NOT parse raw backend JSON to invent semantics.
