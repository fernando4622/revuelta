# ADR-007 — Flutter State Management with Riverpod

**Status:** ACCEPTED

## Context

The mobile application needs role-specific, asynchronous flows for authentication, participant QR generation and the two-step Cafetería scan. Widgets must not own transport parsing or business decisions, and asynchronous states must not be represented by contradictory booleans.

The existing application already uses `flutter_riverpod` for authentication.

## Decision

ReVuelta uses Riverpod 2 as the mobile dependency-injection and state-management mechanism.

- Application controllers are `Notifier`/`AsyncNotifier` classes or providers with explicit immutable state types.
- Widgets render state and invoke controller intentions only.
- Repository interfaces live outside presentation; remote adapters map HTTP JSON into typed domain/application models.
- Multi-step flows use sealed states or an explicit stage enum with validated transitions.
- Provider overrides are the test seam for repositories and external-device adapters.

Riverpod is not a substitute for backend authorization or domain validation. Server responses remain authoritative for eligibility, state and allowed actions.

## Consequences

- New mobile flows follow one testable dependency direction.
- Repeated camera frames can be debounced in a controller instead of a widget callback.
- Existing presentation code may be migrated incrementally when its feature is changed; this ADR does not authorize an unrelated rewrite.

