# ReVuelta — ROADMAP

> **Estado:** Baseline inicial v1.0
> **Metodología:** Spec-Driven Development (SDD) + Domain-Driven Design (DDD) + Contract-Driven Development (CDD) + Test-Driven Development (TDD) + Behavior-Driven Development (BDD) + Architecture Decision Records (ADR) + threat modeling orientado a riesgos.
> **Producto:** Aplicación real para el control operativo de envases reutilizables mediante identificación individual (QR), préstamos, devoluciones, estados de ciclo de vida y trazabilidad.
> **Última revisión:** 2026-09-12

---

## 0. Propósito de este documento

Este archivo define **qué se construye, qué no se construye, en qué orden y bajo qué gates**.

No sustituye las especificaciones de cada funcionalidad. Cada fase del roadmap debe desembocar en specs pequeñas y verificables antes de escribir implementación.

La regla central es:

> **Spec aprobada → diseño/contrato → tests → implementación → verificación → cierre.**

SDD se adopta como fuente de intención compartida entre persona desarrolladora y agentes de IA; el código sigue siendo la implementación ejecutable y los tests constituyen evidencia de comportamiento. Este enfoque coincide con prácticas actuales de SDD que recomiendan contratos explícitos, specs locales y trazabilidad entre intención, implementación y validación. [1][2]

---

# 1. Constitución de producto

## 1.1 Problema

ReVuelta debe permitir controlar el ciclo operativo de envases reutilizables de un sistema de alimentos: identificar un envase concreto, saber quién lo tiene, registrar cuándo fue entregado, controlar su devolución, conocer su estado operativo y conservar trazabilidad de los eventos relevantes.

## 1.2 Resultado esperado de V1

Un operador autorizado debe poder responder, sin consultar sistemas externos ni realizar cálculos manuales:

1. ¿Qué envases existen?
2. ¿Cuál es el identificador de un envase?
3. ¿En qué estado se encuentra?
4. ¿Quién lo tiene actualmente, si está prestado?
5. ¿Cuándo fue entregado?
6. ¿Cuándo debe devolverse?
7. ¿Fue devuelto?
8. ¿Existe un historial verificable de sus transiciones?
9. ¿Qué anomalías o devoluciones vencidas requieren atención?

## 1.3 Objetivo de negocio de V1

Establecer una base operativa confiable para medir y mejorar el retorno de envases reutilizables en un piloto universitario.

La métrica de referencia del piloto será:

`return_rate = envases_devuelto_en_ventana / envases_entregados`

La meta histórica del proyecto es **≥85% de retorno dentro de la ventana definida**. La métrica no se utilizará como criterio de aceptación técnica del software; será una métrica de operación del piloto.

## 1.4 Contexto operativo de V1

El primer piloto se limita a un entorno universitario/cafetería del campus.

La ventana operativa de devolución inicial es configurable y deberá poder representar **1 a 3 días**. El sistema no debe codificar el número 1, 2 o 3 como regla permanente: la duración será configuración de negocio versionada y validada.

---

# 2. Alcance estrictamente delimitado

## 2.1 Incluido en V1

### Identidad y acceso
- Autenticación de usuarios.
- Autorización basada en rol.
- Sesiones/token según la implementación definida por la spec de seguridad.
- Auditoría de acciones sensibles.

### Catálogo de envases
- Alta de envase.
- Consulta de envase.
- Identificador único e inmutable.
- Estado operativo actual.
- Metadatos mínimos necesarios para operación.
- Desactivación lógica, nunca borrado destructivo de un envase que tenga historial.

### Identificación
- Lectura de QR mediante aplicación móvil.
- Resolución del QR a un envase concreto.
- Validación de integridad del identificador.
- Rechazo de QR inexistentes, inactivos o inválidos.

### Préstamo / entrega
- Registrar entrega de un envase.
- Asociar envase con la persona receptora.
- Registrar fecha/hora de operación desde servidor.
- Calcular o registrar fecha límite de devolución según política vigente.
- Crear evento de trazabilidad.

