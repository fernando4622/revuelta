# Return Container — Acceptance Scenarios

## SC-RET-001 — On-time physical return

Given an active circulation whose due-at is equal to or after server return time,
when authorized Cafetería confirms physical receipt,
then the circulation is finalized as `ON_TIME`,
the participant no longer holds the container,
the container becomes `RETURNED`,
and one return event exists.

## SC-RET-002 — Late physical return

Given an active circulation whose due-at is before server return time,
when authorized Cafetería confirms physical receipt,
then the circulation is finalized as `LATE`,
and the container becomes `RETURNED`.

## SC-RET-003 — No active circulation

Given no active circulation exists for the scanned container,
when return is requested,
then it fails without fabricating a circulation or state change.

## SC-RET-004 — Student cannot finalize

Given the Alumno perspective has resolved return instructions,
when it attempts to finalize return,
then the protected operation is unavailable or rejected,
and no state changes.

## SC-RET-005 — Duplicate return

Given a circulation is finalized,
when the same return command is repeated,
then no second return event or mutation is created.

## SC-RET-006 — Concurrent return

Given one active circulation,
when two Cafetería clients return it concurrently,
then only one finalization succeeds and data remains consistent.

## SC-RET-007 — Returned is not available

Given physical return was registered,
when a new delivery is attempted before washing completes,
then delivery is rejected because the container remains `RETURNED`.
