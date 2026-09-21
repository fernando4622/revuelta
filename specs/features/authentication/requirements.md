# Feature Spec — Authentication

**Status:** APPROVED FOR DEVELOPMENT/MVP DEMONSTRATION. Production institutional provisioning, recovery and token revocation require a separate security approval before the real pilot.

## 1. Purpose

Establish a trusted authenticated session and route each user to the UI experience allowed by their server-issued role.

There is no unrestricted perspective selector. A client cannot choose or override its role.

## 2. Scope

This MVP slice includes:

- username/password login against provisioned accounts;
- BCrypt password verification;
- a signed JWT access token with four-hour expiration;
- one server-issued role per MVP account;
- client-side logout by deleting the local token;
- role-based routing after authentication;
- development-only seed accounts.

## 3. Actors and roles

| Technical role | Product experience | Development user |
|---|---|---|
| `PARTICIPANT` | Alumno / maestro participante | `student1` |
| `OPERATOR` | Personal de Cafetería | `operator` |
| `ADMIN` | Operación ReVuelta | `admin` |

Alumno and maestro share `PARTICIPANT` because V1 assigns them the same permissions. The role does not prove an institutional classification and MUST NOT be encoded in a participant operation QR.

All development seed users use `password123`. These credentials MUST NOT be enabled in a production environment.

## 4. Preconditions and inputs

- the provisioned account exists and has exactly one recognized role;
- the client submits a non-empty username and password over an approved secure transport;
- the server owns password verification and role resolution.

The login input is:

```text
username
password
```

## 5. Outputs and state changes

A successful login returns:

```text
access token
token type
user ID
username
role
```

The token contains the authenticated user ID, username, role, issued-at and expiration claims and is signed by the server.

Login does not mutate domain state. Logout removes the local credential; V1 does not maintain a server-side session or refresh token.

## 6. Permissions

- `PARTICIPANT` may enter only the Alumno/participante experience and access only resources explicitly authorized as their own.
- `OPERATOR` may enter only the Cafetería experience and perform approved handoff operations.
- `ADMIN` may enter only the Operación ReVuelta experience and perform approved administrative operations.
- A valid session does not bypass resource authorization or domain-state validation.
- Missing, unknown or multiple ambiguous roles fail closed; they MUST NOT default to `OPERATOR` or `ADMIN`.

## 7. Expected errors

- malformed input: `400 VALIDATION_ERROR`;
- invalid username or password: `401 INVALID_CREDENTIALS` without revealing which field failed;
- missing, invalid or expired token: `401 UNAUTHENTICATED`;
- authenticated role without permission: `403 FORBIDDEN_OPERATION`;
- account without one recognized role: authentication is rejected and an internal security event is recorded without exposing sensitive data.

## 8. Acceptance scenarios

### SC-AUTH-001 — Participant login

Given the development account `student1` has role `PARTICIPANT`,
when valid credentials are submitted,
then the server issues a participant token,
and the app opens the Alumno/participante shell.

### SC-AUTH-002 — Cafetería login

Given the development account `operator` has role `OPERATOR`,
when valid credentials are submitted,
then the server issues an operator token,
and the app opens the Cafetería shell.

### SC-AUTH-003 — ReVuelta login

Given the development account `admin` has role `ADMIN`,
when valid credentials are submitted,
then the server issues an administrator token,
and the app opens the Operación ReVuelta shell.

### SC-AUTH-004 — Invalid credentials

Given a username or password is invalid,
when login is attempted,
then authentication is rejected without identifying which credential was incorrect.

### SC-AUTH-005 — Missing role fails closed

Given an account has no recognized role,
when login is attempted,
then no access token is issued,
and the account receives no fallback permission.

### SC-AUTH-006 — Client cannot choose perspective

Given an authenticated `PARTICIPANT` session,
when the client attempts to open or call a Cafetería operation directly,
then the server rejects the protected operation,
and changing client-side navigation does not change the role.

## 9. Non-goals

- public registration;
- social login;
- password recovery;
- refresh tokens;
- server-side token revocation;
- automatic ITVer identity-provider integration;
- distinguishing alumno from maestro when their permissions are identical;
- using a participant operation QR as an authentication credential.

## 10. Verification boundary

The development/MVP slice is complete only when:

- every enabled sensitive endpoint is exercised with no token, an allowed role and every denied MVP role;
- `ADMIN` cannot perform normal Cafetería delivery/return operations;
- `OPERATOR` cannot access all-inventory or full-audit operations reserved for ReVuelta;
- common migrations create no predictable development account;
- the mobile client clears local session material and returns to login for `401 UNAUTHENTICATED`;
- the mobile client preserves the authenticated session for `403 FORBIDDEN_OPERATION` and presents access denial.

This verification does not approve production provisioning, account suspension or early JWT revocation. Those remain a separate security decision before a real pilot.
