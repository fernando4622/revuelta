# ReVuelta Test Strategy

**Status:** APPROVED BASELINE.

## 1. Test objective

Tests are evidence that specified behavior is implemented correctly. Coverage percentage alone is not a quality criterion.

## 2. Unit tests

Primary targets:

- lifecycle transition rules;
- value objects;
- due-date calculation;
- punctuality classification;
- authorization decisions when pure;
- error classification;
- use-case decisions.

## 3. Integration tests

Must cover:

- PostgreSQL constraints;
- repository adapters;
- real transaction behavior;
- security configuration;
- concurrent invariant protection;
- migrations against a realistic database.

## 4. Contract tests

The Flutter client and backend MUST be tested against the approved API contract.

## 5. Acceptance/BDD

Critical journeys use Given/When/Then scenarios from feature specs.

## 6. E2E

Only critical journeys:

```text
login
→ scan dynamic participant operation QR
→ scan container
→ inspect
→ deliver additional containers to the same participant
→ cafeteria return
→ complete washing
→ inspect history
```

Do not use E2E tests as a substitute for domain tests.

## 7. TDD requirement

For deterministic business rules, implementation follows:

```text
RED → GREEN → REFACTOR
```

Tests must fail for incorrect behavior; they must not merely reproduce existing implementation.

## 8. Concurrency test suite

At minimum:

- two simultaneous delivery attempts for one container;
- two simultaneous return attempts;
- two simultaneous wash-completion attempts;
- delivery of two different containers to one participant;
- retry after client timeout;
- duplicate submission with same idempotency key when adopted.

## 9. Definition of evidence

A feature is not verified until relevant tests have been executed and their result is known. An agent MUST NOT claim tests passed unless actually run.
