# Deliver Container — UI Contract

**Status:** APPROVED FOR F5 IMPLEMENTATION.

## Primary perspective

Cafetería.

Operación ReVuelta and Alumno do not receive the normal delivery action.

## Entry

CAF-02 after QR resolution reports that delivery is allowed.

## Flow

```text
Scan/resolve dynamic `DELIVERY` participant QR
→ scan/resolve eligible container
→ request read-only delivery preview
→ review container + recipient + policy summary and estimated due-at
→ confirm once
→ submit
→ show server-confirmed result or uncertain result
```

## Required content

- public container code;
- current eligibility;
- opaque participant reference and eligibility;
- estimated due-at and policy summary supplied by the preview endpoint;
- explicit confirm and cancel;
- success timestamp/result;
- error/conflict explanation.

## Rules

- UI does not calculate due-at.
- Preview does not reserve the container or consume the participant QR.
- The exact due-at shown after success comes only from the delivery response.
- UI does not expose a generic state change.
- Confirm is disabled while submitting.
- Timeout is not displayed as success.
- A conflict triggers a refresh of current container state.
- The controller retains both scanned payloads in memory only until reset,
  cancellation or completion; widgets never render or log them.
- No direct HTTP/JSON handling occurs in the widget.
- An existing active circulation for another container does not disable delivery.

## Acceptance

- Maps to SC-CAF-001, SC-CAF-003, SC-CAF-004 and SC-CAF-005.
- Domain/API evidence remains SC-DEL-001..008.
