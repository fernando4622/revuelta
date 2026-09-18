# ReVuelta — Decision Log

> **Propósito:** Documentar decisiones temporales de implementación tomadas para desbloquear el MVP cuando las especificaciones contienen `Decision required` sin resolución.
>
> **Regla:** Toda decisión aquí registrada es temporal y debe ser revisada por el product owner antes del piloto. Ninguna decisión aquí reemplaza la autoridad de la especificación gobernante.

---

## DL-001 — Roles operativos simplificados

| Campo | Valor |
|---|---|
| **ID** | DL-001 |
| **Problema** | La matriz exacta de roles y permisos no está definida (D-001). Sin esto no se puede implementar autorización. |
| **Spec afectada** | `specs/security/access-control.md`, `specs/product.md` |
| **Opciones** | (A) Dos roles: OPERATOR y ADMIN. (B) Tres roles: OPERATOR, SUPERVISOR, ADMIN. (C) Roles granulares por permiso individual. |
| **Decisión temporal** | **(A) Dos roles.** `OPERATOR` puede: escanear, consultar envases, crear circulaciones, registrar devoluciones, ver historial. `ADMIN` puede: todo lo anterior + registrar envases, gestionar usuarios/roles, configurar políticas, marcar estados excepcionales, ver auditoría completa. |
| **Consecuencia** | Simplifica la implementación. Si el producto necesita un rol intermedio, se deberá agregar con migración y actualizar autorización. |
| **Revisar para V2** | SÍ — la matriz real puede necesitar más granularidad. |

---

## DL-002 — Identidad del prestatario como usuario registrado

| Campo | Valor |
|---|---|
| **ID** | DL-002 |
| **Problema** | No está definido si el prestatario es un usuario autenticado de ReVuelta, un ID institucional, o una referencia libre (D-002). |
| **Spec afectada** | `specs/product.md`, `specs/domain/circulation.md`, `specs/data/data-model.md` |
| **Opciones** | (A) Prestatario como usuario autenticado de ReVuelta. (B) Referencia institucional (matrícula/ID empleado) capturada por operador. (C) Nombre libre. |
| **Decisión temporal** | **(A) Prestatario como usuario registrado.** El campo `borrower_id` en la circulación será un UUID que hace referencia a la tabla de `users`. Los prestatarios deben existir en el sistema. |
| **Consecuencia** | Mayor trazabilidad e integridad referencial. Requiere un flujo para registrar o importar a los prestatarios al sistema antes de poder entregarles envases. |
| **Revisar para V2** | SÍ — evaluar si los prestatarios necesitarán autenticarse en la app móvil. |

---

## DL-003 — Ventana de devolución por defecto: 2 días

| Campo | Valor |
|---|---|
| **ID** | DL-003 |
| **Problema** | La duración exacta de la ventana de devolución del piloto no está definida (D-003). El rango aprobado es 1-3 días. |
| **Spec afectada** | `specs/domain/circulation.md`, `specs/constitution.md` |
| **Opciones** | 1 día, 2 días, 3 días. |
| **Decisión temporal** | **2 días (48 horas desde delivered_at).** Configurable en la entidad `ReturnPolicy`. |
| **Consecuencia** | Si el piloto necesita otra duración, solo se cambia la configuración de la política activa. No requiere cambio de código. |
| **Revisar para V2** | SÍ — confirmar con operación del piloto. |

---

## DL-004 — Estados excepcionales diferidos

| Campo | Valor |
|---|---|
| **ID** | DL-004 |
| **Problema** | No están definidos los permisos ni la evidencia requerida para marcar un envase como DAMAGED, LOST o RETIRED (D-004). |
| **Spec afectada** | `specs/domain/container-lifecycle.md` |
| **Opciones** | (A) Implementar con permisos/evidencia completa. (B) Implementar solo con permiso ADMIN + razón textual. (C) Diferir estados excepcionales del MVP. |
| **Decisión temporal** | **(B) Solo ADMIN puede marcar estados excepcionales.** Se requiere un campo `reason` (string, obligatorio). No se requiere evidencia fotográfica en V1. Las transiciones implementadas para excepcionales: `AVAILABLE→DAMAGED`, `AVAILABLE→LOST`, `IN_USE→DAMAGED`, `IN_USE→LOST`, `DAMAGED→AVAILABLE` (recuperación), `DAMAGED→RETIRED`, `LOST→RETIRED`. |
| **Consecuencia** | Funcionalidad básica de estados excepcionales disponible. Si se requiere taxonomía de razones o evidencia fotográfica, se agrega después. |
| **Revisar para V2** | SÍ — definir taxonomía de razones y política de evidencia. |

---

## DL-005 — Unificación de ASSIGNED e IN_USE

