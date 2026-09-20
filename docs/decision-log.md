# ReVuelta — Decision Log

> **Propósito:** Documentar decisiones temporales de implementación tomadas para desbloquear el MVP cuando las especificaciones contienen `Decision required` sin resolución.
>
> **Regla:** Toda decisión aquí registrada es temporal y debe ser revisada por el product owner antes del piloto. Ninguna decisión aquí reemplaza la autoridad de la especificación gobernante.

---

## DL-001 — Perspectivas y responsabilidades del piloto

| Campo | Valor |
|---|---|
| **ID** | DL-001 |
| **Problema** | El producto necesita separar Alumno, Cafetería y Operación ReVuelta sin convertir la navegación en autorización. |
| **Spec afectada** | `specs/security/access-control.md`, `specs/product.md` |
| **Opciones** | Mantener dos roles técnicos genéricos o modelar las tres responsabilidades reales del piloto. |
| **Decisión temporal** | Se reconocen tres experiencias de producto vinculadas a roles autenticados: `PARTICIPANT` para **Alumno/maestro**, `OPERATOR` para **Cafetería** y `ADMIN` para **Operación ReVuelta**. Alumno/maestro consulta su información; Cafetería identifica participantes/recipientes, entrega, recibe y completa lavado; ReVuelta administra inventario, incidencias y trazabilidad. |
| **Consecuencia** | Navegación y casos de uso quedan separados. La app obtiene el rol de una sesión firmada y nunca de un selector o encabezado controlado por el cliente. Toda operación continúa requiriendo autorización del servidor. |
| **Revisar para V2** | NO — debe cerrarse antes del piloto mediante la matriz de acceso aprobada. |

---

## DL-002 — Identidad del participante mediante Código ReVuelta

| Campo | Valor |
|---|---|
| **ID** | DL-002 |
| **Problema** | Se necesita asociar uno o varios recipientes a una persona sin implementar todavía login ni exponer datos personales en el QR. |
| **Spec afectada** | `specs/product.md`, `specs/domain/circulation.md`, `specs/data/data-model.md` |
| **Opciones** | Cuenta autenticada, matrícula visible, código por pedido o código persistente y opaco por participante. |
| **Decisión temporal** | Cada participante recibe un **Código ReVuelta persistente**, representable como QR, sin nombre, matrícula, correo ni rol institucional en el payload. Cafetería escanea el Código ReVuelta y el QR del recipiente para efectuar la entrega. Una persona puede tener varias circulaciones activas, pero cada recipiente conserva como máximo una. |
| **Consecuencia** | Permite trazabilidad y agrupación de historial sin login. El código identifica al participante dentro del piloto, pero no autentica al portador ni autoriza operaciones. La recuperación/reemisión se mantiene bloqueada por D-018. |
| **Revisar para V2** | SÍ — vincular el participante con identidad institucional cuando se implemente autenticación. |

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

## DL-006 — RETURNED como estado persistente pendiente de lavado

| Campo | Valor |
|---|---|
| **ID** | DL-006 |
| **Problema** | Debe distinguirse un recipiente recibido físicamente de uno lavado y disponible. |
| **Spec afectada** | `specs/domain/container-lifecycle.md` |
| **Opciones** | (A) RETURNED persistente: el envase espera inspección antes de volver a AVAILABLE. (B) RETURNED transitorio: la devolución transiciona directamente a AVAILABLE. |
| **Decisión temporal** | **(A) Persistente.** La confirmación física de Cafetería finaliza la circulación y transiciona `IN_USE → RETURNED`. `RETURNED` significa “Pendiente de lavado” y no es elegible para entrega. Cafetería registra “Lavado completado” para transicionar `RETURNED → AVAILABLE`. |
| **Consecuencia** | La devolución y la disponibilidad quedan separadas y generan eventos distintos. La UI debe mostrar la cola pendiente de lavado y nunca presentar `RETURNED` como disponible. |
| **Revisar para V2** | NO — es la semántica aprobada para el piloto. |

---

## DL-007 — JWT stateless para autenticación

