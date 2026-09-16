# ReVuelta — AGENTS.md

> **Purpose:** Non-negotiable instructions for developers and AI coding agents working in the ReVuelta repository.
> **Authority:** This file is the project constitution for implementation behavior. Product/domain specifications define feature semantics. ADRs define accepted architectural decisions. When these documents conflict, stop implementation and resolve the conflict; do not silently choose one.

---

# 1. Mission

ReVuelta is a real operational system for controlling reusable food containers through individual identification, QR-based interaction, circulation/loan management, returns, state transitions and traceability.

The repository is developed using:

- **Spec-Driven Development (SDD)** — specifications are reviewed before implementation and guide implementation + verification.
- **Domain-Driven Design (DDD)** — boundaries and business concepts are modeled explicitly.
- **Contract-Driven Development (CDD)** — external API contracts are explicit and versioned.
- **Test-Driven Development (TDD)** — deterministic business rules are developed against tests.
- **Behavior-Driven Development (BDD)** — important user/operational behavior is expressed as scenarios.
- **Architecture Decision Records (ADR)** — important architectural choices are durable and reviewable.
- **Risk/Threat-driven development** — security and reliability work is prioritized from concrete risks, not from checklist fashion.

SDD practices emphasize explicit reviewed specifications, local context and a workflow in which implementation follows the specification rather than replacing it. [1][2]

---

# 2. Source-of-truth hierarchy

Use this order when deciding what is authoritative:

```text
1. Product/domain specification
2. Approved ADR
3. API/UI/data contract
4. AGENTS.md architectural and engineering rules
5. Existing implementation
6. Agent inference
```

The existing code is **not automatically correct** merely because it already exists.

An agent must never infer a business rule from accidental existing behavior when a specification is missing or contradictory.

When a required business decision is unspecified:

```text
STOP → identify ambiguity → create/update spec → obtain approval → implement
```

Do not “pick a reasonable default” for material business semantics.

---

# 3. Absolute rules

## 3.1 No implementation before specification

Do not implement a new feature until its applicable spec exists and contains enough information to determine observable behavior.

Minimum feature spec:

- purpose;
- scope;
- actor;
- preconditions;
- inputs;
- outputs;
- state changes;
- permissions;
- expected errors;
- acceptance scenarios;
- non-goals.

## 3.2 No business logic in presentation or transport

Do not place domain rules in:

- Flutter widgets;
- Spring controllers;
- HTTP filters unless the rule is actually transport-specific;
- DTOs;
- JSON serializers;
- SQL triggers used to compensate for a missing domain model.

Business decisions belong to the domain/application boundary according to their responsibility.

## 3.3 No speculative architecture

Do not introduce microservices, Kafka, Kubernetes, event buses, CQRS, distributed transactions, service meshes, generic “frameworks”, repositories for hypothetical providers, or additional databases without an approved ADR and a real requirement.

V1 is intentionally a **modular monolith** unless an approved ADR says otherwise.

## 3.4 No hidden state mutation

State transitions must be explicit and validated.

Never expose a generic mechanism such as:

```text
container.status = X
```

as the normal way to change business state.

Use a domain operation/use case that validates the transition.

## 3.5 History is append-oriented

Business/audit history must not be rewritten to “make the current state look correct”. Corrections are new events/operations with a reason and actor where the domain allows corrections.

## 3.6 The server owns business time

For business operations, do not trust a client-provided timestamp as the authoritative occurrence time unless a specific spec explicitly requires it.

Client timestamps may be treated as metadata when needed, never silently as authoritative business time.

## 3.7 Concurrency is real

Assume two operators/devices can attempt a conflicting operation at the same time.

Critical invariants must survive concurrent requests.

Do not rely on:

```text
check state → update later
```

without a concurrency strategy.

The strategy must be defined by the relevant use-case/data spec, using mechanisms appropriate to the actual invariant.

---

# 4. Required workflow for every change

