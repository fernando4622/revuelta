# F8 Security, Observability and Resilience Specification

**Status:** VERIFIED AND CLOSED FOR F8 on 2026-09-26.

## 1. Purpose

Harden the approved MVP/demo implementation so that authentication, critical
mutations and basic operations can be monitored and recovered without changing
the product workflow or weakening existing domain invariants.

## 2. Scope

This phase includes:

- JWT claim validation and planned signing-key rotation;
- browser-origin restrictions and API security headers;
- transport input limits aligned with existing domain/API contracts;
- structured operational logs and correlation propagation;
- health probes, operational metrics and minimum alert definitions;
- explicit backend/mobile timeouts and safe retry policy;
- restart and database-dependency recovery verification;
- a security review and an operational runbook.

This phase does not introduce new business operations, server-side sessions,
refresh tokens, account provisioning, early token revocation, a cloud platform
or a production identity provider.

## 3. Actors

- authenticated `PARTICIPANT`, `OPERATOR` and `ADMIN` users;
- an operator diagnosing the local/pilot runtime;
- the deployment platform performing liveness/readiness checks;
- an attacker controlling HTTP headers, bodies, JWT values, QR payloads,
  identifiers, timing and request repetition.

## 4. JWT policy

Every issued access token contains and every protected request validates:

- `iss = revuelta-api`;
- `aud = revuelta-mobile`;
- `sub` as a UUID user identifier;
- one recognized `role`;
- non-blank `username`;
- `iat` and `exp`;
- a protected-header `kid` identifying the signing key.

The existing four-hour lifetime remains unchanged. Validation permits at most
30 seconds of clock skew and rejects a missing/unknown key ID, wrong issuer,
wrong audience, invalid signature, malformed claims or expired token as the
same public `401 UNAUTHENTICATED` response.

The server receives a key ring from environment configuration:

```text
active key ID + active signing secret
zero or more previous key IDs + verification-only secrets
```

New tokens use only the active key. Previous keys validate already-issued
tokens during a bounded overlap no longer than the four-hour token lifetime.
Removing a previous key ends that overlap. Secrets are Base64-encoded values of
at least 256 bits and never appear in logs, responses, metrics or committed
production configuration.

This is signing-key rotation, not per-user token revocation. Early revocation
remains outside the approved MVP authentication scope.

## 5. HTTP security policy

- Native Flutter requests do not depend on CORS.
- Browser origins are denied by default.
- The `dev` profile may allow only configured localhost development origins.
- Credentials/cookies are not enabled for cross-origin requests; the API uses
  an explicit bearer token.
- Allowed methods are only those used by the contract: `GET`, `POST`, `OPTIONS`.
- Allowed request headers are `Authorization`, `Content-Type` and
  `X-Correlation-ID`; the client correlation value remains untrusted.
- Responses expose only `X-Correlation-ID` to browsers.
- API responses use `X-Content-Type-Options: nosniff`, frame denial, a
  restrictive referrer policy, `Cache-Control: no-store` for authenticated
  content, and HSTS when served over HTTPS.

Actuator access is separated:

- liveness and readiness are unauthenticated and contain no component details;
- metrics/Prometheus output is restricted to `ADMIN` and must not contain PII,
  tokens, QR payloads or secrets;
- every other actuator endpoint remains unavailable.

## 6. Input and resource limits

Transport validation adds limits without changing identifier meaning:

- username: 1–64 characters;
- password transport value: 1–128 characters;
- QR payload: 1–512 characters;
- container display code: 1–64 characters, with existing normalization and
  uniqueness rules unchanged;
- reason text: 1–500 characters;
- inventory query: at most 64 characters;
- pagination: page `>= 0`, size `1..100`;
- HTTP request headers: at most 16 KiB;
- JSON request body: at most 16 KiB;
- database pool: maximum 10 connections, 3-second acquisition timeout and
  1-second validation timeout for the pilot runtime.

Malformed/oversized field input returns `400 VALIDATION_ERROR`. A body rejected
before JSON parsing returns `413 REQUEST_TOO_LARGE`, using the normal problem
shape and server correlation ID. No submitted secret or payload is echoed.

## 7. Observability contract

The server continues to generate a UUID for every request and returns it as
`X-Correlation-ID`. Critical-operation logs are structured and include:

```text
service, operation, outcome, errorCode, httpStatus, durationMs, correlationId
```

Actor/resource identifiers may be included only when required for support and
must remain opaque. Passwords, authorization headers, JWTs, QR payloads and
personal records are prohibited.

The runtime exposes:

- standard HTTP request count and latency;
- critical mutation count by `operation` and `outcome`;
- mutation failure count by stable `errorCode`;
- successful delivery count;
- successful return count;
- late-return count;
- successful wash count;
- authentication failure count;
- active circulation gauge;
- datasource pool metrics.

