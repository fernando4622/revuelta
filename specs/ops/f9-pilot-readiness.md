# F9 Integral Verification and Controlled Pilot Readiness Specification

**Status:** PROPOSED — implementation and field `GO` require the decisions in
Section 15.

## 1. Purpose

Produce a reproducible release candidate, exercise the complete approved
ReVuelta journey under pilot-like conditions and make a truthful, evidence-based
`GO CONTROLADO` or `NO-GO` decision.

F9 separates technical readiness from field acceptance. Passing automated and
operational checks may produce `READY FOR FIELD VALIDATION`; it does not by
itself authorize a real pilot.

## 2. Scope

This phase includes:

- a pilot-like staging rehearsal of the modular monolith, PostgreSQL and the
  Android application;
- automated verification of the approved domain, application, persistence,
  concurrency, security, OpenAPI and Flutter behavior;
- a critical E2E journey using isolated controlled accounts and data;
- clean-database and upgrade-path migration verification;
- database backup and non-destructive restore rehearsal;
- application rollback rehearsal with an explicit schema-compatibility check;
- physical Android, camera, QR and cafeteria-connectivity validation;
- a field checklist with named evidence, defect severity and sign-off;
- a final, recorded `GO CONTROLADO` or `NO-GO` result.

## 3. Actors and responsibilities

- **Release verifier:** builds the immutable candidate, executes automated and
  operational checks and collects evidence.
- **ReVuelta field representative:** validates administration, history,
  incident handling and the operational result.
- **Cafeteria representative:** validates delivery, return, washing and the
  physical handoff at the return point.
- **Participant tester:** validates the Alumno/Maestro experience and presents
  the required dynamic QR.
- **Support owner:** receives incidents during the controlled-pilot window and
  can order suspension.
- **Release authority:** records the final decision after every mandatory gate
  is satisfied.

One person may hold more than one responsibility, but every responsibility must
have a named owner before `GO CONTROLADO`.

## 4. Preconditions

- F2 through F8 are closed for the candidate commit.
- Applicable product, domain, API, UI, data, security and deployment specs are
  approved; unresolved blocking decisions prevent field `GO`.
- The candidate commit and APK are identifiable and are not rebuilt during the
  acceptance run.
- Secrets are supplied outside Git and meet the F8 policy.
- The staging data set is isolated from real operational history.
- A physical Android device, printed static container QR labels and cafeteria
  connectivity are available.
- Controlled accounts exist for `PARTICIPANT`, `OPERATOR` and `ADMIN` without
  using production credentials or publicly known passwords.
- The support owner, test window, signatories and suspension criteria are
  recorded.

The current developer seed accounts are acceptable only for a local technical
rehearsal. They are prohibited in a real pilot.

## 5. Inputs

- candidate Git commit and APK checksum;
- container image identifiers and environment configuration version;
- a secret-free environment manifest;
- database migration set and the immediately previous supported schema state;
- controlled users by role;
- at least five uniquely identified physical containers and their signed static
  QR labels;
- approved return-window configuration;
- field-test run sheet, defect register and sign-off record;
- backup location, retention rule and restore target;
- current and previous application release identifiers.

## 6. Outputs

F9 produces:

- an immutable release-candidate manifest;
- machine-readable automated-check results;
- migration, backup, restore and rollback evidence;
- a completed physical field-test record;
- a defect register with severity and disposition;
- Cafeteria, ReVuelta, security/privacy and release-authority sign-off;
- the support window and escalation route;
- the final decision and its reasons.

Evidence must not contain passwords, bearer tokens, participant QR payloads,
signing secrets or unnecessary personal data.

## 7. Readiness state model

```text
NO-GO
  -> TECHNICALLY VERIFIED
  -> READY FOR FIELD VALIDATION
  -> GO CONTROLADO
```

- `NO-GO` is the default and remains active after any failed mandatory check,
  open blocking decision or missing sign-off.
- `TECHNICALLY VERIFIED` means automated checks, migrations and the isolated
  operational rehearsal passed for the recorded candidate.
- `READY FOR FIELD VALIDATION` additionally means backup/restore/rollback and
  the physical environment are prepared with named owners.
- `GO CONTROLADO` requires every Section 13 gate and explicit sign-off.

A failed blocking check or newly discovered P0/P1 defect moves any pre-release
state back to `NO-GO`. This document records readiness; it does not mutate
container or circulation state in a real environment.

