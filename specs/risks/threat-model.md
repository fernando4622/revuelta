# ReVuelta Threat and Risk Model

**Status:** APPROVED BASELINE; mitigations become mandatory per feature.

## RISK-001 QR forgery
**Threat:** attacker fabricates or modifies a QR value.

**Impact:** wrong resource identification or attempted mutation.

**Mitigations:** untrusted-input validation, resource lookup, server authorization, explicit state checks, no authorization by QR possession.

## RISK-002 Duplicate mutation
**Threat:** double tap, retry after timeout, repeated scan.

**Impact:** duplicate delivery/return.

**Mitigations:** idempotency/deduplication strategy, unique database invariant, deterministic retry behavior.

## RISK-003 Concurrent mutation
**Threat:** two devices mutate the same container simultaneously.

**Impact:** two active circulations or invalid state transition.

**Mitigations:** transaction boundary plus explicit concurrency control and integration tests.

## RISK-004 Unauthorized API call
**Threat:** attacker bypasses UI and directly calls REST endpoints.

**Impact:** illicit circulation/lifecycle changes.

**Mitigations:** server-side authorization on every sensitive use case.

## RISK-005 Identifier enumeration
**Threat:** attacker guesses sequential identifiers.

**Impact:** unauthorized discovery of resources.

**Mitigations:** identifier strategy, authorization on resource reads, non-sensitive public identifiers where appropriate.

## RISK-006 PII exposure
**Threat:** API/logs expose unnecessary borrower/operator information.

**Impact:** privacy breach.

**Mitigations:** data minimization, field-level response design, safe logging.

## RISK-007 Token compromise
**Threat:** credential/session token is leaked.

**Impact:** account misuse.

**Mitigations:** secure storage, expiration/revocation strategy, no logging, transport security, least privilege.

## RISK-008 History manipulation
**Threat:** actor edits/deletes evidence of past operations.

**Impact:** loss of accountability.

**Mitigations:** append-oriented audit model, restricted write path, database policy preventing destructive normal operations.

## RISK-009 Client clock manipulation
**Threat:** device changes local time.

**Impact:** incorrect due/return classification.

**Mitigation:** server-authoritative timestamps.

## RISK-010 Network failure ambiguity
**Threat:** mutation succeeds server-side but response is lost.

**Impact:** client retries mutation.

**Mitigations:** idempotency/deduplication, query-after-timeout strategy where useful, deterministic command state.

## RISK-011 Token context and key rollover
**Threat:** a correctly signed token is accepted by the wrong service/context, or key replacement invalidates every in-flight session without a controlled overlap.

**Mitigations:** mandatory issuer/audience/subject/role/time claims, protected `kid`, active signing key plus bounded verification-only previous keys, uniform public authentication failure.

## RISK-012 Resource exhaustion by untrusted input
**Threat:** oversized headers, JSON bodies, fields or database connection demand consume pilot resources.

**Mitigations:** explicit 16 KiB header/body limits, bounded field/query/pagination validation, ten-connection pool, short acquisition/validation timeouts and safe `400/413/503` responses.

## RISK-013 Dependency outage without diagnosis
**Threat:** PostgreSQL becomes unavailable while the API process still responds, causing ambiguous failures or unsafe retries.

**Mitigations:** readiness includes database while liveness does not, dependency failures map to safe `503`, mutations are not automatically retried, structured correlation/metrics and the F8 recovery runbook guide containment.

## F8 review status

Controls for RISK-001 through RISK-013 within the approved MVP/demo scope were
reviewed on 2026-09-26. No P0/P1 finding remains open in that scope. Residual
production identity, TLS, backup/restore, rollback and field-validation risks
remain explicitly gated by F9 and the decision register; see
`docs/security/f8-security-review.md`.