| Campo | Valor |
|---|---|
| **ID** | DL-007 |
| **Problema** | No está definido el mecanismo de autenticación (D-007). |
| **Spec afectada** | `specs/security/access-control.md`, `specs/features/authentication/requirements.md` |
| **Opciones** | (A) JWT stateless. (B) Sesión con cookies HttpOnly. (C) OAuth2 con provider externo. |
| **Decisión temporal** | **(A) JWT stateless aprobado para desarrollo/MVP demostrable.** Login con username/password → JWT access token (expiración: 4 horas). Sin refresh token en V1. El token incluye user ID, username y un rol reconocido. Spring Security valida el token en cada request. Logout es client-side. Las cuentas semilla son exclusivas de desarrollo. |
| **Consecuencia** | El login se conserva y el rol autenticado decide la experiencia. No hay revocación server-side de tokens individuales en V1; el aprovisionamiento institucional, recuperación y endurecimiento productivo deben aprobarse antes del piloto real. |
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

---

## DL-014 — Enrutamiento por rol autenticado; selector descartado

| Campo | Valor |
|---|---|
| **ID** | DL-014 |
| **Problema** | Se necesita revisar y desarrollar las vistas Alumno, Cafetería y Operación ReVuelta sin permitir que el cliente elija privilegios. |
| **Spec afectada** | `specs/ui/mobile.md`, `specs/ui/perspectives.md`, `specs/security/access-control.md` |
| **Opciones** | (A) Selector temporal sin login. (B) Login con cuentas de prueba y enrutamiento por rol firmado. (C) Crear tres aplicaciones separadas. |
| **Decisión temporal** | **(B) Login con cuentas de prueba.** Se descarta el selector. `student1/PARTICIPANT` abre Alumno/maestro, `operator/OPERATOR` abre Cafetería y `admin/ADMIN` abre Operación ReVuelta. Para cambiar de experiencia se cierra sesión y se ingresa con otra cuenta. |
| **Consecuencia** | El prototipo conserva login y prueba el aislamiento de responsabilidades. La cuenta participante no recibe permisos de Cafetería ni administración. Las cuentas y contraseña semilla no pueden habilitarse en producción. |
| **Revisar para V2** | SÍ — sustituir o integrar el aprovisionamiento de prueba con el mecanismo institucional aprobado. |

---

## DL-015 — Cafetería confirma la devolución física

| Campo | Valor |
|---|---|
| **ID** | DL-015 |
| **Problema** | Los mockups permiten interpretar que el alumno finaliza la devolución, mientras el contexto operativo asigna la recepción a Cafetería. |
| **Spec afectada** | `specs/features/return-container/requirements.md`, `specs/ui/student-experience.md`, `specs/ui/cafeteria-experience.md` |
| **Decisión temporal** | Cafetería escanea el QR del recipiente y confirma la recepción física. En ese momento se finaliza la circulación, se desliga el recipiente del participante y pasa a `RETURNED` —“Pendiente de lavado”—. El alumno solo consulta instrucciones y el resultado confirmado por el servidor. |
| **Consecuencia** | La devolución requiere un actor operativo autorizado y no puede completarse desde la perspectiva Alumno. |
| **Revisar para V2** | NO para el piloto actual. |

---

## DL-016 — Activo gráfico oficial del prototipo

| Campo | Valor |
|---|---|
| **ID** | DL-016 |
| **Problema** | Los mockups muestran un símbolo distinto al archivo de marca proporcionado. |
| **Spec afectada** | `specs/ui/reference-mockups.md` |
| **Decisión temporal** | Usar `apps/revuelta-mobile/resources/logo.jpeg` como activo oficial del prototipo ReVuelta. No extraer el símbolo alternativo de las imágenes compuestas. |
| **Consecuencia** | Las pantallas deben adaptar composición, tamaño y contraste al activo aprobado. Una variante transparente puede generarse solo a partir de este archivo y sin rediseñar la marca. |
| **Revisar para V2** | SÍ, si se entrega un paquete de marca oficial nuevo. |

---

## DL-017 — Impacto y notificaciones como demostración

| Campo | Valor |
|---|---|
| **ID** | DL-017 |
| **Problema** | Los mockups muestran métricas ambientales y notificaciones para las que aún no existe fuente o metodología productiva. |
| **Spec afectada** | `specs/ui/student-experience.md` |
| **Decisión temporal** | Mantener ambas vistas en modo mockup/demo, con un indicador visible “Datos de demostración”. No presentar sus valores como resultados reales ni habilitarlas como evidencia del piloto. |
| **Consecuencia** | Permite revisar el diseño sin inventar información operacional. Producción deberá ocultarlas o conectarlas a datos/metodología aprobados. |
| **Revisar para V2** | SÍ — antes de habilitarlas con cifras reales. |
