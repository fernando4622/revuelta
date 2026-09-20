# Complete Container Washing — Acceptance Scenarios

## SC-WASH-001 — Successful wash completion

Given an authorized Cafetería actor and a `RETURNED` container,
when washing is confirmed,
then the container becomes `AVAILABLE`,
washed-at uses server time,
and one wash event exists.

## SC-WASH-002 — In-use container

Given a container is `IN_USE`,
when wash completion is attempted,
then the operation fails without mutation.

## SC-WASH-003 — Duplicate completion

Given a wash completion succeeded,
when the command is repeated,
then no second state transition or wash event is created.

## SC-WASH-004 — Concurrent completion

Given one returned container,
when two Cafetería clients confirm washing concurrently,
then at most one effective transition succeeds.

## SC-WASH-005 — Completed circulation unchanged

Given a returned container has a completed circulation,
when washing completes,
then the circulation's participant, return time and punctuality remain unchanged.