```text
READ
  ↓
LOCATE APPLICABLE SPECS
  ↓
CHECK SCOPE / NON-GOALS
  ↓
PLAN
  ↓
WRITE/UPDATE TESTS
  ↓
IMPLEMENT SMALLEST VALID SLICE
  ↓
RUN CHECKS
  ↓
REVIEW AGAINST SPEC
  ↓
UPDATE SPEC / TASK STATUS
```

Before editing:

1. Read the root `AGENTS.md`.
2. Read applicable `specs/` files.
3. Read relevant ADRs.
4. Inspect the target module.
5. Identify existing tests.
6. Identify contracts affected by the change.

Do not scan or rewrite the entire repository unless the task requires it.

---

# 5. Change sizing

Prefer one vertical slice over many disconnected scaffolds.

A good implementation slice looks like:

```text
spec
→ domain rule
→ use case
→ persistence port/adapter
→ API contract
→ API implementation
→ mobile client
→ UI state
→ tests
```

Avoid creating dozens of empty classes “for architecture”.

Architecture is validated by dependency direction and behavior, not directory count.

---

# 6. Clean Architecture — backend rules

Backend stack:

- Java
- Spring Boot
- PostgreSQL

Reference dependency direction:

```text
interface adapters
      ↓
application
      ↓
domain

infrastructure ──implements──> application/domain ports
```

## 6.1 Domain layer

The domain may contain:

- entities;
- value objects;
- aggregates;
- domain services;
- domain rules;
- domain events;
- domain exceptions/failures where appropriate.

The domain may **not** depend on:

- Spring;
- JPA annotations;
- Hibernate;
- Jackson;
- HTTP;
- JDBC;
- PostgreSQL;
- controller classes.

## 6.2 Application layer

Application use cases coordinate:

- authorization context;
- domain operations;
- repositories/ports;
- transactions;
- external service ports;
- result mapping.

Application services should not become “god services”. One use case should represent one coherent application intention.

## 6.3 Interface adapters

Controllers:

- validate transport-level syntax;
- authenticate/resolve actor context;
- invoke use cases;
- map results to HTTP responses.

Controllers must not contain business decisions.

## 6.4 Infrastructure

Infrastructure implements ports for:

- persistence;
- security providers;
- QR/external integrations;
- clock if abstraction is required;
- notifications if introduced;
- observability.

Infrastructure details must not leak into domain models.

---

# 7. Clean Architecture — Flutter rules

Flutter presentation must not contain backend DTOs as domain objects.

Required conceptual flow:

```text
Widget/Page
   ↓
Controller / State Notifier / ViewModel
   ↓
Use Case
   ↓
Domain
   ↓
Repository interface
   ↓
Remote/local adapter
```

The exact state-management library is an architectural decision and must be recorded in an ADR before being treated as a project-wide rule.

## 7.1 UI responsibilities

UI may:

- render state;
- capture input;
- invoke application actions;
- navigate according to application state;
- display translated failures.

UI must not:

- decide whether a container may be returned;
- calculate authoritative business deadlines;
- mutate domain entities directly;
- build raw HTTP requests;
- parse backend JSON directly in widgets.

---

# 8. Domain modeling rules

Use DDD terminology deliberately.

## Entity
Use when identity persists across changes.

## Value Object
Use when value + invariants matter more than identity.

## Aggregate
Use when consistency must be enforced as a transactional boundary.

## Domain Service
Use only when a domain operation does not naturally belong to one entity/value object.

## Repository
Represents collection-like access to an aggregate boundary; it is a domain/application port, not a generic CRUD dumping ground.

Do not create:

```text
GenericRepository<T>
GenericService<T>
BaseController<T>
```

just to reduce typing.

---

# 9. Container lifecycle rules

The container lifecycle is a domain state machine.

No caller may bypass it.

Baseline states currently documented by the roadmap:

```text
REGISTERED
AVAILABLE
ASSIGNED
IN_USE
RETURNED
DAMAGED
LOST
RETIRED
```

The exact allowed transition matrix must live in `specs/domain/container-lifecycle.md`.

Whenever a transition is changed, update:

