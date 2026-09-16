# Deployment and Operational Specification

**Status:** DRAFT.

## 1. Runtime shape

V1 is a modular monolith backend with PostgreSQL and a Flutter mobile client. No microservice deployment is required.

## 2. Environments

At minimum:

```text
local
staging/test
pilot/production
```

Environment-specific secrets MUST NOT be committed.

## 3. Database migration gate

Application deployment MUST NOT depend on undocumented manual schema edits.

## 4. Backup

Pilot production MUST have a documented database backup strategy and restore procedure before launch.

## 5. Rollback

A pilot deployment MUST have a rollback plan that identifies:

- application rollback mechanism;
- migration compatibility strategy;
- data integrity risk;
- operator communication procedure.

## 6. Seed/admin procedure

The pilot MUST have a repeatable procedure to establish initial authorized users, roles, return policy, and initial container records.

Exact seed data is operational configuration, not domain code.
