# Feature Spec — Scan and Resolve Container

**Status:** DRAFT.

## Purpose

Resolve an untrusted QR payload into a known ReVuelta container so a subsequent authorized operation can proceed.

## Rules

- QR is identification, not authorization.
- malformed payloads fail before business mutation;
- unknown identifiers produce a stable not-found outcome;
- inactive containers are distinguishable from unknown containers where policy permits;
- no mutation occurs during pure resolution.

## Acceptance

- valid QR resolves one container;
- invalid QR resolves none;
- unknown QR resolves none;
- scan failure does not change business state.
