# Participant Operation QR — UI Contract

**Status:** APPROVED FOR PARTICIPANT GENERATION AND CAFETERIA RESOLUTION.

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

## Participant generation

Alumno/maestro chooses delivery or return, requests a fresh QR and sees its server expiration. The page never invents a local token and clearly instructs the user to let Cafetería scan it.

## Acceptance

- participant and container scans are visually distinguishable;
- a successful participant scan advances to container scan;
- repeated frames do not issue duplicate resolutions;
- no delivery is submitted during code resolution;
- QR/code is never presented as staff authentication.
