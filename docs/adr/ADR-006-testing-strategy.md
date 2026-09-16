# ADR-006 — Risk-Weighted Test Pyramid

**Status:** ACCEPTED BASELINE

## Decision

ReVuelta uses unit tests for deterministic domain behavior, integration tests for persistence/security/transaction behavior, contract tests for API compatibility, BDD scenarios for critical business journeys, and a small E2E suite for critical operational flows.

Coverage percentages are secondary to proving invariants and high-risk behaviors.
