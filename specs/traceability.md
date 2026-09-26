# ReVuelta Traceability Matrix

This matrix links approved or draft requirements to their intended evidence. A row moves to `IMPLEMENTED` only after its governing spec is approved and executable validation exists.

| Requirement area | Governing spec | Scenario/test evidence | Implementation | Status |
|---|---|---|---|---|
| Pilot product scope | `constitution.md`, `product.md`, root `context.md` | product acceptance | N/A | PARTIALLY APPROVED |
| UI reference interpretation | `ui/reference-mockups.md` | design review | Flutter theme/components | SPECIFIED |
| Authenticated role routing | `features/authentication/requirements.md`, `ui/perspectives.md`, DL-007/DL-014 | role parsing and shell widget tests; PostgreSQL/API login verification | Explicit router and separate shells; unsupported roles fail closed | IMPLEMENTED |
| Student navigation/home | `ui/student-experience.md`, `features/role-queries/*` | SC-STU-001/002; home loading/empty/error/success widget tests; authenticated Docker smoke | Active circulations and return guidance come from the participant-owned API through typed repository/providers | IMPLEMENTED F7 |
| Student operation QR | `ui/student-experience.md`, `features/identify-participant/*`, `features/scan-container/ui.md` | operation QR controller/widget tests; API client contract test; F4 device acceptance | Participant selects delivery/return and renders the exact short-lived server payload; physical scan accepted on SM-S936B | VERIFIED F4 |
| Student history | `ui/student-experience.md`, `features/role-queries/*` | repository contract, real empty-state widget test and authenticated Docker smoke | Own paged circulation history comes from `/me/circulations`; no production demo rows remain | IMPLEMENTED F7 |
| Student impact | `ui/student-experience.md` | demo-label tests; methodology/data tests for production | Existing screen uses demo data | DEMO ONLY / PROD BLOCKED BY D-017 |
| Student notifications/profile | `ui/student-experience.md` | empty/data/navigation tests | Existing screens require real sources | DRAFT |
| Cafeteria navigation | `ui/cafeteria-experience.md`, `features/role-queries/*` | role shell, dual-scan, pending-wash and recent-operation checks | Shell exposes scan, pending washes and the authenticated operator's recent activity only | IMPLEMENTED F7 |
| Cafeteria delivery | `ui/cafeteria-experience.md`, `features/deliver-container/ui.md` | SC-CAF-001/003/004/005; F5 physical acceptance | Typed controller/repository flow requires both QR values and server confirmation | VERIFIED F5 |
| Cafeteria return | `ui/cafeteria-experience.md`, `features/return-container/ui.md` | SC-CAF-002..005; F6 integrated acceptance | Typed controller/repository flow requires both QR values and leaves the container pending wash | VERIFIED F6 |
| Cafeteria washing | `features/complete-wash/*`, `ui/cafeteria-experience.md` | `CompleteContainerWashUseCaseTest`; PostgreSQL integration; mobile repository test; Docker query smoke | Authorized explicit transition `RETURNED → AVAILABLE`, shown through the real pending-wash queue | IMPLEMENTED F7 |
| Participant operation QR | `domain/participant.md`, `features/identify-participant/*`, `features/scan-container/*` | `QrUseCaseTest`; HMAC codec tests; security HTTP workflow; Flutter controller/widget/client tests; F4 device acceptance | Signed two-minute server token, explicit account binding, purpose and minimal resolution implemented; token consumption remains F5/F6 | VERIFIED F4 |
| Container QR identity | `domain/container-lifecycle.md`, `features/scan-container/*`, `api/openapi-baseline.md` | codec/use-case/contract/security/PostgreSQL tests; Docker HTTP check; F4 device acceptance | Signed/versioned static QR, generation rotation/revocation and server-derived operator actions implemented and physically scanned | VERIFIED F4 |
| ReVuelta operations | `ui/revuelta-operations-experience.md`, `features/role-queries/*` | role shell, repository contract, backend query tests and authenticated Docker smoke | Real summary, participants, inventory/register/activate, circulations and audit; incidents/retirement remain explicitly unavailable under D-004 | IMPLEMENTED F7 APPROVED SCOPE |
| Shared UI states | `ui/state-machines.md` | controller/widget tests for loading, empty, error, success, uncertain result and expired session | Riverpod async states and typed failures drive the enabled role experiences | IMPLEMENTED F7 |
| Authentication UI | `features/authentication/requirements.md` | API login verification; role parsing, session-failure and shell widget tests | Login, seed roles, routing, expired-session logout and denied-access mapping verified; production lifecycle remains pending | MVP/DEV VERIFIED |
| Container identity | `domain/container-lifecycle.md`, `data/data-model.md` | SC-CTR-001/002, SC-DATA-001 | Partial | BLOCKED |
| Container lifecycle | `domain/container-lifecycle.md` | `ContainerTest`; `ReturnContainerUseCaseTest`; `CompleteContainerWashUseCaseTest`; PostgreSQL integration | Normal flow persists explicit `IN_USE → RETURNED → AVAILABLE` transitions; wash completion is operator-authorized | NORMAL FLOW IMPLEMENTED |
| Delivery domain | `domain/circulation.md` | SC-CIR-001/002/003 | Partial; participant model requires change | PRODUCT FLOW APPROVED / TECH BLOCKED |
| Return domain | `domain/circulation.md` | `CirculationTest`; `ReturnContainerUseCaseTest`; `PersistenceAdapterIntegrationTest` | Return completes circulation and persists `RETURNED`; washing is a separate authorized operation | IMPLEMENTED NORMAL FLOW |
| Role-owned operational queries | `features/role-queries/*`, `security/access-control.md`, `api/openapi-baseline.md` | `RoleQueryUseCaseTest`; persistence/security/contract tests; mobile repository tests; Docker smoke for all roles | Session-owned participant history, operator work queues and admin read models are typed, paged and authorization-filtered | IMPLEMENTED F7 |
| Authorization | `security/access-control.md` | SC-SEC-*; `SecurityErrorContractIntegrationTest`; mobile API/session tests | Every enabled sensitive endpoint, including QR generation/resolution/rotation, is tested with absent, allowed and denied roles; scanning never authenticates an actor | VERIFIED MVP / PROD LIFECYCLE PENDING |
| API error contract | `api/errors.md`, `api/openapi-baseline.md` | `GlobalExceptionHandlerTest`; `SecurityErrorContractIntegrationTest`; `RestEndpointOpenApiContractTest` | Expected application failures use stable codes; routes and public response fields match OpenAPI; 400/401/403/404/409/500 use the common problem contract | VERIFIED F2 BASELINE |
| Build/configuration baseline | `ops/deployment.md`, `AGENTS.md`, `ROADMAP.md` F1 | Maven Wrapper build; Flutter checks; OpenAPI lint; Trivy scan; GitHub Actions runs through `35521927862` | Canonical Maven/JDK 17 build, isolated dev seeds, configurable mobile URL and green CI workflow | VERIFIED |
| Domain dependency boundary | `AGENTS.md` §6, ADR-002 | `DomainArchitectureTest` | ArchUnit protects domain from application, infrastructure, interfaces, Spring, JPA and Jackson dependencies | IMPLEMENTED |
| Application dependency direction | `AGENTS.md` §6.2, ADR-001 | `ApplicationArchitectureTest`; `LoginUseCaseTest`; `SpringTransactionRunnerAdapterTest` | Application production code cannot depend on Spring, Lombok, infrastructure or interfaces; authentication and transactions use explicit ports with tested adapters | VERIFIED |
| Persistence integrity | `data/data-model.md`, ADR-005 | `DataIntegrityPostgresIntegrationTest`; `PersistenceAdapterIntegrationTest`; `PersistenceConflictTranslationTest`; `MigrationProfileIsolationTest` | V8 enforces policy provenance, lifecycle consistency, restrictive history FKs, one active circulation per container and optimistic versions; multiple containers per participant remain allowed | VERIFIED F2 BASELINE |
| Event traceability | `data/data-model.md` §7, `api/openapi-baseline.md` | `PersistenceAdapterIntegrationTest`; `SecurityErrorContractIntegrationTest` | Append-only adapter operations preserve actor, server time, operation type and server correlation UUID | VERIFIED F2 BASELINE |
| Observability | `ops/observability.md` | `SecurityErrorContractIntegrationTest`; Docker HTTP check | Server-generated correlation header and matching problem `traceId` are implemented; structured logging, metrics and readiness remain | PARTIAL |
| Threat controls | `risks/threat-model.md` | security, HMAC, expiry, revocation and role-matrix tests | QR tampering/version/type, expiry, replay marker, static generation revocation and least-data resolution covered; broader production hardening remains | PARTIAL |

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
