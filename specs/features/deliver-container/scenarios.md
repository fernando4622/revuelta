# Deliver Container — Acceptance Scenarios

## SC-DEL-001 — Successful delivery
Given an authorized operator, valid recipient, eligible container, and effective policy,
when the operator confirms delivery,
then exactly one circulation is created,
and the container transitions to the approved delivery state,
and the due-at value is recorded,
and one trace event is recorded.

## SC-DEL-002 — Unknown container
Given a syntactically valid but unknown QR,
when delivery is requested,
then no circulation is created,
and no container state changes.

## SC-DEL-003 — Ineligible state
Given an existing container in a non-eligible state,
when delivery is requested,
then the operation fails with a business conflict,
and state is unchanged.

## SC-DEL-004 — Duplicate submission
Given a successful delivery request,
when the same logical command is retried,
then the system does not create a second active circulation.

## SC-DEL-005 — Race condition
Given one eligible container,
when two authorized clients submit delivery concurrently,
then at most one delivery becomes effective.

## SC-DEL-006 — Unauthorized actor
Given a valid container and recipient,
when an actor without the required permission calls the endpoint,
then the system rejects the request without mutation.
