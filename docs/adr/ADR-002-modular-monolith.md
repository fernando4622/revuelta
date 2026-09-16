# ADR-002 — Modular Monolith for V1

**Status:** ACCEPTED BASELINE

## Context

The first operational deployment is a bounded university pilot. Distributed deployment introduces failure modes and operational cost that are not justified by current scale or requirements.

## Decision

Deploy the backend as a modular monolith with clearly separated bounded contexts/modules.

Initial logical contexts:

- Identity & Access;
- Container Management;
- Circulation;
- Audit/Traceability;
- Reporting/Read models.

## Consequences

- single deployable backend;
- simpler transactions;
- strong module boundaries remain possible;
- future extraction is possible only when a real requirement and ADR justify it.

## Rejected for V1

- microservices per bounded context;
- Kafka/event streaming as core transaction mechanism;
- service mesh;
- distributed transactions.
