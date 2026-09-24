# F6 Integrated Return Acceptance

**Status:** ACCEPTED  
**Date:** 2026-09-24  
**Backend:** Docker Compose development profile, PostgreSQL healthy, API health `UP`  
**Mobile:** debug APK installed on Samsung SM-S936B; ADB reverse active

## Accepted journey

1. An authenticated participant obtained a fresh server-issued QR with purpose `DELIVERY`.
2. An authorized Cafetería actor used that QR plus the signed static container QR to create the active circulation.
3. The same participant obtained a fresh QR with purpose `RETURN`.
4. Return preview revalidated both complete payloads and returned the same circulation and participant references, delivery time and historical due-at without mutation.
5. Return confirmation revalidated both payloads inside the transaction and returned `RETURNED`, “Pendiente de lavado”, server return time and punctuality.
6. The persisted container remained unavailable for a new delivery until the separate wash operation.

The integrated acceptance container was `F6-E2E-1790245884`.

## Persistence evidence

```text
preview circulation matches delivery | true
preview participant matches receipt   | true
receipt state                         | RETURNED
state label                           | Pendiente de lavado
punctuality                           | ON_TIME
persisted state                       | RETURNED
return events                         | 1
total lifecycle events                | 4
```

## Automated gate evidence

- Unit tests cover on-time and late return, preserved historical due-at, preview without mutation, purpose mismatch, participant mismatch, already-returned state and consumed-token replay.
- PostgreSQL integration runs two return transactions against one active circulation and proves one winner, one typed conflict, one completion, one event and one consumed token.
- A forced event-persistence exception proves rollback of circulation, container, event and participant-token consumption.
- HTTP security tests prove only `OPERATOR` may call return preview and confirmation.
- Contract tests prove the controller routes and response fields match OpenAPI.
- Flutter tests prove preview-before-confirm, both complete payloads, duplicate-submit suppression, payload clearing after success and timeout recovery without resubmission.
- The complete backend suite reports 98 tests with 0 failures/errors; the Flutter suite reports 24 tests passing.
- Redocly validates OpenAPI without warnings and the Android debug APK builds successfully.

## Security review

- Both QR values are untrusted input and their signatures, versions, purpose, expiry and container generation are validated server-side.
- A participant QR identifies the participant but never grants Cafetería authorization.
- The active circulation must belong to the resolved participant; mismatch returns a stable conflict without exposing another participant.
- Server time owns `returnedAt` and punctuality; no client business timestamp is accepted.
- The token row lock and optimistic circulation/container versions prevent duplicate completion and events under races.
- The token is consumed only if the entire return transaction commits.

## Scope boundary

This evidence closes F6 return only. Wash completion queues, broader history and the F7 cleanup/experience work were not implemented in this phase. The APK is ready for the user to repeat the camera journey manually on the connected Samsung.
