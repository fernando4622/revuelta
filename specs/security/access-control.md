# Identity and Access Control Specification

**Status:** BLOCKED FOR FINAL APPROVAL until the exact role matrix is approved.

## 1. Security principles

- `SEC-001`: Every protected mutation is authenticated.
- `SEC-002`: Every sensitive operation is authorized server-side.
- `SEC-003`: UI visibility is never authorization.
- `SEC-004`: Default authorization posture is deny-by-default.
- `SEC-005`: QR data never grants authorization.
- `SEC-006`: Tokens/secrets/passwords MUST NOT be logged.
- `SEC-007`: Security failures MUST be safe to expose and diagnostically useful through correlation identifiers.

## 2. Authentication

The exact authentication mechanism is an ADR decision. The product only requires that protected actors have a verifiable authenticated identity and that the backend can determine session/token validity.

**Decision required:** selected authentication mechanism, token/session lifecycle, refresh/revocation semantics, and credential provisioning.

## 3. Authorization model

Authorization is evaluated against:

```text
actor identity
+ actor role(s)
+ requested operation
+ target resource
+ current resource/domain state
+ relevant context
```

Having a role is not sufficient if the domain state makes the operation invalid.

## 4. Permission categories

The final matrix MUST include at least:

- read container;
- scan/resolve container;
- create circulation;
- register return;
- inspect circulation/history;
- create/update/deactivate container;
- manage users/roles;
- manage return policy;
- perform exceptional lifecycle transitions;
- view audit records.

Exact role → permission mapping is `Decision required`.

## 5. Resource authorization

The backend MUST check authorization independently of mobile UI state. An attacker who directly calls the REST API must receive the same authorization decision as a legitimate UI flow.

## 6. Least privilege

A role SHOULD receive only the permissions necessary for its operational responsibility.

## 7. QR threat model

A QR payload is untrusted input and can be:

- malformed;
- forged;
- stale;
- copied;
- replayed as part of a request;
- associated with an inactive container.

Scanning MUST resolve identity, then pass through the normal authorization and business-rule pipeline.

## 8. Data exposure

API responses MUST expose only fields necessary for the current actor and use case. Personal information must not be included merely because it exists in the database.

## 9. Security acceptance scenarios

### SC-SEC-001 API bypass
Given an authenticated actor lacking permission, when they call a protected mutation directly, then the API rejects the request regardless of client UI behavior.

### SC-SEC-002 QR does not authorize
Given a valid QR for a container, when an unauthorized actor scans it, then scanning may identify the container if permitted but cannot grant mutation permission.

### SC-SEC-003 Invalid token
Given an invalid/expired session, when a protected operation is attempted, then the API rejects it without performing a business mutation.
