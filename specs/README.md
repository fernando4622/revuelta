# ReVuelta Specifications

## Purpose

This directory is the product and engineering specification baseline for the real ReVuelta application. It is the authority for observable product behavior. Architecture decisions belong in `docs/adr/` and repository-wide engineering constraints in `AGENTS.md`.

## Mandatory interpretation

A developer or AI agent MUST NOT implement behavior that is not specified here when that behavior affects business semantics, data integrity, authorization, public API behavior, lifecycle transitions, or operational policy.

When a required decision is absent:

```text
STOP → record ambiguity → resolve in spec/ADR → update traceability → implement
```

## Status model

Every specification uses one of these statuses:

- `DRAFT`: proposed, not implementation-authoritative.
- `APPROVED`: implementation-authoritative.
- `BLOCKED`: intentionally prevents implementation because a material decision is unresolved.
- `IMPLEMENTED`: approved behavior has been implemented and verified.
- `SUPERSEDED`: replaced by a newer approved specification.

The initial package is a **baseline specification set**. Sections labeled `Decision required` are deliberate blockers, not implementation suggestions.

## Specification conventions

### Normative terms

- **MUST** = mandatory.
- **MUST NOT** = prohibited.
- **SHOULD** = recommended unless a documented reason exists.
- **MAY** = optional.

### Requirement IDs

- `FR-*`: functional requirements.
- `BR-*`: business rules.
- `AR-*`: architectural requirements.
- `SEC-*`: security requirements.
- `DR-*`: data requirements.
- `API-*`: API contract requirements.
- `UI-*`: UI behavior requirements.
- `NFR-*`: non-functional requirements.
- `TR-*`: testing requirements.
- `OPS-*`: operational requirements.
- `RISK-*`: risk controls.

## Build order

1. Freeze constitution and product scope.
2. Freeze lifecycle and circulation semantics.
3. Freeze identity/access and data semantics.
4. Freeze API and UI contracts for the first vertical slice.
5. Define acceptance scenarios and risk controls.
6. Implement the smallest vertical slice.