1. state machine spec;
2. domain tests;
3. acceptance scenarios;
4. API contract if externally observable;
5. UI state handling if observable;
6. ADR only if architecture changes.

---

# 10. Error handling

## 10.1 Domain/application failures

Failures must be meaningful and stable.

Avoid using arbitrary strings such as:

```text
throw new RuntimeException("something went wrong")
```

for expected business situations.

Expected failures should be representable as specific error types/codes, for example:

```text
CONTAINER_NOT_FOUND
CONTAINER_NOT_AVAILABLE
INVALID_STATE_TRANSITION
ACTIVE_CIRCULATION_EXISTS
CIRCULATION_NOT_FOUND
RETURN_ALREADY_REGISTERED
FORBIDDEN_OPERATION
VALIDATION_ERROR
```

The final catalog belongs to the error/API spec, not to this example.

## 10.2 Unexpected failures

Unexpected failures must be logged with correlation data and mapped to a safe generic server error.

Never expose:

- stack traces;
- SQL;
- internal class names;
- secret values;
- access tokens;
- database connection details.

## 10.3 Flutter error translation

Infrastructure and transport errors are mapped into domain/application failures before reaching UI.

UI copy is presentation logic and must not determine machine-readable error semantics.

---

# 11. UI state rules

Do not represent one asynchronous process with independent booleans that permit contradictory combinations.

Bad:

```dart
isLoading = true;
isError = true;
isSuccess = true;
```

Preferred conceptual model:

```text
Initial
Loading
Success(data)
Failure(failure)
```

For multi-step screens, define an explicit state machine.

Every state must define:

- what can be rendered;
- what actions are allowed;
- what transitions are legal.

---

# 12. API rules

The backend API is contract-first.

OpenAPI is the source of truth for REST request/response behavior.

For every endpoint specify:

- method;
- path;
- authentication requirements;
- authorization;
- request schema;
- response schema;
- validation errors;
- business errors;
- conflict behavior;
- idempotency expectations;
- pagination/filter semantics when applicable;
- example success;
- example failure.

Do not create “temporary” production endpoints that are undocumented.

The implementation must not silently diverge from the approved contract.

---

# 13. HTTP semantics baseline

Use status codes intentionally.

Typical mapping:

```text
400 malformed/invalid request
401 unauthenticated
403 authenticated but unauthorized
404 resource absent
409 business/resource conflict
422 semantic validation failure, if adopted consistently
429 rate limited, if implemented
500 unexpected server failure
503 dependency/service unavailable
```

Do not force every failure into `400` or `500`.

The exact public error contract must live in the API spec.

---

# 14. Database rules

PostgreSQL is a consistency boundary, not a passive JSON bucket.

Use database constraints for invariants that are naturally relational:

- primary keys;
- foreign keys;
- uniqueness;
- non-nullability;
- check constraints where appropriate.

Do not move all business logic into triggers/stored procedures merely because PostgreSQL supports them.

Conversely, do not avoid database constraints when an invariant should be enforced against concurrent writers.

Every database rule needs a clear ownership decision:

```text
domain invariant → domain/application
relational invariant → database constraint
transport validation → API boundary
presentation validation → UI convenience only
```

Validation must not be duplicated in ways that allow layers to disagree.

---

# 15. Persistence rules

Use migrations only. Never make manual production schema edits part of the normal workflow.

A migration must be:

- deterministic;
- reviewable;
- reversible where safely possible;
- compatible with the deployment strategy.

Data deletion must be deliberate. Historical records related to circulation/audit must not disappear through casual cascade rules.

---

# 16. Identity and IDs

Identity semantics must be specified before schema/API implementation.

Never introduce UUIDs, numeric sequences or synthetic identifiers solely because they are familiar.

The chosen identifier must have an explicit reason regarding:

- domain identity;
- uniqueness;
- exposure through API;
- privacy;
- mutability;
- lookup characteristics.

External API identifiers and database primary keys may differ only when the architecture/specification justifies it.

---

