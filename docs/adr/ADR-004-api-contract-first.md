# ADR-004 — Contract-First REST API

**Status:** ACCEPTED BASELINE

## Context

Flutter and backend are separate deployable components and must remain compatible.

## Decision

OpenAPI is the versioned source of truth for REST request/response behavior. Contracts are approved before implementing externally observable endpoints.

## Consequences

- client/server mismatch is detected early;
- API behavior is reviewable;
- error semantics are explicit;
- contract tests become possible.

## Rejected behavior

Undocumented production endpoints or client-specific ad-hoc payloads are not allowed.
