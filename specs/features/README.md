# Feature Specification Template

Each material feature gets its own directory:

```text
specs/features/<feature>/
├── requirements.md
├── scenarios.md
├── api.md            # only if external API changes
├── ui.md             # only if mobile behavior changes
├── plan.md
└── validation.md
```

## Requirements template

```markdown
# Feature: <name>

Status: DRAFT

## Purpose

## In scope

## Out of scope

## Actors

## Preconditions

## Inputs

## Outputs

## Domain rules

## State changes

## Authorization

## Failure catalog

## Persistence impact

## Idempotency/concurrency

## Dependencies

## Acceptance criteria
```

## Workflow

```text
requirements
→ review ambiguity
→ domain/spec update
→ scenarios
→ API/UI contract
→ plan
→ tests
→ implementation
→ validation
→ status update
```
