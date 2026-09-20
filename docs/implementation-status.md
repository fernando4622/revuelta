# ReVuelta — Implementation Status

> **Última actualización:** 2026-09-20
> **Estado general:** PROTOTIPO PARCIAL. Existe implementación backend/Flutter, pero no está verificada como MVP completo ni alineada todavía con todas las especificaciones.
>
> **Nota de auditoría:** las afirmaciones históricas de “completado” incluidas más abajo deben interpretarse junto con la revisión de UI de la sección 10 y el estado `NO-GO` de `ROADMAP.md`.

---

## 1. Estado actual del repositorio

### Estructura existente

```text
.
├── AGENTS.md                    ✅ Aprobado
├── ROADMAP.md                   ✅ Aprobado
├── SPEC-PACKAGE.md              ✅ Informativo
├── Inicio.md                    ✅ Instrucciones de arranque
├── docker-compose.yml           ✅ Implementado (PostgreSQL 16)
├── docs/
│   ├── decision-log.md          ✅ DL-001 a DL-013 resueltos
│   ├── implementation-status.md ✅ COMPLETADO
│   ├── adr/                     ✅ ADR-001 a ADR-006 ACCEPTED
│   └── diagrams/                ✅ Diagramas de secuencia y contexto
├── services/revuelta-api/       ✅ Backend Spring Boot 4.1.1 (Clean Arch + DDD parcial)
│   ├── pom.xml + Maven Wrapper  ✅ Build canónico con JDK 17
│   ├── src/main/java/com/revuelta/api/
│   │   ├── domain/              ✅ Container, Circulation, User, ReturnPolicy, ContainerEvent
│   │   ├── application/         ✅ UseCases (Login, Deliver, Return, Container CRUD, History)
│   │   ├── infrastructure/      ✅ JPA Entities, Repositories, Security (JWT 4h), Web Exception Handler
│   │   └── interfaces/rest/     ✅ AuthController, ContainerController, CirculationController
│   ├── src/main/resources/
│   │   ├── db/migration/        ✅ V1–V7 comunes; semillas demo aisladas en `db/dev`
│   │   └── openapi.yaml         ✅ OpenAPI 3.0 specification contract
│   └── src/test/java/           ✅ 34 pruebas de dominio, aplicación, migración, seguridad, adaptación y arquitectura
└── apps/revuelta-mobile/        ✅ App Flutter (Clean Arch + Riverpod AsyncNotifier)
    ├── pubspec.yaml             ✅ Dependencias (riverpod, dio, secure_storage, mobile_scanner)
    └── lib/
        ├── domain/              ✅ Failure sealed hierarchy, UserSession
        ├── data/                ✅ ApiClient con JWT interceptor
        ├── application/         ✅ AuthNotifier (Riverpod AsyncNotifier)
        └── presentation/        ✅ LoginPage, HomePage, ScanPage, DeliveryPage, ReturnPage
```

### Código existente

El repositorio tiene una base ejecutable y verificable, pero los flujos MVP restantes aún no están completos:

- Proyecto Spring Boot 4.1.1 (`services/revuelta-api/`) con límites de dominio y dirección `application → infrastructure/interfaces` protegidos por ArchUnit; F2 aún debe revisar los acoplamientos de framework restantes en aplicación.
- Cliente móvil Flutter (`apps/revuelta-mobile/`) con arquitectura limpia y Riverpod AsyncNotifier.
- Migraciones Flyway comunes (`V1` a `V7`) y semillas repetibles exclusivas del perfil `dev`.
- Docker Compose configurado con PostgreSQL 16.
- Contrato OpenAPI 3.0 (`openapi.yaml`).
- Suite de 34 pruebas, incluidas migraciones sobre PostgreSQL 16, seguridad HTTP y límites de dependencia de dominio y aplicación.


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
| `specs/ui/mobile.md` | Partially approved | Índice, reglas globales y navegación por rol autenticado |
| `specs/ui/state-machines.md` | Approved baseline | Máquinas de estado UI |
| `specs/ui/reference-mockups.md` | Visual baseline | Interpretación de imágenes y sistema visual |
| `specs/ui/perspectives.md` | Approved for MVP | Responsabilidades y navegación por rol autenticado |
| `specs/ui/student-experience.md` | Draft | Pantallas del alumno basadas en los mockups |
| `specs/ui/cafeteria-experience.md` | Draft | Herramienta operativa de cafetería |
| `specs/ui/revuelta-operations-experience.md` | Draft | Administración del piloto ITVer |
| `specs/ops/observability.md` | Approved Baseline | Logging, métricas |
| ADR-001 a ADR-006 | Accepted Baseline | Decisiones arquitectónicas |

