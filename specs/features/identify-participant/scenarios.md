# Generate and Resolve Participant Operation QR — Acceptance Scenarios

## SC-PID-001 — Generate operation QR

Given an authenticated participant account with an active association,
when a `DELIVERY` or `RETURN` QR is requested,
then one short-lived opaque operation token is created,
without creating a participant or circulation.

## SC-PID-002 — Resolve active code

Given an authorized Cafetería actor and current operation QR,
when the code is scanned,
then one participant reference and eligibility result are returned,
without business mutation.

## SC-PID-003 — Multiple deliveries

Given a participant already has an active circulation,
when a fresh `DELIVERY` QR is resolved,
then it remains eligible unless another explicit rule rejects the participant.

## SC-PID-004 — Invalid code

Given malformed or unsupported participant payload,
when resolution is requested,
then it fails before business mutation.

## SC-PID-005 — Unauthenticated resolution

Given a valid participant operation QR,
when an unauthenticated client resolves it,
then protected participant information is not returned.

## SC-PID-006 — Expired token

Given the server expiration has passed,
when Cafetería resolves the QR,
then `QR_EXPIRED` is returned without participant data or mutation.

## SC-PID-007 — Both QR values required

Given Cafetería resolves a participant operation QR but no container QR,
when it attempts delivery or return,
then the operation remains unavailable.
