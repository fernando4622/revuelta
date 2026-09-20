# Scan and Resolve Container — UI Contract

**Status:** DRAFT. Governed by `specs/ui/state-machines.md` and the applicable perspective spec.

## Actors

- Alumno: scans a container to view return information associated with their own circulation.
- Cafetería: scans Participant Code during delivery and container QR during delivery/return/washing.
- Operación ReVuelta: scans/searches for support and inventory inspection.

Rendering a role-specific shell does not authorize the actor; the server validates the signed session and resource permission.

## Shared flow

```text
Open scanner
→ request camera permission
→ scan one payload
→ pause/debounce camera
→ resolve payload
→ render container or typed failure
```

Resolution performs no business mutation.

## Required states

```text
Idle
PermissionRequired
PermissionDenied
Ready
Scanning
Resolving
Resolved
Failed
```

## Perspective results

| Perspective | Successful destination |
|---|---|
| Alumno | STU-03 container/return information, with ownership/privacy checks |
| Cafetería participant scan | Participant eligibility, then container scan |
| Cafetería container scan | CAF-02 operational identification result |
| Operación ReVuelta | OPS-04 container detail |

## Failures

- malformed QR;
- unsupported QR version;
- unknown container;
- inactive container;
- forbidden/not-associated resource;
- network failure;
- unexpected failure.

## Acceptance

### SC-SCAN-UI-001 — Repeated camera frame

Given a payload is resolving,
when the camera reads the same frame again,
then no second resolution command is issued.

### SC-SCAN-UI-002 — Perspective result

Given a container resolves successfully,
when the result is rendered,
then the destination and visible data match the authenticated role,
without changing server state.

### SC-SCAN-UI-003 — Permission denied

Given camera permission is denied,
when the scanner opens,
then a clear explanation and safe recovery action are shown,
and manual entry appears only if approved.