# 17. Authentication and authorization

Authentication answers:

> Who are you?

Authorization answers:

> Are you allowed to perform this operation on this resource in this context?

Never use UI visibility as authorization.

Every sensitive use case must enforce authorization server-side.

Default posture:

```text
DENY unless explicitly allowed
```

Never log:

- passwords;
- access tokens;
- refresh tokens;
- secrets.

---

# 18. QR rules

QR is an identification mechanism, not authorization.

Scanning a QR must never by itself grant permission to mutate a resource.

A QR can identify a container, after which the normal authorization + business validation chain runs.

Treat all scanned values as untrusted input.

Handle:

- malformed payload;
- unknown container;
- inactive container;
- tampered value;
- replayed operation;
- wrong operation/state.

---

# 19. Idempotency and duplicate operations

For every mutating endpoint, explicitly classify it:

```text
idempotent
or
non-idempotent with deduplication strategy
```

Example risks:

- double tap on “Devolver”;
- network timeout followed by retry;
- duplicated HTTP request;
- operator repeating scan.

The user experience must not depend on “the first request probably finished”.

---

# 20. Concurrency

At minimum test:

```text
Device A attempts assign
Device B attempts assign
same container
near-simultaneously
```

The invariant must hold after both requests.

Use an explicitly selected strategy:

- database uniqueness/constraint;
- optimistic locking;
- pessimistic locking;
- atomic conditional update;
- transactional application logic;
- another approved mechanism.

Do not add locking blindly. First identify the invariant and then choose the smallest mechanism that guarantees it.

---

# 21. Testing rules

## Unit tests

Prioritize:

- state transitions;
- value objects;
- business rules;
- use-case decisions;
- error mapping.

## Integration tests

Use realistic infrastructure for:

- PostgreSQL behavior;
- transaction behavior;
- constraints;
- repository adapters;
- security configuration.

## Contract tests

Verify that client expectations match server contract.

## E2E

Cover only critical operational journeys, such as:

```text
login
scan
assign
return
inspect history
```

Never replace domain tests with E2E tests.

---

# 22. Test naming

Tests should describe behavior, not implementation.

Good:

```text
shouldRejectReturnWhenContainerHasNoActiveCirculation
```

Bad:

```text
shouldCallRepositoryMethodX
```

unless the interaction itself is the behavior being tested.

---

# 23. TDD loop

For deterministic business behavior:

```text
RED
↓
GREEN
↓
REFACTOR
```

Do not write a large implementation first and then create tests that merely reproduce it.

Tests must be able to fail for the wrong behavior.

---

# 24. BDD / acceptance scenarios

Important behaviors must be expressible as scenarios:

```text
Given ...
When ...
Then ...
```

Example:

```text
Given container C is AVAILABLE
And operator O is authorized to create circulations
When O assigns C to user U
Then C becomes IN_USE
And exactly one active circulation exists for C
And a trace event is recorded
```

The final scenario belongs to the feature spec and must include all domain-specific conditions.

---

# 25. Observability

Every request path that can mutate critical state should be traceable.

Use a correlation/trace identifier propagated across logs and responses where appropriate.

Logs must be:

- structured;
- useful for diagnosis;
- free of secrets;
- free of unnecessary personal data.

Do not log every object indiscriminately.

---

# 26. Time, dates and time zones

Use a consistent time model defined by the data spec.

Business timestamps must preserve enough information for unambiguous ordering.

Never silently mix:

- local device time;
- server time;
- database time;
- UTC.

The authoritative policy belongs in `specs/data/data-model.md` and the relevant domain specs.

---

# 27. Security review gate

Any change involving authentication, authorization, identifiers, QR, PII, database access, file storage, external integrations or deployment configuration must include a security review.

Ask:

1. What can an attacker control?
2. What privilege is required?
3. What happens if the request is replayed?
4. What happens if two requests race?
5. What data is exposed?
6. What happens on failure?
7. Can the client bypass the UI and call the API directly?

---

# 28. AI-agent rules

