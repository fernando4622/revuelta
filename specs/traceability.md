# ReVuelta Traceability Matrix

This matrix links approved or draft requirements to their intended evidence. A row moves to `IMPLEMENTED` only after its governing spec is approved and executable validation exists.

| Requirement area | Governing spec | Scenario/test evidence | Implementation | Status |
|---|---|---|---|---|
| Pilot product scope | `constitution.md`, `product.md`, root `context.md` | product acceptance | N/A | PARTIALLY APPROVED |
| UI reference interpretation | `ui/reference-mockups.md` | design review | Flutter theme/components | SPECIFIED |
| Authenticated role routing | `features/authentication/requirements.md`, `ui/perspectives.md`, DL-007/DL-014 | SC-AUTH-001..006, SC-PER-001..004, SC-UI-001/002/004 | Login exists; role-specific shells remain incomplete | PARTIAL |
| Student navigation/home | `ui/student-experience.md` | SC-STU-001/002, widget tests | Existing UI requires remediation | DRAFT |
| Student scan/return information | `ui/student-experience.md`, `features/scan-container/ui.md` | SC-STU-003/004, scan tests | Existing UI requires remediation | SPECIFIED FOR DEMO |
| Student history | `ui/student-experience.md` | history state/widget/contract tests | Existing screen uses demo data | DRAFT |
| Student impact | `ui/student-experience.md` | demo-label tests; methodology/data tests for production | Existing screen uses demo data | DEMO ONLY / PROD BLOCKED BY D-017 |
| Student notifications/profile | `ui/student-experience.md` | empty/data/navigation tests | Existing screens require real sources | DRAFT |
| Cafeteria navigation | `ui/cafeteria-experience.md` | navigation/widget review | TBD | PRODUCT FLOW APPROVED |
| Cafeteria delivery | `ui/cafeteria-experience.md`, `features/deliver-container/ui.md` | SC-CAF-001/003/004/005 | Existing page requires layer/state remediation | BLOCKED |
| Cafeteria return | `ui/cafeteria-experience.md`, `features/return-container/ui.md` | SC-CAF-002..005 | Existing page requires layer/state remediation | PRODUCT FLOW APPROVED |
| Cafeteria washing | `features/complete-wash/*`, `ui/cafeteria-experience.md` | SC-WASH-*, SC-CAF-006 | TBD | PRODUCT FLOW APPROVED |
| Participant Code | `domain/participant.md`, `features/identify-participant/*` | SC-PAR-*, SC-PID-* | TBD | APPROVED BASELINE |
| ReVuelta operations | `ui/revuelta-operations-experience.md` | SC-OPS-001..005 | TBD | PRODUCT RESPONSIBILITIES APPROVED |
| Shared UI states | `ui/state-machines.md` | state/controller tests | Partial | SPECIFIED |
| Authentication UI | `features/authentication/requirements.md` | SC-AUTH-001..006 | Login exists; seed roles and routing require verification | PARTIAL |
| Container identity | `domain/container-lifecycle.md`, `data/data-model.md` | SC-CTR-001/002, SC-DATA-001 | Partial | BLOCKED |
| Container lifecycle | `domain/container-lifecycle.md` | SC-CTR-* | Partial; current code does not persist pending wash | NORMAL FLOW APPROVED / IMPLEMENTATION GAP |
| Delivery domain | `domain/circulation.md` | SC-CIR-001/002/003 | Partial; participant model requires change | PRODUCT FLOW APPROVED / TECH BLOCKED |
| Return domain | `domain/circulation.md` | SC-CIR-004/006 | Current code returns directly to available | PRODUCT FLOW APPROVED / IMPLEMENTATION GAP |
| Authorization | `security/access-control.md` | SC-SEC-* | Partial | BLOCKED |
| API error contract | `api/errors.md`, `api/openapi-baseline.md` | contract tests | Partial | BLOCKED |
| Persistence integrity | `data/data-model.md` | SC-DATA-* | Partial | BLOCKED |
| Observability | `ops/observability.md` | integration/ops checks | Partial | DRAFT |
| Threat controls | `risks/threat-model.md` | security tests | Partial | BLOCKED |

## UI evidence rule

Visual similarity to a mockup is not sufficient evidence.

Each UI row requires, as applicable:

- controller/state tests;
- widget tests for content and allowed actions;
- navigation tests;
- accessibility checks;
- API contract compatibility;
- device verification for camera/QR;
- proof that sample data is absent from production paths.
