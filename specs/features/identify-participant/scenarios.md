# Issue and Resolve Participant Code — Acceptance Scenarios

## SC-PID-001 — Issue new code

Given an authorized ReVuelta actor,
when a Participant Code is issued,
then one participant and one active opaque code are created,
and an issuance event exists.

## SC-PID-002 — Resolve active code

Given an authorized Cafetería actor and active Participant Code,
when the code is scanned,
then one participant reference and eligibility result are returned,
without business mutation.

## SC-PID-003 — Multiple deliveries

Given a participant code was used for an earlier active circulation,
when it is resolved for another delivery,
then it remains eligible unless another explicit rule rejects the participant.

## SC-PID-004 — Invalid code

Given malformed or unsupported participant payload,
when resolution is requested,
then it fails before business mutation.

## SC-PID-005 — Unauthenticated resolution

Given a valid participant code,
when an unauthenticated client resolves it,
then protected participant information is not returned.

## SC-PID-006 — Recovery unavailable

Given a participant reports a lost code,
when replacement is requested before D-018 is approved,
then normal UI reports recovery is not supported and performs no reassociation.