| Campo | Valor |
|---|---|
| **ID** | DL-005 |
| **Problema** | No está claro si `ASSIGNED` y `IN_USE` son estados materialmente distintos o redundantes (D-005). |
| **Spec afectada** | `specs/domain/container-lifecycle.md` |
| **Opciones** | (A) Mantener ambos: ASSIGNED = reservado, IN_USE = en custodia física. (B) Unificar en IN_USE: la entrega implica custodia inmediata. |
| **Decisión temporal** | **(B) Unificar.** En el piloto universitario/cafetería, la entrega es presencial e implica custodia inmediata. No hay un paso de "asignación previa" separado de la entrega física. El estado `ASSIGNED` no se usa en V1. La transición de entrega es: `AVAILABLE → IN_USE`. |
| **Consecuencia** | La máquina de estados es más simple (6 estados activos en lugar de 8). Si un futuro escenario requiere reserva previa, se reintroduce ASSIGNED con migración y actualización de la spec. |
| **Revisar para V2** | SÍ — evaluar si se necesita reserva previa. |

---

## DL-006 — RETURNED como estado transitorio

| Campo | Valor |
|---|---|
| **ID** | DL-006 |
| **Problema** | No está definido si `RETURNED` es un estado persistente (cola de lavado/inspección) o transitorio (D-006). |
| **Spec afectada** | `specs/domain/container-lifecycle.md` |
| **Opciones** | (A) RETURNED persistente: el envase espera inspección antes de volver a AVAILABLE. (B) RETURNED transitorio: la devolución transiciona directamente a AVAILABLE. |
| **Decisión temporal** | **(B) Transitorio.** Al registrar una devolución, el envase transiciona de `IN_USE → AVAILABLE` en una sola operación atómica. El estado `RETURNED` no se persiste como estado del envase. La circulación se marca como `COMPLETED` con su timestamp de devolución y clasificación de puntualidad. |
| **Consecuencia** | Simplifica el flujo. Si el piloto necesita cola de inspección/lavado, se reintroduce RETURNED como estado persistente. |
| **Revisar para V2** | SÍ — evaluar si se necesita proceso de inspección post-devolución. |

---

## DL-007 — JWT stateless para autenticación

| Campo | Valor |
|---|---|
| **ID** | DL-007 |
| **Problema** | No está definido el mecanismo de autenticación (D-007). |
| **Spec afectada** | `specs/security/access-control.md`, `specs/features/authentication/requirements.md` |
| **Opciones** | (A) JWT stateless. (B) Sesión con cookies HttpOnly. (C) OAuth2 con provider externo. |
| **Decisión temporal** | **(A) JWT stateless.** Login con username/password → JWT access token (expiración: 4 horas). Sin refresh token en V1. El token incluye: user ID, username, roles. Spring Security valida el token en cada request. Logout es client-side (borrar token). |
| **Consecuencia** | No hay revocación server-side de tokens individuales en V1. Si un token se compromete, solo es válido por 4 horas. |
| **Revisar para V2** | SÍ — evaluar refresh tokens, revocación, y posiblemente OAuth2. |

---

## DL-008 — UUIDs v4 para identificadores

| Campo | Valor |
|---|---|
| **ID** | DL-008 |
| **Problema** | No está definida la estrategia de PKs y IDs externos (D-008). |
| **Spec afectada** | `specs/data/data-model.md` |
| **Opciones** | (A) UUID v4. (B) UUID v7 (time-ordered). (C) Secuencial numérico. (D) Natural/alfanumérico. |
| **Decisión temporal** | **(A) UUID v4.** PK de base de datos = ID externo de API. Sin diferenciación. Tipo `UUID` nativo de PostgreSQL. Generado por la aplicación (Java `UUID.randomUUID()`). |
| **Consecuencia** | Evita enumeración (RISK-005). Buen soporte en PostgreSQL y Java. Índices ligeramente menos eficientes que secuenciales, pero irrelevante para la escala del piloto. Si se necesita ordenamiento por tiempo en el ID, migrar a UUIDv7. |
| **Revisar para V2** | NO — a menos que haya problema de performance en consultas. |

---

## DL-009 — Timestamps UTC Instant

| Campo | Valor |
|---|---|
| **ID** | DL-009 |
| **Problema** | No está definida la representación de tiempo y zona horaria (D-009). |
| **Spec afectada** | `specs/data/data-model.md`, `specs/domain/circulation.md` |
| **Opciones** | (A) UTC Instant en BD y API; zona horaria de negocio configurable para interpretación. (B) Timestamps con offset. (C) Local time de la zona del piloto. |
| **Decisión temporal** | **(A) UTC Instant.** PostgreSQL: `TIMESTAMP WITH TIME ZONE` (almacena en UTC). API: formato ISO 8601 con `Z` (`2026-09-15T18:30:00Z`). Java: `Instant`. Zona horaria del piloto (ej. `America/Mexico_City`) configurable para interpretación de políticas de devolución. La comparación de puntualidad es por instante (no por día calendario). Igualdad en `due_at` se clasifica como `ON_TIME`. |
| **Consecuencia** | Consistente y sin ambigüedad. La UI formatea a la zona local del dispositivo. |
| **Revisar para V2** | NO — es la práctica estándar recomendada. |

