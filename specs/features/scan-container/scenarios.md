# Dual QR — Acceptance Scenarios

**Status:** APPROVED FOR F4 MVP.

## SC-QR-001 — Resolve static container QR

Given a signed current-generation QR for a known container,
when authorized Cafetería resolves it,
then the server returns real container state and allowed actions,
without mutation.

## SC-QR-002 — Reject altered QR

Given any signed field was changed,
when resolution is attempted,
then `QR_TAMPERED` is returned and no lookup result or mutation occurs.

## SC-QR-003 — Rotate one container QR

Given an authorized ReVuelta actor and a non-empty reason,
when the container QR is rotated,
then generation increases once, a trace event is appended and the previous label returns `CONTAINER_QR_REVOKED`.

## SC-QR-004 — Generate dynamic participant QR

Given an authenticated participant account with an active association,
when it requests a `DELIVERY` or `RETURN` QR,
then the server emits a signed token expiring after the configured lifetime,
without PII or circulation mutation.

## SC-QR-005 — Reject expired or consumed token

Given participant operation QR is expired or consumed,
when Cafetería resolves it,
then the typed conflict is returned without exposing participant data.

## SC-QR-006 — Repeated camera frame

Given the camera already sent one payload for resolution,
when the same frame is observed while resolving,
then no second request is issued.

## SC-QR-007 — Camera denied

Given camera permission is denied,
when Cafetería opens scanning,
then the UI explains how to retry or open settings,
without showing manual entry.

## SC-QR-008 — QR is not authorization

Given an unauthenticated or unauthorized actor possesses both QR payloads,
when it calls a protected endpoint,
then the server rejects it before business mutation.

## SC-QR-009 — Both QR values mandatory

Given Cafetería has only one of the two required QR values,
when delivery or return is attempted,
then confirmation remains unavailable and no mutation is submitted.
