# Observability Specification

**Status:** APPROVED BASELINE.

## 1. Correlation

Every request path that can mutate critical business state SHOULD carry a trace/correlation identifier. The identifier should be returned where useful for support/debugging.

## 2. Structured logs

Logs MUST be structured and SHOULD include:

- timestamp;
- severity;
- service/component;
- operation/use-case name;
- correlation/trace ID;
- actor identifier only when necessary and safe;
- resource identifier only when necessary and safe;
- outcome/error code.

## 3. Prohibited logging

Never log:

- passwords;
- access/refresh tokens;
- secret material;
- full sensitive personal records;
- raw credential payloads.

## 4. Health

Backend MUST expose liveness/readiness semantics appropriate to deployment.

Health endpoints MUST not expose secrets or detailed infrastructure credentials.

## 5. Metrics

Minimum useful metrics:

- request counts by outcome;
- mutation failure counts by stable error code;
- delivery count;
- return count;
- late return count;
- active circulation count;
- authentication failure count;
- API latency for critical operations.

Metrics MUST NOT be treated as the business source of truth; they are operational observations.