## 8. Environment and data policy

The first technical rehearsal may use the existing laptop and local hotspot if
its runtime shape matches the controlled-pilot topology. It must be described
as **pilot-like local staging**, never as production infrastructure.

The rehearsal environment must:

- use PostgreSQL through the same migration path as the pilot;
- use non-default secrets supplied at runtime;
- disable developer seed creation by default;
- establish test users and fixtures through a controlled, repeatable procedure;
- bind evidence to the candidate commit and configuration fingerprint;
- expose the API to test devices only on the intended private network;
- keep staging data separate from any future pilot database.

Moving from the local staging topology to a hosted or institution-managed pilot
requires the same operational checks in that target environment.

## 9. Automated verification contract

The recorded candidate must pass:

1. backend unit, architecture, application, authorization and API tests;
2. PostgreSQL integration, constraint, transaction and concurrency tests;
3. clean-schema migration and migration from the previous supported schema;
4. OpenAPI lint/validation and client-contract checks;
5. Flutter analysis, unit/controller/widget tests and Android build;
6. dependency/secret scanning required by F8;
7. an isolated critical E2E journey:

```text
login by role
-> issue operation QR
-> resolve operation QR and static container QR
-> deliver multiple containers to one participant
-> participant views active circulations
-> return a container
-> complete washing
-> inspect history
```

The E2E journey must assert stable error codes for malformed QR, wrong role,
replayed operation, unknown container and concurrent duplicate mutation. It
must never run against real pilot data.

## 10. Backup, restore and rollback contract

### 10.1 Backup and restore

- The backup is taken with PostgreSQL tooling from the recorded candidate
  database and receives a checksum.
- Restore occurs into a new isolated database or disposable stack; the source
  database is never overwritten by the rehearsal.
- Verification checks migrations, representative users, containers,
  circulations and append-oriented history after restore.
- A backup that cannot be restored and queried is not valid evidence.

### 10.2 Application rollback

- The current and previous application artifacts are retained by immutable
  identifier.
- Rollback switches the application artifact/configuration; it does not rewrite
  audit history or automatically reverse migrations.
- Before deployment, every migration is classified as backward compatible or
  rollback-blocking for the previous application.
- If the previous application cannot safely run on the migrated schema, the
  release remains `NO-GO` until a forward-fix or compatible migration plan is
  approved.
- The drill verifies health, authentication and read-only inspection after the
  previous application starts, then returns to the candidate.

No F9 script may delete the source database, Docker volume or backup as part of
normal execution.

## 11. Physical field scenarios

Every scenario records candidate, device, actor, UTC time, outcome, correlation
ID where available and defect reference where applicable.

1. access and denied access for each role;
2. register and inspect the five physical containers;
3. normal delivery using both mandatory QR values;
4. delivery of more than one container to the same participant;
5. malformed, unknown and replayed QR attempts;
6. response loss/network interruption during delivery followed by state
   recovery without blind mutation retry;
7. simultaneous delivery attempts for the same container;
8. participant inspection of active circulations and due state;
9. normal and late return using both mandatory QR values;
10. response loss/network interruption during return followed by state
    recovery;
11. simultaneous return attempts for the same circulation;
12. washing completion and history inspection;
13. the approved exceptional lifecycle cases, if D-004 is included in the
    controlled-pilot scope;
14. database outage detection and service recovery;
15. restoration from backup and application rollback rehearsal.

No scenario may claim acceptance for unresolved or unimplemented business
behavior.

## 12. Defects, support and suspension

Severity is release-oriented:

- **P0:** safety, data-loss, broad unauthorized access or unrecoverable
  corruption; immediate suspension.
- **P1:** critical journey or invariant cannot be completed safely and no
  approved workaround exists; blocks `GO`.
- **P2:** material degraded behavior with a documented safe workaround; requires
  explicit disposition before `GO`.
- **P3:** cosmetic or low-impact issue that does not change business behavior;
  may be scheduled after the pilot.

The controlled pilot is suspended when any of the following occurs:

- a P0/P1 defect is discovered;
- an unauthorized mutation or suspected credential/secret exposure occurs;
- delivery/return state cannot be reconciled with physical possession;
- the database cannot be restored within the approved recovery objective;
- readiness or database connectivity remains unavailable beyond the approved
  field threshold;
- the support owner or either operational signatory withdraws acceptance.

