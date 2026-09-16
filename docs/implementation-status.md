# ReVuelta — Implementation Status

> **Última actualización:** 2026-09-15
> **Estado general:** Pre-implementación. El repositorio contiene únicamente documentación gobernante. No existe código de aplicación.

---

## 1. Estado actual del repositorio

### Estructura existente

```text
.
├── AGENTS.md                    ✅ Aprobado
├── ROADMAP.md                   ✅ Aprobado
├── SPEC-PACKAGE.md              ✅ Informativo
├── Inicio.md                    ✅ Instrucciones de arranque
├── docs/
│   ├── adr/
│   │   ├── ADR-001-clean-architecture.md       ✅ ACCEPTED BASELINE
│   │   ├── ADR-002-modular-monolith.md         ✅ ACCEPTED BASELINE
│   │   ├── ADR-003-state-machine.md            ✅ ACCEPTED BASELINE
│   │   ├── ADR-004-api-contract-first.md       ✅ ACCEPTED BASELINE
│   │   ├── ADR-005-time-and-concurrency.md     ✅ ACCEPTED BASELINE
│   │   └── ADR-006-testing-strategy.md         ✅ ACCEPTED BASELINE
│   └── diagrams/
│       ├── context.md                          ✅ Diagrama de contexto
│       ├── delivery-flow.md                    ✅ Flujo de entrega
│       └── return-flow.md                      ✅ Flujo de devolución
└── specs/
    ├── constitution.md                         ✅ APPROVED BASELINE
    ├── product.md                              🔴 BLOCKED
    ├── decision-register.md                    ⚠️ 10/13 decisiones sin resolver
    ├── definition-of-done.md                   ✅ APPROVED BASELINE
    ├── definition-of-ready.md                  ✅ APPROVED BASELINE
    ├── traceability.md                         🔴 BLOCKED
    ├── domain/
    │   ├── container-lifecycle.md              🔴 BLOCKED (D-004, D-005, D-006)
    │   └── circulation.md                      🔴 BLOCKED (D-002, D-003, D-010)
    ├── data/
    │   └── data-model.md                       🔴 BLOCKED (D-008, D-009, D-013)
    ├── security/
    │   └── access-control.md                   🔴 BLOCKED (D-001, D-007)
    ├── api/
    │   ├── openapi-baseline.md                 🔴 BLOCKED (D-002, D-007, D-010)
    │   └── errors.md                           ✅ APPROVED BASELINE
    ├── features/
    │   ├── authentication/requirements.md      🔴 BLOCKED (D-007)
    │   ├── deliver-container/requirements.md   🔴 BLOCKED (D-001..D-013)
    │   ├── deliver-container/scenarios.md      ✅ BDD scenarios definidos
    │   ├── return-container/requirements.md    🔴 BLOCKED (D-001..D-010)
    │   ├── return-container/scenarios.md       ✅ BDD scenarios definidos
    │   └── scan-container/requirements.md      ⚠️ DRAFT
    ├── testing/
    │   └── test-strategy.md                    ✅ APPROVED BASELINE
    ├── ops/
    │   ├── deployment.md                       ⚠️ DRAFT
    │   └── observability.md                    ✅ APPROVED BASELINE
    ├── risks/
    │   └── threat-model.md                     ✅ APPROVED BASELINE
    └── ui/
        ├── mobile.md                           🔴 BLOCKED (D-001, D-011)
        └── state-machines.md                   ✅ Baseline definido
```

### Código existente

**No existe ningún código de aplicación.** No hay:

- proyecto Spring Boot (`services/revuelta-api/`);
- proyecto Flutter (`apps/revuelta-mobile/`);
- migraciones de base de datos;
- configuración de entorno;
- tests;
- OpenAPI YAML/JSON.

El repositorio está en **Fase 0** del ROADMAP (constitución y especificación base). Los entregables de Fase 0 están sustancialmente completos en documentación, pero 10 decisiones críticas permanecen sin resolver.

---

## 2. Especificaciones utilizadas para este análisis

| Especificación | Estado | Relevancia MVP |
|---|---|---|
| `AGENTS.md` | Aprobado | Reglas de implementación |
| `ROADMAP.md` | Aprobado | Fases, arquitectura, principios |
| `specs/constitution.md` | Approved Baseline | Alcance, principios, exclusiones |
| `specs/product.md` | Blocked | Actores, journeys, requisitos funcionales |
| `specs/domain/container-lifecycle.md` | Blocked | Máquina de estados del envase |
| `specs/domain/circulation.md` | Blocked | Préstamo/devolución, invariantes |
| `specs/data/data-model.md` | Blocked | Modelo relacional, concurrencia |
| `specs/security/access-control.md` | Blocked | Autenticación, autorización |
| `specs/api/openapi-baseline.md` | Blocked | Contrato REST |
| `specs/api/errors.md` | Approved Baseline | Taxonomía de errores |
| `specs/features/*/` | Blocked/Draft | Requisitos y escenarios por feature |
| `specs/testing/test-strategy.md` | Approved Baseline | Estrategia de testing |
| `specs/risks/threat-model.md` | Approved Baseline | Modelo de amenazas |
| `specs/ui/mobile.md` | Blocked | Pantallas, flujo Flutter |
| `specs/ui/state-machines.md` | Baseline | Máquinas de estado UI |
| `specs/ops/observability.md` | Approved Baseline | Logging, métricas |
| ADR-001 a ADR-006 | Accepted Baseline | Decisiones arquitectónicas |