AI agents are implementation assistants, not product owners.

An agent must:

- read the relevant specs before coding;
- prefer existing abstractions when they are correct;
- avoid broad refactors unless requested/spec-authorized;
- state uncertainty when a material rule is missing;
- keep changes traceable;
- run relevant tests/checks;
- update docs when behavior/architecture changes.

An agent must not:

- invent product behavior;
- silently change API contracts;
- delete tests to make a suite pass;
- weaken authorization to make a feature work;
- swallow exceptions;
- use `catch` blocks as business logic dumpsters;
- bypass domain rules from controllers/UI;
- introduce dependencies without justification;
- claim verification that was not actually performed.

---

# 29. When requirements change

Do not patch code first.

Correct sequence:

```text
requirement change
↓
update affected spec
↓
identify impacted contracts/tests/ADR
↓
update acceptance criteria
↓
implement delta
↓
verify regression
```

Code changes made without updating the governing spec are incomplete work.

---

# 30. Definition of done for code changes

Before declaring a change complete, verify:

- [ ] applicable spec exists and is current;
- [ ] non-goals were respected;
- [ ] domain rules have a single owner;
- [ ] state transitions are explicit;
- [ ] errors are intentional and typed/mapped;
- [ ] authorization is enforced server-side;
- [ ] concurrency implications were considered;
- [ ] API contract is current;
- [ ] tests were added/updated;
- [ ] relevant tests pass;
- [ ] no secrets are introduced;
- [ ] logs do not leak sensitive data;
- [ ] database changes use migrations;
- [ ] affected docs/specs are updated;
- [ ] diff contains no unrelated cleanup;
- [ ] the agent has not relied on an unverified assumption.

---

# 31. Review questions

Every substantive PR/code review should answer:

### Product
- Does this implement exactly what the spec says?
- Did implementation add behavior not requested?

### Domain
- Is the invariant in the correct bounded context?
- Can an impossible state still be created?

### API
- Is the contract explicit?
- Are failure responses predictable?

### Persistence
- Can concurrent requests violate an invariant?
- Is destructive behavior possible?

### Security
- Can an unauthorized client bypass the UI?
- Are identifiers and inputs treated as untrusted?

### Quality
- Do tests prove behavior rather than implementation details?
- Could this change be smaller without reducing correctness?

---

# 32. Forbidden shortcuts

Never merge code that solves a core feature using:

```text
TODO: implement properly later
mock data in production path
hard-coded user IDs
hard-coded container IDs
random status changes
client-authoritative business dates
UI-only authorization
silent exception swallowing
unversioned schema changes
undocumented endpoints
```

Temporary code is allowed only when explicitly isolated behind a spec/flag and tracked with a removal condition.

---

# 33. Repository conventions

Recommended repository structure:

```text
.
├── AGENTS.md
├── ROADMAP.md
├── specs/
├── docs/
│   └── adr/
├── apps/
│   └── revuelta-mobile/
└── services/
    └── revuelta-api/
```

The exact Flutter package/module and Spring package names must be decided in the architecture skeleton spec, not invented independently by different contributors.

---

# 34. Completion philosophy

A feature is not “done” because:

- it compiles;
- the happy path works;
- Postman returns 200;
- the UI looks correct;
- an AI agent says it is finished.

A feature is done only when its **specified behavior, failure behavior, state invariants, security properties and verification evidence** are aligned.

That is the standard for ReVuelta.

---

# References

[1] Microsoft, “Spec-Driven Development: A Spec-First Approach to AI-Native Engineering”, 2026. https://developer.microsoft.com/blog/spec-driven-development-ai-native-engineering/

[2] SpecDD, “Spec-Driven Development framework”, 2026. https://github.com/specdd/specdd

[3] AWS Prescriptive Guidance, “Hexagonal architectures / Domain-driven design”. https://docs.aws.amazon.com/prescriptive-guidance/latest/hexagonal-architectures/overview.html

[4] Specmatic, “Contract Driven Development”. https://docs.specmatic.io/contract_driven_development
