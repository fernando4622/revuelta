# Return Sequence

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
Active circulation lookup
  │
  ▼
Authorization + return eligibility
  │
  ▼
Server time
  │
  ▼
Classify ON_TIME/LATE
  │
  ▼
Finalize circulation + transition container + trace event
  │
  ▼
Atomic commit
  │
  ▼
Response
```
