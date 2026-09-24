# F5 Physical Delivery Acceptance

**Status:** ACCEPTED  
**Date:** 2026-09-23  
**Build:** `5709e5e`  
**Device:** Samsung SM-S936B, Android 16 / API 36  
**Transport:** USB debugging with `adb reverse tcp:8080 tcp:8080`  
**Backend:** Docker Compose development profile, PostgreSQL healthy, API health `UP`

## Accepted journey

1. Cafetería authenticated with the development `OPERATOR` account.
2. The device camera resolved a fresh server-issued participant QR with purpose `DELIVERY`.
3. The same device resolved the signed static QR for available container `F5-PHYSICAL-1790221102`.
4. Before mutation, the app displayed the participant reference, container state `Disponible`, active policy `Default Pilot 48h Policy` version 1 and a server-supplied estimated due-at.
5. The explicit `Confirmar entrega` action produced a server-confirmed result with delivery time, authoritative due-at, policy version and circulation reference.
6. The final screen displayed `Entrega confirmada`; no manual identifier entry or single-QR bypass was available.

## Persistence evidence

The acceptance container was queried directly after confirmation. The result was:

```text
container state | active circulations | linked delivery events | consumed operation tokens
IN_USE          | 1                   | 1                      | 1
```

The delivery event contains the same circulation and participant references as the active circulation.

## Automated gate evidence

- PostgreSQL integration runs two delivery transactions against one container and proves one winner plus one typed conflict.
- A forced event-persistence exception proves rollback of container state, circulation, event and QR-token consumption.
- Repository and controller tests prove that the mutation receives both complete signed QR payloads, not internal identifiers.
- Flutter tests prove preview-before-confirm, one submit, clearing ephemeral payloads after success and recovery after a network timeout by reading current state without resubmitting.
- The complete backend test inventory reports 93 tests with 0 failures/errors; the Flutter suite reports 21 tests passing.
- Redocly validates the OpenAPI contract and the Android debug APK builds successfully.

## Security review

- The server treats both scanned payloads as untrusted and validates signature, version, purpose, expiration and current container QR generation inside the operation.
- `OPERATOR` authorization is enforced server-side for preview and delivery.
- The participant token row is locked and consumed only in the successful transaction; replay returns a stable conflict.
- Container availability is protected by aggregate versioning and the partial unique active-circulation index.
- QR payloads contain no PII and are neither rendered as text nor logged by the app.
- Server time and the captured policy version own `deliveredAt` and `dueAt`.

## Observed negative behavior

- An expired dynamic QR was rejected before delivery.
- Loss of the local USB reverse tunnel produced the explicit network failure state rather than a false success. Restoring the tunnel and repeating with a fresh QR completed normally.

## Scope boundary

This evidence closes F5 delivery only. Return mutation and participant matching for return remain governed by F6 and were not implemented in this phase.
