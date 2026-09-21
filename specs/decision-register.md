# Decision Register — ReVuelta Baseline

This register prevents silent assumptions.

| ID | Decision | Current state | Blocking? | Owner |
|---|---|---|---|---|
| D-001 | Exact operational/admin role matrix | approved for MVP: `PARTICIPANT` → Alumno/maestro, `OPERATOR` → Cafetería, `ADMIN` → Operación ReVuelta | NO for MVP; production provisioning review remains | Product |
| D-002 | Borrower identity model | superseded by D-019: authenticated participant account plus short-lived operation QR; no PII in QR | NO for MVP demo; production account binding remains | Product |
| D-003 | Exact pilot return window within 1–3 days | unresolved | YES for pilot config | Product |
| D-004 | Exceptional lifecycle transition permissions/evidence | unresolved | YES | Product + Operations |
| D-005 | Meaning of ASSIGNED vs IN_USE | unresolved | YES | Product |
| D-006 | Meaning/persistence of RETURNED state | approved: persistent pending-wash state | NO | Product |
| D-007 | Authentication/session mechanism | approved for development/MVP demo: username/password + signed JWT for 4 hours, no refresh; production identity provisioning/revocation remains open | NO for MVP demo; YES before real pilot | Architecture/Security |
| D-008 | Final PK/external identifier strategy | approved for MVP: application-generated UUID v4, shared as PostgreSQL PK and API identifier | NO | Architecture/Data |
| D-009 | Time/zone representation | approved: UTC `Instant`, PostgreSQL `TIMESTAMP WITH TIME ZONE`, ISO 8601 API values; business-zone interpretation is configuration | NO | Architecture/Data |
| D-010 | API idempotency key/deduplication mechanism | approved for MVP: database-enforced state/uniqueness conflicts with deterministic `409`; no client idempotency key | NO for MVP; review after pilot | Architecture |
| D-011 | Flutter state-management library | unresolved | NO for domain, YES before project-wide convention | Architecture |
| D-012 | Offline mutation support | baseline recommendation: NO | NO unless scope changes | Product |
| D-013 | Exact database concurrency mechanism | approved: partial unique index for active delivery plus optimistic locking for conflicting aggregate updates | NO | Architecture/Data |
| D-014 | Perspective selection mechanism | superseded: no selector; authenticated server role selects the experience | NO | Product |
| D-015 | Actor and physical handoff that finalize a return | approved: Cafetería confirms physical receipt by scanning the container | NO | Product + Operations |
| D-016 | Canonical ReVuelta logo/brand asset | approved: `apps/revuelta-mobile/resources/logo.jpeg` | NO | Product/Brand |
| D-017 | Environmental-impact metric methodology and data source | demo/mockup data approved only when clearly labeled; real methodology unresolved | YES before production numeric impact UI | Product + Data |
| D-018 | Lost/replaced persistent Participant Code recovery and reassociation | superseded: persistent client codes are not used in the approved handoff | NO | Product + Operations + Security |
| D-019 | QR model for physical handoff | approved: signed/versioned static container QR plus server-issued participant QR scoped to `DELIVERY` or `RETURN`, valid for 2 configurable minutes and consumed by exactly one successful operation | NO for MVP demo; physical-device evidence remains | Product + Security |
| D-020 | QR requirements per handoff | approved: both the participant operation QR and container QR are mandatory for every delivery and every return; no manual-entry or absent-participant exception | NO | Product + Operations |

## Rule

No agent may convert an unresolved row into an implementation detail without updating the governing specification and decision record.

The current D-014 decision removes the unrestricted selector. Only the role carried by a valid server-issued session selects the application experience.

D-019 does not make possession of either QR an authenticated staff session. Only an authorized Cafetería actor may consume the two validated references in a handoff operation.

The participant QR is emitted only for an authenticated `PARTICIPANT` account with an explicit participant association. It is read-only while resolved and is consumed atomically only when F5/F6 commits the matching handoff. Server time determines expiration.

D-010 makes mutating operations deterministic for the MVP but does not promise replay of the original success response. A request observed after the first commit receives the stable conflict for its resulting state. Introducing stored idempotency keys requires a future contract decision.
