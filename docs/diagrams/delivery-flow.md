# Delivery Sequence

```text
Mobile
  │ scan
  ▼
QR resolution
  │
  ▼
Container lookup
  │
  ▼
Authorization
  │
  ▼
Domain eligibility
  │
  ▼
Return-policy resolution
  │
  ▼
Create circulation + transition container + trace event
  │
  ▼
Atomic commit
  │
  ▼
Response
```

Any failure before commit MUST leave no partial business mutation.