### Devolución
- Registrar devolución.
- Validar que el envase está en estado compatible con devolución.
- Registrar fecha/hora efectiva desde servidor.
- Determinar si la devolución fue dentro de plazo.
- Crear evento de trazabilidad.

### Estado y ciclo de vida
- Máquina de estados explícita.
- Transiciones válidas explícitas.
- Rechazo de transiciones imposibles.
- Historial de transiciones/eventos.

### Operación y observabilidad
- Manejo uniforme de errores API.
- Logs estructurados.
- Correlation/request ID.
- Health checks básicos.
- Métricas técnicas mínimas.

## 2.2 Fuera de V1

No se implementará en V1 salvo que una nueva spec aprobada cambie el alcance:

- Procesamiento de pagos.
- Wallet, saldo o cobro automático.
- Publicidad integrada.
- Marketplace.
- Multi-campus productivo.
- Integración con ERP/SIS universitario.
- NFC/RFID.
- Bluetooth.
- IoT.
- IA generativa como parte crítica del flujo de préstamo/devolución.
- Microservicios independientes por cada módulo.
- Kubernetes.
- Event streaming distribuido.
- Recompensas complejas/gamificación.
- Programa de puntos monetizable.
- Integraciones de terceros no necesarias para el piloto.

Estas exclusiones son deliberadas. El objetivo de V1 es validar **control, trazabilidad y operación**, no maximizar funcionalidades.

---

# 3. Arquitectura objetivo

## 3.1 Estilo

Se adopta **Clean Architecture + DDD táctico + Ports & Adapters / Hexagonal Architecture**.

La lógica de negocio debe permanecer independiente de Flutter widgets, HTTP, PostgreSQL, ORM, QR scanner, proveedores de autenticación y otros detalles externos. DDD y arquitectura hexagonal son compatibles con una separación por dominio y puertos/adaptadores. [3]

## 3.2 Backend

**Tecnología base:** Spring Boot + Java + PostgreSQL.

Capas lógicas:

```text
interfaces
  ├── REST controllers
  ├── DTOs / request-response models
  └── exception translation
          ↓
application
  ├── use cases
  ├── commands / queries
  ├── transaction boundaries
  └── ports
          ↓
domain
  ├── entities
  ├── value objects
  ├── aggregates
  ├── domain services
  ├── domain events
  └── business rules
          ↑
infrastructure
  ├── persistence adapters
  ├── security adapters
  ├── QR/external adapters
  └── observability adapters
```

El dominio **no puede importar** Spring, JPA, JDBC, HTTP, Jackson ni clases de infraestructura.

## 3.3 Aplicación Flutter

```text
presentation
  ├── pages/screens
  ├── widgets
  ├── state/controllers
  └── navigation
          ↓
application
  ├── use-case orchestration
  ├── state models
  └── dependency interfaces
          ↓
domain
  ├── entities
  ├── value objects
  ├── failures
  └── repository contracts
          ↑
data/infrastructure
  ├── API clients
  ├── DTOs
  ├── mappers
  ├── local persistence/cache
  └── device integrations
```

Los widgets no llaman HTTP directamente.

La UI no conoce DTOs de backend.

La capa de dominio no depende de Flutter.

---

# 4. Dominios y bounded contexts

La descomposición inicial será por **responsabilidad de negocio**, no por tipo técnico.

## 4.1 Identity & Access

Responsable de:
- usuario;
- autenticación;
- roles/permisos;
- autorización de operaciones.

No es responsable del ciclo de vida de envases.

## 4.2 Container Management

Responsable de:
- identidad del envase;
- catálogo;
- estado operativo;
- elegibilidad para préstamo/devolución;
- historial relacionado.

## 4.3 Circulation

Responsable de:
- entrega;
- préstamo activo;
- devolución;
- vencimiento;
- vínculo temporal usuario-envase.