Exact response/recovery objectives, support hours and contact route are
deployment configuration and must be approved before field `GO`.

## 13. Permissions and release gate

- Only authenticated, server-authorized actors execute product operations.
- Only the release verifier executes backup/restore/rollback procedures.
- Only named Cafeteria and ReVuelta representatives sign their field journeys.
- Only the release authority records `GO CONTROLADO`.

All of the following are mandatory:

- [ ] all applicable specifications and blocking decisions are approved;
- [ ] no developer seeds or publicly known credentials are enabled;
- [ ] automated verification and migrations pass for the candidate;
- [ ] no open P0/P1 defect exists and every P2 has explicit disposition;
- [ ] security/privacy review is signed;
- [ ] backup, isolated restore and rollback are demonstrated;
- [ ] physical QR, device and network scenarios pass;
- [ ] Cafeteria and ReVuelta representatives accept their journeys;
- [ ] the support owner, hours and escalation route are active;
- [ ] pilot metrics, recovery objective and suspension criteria are approved;
- [ ] the decision record identifies candidate, configuration and signatories.

Anything less is `NO-GO` or, when only field evidence remains, `READY FOR FIELD
VALIDATION`.

## 14. Expected failures

- failed mandatory automated/operational check: `NO-GO` with evidence link;
- missing/unapproved specification or decision: `NO-GO`, no silent default;
- source and restored data mismatch: `NO-GO` and incident investigation;
- rollback-incompatible migration: `NO-GO` until an approved forward strategy;
- unavailable physical device, network, owner or signatory: field validation
  incomplete, never a synthetic pass;
- exposed secret/credential in evidence: revoke/rotate, sanitize evidence and
  open a security incident;
- P0/P1 field defect: stop the run and suspend candidate approval.

## 15. Decisions required before implementation

The following decisions are intentionally not selected by this proposal:

1. **F9 target:** approve the laptop/local-hotspot topology as pilot-like local
   staging for technical verification, or provide the real staging target.
2. **D-003:** approve the exact return window. The current development seed is
   48 hours but is not an approved pilot decision.
3. **D-005:** approve whether delivery transitions directly from `AVAILABLE` to
   `IN_USE` and leaves `ASSIGNED` unused in V1.
4. **D-004:** either defer exceptional damaged/lost/retired operations from the
   first controlled pilot or approve a complete transition/evidence/circulation
   policy before including Scenario 13.
5. **D-007:** approve a real pilot account provisioning/revocation procedure;
   developer seed users cannot satisfy this gate.
6. Name the Cafeteria representative, ReVuelta representative, support owner,
   release authority, support schedule and recovery objective.

## 16. Acceptance scenarios

### SC-F9-001 — Technical success is not field authorization

Given every automated check passes,
when physical validation or a blocking decision remains incomplete,
then the candidate is at most `READY FOR FIELD VALIDATION` and remains
unauthorized for a real pilot.

### SC-F9-002 — Reproducible candidate

Given the recorded commit, environment manifest and external secrets,
when the release verifier rebuilds the candidate,
then the artifacts and schema can be identified and the mandatory checks
produce the same pass/fail result without manual schema edits.

### SC-F9-003 — Non-destructive restore

Given a checksummed backup of representative staging data,
when it is restored into an isolated database,
then representative state and history match the source and the source database
remains unchanged.

### SC-F9-004 — Incompatible rollback blocks release

Given a migration that prevents the previous application from starting safely,
when rollback compatibility is evaluated,
then the candidate remains `NO-GO` until an approved compatible or forward-fix
plan exists.

### SC-F9-005 — Lost delivery response

Given the server commits a delivery but the device loses the response,
when connectivity returns,
then the operator recovers authoritative state without blindly repeating the
delivery and the container has exactly one active circulation.

### SC-F9-006 — Field suspension

Given a controlled pilot candidate is approved,
when a P0/P1 defect or possession/state mismatch is observed,
then operations stop, the support path is activated and the recorded state
returns to `NO-GO` until resolution and re-verification.

## 17. Non-goals

- declaring a real pilot ready from automated tests alone;
- inventing the unresolved D-003, D-004, D-005 or D-007 semantics;
- using developer seeds in production;
- provisioning cloud infrastructure without a separate approved decision;
- implementing offline mutations;
- rewriting history or destructive rollback of business data;
- validating real environmental-impact methodology, which remains D-017;
- replacing domain/integration tests with one E2E script.