---

## 3. Features implementadas

Existe código ejecutable backend y Flutter. La autenticación de desarrollo y el enrutamiento móvil por rol ya tienen verificación ejecutable contra sus specs. La implementación todavía no modela Código ReVuelta persistente ni `RETURNED/Pendiente de lavado`.

---

## 4. Features restantes para MVP

Ordenadas por dependencia y prioridad operativa:

| # | Feature | Specs relacionadas | Decisiones bloqueantes |
|---|---|---|---|
| 1 | Skeleton arquitectónico backend | ADR-001, ADR-002 | Ninguna |
| 2 | Skeleton arquitectónico Flutter | ADR-001, ui/mobile.md | D-011 |
| 3 | Base de datos + migraciones iniciales | data/data-model.md | D-008, D-009, D-013 |
| 4 | Dominio: Container entity + state machine | container-lifecycle.md | D-005 |
| 5 | Dominio: Participant + Participant Code | participant.md, identify-participant/* | D-008, D-018 para recuperación |
| 6 | Dominio: Circulation entity | circulation.md | D-008, D-009, D-013 |
| 7 | Autenticación MVP/demo | authentication/requirements.md, access-control.md | Aprobada; falta hardening productivo |
| 8 | Autorización (roles/permisos) | access-control.md | Matriz aprobada; falta verificación integral |
| 9 | Container registry (alta, consulta) | product.md FR-010..FR-014 | D-008 |
| 10 | QR de participante y recipiente | identify-participant/*, scan-container/* | D-008 |
| 11 | Entrega (crear circulación) | deliver-container/* | D-007..D-013 |
| 12 | Devolución a pendiente de lavado | return-container/* | D-007..D-013 |
| 13 | Lavado completado | complete-wash/* | D-007, D-010, D-013 |
| 14 | Historial/trazabilidad | traceability.md, FR-050..FR-052 | — |
| 15 | Error handling uniforme | errors.md | — |
| 16 | Observabilidad básica | observability.md | — |
| 17 | Flutter: enrutamiento por rol y shells | ui/mobile.md, ui/perspectives.md | Base implementada y verificada; módulos internos aún parciales |
| 18 | Flutter: Scan + Inspect | ui/mobile.md, state-machines.md | — para demo |
| 19 | Flutter: Delivery/Return/Wash | specs UI por feature | D-007, D-010, D-013 |
| 20 | Flutter: alumno/historial | student-experience.md | D-007 para datos reales |
| 21 | E2E journey completo | test-strategy.md | Todas anteriores |

---

## 5. Decisiones bloqueantes actuales

Las decisiones de identidad del participante, actor de devolución y estado pendiente de lavado ya fueron resueltas. Permanecen:

| ID | Decisión | Impacto |
|---|---|---|
| **D-003** | Ventana exacta de devolución | Configuración del piloto |
| **D-004** | Evidencia para daño/pérdida/retiro | Flujos excepcionales |
| **D-005** | Tratamiento final de `ASSIGNED` | Limpieza de contrato/modelo |
| **D-007** | Aprovisionamiento, recuperación y revocación productivos; el JWT MVP/demo ya está aprobado | Piloto real |
| **D-008** | Estrategia final de identificadores | Persistencia/API |
| **D-009** | Tiempo/zona horaria | Fechas límite y puntualidad |
| **D-010** | Idempotencia | Reintentos de mutaciones |
| **D-013** | Control de concurrencia final | Entrega, devolución y lavado |
| **D-017** | Metodología ambiental real | Impacto productivo |
| **D-018** | Recuperación/reemisión del Código ReVuelta | Operación con participantes reales |

---

## 6. Decisiones de producto vigentes

Ver `/docs/decision-log.md`. Resumen:

1. Tres perspectivas: Alumno, Cafetería y Operación ReVuelta.
2. No hay selector de perspectiva: el rol autenticado decide la experiencia (`PARTICIPANT`, `OPERATOR`, `ADMIN`).
3. Participante identificado por Código ReVuelta persistente, opaco y sin PII.
4. Cafetería escanea Código ReVuelta + recipiente para entregar.
5. Un participante puede tener múltiples circulaciones activas; cada recipiente solo una.
6. Cafetería confirma la devolución escaneando el recipiente.
7. La devolución finaliza la circulación y deja el recipiente en `RETURNED/Pendiente de lavado`.
8. Cafetería confirma lavado para transicionar `RETURNED → AVAILABLE`.
9. Operación ReVuelta administra códigos, inventario, incidencias, excepciones y auditoría mediante operaciones explícitas.
10. El punto se denomina “Punto ReVuelta — Cafetería del Instituto”.
11. El activo gráfico aprobado es `apps/revuelta-mobile/resources/logo.jpeg`.
12. Impacto y notificaciones son mockup con “Datos de demostración” hasta contar con fuentes reales.

Las decisiones técnicas temporales existentes —JWT, UUID, UTC, índice parcial, Riverpod— no se consideran aprobación final mientras su registro gobernante permanezca abierto.

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
| Fase 1 — Skeleton / F1 build | ✅ Completa | Backend, Flutter, Docker, wrapper y CI verificados local y remotamente |
| Fase 2 — Identity & Access | 🔜 Día 3 | JWT + roles |
| Fase 3 — Container Registry | 🔜 Día 3 | CRUD básico |
| Fase 4 — Circulation: Entrega | 🔜 Día 4 | Primer vertical completo |
| Fase 5 — Circulation: Devolución | 🔜 Día 5 | Segundo vertical |
| Fase 6 — Operación móvil | 🔜 Día 6 | Flutter flows |
| Fase 7 — Observabilidad | 🔜 Día 7 | Básica para MVP |
| Fase 8 — Hardening | ⏳ Post-MVP | Seguridad avanzada, performance |
| Fase 9 — Pilot release | ⏳ Post-MVP | Deployment, seed, rollback |

---

## 10. Revisión de especificaciones UI — 2026-09-18

### Especificado

- Login con cuentas de desarrollo para Alumno/maestro, Cafetería y Operación ReVuelta.
- Navegación y límites de responsabilidad gobernados por el rol autenticado.
- Contratos de pantalla del alumno derivados de `ejemplo1.png`, `ejemplo2.png` y `ejemplo3.png`.
- Contratos operativos mínimos para Cafetería y Operación ReVuelta derivados de `context.md`.
- Estados de escaneo, carga, mutación, resultado incierto e información no disponible.
- Contratos UI específicos para escaneo, entrega y devolución.
- Regla de no mostrar datos o métricas de demostración como información real.

### Pendiente de decisión

- D-017: fuente y metodología de métricas ambientales reales; el mockup demo sí está aprobado.
- D-018: recuperación/reemisión del Código ReVuelta.
- Aprovisionamiento institucional, recuperación y revocación antes del piloto real.
- Vinculación explícita entre cuenta `PARTICIPANT` y el participante de dominio para datos personales reales.
- Mockups específicos para Cafetería y Operación ReVuelta.

### Implicación

Las specs permiten comenzar la separación de shells y estados visuales mediante cuentas autenticadas de desarrollo. La devolución física por Cafetería, `RETURNED/Pendiente de lavado`, la operación separada “Lavado completado”, los múltiples recipientes por participante, el Código ReVuelta persistente y las responsabilidades de Operación ReVuelta ya están definidos a nivel de producto. El piloto real sigue bloqueado por aprovisionamiento institucional, contratos pendientes y verificación.

### Decisiones aprobadas el 2026-09-19

- Código ReVuelta persistente, opaco y sin PII para identificar al participante.
- Cafetería escanea Código ReVuelta + recipiente para entregar.
- Un participante puede tener múltiples recipientes activos.
- Cafetería confirma la devolución escaneando el recipiente.
- La devolución finaliza la circulación y deja el recipiente en `RETURNED`, “Pendiente de lavado”.
- Cafetería confirma el lavado para transicionar a `AVAILABLE`.
- Nombre: “Punto ReVuelta — Cafetería del Instituto”.
- Logo: `apps/revuelta-mobile/resources/logo.jpeg`.
- Impacto y notificaciones pueden mostrarse como mockup con “Datos de demostración”.
- Se conserva login y se descarta el selector libre de perspectiva.
- `student1` usa `PARTICIPANT`; `operator` usa `OPERATOR`; `admin` usa `ADMIN`.

## 11. Verificación de autenticación por rol — 2026-09-20

- Compilación backend ejecutada con Java 17.
- `mvn verify`: 34 pruebas ejecutadas, 0 fallos, 0 errores.
- Incluye pruebas nuevas para login `PARTICIPANT` y rechazo de cuentas sin rol, con rol desconocido o con múltiples roles.
- `git diff --check`: sin errores de espacios en el diff.
- Flyway aplicó V6 contra PostgreSQL real y la tabla de roles confirmó `student1:PARTICIPANT`, `operator:OPERATOR` y `admin:ADMIN`.
- Los tres logins se probaron mediante el API real; credenciales inválidas devolvieron `401`.
- Flutter enruta a shells separados de Alumno/Maestro, Cafetería y Operación ReVuelta; un rol desconocido no recibe un shell protegido.
- La ruta de login ya no ofrece registro público ni recuperación simulada.
- `flutter test`: 8 pruebas ejecutadas, todas aprobadas. Incluye configuración del API, resolución de roles y aislamiento de shells.
- `flutter analyze`: sin errores ni advertencias bloqueantes; permanecen observaciones informativas de estilo y APIs deprecadas preexistentes.

## 12. Verificación F1 — 2026-09-20

- Maven es el único build del backend; el wrapper real fija Maven 3.9.6 y el enforcer exige JDK 17.
- Spring Boot se actualizó de 3.2.3 a 4.1.1 y Tomcat a 11.0.25 para eliminar dependencias con vulnerabilidades corregibles conocidas.
- Flyway 12.4.0 y Testcontainers 2.0.5 validan las migraciones comunes y las semillas `dev` contra PostgreSQL 16.
- Sin el perfil `dev`, V7 retira las tres cuentas demo conocidas; el repeatable `db/dev` las crea únicamente en desarrollo.
- Los hashes de las tres cuentas se verifican contra la contraseña documentada mediante BCrypt.
- La configuración base exige conexión PostgreSQL y `JWT_SECRET`; los valores locales viven solo en `application-dev.yml`.
- Flutter recibe el API mediante `API_BASE_URL`; `localhost` queda como fallback explícito de desarrollo.
- ArchUnit protege al dominio de dependencias hacia aplicación, infraestructura, interfaces, Spring, JPA y Jackson.
- Redocly valida el OpenAPI; Trivy 0.74.0 reporta 0 vulnerabilidades `HIGH/CRITICAL` corregibles en `pom.xml` y `pubspec.lock` y no detectó secretos.
- `.github/workflows/ci.yml` reproduce build/pruebas backend, migraciones, arquitectura, OpenAPI, seguridad y checks Flutter.
- GitHub Actions run `35519801008` terminó correctamente sobre el checkout limpio del commit `cce83b7`.

## 13. Contrato de seguridad HTTP y arranque limpio — 2026-09-20

- El starter oficial de Flyway ejecuta migraciones antes de la validación JPA en una base PostgreSQL vacía.
- Token ausente, inválido o expirado devuelve `401 UNAUTHENTICATED` con `application/problem+json`.
- Un `PARTICIPANT` que llama directamente un endpoint de Cafetería/Operación recibe `403 FORBIDDEN_OPERATION`.
- Las respuestas incluyen código estable, instancia, timestamp y referencia de trazabilidad sin exponer el token.
- La configuración común ya no contiene un secreto JWT por defecto; solo el perfil local `dev` aporta la credencial de demostración.
- La verificación de autorización todavía debe extenderse a cada endpoint sensible antes de cerrar F3.

## 14. Puertos de autenticación y límite de aplicación — 2026-09-20

- `LoginUseCase` dejó de importar `JwtTokenProvider`, `PasswordEncoder`, anotaciones Spring y logging concreto.
- La aplicación expone puertos para emisión de token, verificación de contraseña y auditoría de autenticación; infraestructura los adapta con JWT, BCrypt y SLF4J.
- La ausencia de cuenta y la contraseña incorrecta conservan un mismo fallo público y se auditan sin registrar usuario, contraseña ni token.
- `ApplicationArchitectureTest` falla si código de producción en `application` depende de `infrastructure` o `interfaces`.
- `mvn verify`: 34 pruebas, 0 fallos, 0 errores, incluidas dos bases PostgreSQL 16 efímeras.
- Docker reconstruyó el perfil `full`; salud `UP` y login `student1` emitió un token con rol `PARTICIPANT`.
- El CI remoto anterior (run `35520629016`, commit `499dfc1`) terminó correctamente; este cambio requiere su propio CI después del push.