## 4.4 Audit / Traceability

Responsable de:
- eventos de negocio auditables;
- quién realizó una acción;
- cuándo ocurrió;
- qué agregado fue afectado;
- correlación técnica.

No debe convertirse en un segundo sistema de negocio.

## 4.5 Reporting

En V1 será una capacidad de lectura derivada, no una fuente primaria de verdad.

No podrá modificar el dominio.

---

# 5. Máquina de estados del envase

El modelo de estado debe definirse en una spec antes de implementación.

Baseline inicial propuesto:

```text
REGISTERED
    ↓
AVAILABLE
    ↓
ASSIGNED
    ↓
IN_USE
    ↓
RETURNED
    ↓
AVAILABLE
```

Estados excepcionales:

```text
AVAILABLE / RETURNED → DAMAGED
AVAILABLE / RETURNED → LOST
DAMAGED → AVAILABLE        (solo después de validación operativa)
LOST → RETIRED              (solo por operación autorizada)
DAMAGED → RETIRED
```

### Regla fundamental

**No se debe modificar `status` arbitrariamente.** Toda transición debe ejecutarse mediante un caso de uso que valide:

- estado actual;
- actor;
- permisos;
- precondiciones;
- datos requeridos;
- efecto esperado;
- evento de trazabilidad.

La lista anterior es un baseline arquitectónico. La máquina final se congela en la spec `container-lifecycle` antes del primer código de producción.

---

# 6. Modelo de dominio mínimo

Los nombres concretos de tablas/clases se decidirán en la spec de datos, pero V1 debe representar al menos:

### User
Identidad operativa de una persona.

### Container
Unidad física individual e identificable.

### Circulation / Loan
Hecho de que un envase fue entregado a una persona durante un intervalo temporal.

### ContainerEvent
Hecho inmutable relacionado con el ciclo de vida o auditoría del envase.

### ReturnPolicy
Regla que determina la ventana de devolución aplicable.

### Role / Permission
Modelo de autorización.

No se crearán entidades “porque quizá luego hagan falta”. Toda entidad necesita una responsabilidad y al menos una regla que justifique su existencia.

---

# 7. Reglas de negocio que deben quedar explícitas

Estas reglas no deberán quedar implícitas en controllers, widgets, SQL o validaciones duplicadas.

1. Un envase tiene un identificador único.
2. Un envase no puede tener dos préstamos activos simultáneamente.
3. Un préstamo debe apuntar a un envase existente y elegible.
4. Solo roles autorizados pueden ejecutar operaciones sensibles.
5. La fecha/hora de negocio usada para la operación se obtiene del servidor.
6. La fecha límite se determina a partir de la política vigente del préstamo.
7. Una devolución no puede registrarse dos veces como devolución efectiva del mismo préstamo.
8. Toda transición válida produce una huella de trazabilidad.
9. Una transición inválida no cambia el estado.
10. El historial de eventos de auditoría no se edita destructivamente.
11. Los errores esperables se devuelven como errores de negocio tipados, no como `500` genérico.
12. Una petición repetida accidentalmente no debe crear dos operaciones cuando el caso de uso sea idempotente.
13. Las operaciones que cruzan varias escrituras críticas deben ejecutarse dentro de una frontera transaccional definida.
14. La concurrencia debe resolverse explícitamente; nunca asumirse inexistente.

---

# 8. Estrategia de manejo de errores

## 8.1 Jerarquía conceptual

```text
Failure
├── ValidationFailure
├── AuthenticationFailure
├── AuthorizationFailure
├── NotFoundFailure
├── ConflictFailure
├── BusinessRuleFailure
├── InfrastructureFailure
└── UnexpectedFailure
```

## 8.2 API

Los errores deben tener una forma estable, versionable y documentada mediante OpenAPI.

Baseline conceptual:

```json
{
  "type": "https://revuelta.app/problems/container-not-available",
  "title": "Container is not available",
  "status": 409,
  "code": "CONTAINER_NOT_AVAILABLE",
  "detail": "The container cannot be assigned in its current state.",
  "instance": "/api/v1/circulations",
  "traceId": "...",
  "errors": []
}
```

No se debe filtrar stack traces, SQL, secretos ni detalles internos al cliente.

## 8.3 Flutter

Los fallos de dominio/API se transformarán a estados presentables para UI.

La UI no mostrará mensajes de excepción cruda.

---

# 9. Estrategia de estados de UI

Los flujos asíncronos no se modelarán con múltiples booleanos contradictorios (`isLoading`, `hasError`, `isSuccess`, etc.).

Baseline:

```text
Initial
Loading
Success<T>
Failure<Failure>
```

Para flujos complejos se usará un modelo discriminado explícito, por ejemplo:

```text
AuthenticationState
Unauthenticated
Authenticating
Authenticated(session)
AuthenticationFailed(failure)
```

El estado debe poder representar exactamente una situación válida por vez.

---

# 10. API: Contract-Driven Development

La API será **contract-first**.

El contrato OpenAPI versionado será aprobado antes de implementar cada vertical relevante. Contract-driven development usa las especificaciones de API como contratos ejecutables o verificables y desplaza errores de compatibilidad hacia etapas tempranas. [4]

Orden obligatorio:

```text
Business spec
    ↓
Use-case spec
    ↓
API contract
    ↓
Acceptance tests
    ↓
Implementation
```

La implementación no puede introducir endpoints ad hoc “porque era más rápido”.

---

# 11. Estrategia de testing

Se combina:

## TDD
Para reglas de dominio, casos de uso y lógica determinista.

## BDD / Acceptance Testing
Para flujos observables por usuario y operación.

## Contract Testing
Para asegurar compatibilidad entre app móvil y backend.

## Integration Testing
Para persistencia, seguridad, transacciones y adaptadores reales.

## E2E Testing
Solo para journeys críticos, no para cada detalle de UI.

### Pirámide objetivo

```text
              E2E
           /       \
      Contract   Integration
       /               \
    Application / Domain
       /               \
   Unit tests (mayoría)
```

No se perseguirá cobertura porcentual ciega. La prioridad será la cobertura de **riesgos y reglas de negocio**.

---

# 12. Threat / risk driven development

Antes de implementar seguridad avanzada se identificarán amenazas concretas.

Riesgos mínimos a analizar:

- QR manipulado.
- Usuario no autorizado intentando devolver/asignar.
- Repetición de una operación.
- Dos operaciones concurrentes sobre el mismo envase.
- Manipulación del identificador de otro usuario.
- Exposición de datos personales.
- Enumeración de recursos.
- Token comprometido.
- Requests falsificados desde clientes no oficiales.
- Borrado accidental de historial.

Cada riesgo debe quedar relacionado con una mitigación verificable.

---

# 13. Fases de implementación

## FASE 0 — Constitución y especificación base

**Objetivo:** que el proyecto tenga una única fuente de verdad antes del código serio.

Entregables:

- `AGENTS.md` aprobado.
- `ROADMAP.md` aprobado.
- `specs/constitution.md`.
- `specs/product.md`.
- `specs/domain/container-lifecycle.md`.
- `specs/domain/circulation.md`.
- `specs/security/access-control.md`.
- `specs/data/data-model.md`.
- ADR inicial de arquitectura.
- matriz de trazabilidad.

**Gate:** ningún feature puede pasar a implementación si hay ambigüedades en actores, estados, entradas, salidas o reglas críticas.

---

## FASE 1 — Skeleton arquitectónico

**Objetivo:** crear la estructura física de backend y Flutter sin funcionalidad de negocio significativa.

Backend:
- módulos/capas Clean Architecture;
- configuración;
- error boundary;
- logging;
- health endpoint;
- OpenAPI base;
- test infrastructure.

