# Revisión de seguridad F8

**Fecha:** 2026-09-26

**Alcance:** autenticación JWT MVP, API REST, QR, identificadores, PII mínima, PostgreSQL, observabilidad y cliente Flutter.

**Resultado:** sin hallazgos P0/P1 abiertos dentro del alcance demostrable aprobado; el piloto real continúa en `NO-GO` hasta F9 y las decisiones productivas pendientes.

## 1. Superficies controladas por un atacante

- cabeceras HTTP, origen CORS, cuerpo JSON, parámetros, UUID y paginación;
- bearer token completo y sus claims/header;
- payloads QR alterados, caducados, revocados o repetidos;
- orden, repetición y simultaneidad de peticiones;
- pérdida de conexión después de enviar una mutación;
- llamadas directas al API sin pasar por la interfaz móvil.

## 2. Controles verificados

| Riesgo | Control | Evidencia |
|---|---|---|
| Token fuera de contexto o firma rotada | valida firma, `kid`, `iss`, `aud`, UUID `sub`, rol conocido, username, `iat`, `exp` y skew máximo de 30 s; anillo activo/anterior | `JwtTokenProviderTest`, integración HTTP |
| Bypass de interfaz/rol | denegación por defecto y autorización de servidor en cada endpoint sensible; Prometheus solo `ADMIN` | `SecurityErrorContractIntegrationTest` |
| QR manipulado o replay | HMAC/versionado, propósito/expiración, generación vigente y consumo transaccional | suites QR, entrega y devolución existentes |
| Entrada excesiva/malformada | límites de campo, query, paginación, cabecera y cuerpo JSON de 16 KiB; `400/413` estable sin eco | integración HTTP y OpenAPI |
| Carrera o doble envío | invariantes PostgreSQL, bloqueo/transacción y conflictos estables; sin retry automático móvil | suites PostgreSQL de F5/F6 y controladores móviles |
| Fuga en logs/métricas | logs JSON con etiquetas acotadas; sin body, bearer, JWT, QR ni identificadores como etiquetas métricas | `OperationalTelemetryTest`, inspección de código/configuración |
| Dependencia caída | pool acotado, timeout, `503` seguro, liveness/readiness separadas | integración y ensayo Docker F8 |
| Exposición web | orígenes negados por defecto, allowlist local dev, sin credenciales CORS, métodos/cabeceras acotados y cabeceras defensivas | integración CORS/cabeceras |

## 3. Hallazgos y resolución

- **P1 — contexto JWT incompleto:** resuelto incorporando issuer, audience, claims obligatorios y `kid` con rotación solapada.
- **P1 — telemetría/probes sin control suficiente:** resuelto con health mínimo público y métricas restringidas a `ADMIN`.
- **P1 — respuesta incierta de lavado:** resuelto refrescando el estado y prohibiendo reenvío automático.
- **P2 — límites HTTP implícitos:** resuelto con límites explícitos y error `REQUEST_TOO_LARGE`.
- **P2 — diagnóstico de dependencia:** resuelto con `503 DEPENDENCY_UNAVAILABLE`, métricas, logs estructurados y runbook.

No se debilitó autorización, firma QR, historia append-oriented ni control de concurrencia.

## 4. Riesgos residuales aceptados/diferidos

- Las cuentas `student1`, `operator` y `admin`, contraseñas y secretos conocidos existen solo en el perfil `dev`; este perfil no es una configuración productiva.
- El acceso local por HTTP es para desarrollo/hotspot. El piloto real requiere terminación TLS/HSTS efectiva.
- No hay revocación anticipada por usuario, refresh token, recuperación ni aprovisionamiento institucional; siguen bloqueados por D-007 y fuera del alcance F8.
- Incidencias, daño/pérdida/retiro siguen diferidos por D-004.
- Respaldo, restauración, rollback, staging equivalente y aceptación de campo corresponden a F9.
- CORS no protege clientes nativos ni sustituye autenticación/autorización; un atacante puede llamar directamente al API y recibe los mismos controles de servidor.

## 5. Decisión

Las suites completas, lint OpenAPI, análisis Flutter, revisión de dependencias y ensayo de reinicio/recuperación quedaron verdes. F8 se cierra sin hallazgos P0/P1 abiertos en su alcance. Esta revisión no concede `GO` de piloto: F9 mantiene la decisión de liberación.