---

## DL-010 — Idempotencia por constraint de BD

| Campo | Valor |
|---|---|
| **ID** | DL-010 |
| **Problema** | No está definido el mecanismo de idempotencia/deduplicación API (D-010). |
| **Spec afectada** | `specs/api/openapi-baseline.md`, features de delivery y return |
| **Opciones** | (A) Header `Idempotency-Key` con almacenamiento server-side. (B) Constraint de BD (unique partial index en circulación activa). (C) Ambos. |
| **Decisión temporal** | **(B) Constraint de BD.** Para delivery: el partial unique index de una circulación activa por container previene duplicados naturalmente. Una segunda solicitud de entrega para el mismo container ya en uso recibe `409 ACTIVE_CIRCULATION_EXISTS`. Para return: la BD previene doble finalización verificando el estado de la circulación dentro de la transacción. Respuesta determinista: `409 RETURN_ALREADY_REGISTERED`. |
| **Consecuencia** | Más simple que un sistema de idempotency keys. No protege contra un retry exacto que llega entre el commit y la respuesta del primer request (window muy pequeño). Aceptable para el piloto. |
| **Revisar para V2** | SÍ — evaluar `Idempotency-Key` header si los operadores reportan problemas con reintentos. |

---

## DL-011 — Riverpod para state management Flutter

| Campo | Valor |
|---|---|
| **ID** | DL-011 |
| **Problema** | No está definida la librería de state management para Flutter (D-011). |
| **Spec afectada** | `specs/ui/mobile.md` |
| **Opciones** | (A) Riverpod. (B) Bloc/Cubit. (C) ChangeNotifier/Provider. |
| **Decisión temporal** | **(A) Riverpod.** Type-safe, compile-time verified, testable, buen soporte para estados discriminados (AsyncValue ≈ Initial/Loading/Success/Error). Compatible con la arquitectura de UI state machines de la spec. |
| **Consecuencia** | Dependencia en `flutter_riverpod` y `riverpod_annotation`. Si el equipo prefiere Bloc, requiere migración pero la capa de dominio/aplicación no se ve afectada. |
| **Revisar para V2** | NO — a menos que el equipo exprese preferencia diferente. |

---

## DL-012 — QR payload format

| Campo | Valor |
|---|---|
| **ID** | DL-012 |
| **Problema** | El formato del payload QR no está especificado en `scan-container/requirements.md`. |
| **Spec afectada** | `specs/features/scan-container/requirements.md` |
| **Opciones** | (A) UUID del container en texto plano. (B) URL con el UUID. (C) Token firmado/HMAC. |
| **Decisión temporal** | **(A) UUID del container en texto plano.** El QR contiene únicamente el UUID del container. La app lo lee, lo envía al backend, el backend lo busca en la BD. Es untrusted input validado por formato (UUID) antes de lookup. |
| **Consecuencia** | Simple y funcional. No protege contra copia del QR (aceptable: RISK-001 se mitiga por autorización server-side, no por el QR). Si se necesita protección anti-falsificación del QR, migrar a tokens firmados. |
| **Revisar para V2** | SÍ — evaluar si se necesita firma/HMAC. |

---

## DL-013 — Partial unique index para concurrencia

| Campo | Valor |
|---|---|
| **ID** | DL-013 |
| **Problema** | No está definido el mecanismo exacto de concurrencia en PostgreSQL para garantizar una circulación activa por envase (D-013). |
| **Spec afectada** | `specs/data/data-model.md` |
| **Opciones** | (A) Partial unique index (`UNIQUE(container_id) WHERE status = 'ACTIVE'`). (B) `SELECT ... FOR UPDATE` pessimistic lock. (C) Optimistic locking con version column. |
| **Decisión temporal** | **(A) Partial unique index.** PostgreSQL soporta nativamente índices únicos parciales. La constraint se evalúa atómicamente en el commit de la transacción. Si dos transacciones concurrentes intentan crear una circulación activa para el mismo container, la segunda falla con unique violation, que se traduce a `409 ACTIVE_CIRCULATION_EXISTS`. |
| **Consecuencia** | Mecanismo más simple y confiable. La BD es la última línea de defensa del invariante. No requiere código de locking adicional. Probado bajo concurrencia con integration tests. |
| **Revisar para V2** | NO — es el mecanismo recomendado por la comunidad PostgreSQL. |
