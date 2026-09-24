# Deliver Container — Acceptance Scenarios

## SC-DEL-001 — Successful delivery

Given an authorized Cafetería actor,
an active participant resolved from a current `DELIVERY` operation QR,
an available container resolved from its QR,
and an effective return policy,
when the actor confirms delivery,
then exactly one active circulation is created,
the container becomes `IN_USE`,
due-at and policy provenance are recorded,
and one delivery event exists.

The command contains both signed QR payloads and does not accept resolved IDs as
a substitute for either scan.

## SC-DEL-002 — Additional container for participant

Given the participant already has one active circulation,
and a different container is available,
when Cafetería confirms delivery of the different container,
then a second active circulation is created for the participant.

## SC-DEL-003 — Unknown participant operation QR

Given a syntactically valid but unknown participant operation QR,
when delivery is attempted,
then no circulation or state mutation occurs.

## SC-DEL-004 — Unknown container

Given a valid participant and unknown container QR,
when delivery is attempted,
then no circulation or state mutation occurs.

## SC-DEL-005 — Ineligible container

Given a container is not `AVAILABLE`,
when delivery is requested,
then it fails with a business conflict,
and state is unchanged.

## SC-DEL-006 — Duplicate submission

Given a successful delivery command,
when the same logical command is retried,
then no second circulation or delivery event is created.

## SC-DEL-007 — Concurrent delivery

Given one available container,
when two authorized clients submit delivery concurrently,
then at most one becomes effective.

## SC-DEL-008 — Unauthorized actor

Given valid participant and container codes,
when an unauthorized client requests delivery,
then the request is rejected without mutation.

## SC-DEL-009 — Missing or substituted QR proof

Given an actor knows a participant or container identifier,
when delivery is requested without both signed QR payloads,
then validation rejects the command without mutation.

## SC-DEL-010 — Wrong QR purpose

Given a current participant operation QR with purpose `RETURN`,
when it is used for delivery,
then delivery fails with `QR_PURPOSE_MISMATCH`,
and the token remains unconsumed.

## SC-DEL-011 — Transaction rollback

Given both QR values and eligibility are valid,
when circulation, container, event or token persistence fails,
then none of the four mutations remains committed.
