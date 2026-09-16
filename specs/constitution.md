# ReVuelta Product Constitution

**Status:** APPROVED BASELINE, subject to explicit decisions listed in `product.md` and domain specs.

## 1. Product identity

ReVuelta is an operational system for controlling reusable food containers through individual identification, QR interaction, circulation/loan management, returns, lifecycle state transitions, and traceability.

## 2. Product objective

V1 exists to make the operational lifecycle of a reusable container observable and auditable in a bounded university cafeteria pilot.

The system MUST let an authorized operator determine:

1. which containers exist;
2. which unique identifier belongs to a container;
3. current operational state;
4. current holder when a circulation is active;
5. delivery time;
6. due date;
7. return status;
8. lifecycle history;
9. anomalies and overdue returns requiring attention.

## 3. Operating principles

### 3.1 Domain first
Business semantics are defined independently of frameworks and transport mechanisms.

### 3.2 Explicit state
Business state is changed only by explicit domain/application operations.

### 3.3 Immutable history
Historical facts are append-oriented. Corrections are new facts/operations, never silent rewrites.

### 3.4 Server authority
The server/database is authoritative for business time and persisted business state.

### 3.5 Secure by default
Authentication and authorization are enforced server-side. UI visibility is not a security boundary.

### 3.6 Concurrency is a requirement
Any invariant involving a resource that can be touched by two devices must remain true under concurrent requests.

### 3.7 AI is not product authority
AI agents may accelerate implementation but MUST NOT decide unresolved product semantics.

## 4. Product boundaries

### In scope for V1

- authenticated access;
- role-based authorization;
- individual container registry;
- QR-based identification;
- container lifecycle state;
- container assignment/delivery;
- active circulation tracking;
- return registration;
- due-date policy;
- overdue/late classification;
- traceability/audit;
- operational error handling;
- basic observability.

### Out of scope for V1

- payment processing;
- wallet/balance/automatic charging;
- advertising;
- marketplace;
- multi-campus production support;
- ERP/SIS integration;
- NFC/RFID/Bluetooth/IoT;
- generative AI in the critical transaction path;
- microservice decomposition;
- Kubernetes;
- distributed event streaming;
- complex gamification/reward economy.

## 5. Pilot boundary

V1 is a single bounded university/cafeteria pilot. It is not a generalized multi-tenant SaaS product.

The return window MUST be configurable and MUST support an operational range of 1–3 days. The exact pilot value is a product decision and cannot be hard-coded until approved.

## 6. Non-goals of the constitution

This document does not define implementation details such as exact Spring package names, exact Flutter state-management library, database vendor beyond the approved PostgreSQL target, or exact authentication provider. Those are architectural decisions governed elsewhere.
