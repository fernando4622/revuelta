# Return Container — Acceptance Scenarios

## SC-RET-001 — On-time return
Given an active circulation whose due-at is equal to or after the authoritative return time,
when the operator confirms return,
then the circulation is finalized,
and punctuality is `ON_TIME`,
and the container reaches the approved post-return state,
and one trace event exists.

## SC-RET-002 — Late return
Given an active circulation whose due-at is before the authoritative return time,
when the operator confirms return,
then the circulation is finalized,
and punctuality is `LATE`.

## SC-RET-003 — No active circulation
Given no active circulation for a container,
when return is requested,
then the operation fails,
and no fabricated circulation or state mutation is created.

## SC-RET-004 — Duplicate return
Given a finalized circulation,
when the same return command is repeated,
then it does not create a second return event that changes business truth.

## SC-RET-005 — Concurrent return
Given one active circulation,
when two operators attempt return concurrently,
then only one successful business finalization occurs and the data remains consistent.
