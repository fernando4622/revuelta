# Decision Register — ReVuelta Baseline

This register prevents silent assumptions.

| ID | Decision | Current state | Blocking? | Owner |
|---|---|---|---|---|
| D-001 | Exact operational/admin role matrix | unresolved | YES | Product |
| D-002 | Borrower identity model | unresolved | YES | Product |
| D-003 | Exact pilot return window within 1–3 days | unresolved | YES for pilot config | Product |
| D-004 | Exceptional lifecycle transition permissions/evidence | unresolved | YES | Product + Operations |
| D-005 | Meaning of ASSIGNED vs IN_USE | unresolved | YES | Product |
| D-006 | Meaning/persistence of RETURNED state | unresolved | YES | Product |
| D-007 | Authentication/session mechanism | unresolved | YES | Architecture/Security |
| D-008 | Final PK/external identifier strategy | unresolved | YES | Architecture/Data |
| D-009 | Time/zone representation | unresolved | YES | Architecture/Data |
| D-010 | API idempotency key/deduplication mechanism | unresolved | YES | Architecture |
| D-011 | Flutter state-management library | unresolved | NO for domain, YES before project-wide convention | Architecture |
| D-012 | Offline mutation support | baseline recommendation: NO | NO unless scope changes | Product |
| D-013 | Exact database concurrency mechanism | unresolved | YES before circulation implementation | Architecture/Data |

## Rule

No agent may convert an unresolved row into an implementation detail without updating the governing specification and decision record.
