# Decision Register — ReVuelta Baseline

This register prevents silent assumptions.

| ID | Decision | Current state | Blocking? | Owner |
|---|---|---|---|---|
| D-001 | Exact operational/admin role matrix | approved for MVP: `PARTICIPANT` → Alumno/maestro, `OPERATOR` → Cafetería, `ADMIN` → Operación ReVuelta | NO for MVP; production provisioning review remains | Product |
| D-002 | Borrower identity model | approved: persistent opaque Participant Code, no PII in QR | NO for domain; recovery remains D-018 | Product |
| D-003 | Exact pilot return window within 1–3 days | unresolved | YES for pilot config | Product |
| D-004 | Exceptional lifecycle transition permissions/evidence | unresolved | YES | Product + Operations |
| D-005 | Meaning of ASSIGNED vs IN_USE | unresolved | YES | Product |
| D-006 | Meaning/persistence of RETURNED state | approved: persistent pending-wash state | NO | Product |
| D-007 | Authentication/session mechanism | approved for development/MVP demo: username/password + signed JWT for 4 hours, no refresh; production identity provisioning/revocation remains open | NO for MVP demo; YES before real pilot | Architecture/Security |
| D-008 | Final PK/external identifier strategy | unresolved | YES | Architecture/Data |
| D-009 | Time/zone representation | unresolved | YES | Architecture/Data |
| D-010 | API idempotency key/deduplication mechanism | unresolved | YES | Architecture |
| D-011 | Flutter state-management library | unresolved | NO for domain, YES before project-wide convention | Architecture |
| D-012 | Offline mutation support | baseline recommendation: NO | NO unless scope changes | Product |
| D-013 | Exact database concurrency mechanism | unresolved | YES before circulation implementation | Architecture/Data |
| D-014 | Perspective selection mechanism | superseded: no selector; authenticated server role selects the experience | NO | Product |
| D-015 | Actor and physical handoff that finalize a return | approved: Cafetería confirms physical receipt by scanning the container | NO | Product + Operations |
| D-016 | Canonical ReVuelta logo/brand asset | approved: `apps/revuelta-mobile/resources/logo.jpeg` | NO | Product/Brand |
| D-017 | Environmental-impact metric methodology and data source | demo/mockup data approved only when clearly labeled; real methodology unresolved | YES before production numeric impact UI | Product + Data |
| D-018 | Lost/replaced Participant Code recovery and reassociation | unresolved | YES before pilot with real participants | Product + Operations + Security |

## Rule

No agent may convert an unresolved row into an implementation detail without updating the governing specification and decision record.

The current D-014 decision removes the unrestricted selector. Only the role carried by a valid server-issued session selects the application experience.

D-002 does not make possession of a Participant Code an authenticated session. Only an authorized Cafetería/ReVuelta actor may use it in a protected operation.