Metric labels are bounded enums/codes. Correlation, actor, participant,
container and circulation identifiers are never metric labels.

The repository documents queries/thresholds for:

- readiness unavailable for two consecutive minutes;
- database connectivity/pool acquisition failures;
- five or more server errors in five minutes;
- twenty or more authentication failures in five minutes;
- conflict responses above 25% of at least ten critical mutations in ten
  minutes.

The runbook identifies diagnosis, safe containment, recovery and escalation.
Metrics remain operational observations, never the business source of truth.

## 8. Resilience contract

- backend connection acceptance timeout: 5 seconds;
- database acquisition timeout: 3 seconds;
- Flutter connect timeout: 5 seconds;
- Flutter send timeout: 10 seconds;
- Flutter receive timeout: 10 seconds;
- no automatic retry for login or any mutating request;
- no automatic retry for QR generation/resolution because expiry and scan state
  are user-visible;
- read-only queries may be retried only by explicit user action in V1;
- delivery and return retain query-after-timeout recovery and never blindly
  repeat a mutation;
- wash completion treats an uncertain response as unknown until the pending
  queue/detail is refreshed; it is not automatically resubmitted;
- PostgreSQL unavailability makes readiness fail while liveness stays healthy;
- after database recovery/restart, the same persisted state and invariants are
  available without manual schema changes.

## 9. Permissions

Hardening does not change the approved role matrix. Health probes reveal only
aggregate status. Operational metrics require `ADMIN`. Direct API calls,
replays and altered clients receive the same authorization and domain checks as
the mobile UI.

## 10. Expected errors

- missing/invalid JWT or claims: `401 UNAUTHENTICATED`;
- denied role: `403 FORBIDDEN_OPERATION`;
- malformed/invalid bounded input: `400 VALIDATION_ERROR`;
- oversized JSON body: `413 REQUEST_TOO_LARGE`;
- established replay/domain conflicts: existing stable `409` codes;
- unavailable database/dependency: safe `503` without connection details;
- unexpected failure: safe `500 INTERNAL_SERVER_ERROR` with correlation ID.

## 11. Acceptance scenarios

### SC-F8-001 — Wrong JWT context

Given a correctly signed token with the wrong issuer or audience,
when it calls a protected endpoint,
then the request returns `401 UNAUTHENTICATED` and no mutation occurs.

### SC-F8-002 — Signing-key overlap

Given a token signed by the previous configured key within its lifetime,
when the previous key remains in the verification ring,
then it is accepted,
and when that key is removed,
then the same token is rejected without exposing the key ID or secret.

### SC-F8-003 — Restricted browser origin

Given an origin not present in the configured allowlist,
when it sends a browser preflight request,
then no permissive CORS response is returned.

### SC-F8-004 — Oversized untrusted input

Given a request exceeds an approved field/body limit,
when it reaches the API,
then it is rejected before any domain mutation and the response contains no
submitted secret or QR payload.

### SC-F8-005 — Traceable critical mutation

Given an authorized delivery, return or wash request,
when it succeeds or fails,
then the response, structured log and mutation metric identify the same
operation/outcome without recording either QR payload or bearer token.

### SC-F8-006 — Database outage and recovery

Given the API process remains running while PostgreSQL is unavailable,
when probes are requested,
then liveness remains healthy and readiness fails,
and after PostgreSQL returns,
then readiness recovers and persisted state is still queryable.

### SC-F8-007 — Ambiguous mobile response

Given a delivery or return succeeds but its response is lost,
when the mobile timeout path runs,
then it queries server state and does not resubmit the command automatically.

## 12. Non-goals

- completing F9 field acceptance, backup/restore or release approval;
- adding a distributed tracing platform, message broker or microservice;
- changing domain lifecycle rules;
- production account provisioning/recovery;
- per-user token revocation or refresh tokens;
- treating metrics/logs as audit history;
- installing a cloud alert delivery provider.

## 13. Verification evidence

- backend `mvn verify`: 124 tests, 0 failures/errors/skips;
- Flutter: 36 tests passing; analysis has no errors or warnings, only existing informational lints;
- Redocly 2.53.3: OpenAPI valid;
- Trivy 0.74.0: 0 fixable `HIGH/CRITICAL` vulnerabilities and 0 detected secrets;
- Docker: API and PostgreSQL healthy after rebuild;
- outage drill: PostgreSQL stopped while liveness stayed `200`, readiness returned `503`, readiness recovered to `200`, and the same persisted resource remained queryable;
- debug APK built for the approved local hotspot URL.

Operational and security evidence lives in
`docs/runbooks/f8-operations.md` and `docs/security/f8-security-review.md`.
F9 remains out of scope and is the next phase.
