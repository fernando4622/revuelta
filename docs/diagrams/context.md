# System Context Diagram

```text
                 ┌──────────────────────┐
                 │   Operator/Admin     │
                 └──────────┬───────────┘
                            │
                            ▼
                 ┌──────────────────────┐
                 │  ReVuelta Mobile     │
                 │      Flutter         │
                 └──────────┬───────────┘
                            │ HTTPS/JSON
                            ▼
                 ┌──────────────────────┐
                 │   ReVuelta API       │
                 │ Spring Boot modular  │
                 │      monolith        │
                 └──────────┬───────────┘
                            │
                            ▼
                 ┌──────────────────────┐
                 │      PostgreSQL      │
                 └──────────────────────┘

QR scanner is a device capability used by the mobile app to obtain an untrusted identifier.
```