---

## 3. Features implementadas

**Ninguna.** El repositorio no contiene código ejecutable.

---

## 4. Features restantes para MVP

Ordenadas por dependencia y prioridad operativa:

| # | Feature | Specs relacionadas | Decisiones bloqueantes |
|---|---|---|---|
| 1 | Skeleton arquitectónico backend | ADR-001, ADR-002 | Ninguna |
| 2 | Skeleton arquitectónico Flutter | ADR-001, ui/mobile.md | D-011 |
| 3 | Base de datos + migraciones iniciales | data/data-model.md | D-008, D-009, D-013 |
| 4 | Dominio: Container entity + state machine | container-lifecycle.md | D-005, D-006 |
| 5 | Dominio: Circulation entity | circulation.md | D-002 |
| 6 | Autenticación | authentication/requirements.md, access-control.md | D-007 |
| 7 | Autorización (roles/permisos) | access-control.md | D-001 |
| 8 | Container registry (alta, consulta) | product.md FR-010..FR-013 | D-008 |
| 9 | QR scan + resolución | scan-container/requirements.md | — |
| 10 | Entrega (crear circulación) | deliver-container/requirements.md | D-001..D-013 |
| 11 | Devolución | return-container/requirements.md | D-001..D-010 |
| 12 | Historial/trazabilidad | traceability.md, FR-050..FR-052 | — |
| 13 | Error handling uniforme | errors.md | — |
| 14 | Observabilidad básica | observability.md | — |
| 15 | Flutter: Login | ui/mobile.md | D-007, D-011 |
| 16 | Flutter: Scan + Inspect | ui/mobile.md, state-machines.md | D-011 |
| 17 | Flutter: Delivery flow | ui/mobile.md | D-011 |
| 18 | Flutter: Return flow | ui/mobile.md | D-011 |
| 19 | Flutter: History view | ui/mobile.md | D-011 |
| 20 | E2E journey completo | test-strategy.md | Todas anteriores |

---

## 5. Ambigüedades bloqueantes

Las siguientes decisiones del `specs/decision-register.md` están sin resolver y bloquean implementación:

### Críticas para el primer vertical slice

| ID | Decisión | Impacto |
|---|---|---|
| **D-005** | ¿`ASSIGNED` es materialmente diferente de `IN_USE`? | Define la máquina de estados. Sin esto no se puede implementar el dominio del envase. |
| **D-006** | ¿`RETURNED` es estado persistente o transitorio? | Define si el envase pasa por inspección/lavado antes de volver a `AVAILABLE`. |
| **D-002** | Modelo de identidad del prestatario | Define si el receptor es un usuario autenticado, un ID institucional, o una referencia libre. |
| **D-007** | Mecanismo de autenticación | JWT vs sesión. Define toda la infraestructura de seguridad. |
| **D-008** | Estrategia de identificadores (PKs) | UUIDv4, UUIDv7, secuencial, natural. Afecta toda la persistencia y API. |
| **D-009** | Representación de tiempo/zona horaria | UTC instants vs offsets. Afecta toda comparación temporal. |
| **D-013** | Mecanismo de concurrencia en BD | Partial unique index vs locks. Afecta integridad de circulaciones. |

### Importantes pero no bloqueantes para el skeleton

| ID | Decisión | Impacto |
|---|---|---|
| **D-001** | Matriz de roles/permisos | Necesaria antes de implementar autorización. |
| **D-003** | Ventana de devolución del piloto (1-3 días) | Necesaria antes de configurar el piloto, no para la arquitectura. |
| **D-004** | Permisos de estados excepcionales | Necesaria para DAMAGED/LOST/RETIRED, no para el happy path. |
| **D-010** | Mecanismo de idempotencia API | Necesaria antes de endpoints mutativos en producción. |
| **D-011** | Librería de state management Flutter | Necesaria antes de escribir código Flutter. |

---

## 6. Supuestos adoptados

Ver `/docs/decision-log.md` para la documentación completa de cada decisión temporal. Resumen:

1. **D-005/D-006:** Se unifica `ASSIGNED`/`IN_USE` en `IN_USE` y `RETURNED` se trata como transitorio (auto-transición a `AVAILABLE`). Razón: el piloto no requiere confirmación de entrega física separada ni cola de lavado/inspección.
2. **D-002:** El prestatario se modela como string de referencia institucional (ej. matrícula) capturada por el operador, sin requerir cuenta de usuario en ReVuelta. Razón: simplifica el MVP; los prestatarios no usan la app.
3. **D-007:** JWT stateless con Spring Security. Razón: estándar para REST APIs móviles, sin necesidad de almacenar sesiones.
4. **D-008:** UUIDs (v4) para todas las entidades. PKs internas = IDs de API. Razón: evita enumeración, simple, sin ambigüedad.
5. **D-009:** Timestamps UTC (Instant) en BD y API. Zona horaria del negocio configurable para interpretación de políticas. Razón: recomendación explícita del spec de datos.
6. **D-013:** Partial unique index en PostgreSQL (`container_id WHERE status = 'ACTIVE'`) para garantizar una circulación activa por envase. Razón: mínimo mecanismo, probado bajo concurrencia.
7. **D-001:** Dos roles: `OPERATOR` (entrega/devolución/consulta) y `ADMIN` (todo lo anterior + gestión de envases, usuarios, políticas). Razón: mínimo viable para el piloto.
8. **D-003:** Ventana de devolución por defecto: 2 días. Configurable. Razón: punto medio del rango 1-3 días.
9. **D-010:** Idempotencia por unique constraint en BD + respuesta determinista en duplicado. Sin header `Idempotency-Key` en V1. Razón: simplicidad; la BD garantiza el invariante.
10. **D-011:** Riverpod como state management Flutter. Razón: type-safe, testable, sin boilerplate excesivo.

---

## 7. Riesgos técnicos

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Las decisiones temporales (§6) difieren de lo que el producto quiere | Alta | Medio | Todas documentadas en decision-log.md con flag de revisión |
| Deadline de 1 semana es agresivo para backend + Flutter + testing | Alta | Alto | Vertical slices, priorizar backend funcional sobre UI pulida |
| Sin entorno de hosting definido | Media | Alto | Desarrollar con Docker Compose local; deployment spec es DRAFT |
| QR payload format no especificado | Media | Bajo | Definir formato simple (UUID del container en texto plano) |
| Modelo de prestatario como string libre pierde trazabilidad | Media | Medio | Suficiente para piloto; campo validado, no nulo |
| Sin decisión final sobre D-004 (DAMAGED/LOST) | Baja | Bajo | No es parte del happy path MVP; se difiere |

---

## 8. Orden de implementación recomendado

### Día 1: Foundation
1. ✅ Inspección del repositorio y generación de `implementation-status.md` y `decision-log.md`
2. Backend skeleton: proyecto Spring Boot con estructura Clean Architecture
3. Flutter skeleton: proyecto con estructura Clean Architecture + Riverpod
4. Docker Compose para PostgreSQL de desarrollo

### Día 2: Domain + Persistence
5. Dominio: `Container` entity, value objects, state machine (estados simplificados)
6. Dominio: `Circulation` entity, invariantes
7. Dominio: `ContainerEvent` para trazabilidad
8. Migraciones iniciales PostgreSQL
9. Tests unitarios de dominio (transiciones, invariantes)

### Día 3: Authentication + Container Registry
10. Spring Security + JWT (login, token validation)
11. Modelo User/Role en dominio + persistencia
12. Endpoints de autenticación (login)
13. Container registry: alta, consulta, listado
14. Tests de integración (persistencia, auth)

### Día 4: Circulation — Delivery
15. Use case: crear circulación (entrega)
16. Return policy entity + configuración
17. Endpoint `POST /api/v1/circulations`
18. Endpoint `GET /api/v1/containers/{id}`
19. Tests: dominio, integración, concurrencia
20. Contrato OpenAPI para endpoints implementados

### Día 5: Circulation — Return + History
21. Use case: registrar devolución
22. Clasificación de puntualidad (ON_TIME/LATE)
23. Endpoint `POST /api/v1/circulations/{id}/return`
24. Endpoint `GET /api/v1/containers/{id}/history`
25. Tests: dominio, integración, concurrencia, duplicados

### Día 6: Flutter Critical Flows
26. Pantalla de login
27. Scanner QR + resolución
28. Pantalla de detalle de envase
29. Flujo de entrega
30. Flujo de devolución
31. Vista de historial

### Día 7: Integration, E2E, Polish
32. Integration tests completos
33. E2E journey: login → scan → inspect → deliver → return → history
34. Error handling uniforme
35. Observabilidad básica (correlation ID, structured logging, health)
36. Documentación final: actualizar specs, implementation-status, decision-log
37. Verificación final contra specs

---

## 9. Estado de las fases del ROADMAP

| Fase | Estado | Notas |
|---|---|---|
| Fase 0 — Constitución | ✅ ~Completa | Docs existentes; decisiones pendientes resueltas temporalmente |
| Fase 1 — Skeleton | 🔜 Siguiente | Backend + Flutter + Docker |
| Fase 2 — Identity & Access | 🔜 Día 3 | JWT + roles |
| Fase 3 — Container Registry | 🔜 Día 3 | CRUD básico |
| Fase 4 — Circulation: Entrega | 🔜 Día 4 | Primer vertical completo |
| Fase 5 — Circulation: Devolución | 🔜 Día 5 | Segundo vertical |
| Fase 6 — Operación móvil | 🔜 Día 6 | Flutter flows |
| Fase 7 — Observabilidad | 🔜 Día 7 | Básica para MVP |
| Fase 8 — Hardening | ⏳ Post-MVP | Seguridad avanzada, performance |
| Fase 9 — Pilot release | ⏳ Post-MVP | Deployment, seed, rollback |
