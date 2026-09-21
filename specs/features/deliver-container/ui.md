# Deliver Container — UI Contract

**Status:** PRODUCT UI FLOW APPROVED. Authentication and core technical decisions are resolved; participant/QR resolution, final API integration and state-layer implementation remain gated.

## Primary perspective

Cafetería.

Operación ReVuelta and Alumno do not receive the normal delivery action.

## Entry

CAF-02 after QR resolution reports that delivery is allowed.

## Flow

```text
Scan/resolve Participant Code
→ scan/resolve eligible container
→ review container + recipient + policy summary
→ confirm once
→ submit
→ show server-confirmed result or uncertain result
```

## Required content

- public container code;
- current eligibility;
- opaque participant reference and eligibility;
- due-at/policy summary supplied by server;
- explicit confirm and cancel;
- success timestamp/result;
- error/conflict explanation.

## Rules

- UI does not calculate due-at.
- UI does not expose a generic state change.
- Confirm is disabled while submitting.
- Timeout is not displayed as success.
- A conflict triggers a refresh of current container state.
- No direct HTTP/JSON handling occurs in the widget.
- An existing active circulation for another container does not disable delivery.

## Acceptance

- Maps to SC-CAF-001, SC-CAF-003, SC-CAF-004 and SC-CAF-005.
- Domain/API evidence remains SC-DEL-001..008.