Flutter:
- capas Clean Architecture;
- routing;
- dependency injection;
- estado global mínimo;
- error presentation;
- environment configuration;
- API client abstraction.

**Gate:** arquitectura compilable, tests base ejecutándose y reglas de dependencia verificables.

---

## FASE 2 — Identity & Access

Implementar:
- autenticación;
- sesión/token;
- roles;
- autorización;
- logout/revocación según spec;
- auditoría de operaciones sensibles.

**Acceptance:** un usuario sin permisos no puede acceder ni por UI ni por API a una operación restringida.

---

## FASE 3 — Container Registry

Implementar:
- registrar envase;
- consultar envase;
- listar/filtrar;
- desactivar;
- QR identity;
- estado inicial;
- historial.

**Acceptance:** cada envase existe una sola vez y su identidad no puede colisionar.

---

## FASE 4 — Circulation: entrega

Implementar el primer vertical completo:

```text
scan QR
 → resolve container
 → validate state
 → authorize actor
 → create circulation
 → transition container
 → persist event
 → return result
```

La operación deberá probarse bajo repetición y concurrencia.

---

## FASE 5 — Circulation: devolución

Implementar:

```text
scan QR
 → resolve container
 → resolve active circulation
 → validate actor/policy
 → register return
 → calculate punctuality
 → transition container
 → persist event
 → return result
```

Debe diferenciarse claramente:

- devuelto a tiempo;
- devuelto tarde;
- devolución inválida;
- envase no encontrado;
- envase sin préstamo activo.

---

## FASE 6 — Operación móvil

Implementar UX de los journeys críticos:

1. Login.
2. Escanear envase.
3. Ver detalle.
4. Registrar entrega.
5. Registrar devolución.
6. Ver estado.
7. Ver incidencias necesarias para el rol.

La UI no implementará reglas de negocio duplicadas.

---

## FASE 7 — Observabilidad y resiliencia

Agregar:
- correlation IDs;
- structured logs;
- métricas;
- health/readiness;
- timeouts;
- retry solo donde sea seguro;
- idempotency donde corresponda;
- manejo explícito de degradación de red en móvil.

---

## FASE 8 — Hardening y validación de piloto

Validar:
- seguridad;
- concurrencia;
- integridad de datos;
- backups;
- restauración;
- performance razonable;
- errores de conectividad;
- dispositivos reales;
- operación de campo;
- trazabilidad completa.

**Gate de piloto:** ninguna severidad crítica/alta abierta que comprometa identidad, autorización, integridad de circulación, pérdida de historial o consistencia de estados.

---

## FASE 9 — Pilot release

El piloto se desplegará como **una unidad operativa acotada**.

Antes de activarlo debe existir:

- procedimiento operativo;
- procedimiento de recuperación;
- definición de soporte;
- mecanismo de reporte de incidencias;
- dataset inicial controlado;
- seed/admin procedure;
- métricas de éxito;
- rollback plan.

---

# 14. Feature workflow obligatorio

Cada nueva feature sigue este flujo:

```text
01. Idea
 ↓
02. Feature spec
 ↓
03. Review / ambiguity removal
 ↓
04. Domain design
 ↓
05. API/UI contract if applicable
 ↓
06. Acceptance scenarios
 ↓
07. Implementation tasks
 ↓
08. TDD / implementation
 ↓
09. Integration + contract tests
 ↓
10. Security/risk review
 ↓
11. Verification
 ↓
12. Merge
 ↓
13. Spec/task status update
```

Nunca:

```text
Prompt → generate 500 files → debug until it works
```

---

# 15. Definition of Ready

Una feature está **Ready for Implementation** solo si:

- tiene propósito;
- tiene actor;
- tiene precondiciones;
- tiene postcondiciones;
- define entradas;
- define salidas;
- define errores esperables;
- define permisos;
- define cambios de estado;
- define persistencia cuando corresponda;
- tiene escenarios de aceptación;
- tiene fuera de alcance;
- tiene dependencias identificadas;
- no contiene decisiones técnicas contradictorias con `AGENTS.md` o ADRs.

