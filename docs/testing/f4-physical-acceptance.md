# F4 Physical QR Acceptance

**Status:** ACCEPTED  
**Date:** 2026-09-23  
**Build:** `1d291fd`  
**Device:** Samsung SM-S936B, Android 16 / API 36  
**Transport:** USB debugging with `adb reverse tcp:8080 tcp:8080`  
**Backend:** Docker Compose development profile, PostgreSQL healthy, API health `UP`

## Accepted journey

1. Cafetería authenticated with the development `OPERATOR` account.
2. The device camera resolved a current server-issued participant QR with purpose `DELIVERY`.
3. The same device then resolved the signed static QR for active container `RV-PHYSICAL-1790218232`.
4. The application displayed `Disponible`, confirmed that both QR values were valid and identified delivery as the next allowed operation.
5. Resolution did not mutate the container or create a circulation.

## Permission-denial evidence

1. Camera permission was revoked and its initial Android permission state was reset.
2. The user selected `No permitir` in the Android permission dialog.
3. ReVuelta displayed a camera-permission explanation and `Reintentar cámara`.
4. No manual text-entry bypass appeared.
5. Camera permission was restored after the test.

## Scope boundary

This evidence closes the F4 read-only identification gate. Atomic consumption of the participant token and delivery mutation remain governed by F5; return mutation remains governed by F6.
