# Participant Code — UI Contract

**Status:** APPROVED FOR ISSUE AND CAFETERIA RESOLUTION; recovery UI is blocked.

## Cafetería delivery step

```text
ReadyToScanParticipant
→ ResolvingParticipant
→ ParticipantEligible
→ ReadyToScanContainer
```

Failures:

```text
InvalidCode
ParticipantNotFound
ParticipantInactive
Forbidden
NetworkFailure
UnexpectedFailure
```

The result shows an opaque participant reference and operational eligibility, not unnecessary personal information.

## ReVuelta issuance

Operación ReVuelta may:

- create the participant/code;
- display the QR for printing or delivery;
- confirm issuance;
- inspect issuance history.

It may not replace a lost code until D-018 is approved.

## Acceptance

- participant and container scans are visually distinguishable;
- a successful participant scan advances to container scan;
- repeated frames do not issue duplicate resolutions;
- no delivery is submitted during code resolution;
- QR/code is never presented as staff authentication.