---

# 16. Definition of Done

Una feature está terminada solo si:

- la implementación coincide con la spec;
- los tests de dominio pasan;
- los casos de uso están cubiertos por tests relevantes;
- los contratos API están validados;
- los errores están tipados y mapeados;
- las reglas de autorización están probadas;
- no existe lógica de negocio duplicada entre capas;
- no hay TODO crítico;
- la documentación afectada está actualizada;
- la spec está marcada como implementada solo después de verificarla;
- el diff no contiene cambios no relacionados.

---

# 17. Trazabilidad

Cada feature deberá poder responder:

```text
Requirement
   ↓
Spec
   ↓
Scenario
   ↓
Use Case
   ↓
Domain Rule
   ↓
API/UI Contract
   ↓
Test
   ↓
Implementation
```

Código sin razón de negocio rastreable debe cuestionarse.

---

# 18. Estructura documental propuesta

```text
.
├── AGENTS.md
├── ROADMAP.md
├── docs/
│   ├── adr/
│   │   ├── ADR-001-clean-architecture.md
│   │   ├── ADR-002-api-versioning.md
│   │   └── ADR-003-state-machine.md
│   └── diagrams/
├── specs/
│   ├── constitution.md
│   ├── product.md
│   ├── security/
│   ├── domain/
│   ├── data/
│   ├── api/
│   ├── ui/
│   ├── testing/
│   └── features/
│       └── <feature>/
│           ├── requirements.md
│           ├── plan.md
│           └── validation.md
├── apps/
│   └── revuelta-mobile/
└── services/
    └── revuelta-api/
```

---

# 19. ADR policy

Toda decisión arquitectónica con impacto transversal se registra como ADR.

Ejemplos:

- por qué modular monolith y no microservices;
- estrategia de autenticación;
- control de concurrencia;
- política de IDs;
- estrategia de migraciones;
- versionado API;
- estrategia de estado Flutter;
- observabilidad.

Los ADRs no deben documentar preferencias triviales.

---

# 20. Principios de diseño

1. **Domain first.** El negocio manda sobre el framework.
2. **Explicit over implicit.** Las reglas importantes se escriben.
3. **Small specs over giant specs.** Cada spec debe tener un alcance manejable.
4. **One source of truth per concern.** No duplicar reglas.
5. **Fail explicitly.** Los estados imposibles deben ser imposibles o rechazados.
6. **Immutable history.** El pasado se registra; no se reescribe.
7. **Secure by default.** La autorización se deniega por defecto.
8. **Concurrency is a requirement.** No se asume secuencialidad.
9. **No speculative architecture.** No agregar complejidad por posibles futuros.
10. **AI accelerates implementation; it does not decide product semantics.**

---

# 21. Próximo trabajo concreto

El siguiente lote no es escribir controllers ni pantallas.

Debe producir exactamente estos artefactos:

1. `specs/constitution.md`
2. `specs/product.md`
3. `specs/domain/container-lifecycle.md`
4. `specs/domain/circulation.md`
5. `specs/security/access-control.md`
6. `specs/data/data-model.md`
7. `docs/adr/ADR-001-clean-architecture.md`
8. primera matriz de trazabilidad.

Después se congela el baseline y comienza **FASE 1**.

---

# Referencias

[1] Microsoft, “Spec-Driven Development: A Spec-First Approach to AI-Native Engineering”, 2026. https://developer.microsoft.com/blog/spec-driven-development-ai-native-engineering/

[2] SpecDD, “Spec-Driven Development framework”, 2026. https://github.com/specdd/specdd

[3] AWS Prescriptive Guidance, “Hexagonal architectures / Domain-driven design”. https://docs.aws.amazon.com/prescriptive-guidance/latest/hexagonal-architectures/overview.html

[4] Specmatic, “Contract Driven Development”. https://docs.specmatic.io/contract_driven_development
