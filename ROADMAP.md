# ReVuelta — Roadmap de remediación y entrega del MVP ITVer

> **Estado:** Propuesto para aprobación
> **Versión:** 2.0
> **Última revisión:** 2026-09-18
> **Punto de partida técnico:** commit `4f4967d` (`feat: initialize ReVuelta MVP`)
> **Objetivo:** convertir el prototipo actual en un piloto operativo, seguro y verificable para la Cafetería del Instituto Tecnológico de Veracruz.

---

## 0. Propósito y autoridad

Este documento define la ruta de trabajo para corregir, completar y validar ReVuelta. No declara que el sistema actual esté listo para producción ni reemplaza las especificaciones de producto.

La ejecución debe respetar este orden:

```text
decisión de producto
→ especificación aprobada
→ contrato y pruebas
→ implementación
→ verificación
→ evidencia de aceptación
```

Jerarquía de fuentes:

1. especificaciones de producto y dominio;
2. ADR aprobados;
3. contratos API, UI y datos;
4. `AGENTS.md`;
5. implementación existente;
6. este roadmap;
7. inferencias del equipo.

Si una decisión de negocio material no está especificada, la tarea se detiene en su gate correspondiente. No se debe conservar un comportamiento solo porque ya existe en el código.

---

## 1. Diagnóstico de partida

El repositorio ya contiene una base útil, pero sigue siendo un prototipo parcial. La entrega a GitHub resuelve la trazabilidad del código inicial, no su preparación para piloto.

### 1.1 Activos reutilizables

- Backend Java/Spring Boot organizado por capas.
- Modelo inicial de contenedores, circulaciones y eventos.
- PostgreSQL y migraciones iniciales.
- Contrato OpenAPI inicial.
- Autenticación JWT básica.
- Cliente Flutter con navegación y flujos demostrables.
- Pruebas unitarias iniciales del backend.
- Documentación de arquitectura, dominio y decisiones pendientes.

### 1.2 Brechas que impiden declarar el MVP terminado

| Área | Estado actual | Riesgo |
|---|---|---|
| Producto | Las decisiones abiertas no reflejan por completo las tres perspectivas descritas en `context.md`. | Se puede implementar el flujo equivocado. |
| Especificaciones | Hay reglas bloqueadas, documentos contradictorios y trazabilidad desactualizada. | El código termina siendo la fuente de verdad accidental. |
| Acceso | Existen elementos de registro público o acceso social que no están autorizados para el piloto institucional. | Identidades y permisos incorrectos. |
| Arquitectura móvil | Varias pantallas consumen HTTP y mapas dinámicos directamente. | Reglas duplicadas, estados inconsistentes y baja capacidad de prueba. |
| Datos de UI | Existen métricas, historial, pasaporte y contenido demostrativo codificado. | El usuario puede interpretar datos ficticios como reales. |
| QR | El flujo actual acepta captura manual; no existe un escaneo físico completo y validado. | El recorrido operativo principal no está implementado. |
| Entrega/devolución | Falta cerrar política, identidad, idempotencia y control de concurrencia. | Doble asignación, doble devolución o historial incorrecto. |
| API | Implementación, OpenAPI y catálogo de errores no están completamente alineados. | Clientes impredecibles y errores difíciles de operar. |
| Seguridad | Secretos y semillas ya están aislados y existe escaneo; autorización integral, concurrencia y hardening de piloto siguen pendientes. | Exposición o accesos indebidos si se libera antes de F8/F9. |
| Pruebas | Ya existen pruebas unitarias, de migración PostgreSQL y arquitectura; faltan contrato integral, seguridad, concurrencia y E2E. | Los invariantes operativos críticos aún no están demostrados. |
| Operación | No existe todavía evidencia de observabilidad, respaldo, recuperación, despliegue y rollback del piloto. | Incidentes sin diagnóstico o recuperación confiable. |

### 1.3 Evidencia técnica actual

- El backend compila con el Maven Wrapper real y JDK 17; 62 pruebas pasan, incluidas migraciones y concurrencia sobre PostgreSQL 16, contrato OpenAPI, seguridad HTTP, transacciones y límites arquitectónicos de dominio y aplicación.
- Maven es la única herramienta de build del backend; JDK 17 está fijado y el wrapper descarga Maven 3.9.6.
- Flutter 3.41.9/Dart 3.11.5 ejecuta 8 pruebas; el análisis no presenta errores ni advertencias bloqueantes.
- Trivy 0.74.0 no detecta vulnerabilidades `HIGH/CRITICAL` corregibles ni secretos en la revisión local posterior a actualizar Spring Boot 4.1.1 y Tomcat 11.0.25.
- GitHub Actions completó correctamente los CI remotos hasta el commit `974ad4b` (run `35521927862`).
- No hay evidencia suficiente para autorizar despliegue productivo.

**Decisión de estado:** `NO-GO` para piloto operativo hasta completar los gates P0 de este roadmap.

---

## 2. Producto objetivo según `context.md`

### 2.1 Alcance del primer piloto

El primer despliegue es:

- una sola institución: Instituto Tecnológico de Veracruz;
- una sola ubicación operativa principal: Cafetería del Instituto;
- un punto de devolución ReVuelta asociado;
- circulación de recipientes reutilizables;
- entrega, devolución, consulta de estado e historial trazable;
- operación en español.

No forman parte del alcance actual:

- múltiples campus;
- múltiples restaurantes, comercios o socios;
- marketplace;
- arquitectura multi-tenant general;
- programa de recompensas no especificado;
- aplicación institucional oficial del ITVer;
- integraciones sociales o comerciales no aprobadas.

### 2.2 Perspectivas que deben diseñarse por separado

| Perspectiva | Necesidad principal | Acciones mínimas |
|---|---|---|
| Estudiante | Saber qué recipiente tiene, cuándo devolverlo y dónde hacerlo. | Acceder, consultar préstamo activo, ver fecha límite, historial propio e instrucciones. |
| Personal de cafetería | Atender rápido y sin ambigüedad. | Escanear, identificar recipiente y persona, validar elegibilidad, confirmar entrega o devolución y conocer el siguiente paso. |
| Operación ReVuelta | Controlar el piloto y resolver excepciones. | Registrar/desactivar recipientes, consultar circulación e historial, atender incidencias y revisar indicadores reales. |

La matriz exacta de permisos debe aprobarse en la fase G0; esta tabla no concede permisos por sí misma.

### 2.3 Lenguaje, identidad y experiencia

- Usar “Cafetería” o “Cafetería del Instituto”.
- Evitar términos genéricos como “partner”, “vendor”, “restaurant” o “comercio” en el piloto.
- Presentar ReVuelta como un servicio diferenciado; no aparentar ser la aplicación oficial del ITVer.
- No inventar logotipos, colores oficiales, áreas institucionales ni respaldo formal.
- La interfaz de cafetería debe responder con claridad:
  1. qué recipiente es;
  2. quién lo tiene o recibirá;
  3. si puede entregarse o recibirse;
  4. cuál es el siguiente paso.
- Ninguna cifra ambiental, recompensa, historial o estado puede mostrarse como real si proviene de datos de demostración.

### 2.4 Funciones actuales que requieren decisión o aislamiento

Hasta que exista especificación aprobada, deben retirarse del flujo productivo, esconderse detrás de un modo demo claramente identificado o implementarse correctamente:

- registro público de usuarios;
- acceso con Google o Microsoft;
- mapas o rutas no sustentados por una necesidad operativa;
- notificaciones;
- métricas de impacto ambiental;
- recompensas;
- “pasaporte” con datos ficticios;
- contenido de historial codificado;
- navegación que mezcle funciones de estudiante, cafetería y operación.

---

## 3. Priorización y secuencia obligatoria

### 3.1 Niveles

- **P0 — Bloqueante:** sin esto no se desarrolla el siguiente flujo crítico ni se autoriza piloto.
- **P1 — Necesario para piloto:** debe existir antes de operar con usuarios reales.
- **P2 — Posterior al piloto estable:** aporta valor, pero no debe retrasar la seguridad y consistencia del núcleo.

### 3.2 Mapa de dependencias

```text
G0 Decisiones y specs
 ├─ F1 Build, configuración y CI
 ├─ F2 Arquitectura, errores, contrato y datos
 │   ├─ F3 Identidad y permisos
 │   └─ F4 Registro, consulta y QR
 │       └─ F5 Entrega
 │           └─ F6 Devolución
 │               └─ F7 Experiencias completas e historial
 └──────────────────────────────┬─ F8 Seguridad, observabilidad y resiliencia
                                └─ F9 Validación de campo y salida a piloto
```

No se debe trabajar en F5 o F6 mientras sus reglas de G0 sigan abiertas.

---

## 4. G0 — Cerrar decisiones y especificaciones

**Prioridad:** P0
**Resultado:** comportamiento observable aprobado antes de corregir el núcleo.

### G0-01 — Actores y permisos

**Estado 2026-09-20:** cerrado para el MVP demostrable en la matriz base: `PARTICIPANT`, `OPERATOR` y `ADMIN`. Permanecen abiertos para piloto real las bajas, suplencias, cambios de rol y aprovisionamiento institucional.

Definir:

- roles reales del piloto;
- quién es estudiante, personal de cafetería y operación ReVuelta;
- qué puede consultar y mutar cada rol;
- separación entre funciones operativas y administrativas;
- tratamiento de suplencias, bajas y cambio de rol;
- regla de denegación por defecto.

**Entregables:** matriz actor–acción–recurso y escenarios de autorización.

### G0-02 — Superficies de uso

**Estado 2026-09-20:** decidido e implementado como base móvil. Se conserva una sola aplicación y el rol autenticado determina el shell. No se utiliza un selector libre de perspectiva. Los shells de Cafetería y Operación ReVuelta ya existen; sus módulos sin contrato de datos muestran indisponibilidad explícita y no inventan información operativa.

Decidir:

- si existe una sola app con navegación por rol;
- si cafetería usa una superficie separada;
- si operación ReVuelta usa móvil, web o una herramienta administrativa mínima;
- qué pantallas pertenecen realmente al estudiante.

**Entregables:** mapa de navegación por perspectiva y no-goals de cada superficie.

### G0-03 — Acceso institucional

**Estado 2026-09-20:** la base de desarrollo/MVP está aprobada e implementada parcialmente con username/password, BCrypt, JWT de cuatro horas y logout local. El mecanismo institucional productivo, recuperación, revocación y baja siguen abiertos antes del piloto real.

Especificar:

- método real de autenticación;
- emisor y verificación de identidad;
- duración y renovación de sesión;
- cierre de sesión;
- recuperación o soporte de acceso;
- comportamiento sin conexión;
- datos personales mínimos.

No mantener registro público ni acceso social por conveniencia técnica.

### G0-04 — Alta de estudiantes y personal

**Estado 2026-09-20:** existen cuentas semilla exclusivamente para desarrollo (`student1`, `operator`, `admin`). El alta, importación o vinculación de cuentas reales no está aprobada y no debe inferirse de estas semillas.

Definir si las cuentas son:

- aprovisionadas;
- importadas;
- invitadas;
- vinculadas a un identificador institucional;
- creadas por operación ReVuelta.

Incluir duplicados, bajas, datos incompletos y correcciones.

### G0-05 — Identidad del prestatario

Definir el identificador que usa la entrega:

- quién lo captura;
- cómo se verifica;
- qué parte puede mostrarse al personal;
- cómo se protege en logs y respuestas;
- cómo se evita entregar al usuario equivocado.

### G0-06 — Propietario del escaneo

Para entrega y devolución, documentar:

- quién escanea;
- qué dispositivo se usa;
- quién confirma;
- qué ocurre si falla la cámara;
- si existe captura manual y bajo qué permiso;
- cómo se maneja un reintento.

### G0-07 — Ciclo de vida del recipiente

Cerrar la matriz completa para:

```text
REGISTERED
AVAILABLE
ASSIGNED
IN_USE
RETURNED
DAMAGED
LOST
RETIRED
```

Definir:

- transición, actor y precondiciones;
- estado posterior a entrega y devolución;
- inspección;
- daño, pérdida, retiro y corrección;
- diferencia exacta entre `ASSIGNED`, `IN_USE` y `RETURNED`;
- evento de historial producido por cada transición.

### G0-08 — Política de devolución

Definir:

- fecha límite;
- fuente de la política;
- versión de política aplicada;
- zona horaria;
- puntualidad/retraso;
- excepciones;
- cambios posteriores de política;
- información visible para estudiante y personal.

### G0-09 — Idempotencia y duplicados

Clasificar cada endpoint mutante. Para entrega y devolución, decidir:

- clave idempotente;
- alcance y vigencia;
- respuesta ante repetición;
- comportamiento después de timeout;
- estrategia ante doble toque, reescaneo o repetición desde otro dispositivo.

### G0-10 — Contenido del QR

Definir:

- formato y versión;
- identificador expuesto;
- firma o protección contra manipulación, si aplica;
- rotación/reimpresión;
- QR desconocido, malformado, inactivo o alterado;
- ausencia de autorización implícita por escanear.

### G0-11 — Terminología e identidad visual

Aprobar:

- nombres del servicio y ubicaciones;
- textos principales en español;
- tratamiento de marca ReVuelta e ITVer;
- avisos para evitar afiliación institucional falsa;
- estados y mensajes de error comprensibles.

### G0-12 — Operación del piloto

Definir:

- ambiente y responsable de despliegue;
- volumen estimado de recipientes y usuarios;
- horario y responsables de soporte;
- dispositivo de cafetería;
- conexión disponible;
- procedimiento manual de contingencia;
- respaldo, recuperación y rollback;
- criterio de suspensión del piloto.

### Documentos que deben quedar alineados

- `context.md`;
- specs de producto, autenticación, QR, ciclo de vida, circulación, historial y UI;
- modelo de datos;
- OpenAPI;
- ADR de decisiones técnicas afectadas;
- registro de decisiones;
- matriz de trazabilidad;
- estado de implementación.

### Resoluciones aprobadas — actualización 2026-09-20

- Tres perspectivas: Alumno, Cafetería y Operación ReVuelta.
- Una sola aplicación conserva el inicio de sesión; no existe selector libre de perspectiva.
- El rol autenticado decide la experiencia: `PARTICIPANT` → Alumno/maestro, `OPERATOR` → Cafetería y `ADMIN` → Operación ReVuelta.
- Para desarrollo se usan `student1`, `operator` y `admin`; las credenciales semilla están prohibidas en producción.
- Participante identificado mediante Código ReVuelta persistente, opaco y sin PII.
- Cafetería escanea Código ReVuelta + QR de recipiente para entregar.
- Un participante puede tener múltiples recipientes activos.
- Cafetería escanea y confirma la devolución física.
- La devolución finaliza la circulación y transiciona `IN_USE → RETURNED`.
- `RETURNED` significa “Pendiente de lavado”.
- Cafetería ejecuta “Lavado completado” para `RETURNED → AVAILABLE`.
- Punto: “Punto ReVuelta — Cafetería del Instituto”.
- Activo de marca: `apps/revuelta-mobile/resources/logo.jpeg`.
- Impacto y notificaciones se permiten como mockup con “Datos de demostración”, no como hechos productivos.

Siguen abiertos el aprovisionamiento/recuperación institucional para producción, la vinculación real cuenta–participante, la recuperación del Código ReVuelta, la duración final de la política y la evidencia de estados excepcionales. La representación de tiempo, replay del MVP y concurrencia ya tienen decisión técnica aprobada.

### Evidencia de avance — 2026-09-20

- El backend reconoce `PARTICIPANT`, `OPERATOR` y `ADMIN`.
- `student1` recibe `PARTICIPANT` mediante la migración V6.
- Una cuenta sin exactamente un rol reconocido falla cerrada y no hereda permisos de Cafetería.
- Credenciales inválidas se traducen a `401 INVALID_CREDENTIALS`.
- La suite backend compila con Java 17: 62 pruebas, 0 fallos y 0 errores.
- Flyway aplicó V6 contra PostgreSQL real y se verificaron los roles efectivos de `student1`, `operator` y `admin` mediante el API.
- Flutter enruta `PARTICIPANT`, `OPERATOR` y `ADMIN` a shells separados y falla cerrado ante un rol no soportado.
- La app ya no ofrece registro público ni recuperación simulada desde la ruta de login aprobada.
- La suite Flutter ejecuta 8 pruebas, incluidas configuración, resolución de rol y aislamiento de shells, sin fallos.

### Gate G0

- [ ] No existen decisiones bloqueantes para autenticación, roles, entrega, devolución, QR y tiempo.
- [ ] Cada flujo crítico tiene escenarios Given/When/Then aprobados.
- [x] Los no-goals del piloto están escritos.
- [ ] La trazabilidad enlaza requisito → spec → contrato → prueba prevista.

G0 no está cerrado por completo. Esto no impide continuar el slice de autenticación y enrutamiento por rol, cuya especificación sí está lista; sí impide declarar listas las operaciones críticas de entrega/devolución mientras idempotencia, tiempo y concurrencia sigan abiertas.

---

## 5. F1 — Build reproducible, configuración segura y CI

**Prioridad:** P0
**Dependencia:** puede avanzar en paralelo con G0 solo en tareas que no impliquen reglas de negocio.

### Trabajo

1. [x] Elegir Maven como herramienta canónica del backend.
2. [x] Instalar un Maven Wrapper real y fijar JDK 17.
3. [x] Retirar configuración Gradle redundante.
4. [x] Documentar versiones compatibles de Flutter y Dart.
5. [x] Separar configuración de desarrollo y despliegue; las pruebas usan configuración explícita y PostgreSQL efímero.
6. [x] Eliminar secretos y credenciales predecibles de rutas de producción.
7. [x] Aislar datos semilla de desarrollo.
8. [x] Hacer configurable la URL del API móvil.
9. [x] Crear CI con:
   - compilación backend;
   - pruebas unitarias;
   - pruebas de migración e integración;
   - validación OpenAPI;
   - análisis/formato/pruebas Flutter;
   - detección de secretos;
   - verificación de dependencias y arquitectura.
10. [x] Actualizar el README con arranque local verificable.

### Gate F1

- [x] Un checkout limpio compila con versiones documentadas en GitHub Actions.
- [x] CI reproduce los checks obligatorios.
- [x] Ningún secreto real fue detectado por el gate local automatizado.
- [x] Las migraciones comunes no dejan usuarios demo; existe prueba PostgreSQL ejecutable.
- [x] La URL del API móvil es configurable con `API_BASE_URL`.

**Estado 2026-09-20:** F1 cerrada. La ejecución remota `35519801008` terminó correctamente sobre `cce83b7`.

---

## 6. F2 — Arquitectura, errores, contrato y consistencia de datos

**Prioridad:** P0
**Dependencias:** G0 para semántica; F1 para verificación.

### Estado — 2026-09-20: cerrada

- `LoginUseCase` ya depende de puertos de aplicación para emitir tokens, verificar contraseñas y auditar rechazos; JWT, BCrypt y logging quedan en adaptadores de infraestructura.
- `ApplicationArchitectureTest` impide dependencias de producción desde `application` hacia `infrastructure` o `interfaces`.
- Los límites, las transacciones y la correlación están verificados con 62 pruebas y OpenAPI válido.
- Cada respuesta HTTP recibe un `X-Correlation-ID` generado por el servidor; los errores reutilizan ese valor en `traceId` y rechazan valores entrantes no confiables.
- Aplicación ya no depende de Spring ni Lombok; la demarcación transaccional usa un puerto y un adaptador Spring probado para `commit` y `rollback`.
- Los fallos esperados usan códigos estables y se traducen a `400/404/409` sin filtrar detalles internos.
- Rutas y campos públicos de respuesta tienen una prueba automática de paridad con OpenAPI; Redocly valida el contrato sin advertencias.
- La migración V8 agrega versión/origen de política, `RETURNED`, restricciones de consistencia, versiones optimistas y correlación de eventos.
- PostgreSQL demuestra un único ganador bajo entrega concurrente y permite varios recipientes activos para el mismo participante.
- Los eventos se persisten de forma append-only desde el puerto público y conservan actor, tiempo del servidor, operación y correlación.

### 6.1 Fallos y límites de capa

- Crear fallos de dominio/aplicación estables, no excepciones genéricas con textos arbitrarios.
- Alinear el catálogo público de errores.
- Mapear intencionalmente `400`, `401`, `403`, `404`, `409` y `500`.
- Evitar que controladores contengan decisiones de negocio.
- Definir puertos de aplicación; la capa de aplicación no debe depender directamente de detalles de infraestructura.
- Mantener dominio libre de Spring, JPA, Jackson y HTTP.
- Emitir identificador de correlación sin exponer detalles internos.

### 6.2 Modelo y base de datos

- Crear migraciones aditivas para cualquier ajuste.
- Registrar versión/origen de la política aplicada a una circulación.
- Definir nulabilidad, unicidad, claves foráneas y restricciones coherentes con specs.
- Seleccionar y documentar la estrategia de concurrencia:
  - restricción única;
  - bloqueo optimista;
  - bloqueo pesimista;
  - actualización condicional atómica;
  - combinación mínima necesaria.
- Proteger el historial contra reescritura o borrado casual.
- Revisar cascadas y operaciones administrativas destructivas.

### 6.3 Contrato

- Hacer de OpenAPI la descripción exacta de:
  - autenticación y autorización;
  - esquemas;
  - errores;
  - conflictos;
  - idempotencia;
  - filtros/paginación;
  - ejemplos.
- Eliminar endpoints no documentados o documentarlos antes de habilitarlos.
- Agregar pruebas de contrato servidor–cliente.

### Gate F2

- [x] No hay excepciones genéricas para fallos esperados en los casos de uso; validaciones sintácticas se traducen a `VALIDATION_ERROR`.
- [x] Dominio y aplicación respetan la dirección de dependencias.
- [x] OpenAPI e implementación coinciden en rutas y campos públicos de respuesta, con validación Redocly.
- [x] Las restricciones relacionales y la concurrencia están documentadas y probadas sobre PostgreSQL 16.
- [x] El historial conserva actor, tiempo del servidor, operación y correlación.

---

## 7. F3 — Identidad, autenticación y autorización

**Prioridad:** P0
**Dependencias:** G0-01 a G0-05, F2.

### Estado — 2026-09-20

Completado y verificado en backend:

- login username/password para cuentas provisionadas de desarrollo;
- BCrypt y JWT con rol;
- rol `PARTICIPANT` para `student1`;
- rechazo seguro de roles ausentes, múltiples o desconocidos;
- respuesta `401 INVALID_CREDENTIALS`;
- contrato `application/problem+json` para token ausente, inválido o expirado (`401 UNAUTHENTICATED`);
- rechazo `403 FORBIDDEN_OPERATION` probado al intentar saltar la UI con un rol `PARTICIPANT`;
- pruebas unitarias de autenticación y resolución de rol.

Pendiente para cerrar F3:

- probar `403` por rol en cada endpoint sensible;
- definir aprovisionamiento, baja, recuperación y revocación para el piloto real.

### Trabajo

1. Implementar el método de acceso aprobado.
2. Implementar aprovisionamiento/baja según especificación.
3. Validar credenciales sin revelar si una cuenta existe más allá de lo permitido.
4. Devolver `401` para autenticación inválida o expirada.
5. Devolver `403` para una operación no autorizada.
6. Aplicar autorización en cada caso de uso sensible.
7. Hacer que el filtro de seguridad responda con el contrato JSON común.
8. Implementar expiración, renovación —si fue aprobada— y cierre de sesión.
9. Separar navegación y acciones por permisos, sin usar la UI como control de seguridad.
10. Retirar registro público y acceso social si no fueron aprobados.
11. Auditar cambios de rol y acciones administrativas.

### Pruebas mínimas

- acceso correcto e incorrecto;
- token ausente, alterado y expirado;
- rol correcto e incorrecto;
- acceso directo al API saltándose la UI;
- usuario dado de baja;
- datos personales ausentes en logs.

### Gate F3

- [ ] Cada endpoint sensible tiene prueba de autorización.
- [x] El servidor niega por defecto solicitudes sin una sesión válida y usa el contrato de error común.
- [ ] No existen credenciales o flujos demo en producción.
- [ ] La experiencia móvil representa correctamente sesión vencida y acceso denegado.

---

## 8. F4 — Registro, consulta operativa y QR real

**Prioridad:** P0
**Dependencias:** G0-07, G0-10, F2, F3.

### 8.1 Backend

- Registrar un recipiente con identificador definido y evento inicial.
- Resolver QR como entrada no confiable.
- Distinguir QR malformado, desconocido, inactivo o alterado.
- Consultar detalle operativo:
  - estado;
  - circulación activa;
  - prestatario visible según permisos;
  - momento de entrega;
  - fecha límite;
  - historial;
  - acciones permitidas.
- Desactivar/retirar con transición explícita; no borrar historial.

### 8.2 Flutter

- Integrar escáner de cámara real.
- Declarar y manejar permisos de cámara.
- Modelar estados `Initial / RequestingPermission / Scanning / Resolving / Success / Failure`.
- Evitar dobles lecturas mediante pausa/debounce.
- Mostrar captura manual solo si G0 la autoriza.
- Traducir fallos sin inventar la elegibilidad en la UI.
- Eliminar datos de ejemplo del detalle productivo.

### Pruebas mínimas

- payload válido, inválido, desconocido e inactivo;
- manipulación o formato no soportado;
- escaneo repetido;
- permiso de cámara denegado;
- resolución con rol no autorizado;
- prueba en dispositivo físico objetivo.

### Gate F4

- [ ] El QR físico del piloto se resuelve de extremo a extremo.
- [ ] Escanear nunca concede autorización.
- [ ] La UI muestra únicamente información real del servidor.
- [ ] El operador puede distinguir claramente la siguiente acción válida.

---

## 9. F5 — Entrega de recipiente

**Prioridad:** P0
**Dependencias:** G0 completo para entrega, F2–F4.

### Resultado atómico esperado

Una entrega exitosa debe:

1. autenticar y autorizar al actor;
2. resolver y validar el recipiente;
3. resolver y validar al prestatario;
4. comprobar disponibilidad;
5. seleccionar una política de devolución versionada;
6. usar tiempo autoritativo del servidor;
7. crear exactamente una circulación activa;
8. cambiar el estado mediante una transición válida;
9. registrar exactamente un evento trazable;
10. responder de forma estable ante reintento.

Todo lo anterior debe confirmar o revertir como una sola operación.

### Correcciones obligatorias

- No usar una política silenciosa por defecto.
- Guardar la política y versión aplicada.
- Impedir dos circulaciones activas para el mismo recipiente.
- Convertir conflictos de base de datos a un error de negocio estable.
- Definir idempotencia y deduplicación.
- No exigir que el personal memorice o capture UUID internos.
- Mostrar confirmación antes de una mutación irreversible cuando la spec lo requiera.

### Pruebas mínimas

- entrega válida;
- recipiente inexistente/no disponible/inactivo;
- usuario inexistente/no elegible;
- operador no autorizado;
- política ausente;
- reintento con la misma clave;
- rollback si falla el evento o la actualización;
- dos dispositivos intentan entregar el mismo recipiente casi simultáneamente;
- verificación de tiempo y fecha límite.

### Gate F5

- [ ] Una carrera produce una entrega y un conflicto controlado.
- [ ] Nunca quedan dos circulaciones activas.
- [ ] Estado, circulación y evento siempre coinciden.
- [ ] La app puede recuperarse de timeout sin duplicar la operación.

---

## 10. F6 — Devolución de recipiente

**Prioridad:** P0
**Dependencias:** G0 completo para devolución, F5.

### Resultado atómico esperado

Una devolución exitosa debe:

1. autenticar y autorizar al actor;
2. resolver y validar el recipiente;
3. localizar una única circulación activa;
4. tomar el tiempo autoritativo del servidor;
5. finalizar la circulación una sola vez;
6. calcular puntualidad según la política aplicada;
7. ejecutar la transición de estado aprobada;
8. registrar exactamente un evento;
9. responder de manera determinista ante repetición.

### Correcciones obligatorias

- Usar la estrategia de concurrencia aprobada.
- Evitar que dos devoluciones creen dos eventos.
- Distinguir “sin circulación activa” de “ya devuelto”.
- Definir si existe inspección antes de volver a `AVAILABLE`.
- No aceptar fechas del cliente como tiempo de negocio.
- Después de un timeout, permitir consultar el resultado antes de repetir.

### Pruebas mínimas

- devolución válida y tardía;
- recipiente desconocido o inactivo;
- ausencia de circulación activa;
- devolución repetida;
- rol no autorizado;
- dos dispositivos devuelven simultáneamente;
- rollback ante fallo parcial;
- preservación de la política histórica.

### Gate F6

- [ ] Una carrera produce una devolución y una respuesta idempotente/conflicto definido.
- [ ] No hay eventos duplicados.
- [ ] El recipiente nunca queda en un estado imposible.
- [ ] El resultado visible proviene del servidor.

---

## 11. F7 — Flutter limpio, historial y experiencias por perspectiva

**Prioridad:** P1
**Dependencias:** F3–F6.

### 11.1 Arquitectura móvil

Organizar el flujo conceptual:

```text
Widget/Page
→ Controller / Notifier
→ Use Case
→ Domain
→ Repository interface
→ Remote/local adapter
```

Acciones:

- mover Dio, DTO y JSON a la capa de datos;
- reemplazar `Map<String, dynamic>` en widgets por modelos tipados;
- evitar llamadas directas a `ApiClient` desde pantallas;
- modelar estados asíncronos explícitos;
- traducir errores a mensajes en español;
- controlar navegación, cancelación, `mounted` y pérdida de red;
- agregar pruebas de widget y de estado.

### 11.2 Experiencia del estudiante

Como mínimo:

- préstamo activo real;
- recipiente;
- fecha/hora límite;
- lugar e instrucciones de devolución;
- historial propio;
- estado vacío;
- sesión/error/sin conexión;
- privacidad adecuada.

### 11.3 Experiencia de cafetería

Como mínimo:

- escáner;
- identificación operativa mínima;
- elegibilidad;
- entrega;
- devolución;
- conflictos y reintentos;
- flujo breve, legible y sin funciones administrativas innecesarias.

### 11.4 Experiencia de operación ReVuelta

Como mínimo:

- alta y retiro de recipientes;
- búsqueda y detalle;
- circulación activa;
- historial y actor;
- incidencias aprobadas;
- métricas exclusivamente derivadas de datos reales.

### Consultas necesarias

Implementar contratos explícitos para:

- circulación activa del estudiante;
- historial propio paginado;
- detalle operativo por recipiente;
- listado/búsqueda de recipientes para operación;
- eventos con filtros autorizados.

### Gate F7

- [ ] No hay HTTP ni JSON crudo en widgets.
- [ ] No hay información de negocio ficticia en modo productivo.
- [ ] Cada perspectiva ve solo sus funciones.
- [ ] Estados de carga, vacío, error, éxito y sesión vencida están cubiertos.

---

## 12. F8 — Seguridad, observabilidad y resiliencia

**Prioridad:** P1
**Dependencias:** atraviesa F2–F7 y se cierra antes de F9.

### Seguridad

- modelar amenazas para autenticación, QR, identificadores, PII y base de datos;
- endurecer CORS y cabeceras;
- validar firma, emisor, audiencia, expiración y rotación JWT según spec;
- limitar tamaño y formato de entradas;
- evitar enumeración de usuarios y recursos;
- revisar dependencias;
- verificar que logs y respuestas no expongan secretos ni datos innecesarios;
- probar acceso directo al API y repetición de solicitudes.

### Observabilidad

- propagar `correlationId`;
- logs estructurados por operación y resultado;
- métricas de entrega, devolución, conflicto y error;
- health, liveness y readiness;
- alertas mínimas para fallos de base de datos, autenticación y tasa anómala de conflictos;
- trazabilidad sin registrar tokens ni payloads sensibles.

### Resiliencia

- timeouts explícitos;
- reintentos únicamente donde sean seguros;
- manejo de pérdida de red;
- consulta de resultado tras respuesta incierta;
- límites de conexión;
- prueba de reinicio y recuperación.

### Gate F8

- [ ] La revisión de seguridad no tiene hallazgos P0/P1 abiertos.
- [ ] Cada mutación crítica puede rastrearse de extremo a extremo.
- [ ] Un timeout o reintento no viola invariantes.
- [ ] Monitoreo y runbook permiten detectar y atender fallos básicos.

---

## 13. F9 — Verificación integral y salida controlada a piloto

**Prioridad:** P0 para liberar
**Dependencias:** todos los gates anteriores.

### 13.1 Pirámide de verificación

| Nivel | Evidencia mínima |
|---|---|
| Dominio | Transiciones, valores, política, fechas e invariantes. |
| Aplicación | Autorización, orquestación, idempotencia y errores. |
| Persistencia | PostgreSQL real, migraciones, restricciones y transacciones. |
| Concurrencia | Entrega y devolución simultáneas desde dos sesiones. |
| Seguridad | Tokens, roles, acceso directo, entradas alteradas y fuga de datos. |
| Contrato | OpenAPI contra servidor y cliente. |
| Flutter | Controladores, widgets, cámara, errores y navegación por rol. |
| E2E | Acceso → escaneo → entrega → consulta → devolución → historial. |
| Operación | Despliegue, respaldo, restauración, observabilidad y rollback. |

### 13.2 Preparación de ambiente

- staging equivalente al piloto;
- migraciones desde una base vacía y desde la versión anterior;
- respaldo y restauración ensayados;
- secretos administrados fuera del repositorio;
- datos semilla controlados;
- dispositivo y QR físicos;
- conectividad real de cafetería;
- cuentas de prueba por rol;
- procedimiento de soporte e incidentes;
- rollback probado.

### 13.3 Prueba de campo

Ejecutar con responsables:

1. alta de recipientes;
2. acceso de cada rol;
3. entrega normal;
4. doble escaneo;
5. pérdida de red durante confirmación;
6. entrega concurrente;
7. consulta del estudiante;
8. devolución normal y tardía;
9. devolución concurrente;
10. recipiente desconocido, dañado, perdido o retirado;
11. consulta de historial;
12. recuperación ante error operativo.

### Gate de salida

- [ ] Todas las specs aplicables están aprobadas.
- [ ] No quedan datos ficticios en el flujo productivo.
- [ ] Todas las migraciones y pruebas obligatorias pasan en CI.
- [ ] No hay defectos P0/P1 abiertos.
- [ ] Seguridad y privacidad tienen aprobación.
- [ ] Respaldo, restauración y rollback fueron demostrados.
- [ ] Cafetería y operación ReVuelta aceptaron los recorridos.
- [ ] Existe responsable y horario de soporte.
- [ ] Se acordaron métricas y criterio de suspensión.

Solo entonces el estado cambia de `NO-GO` a `GO CONTROLADO`.

---

## 14. Plan indicativo de ejecución

Las duraciones son esfuerzo aproximado, no fechas comprometidas. Deben recalcularse después de G0 según capacidad real.

| Tramo | Duración estimada | Salida |
|---|---:|---|
| G0 Decisiones y specs | 2–4 días-persona | Requisitos aprobados y trazables |
| F1 Build y CI | 2–3 días-persona | Entorno reproducible |
| F2 Arquitectura/contrato/datos | 3–5 días-persona | Base consistente y verificable |
| F3 Identidad y permisos | 3–4 días-persona | Acceso institucional seguro |
| F4 Registro/consulta/QR | 3–5 días-persona | Escaneo real y detalle operativo |
| F5 Entrega | 3–4 días-persona | Entrega atómica e idempotente |
| F6 Devolución | 3–4 días-persona | Devolución concurrente segura |
| F7 Experiencias e historial | 4–6 días-persona | Flujos completos por perspectiva |
| F8 Seguridad/observabilidad | 3–5 días-persona | Operación diagnosticable |
| F9 Verificación/piloto | 4–7 días-persona | Evidencia y decisión GO/NO-GO |

**Rango inicial:** 30–47 días-persona, sujeto a las decisiones de G0 y a la disponibilidad de infraestructura e identidad institucional.

Una demostración de una semana puede cubrir una porción del flujo, pero no equivale a un piloto autorizado.

### Iteraciones sugeridas

- **Iteración 0:** G0 + F1.
- **Iteración 1:** F2 + completar autenticación/enrutamiento de F3. La autenticación base del backend ya está implementada.
- **Iteración 2:** F3 completo + F4.
- **Iteración 3:** F5.
- **Iteración 4:** F6 + consultas reales.
- **Iteración 5:** F7 + cierre F8.
- **Iteración 6:** F9 y piloto controlado.

Cada iteración debe terminar con software demostrable, pruebas y documentación alineada.

---

## 15. Definition of Ready por historia

Una historia puede entrar a implementación solo si:

- [ ] tiene propósito y actor;
- [ ] alcance y no-goals son explícitos;
- [ ] precondiciones, entradas y salidas están definidas;
- [ ] permisos están definidos;
- [ ] transiciones e invariantes están definidas;
- [ ] tiempo autoritativo y zona horaria están definidos;
- [ ] errores y conflictos están enumerados;
- [ ] idempotencia/concurrencia están clasificadas;
- [ ] impacto en datos, API y UI está identificado;
- [ ] escenarios de aceptación están aprobados;
- [ ] no depende de una decisión bloqueada.

---

## 16. Definition of Done por vertical

Una entrega vertical está terminada solo si:

- [ ] cumple exactamente la spec aprobada;
- [ ] no introduce comportamiento adicional;
- [ ] dominio, aplicación, adaptadores e UI respetan sus responsabilidades;
- [ ] OpenAPI y modelos del cliente coinciden;
- [ ] migraciones son deterministas;
- [ ] autorización se aplica en servidor;
- [ ] concurrencia e idempotencia están probadas;
- [ ] fallos son tipados y traducidos;
- [ ] pruebas unitarias, integración, contrato y UI relevantes pasan;
- [ ] logs no exponen secretos ni PII innecesaria;
- [ ] documentación y trazabilidad están actualizadas;
- [ ] no hay datos demo en la ruta productiva;
- [ ] CI conserva evidencia del resultado;
- [ ] no existen cambios ajenos al alcance.

---

## 17. Definition of Done del MVP

El MVP del piloto ITVer está completo cuando:

- [ ] las tres perspectivas aprobadas funcionan;
- [ ] autenticación y autorización institucional están validadas;
- [ ] el QR físico funciona en el dispositivo objetivo;
- [ ] entrega y devolución preservan invariantes bajo concurrencia;
- [ ] el estudiante consulta información real;
- [ ] el personal de cafetería completa cada operación sin ambigüedad;
- [ ] operación ReVuelta puede rastrear y atender incidencias;
- [ ] el historial es append-oriented y auditable;
- [ ] no existen endpoints o pantallas productivas sin especificación;
- [ ] el sistema es desplegable, observable, respaldable y reversible;
- [ ] la prueba E2E y la prueba de campo fueron aceptadas;
- [ ] la decisión de salida está firmada por producto, operación y responsable técnico.

---

## 18. Trazabilidad y control de estado

Cada requisito debe mantener esta cadena:

```text
REQ-ID
→ SPEC
→ ADR (si aplica)
→ OPENAPI / MODELO DE DATOS
→ CASO DE USO
→ PRUEBAS
→ EVIDENCIA CI
→ ESTADO
```

Estados recomendados:

```text
DRAFT
→ READY_FOR_REVIEW
→ APPROVED
→ IMPLEMENTING
→ VERIFIED
→ ACCEPTED
```

Reglas:

- “implementado” no significa “verificado”;
- un cambio de requisito vuelve a abrir contrato y pruebas afectadas;
- no se cierra una tarea con checks pendientes;
- el estado de implementación debe derivarse de evidencia, no de una declaración manual;
- cada PR debe indicar requisito, spec, pruebas y riesgos.

---

## 19. Próximo lote concreto

El incremento de **autenticación y navegación por rol** quedó implementado y verificado el 2026-09-20:

- [x] V6 aplicada y tres cuentas verificadas contra PostgreSQL real.
- [x] Router explícito para `PARTICIPANT`, `OPERATOR`, `ADMIN` y rol no soportado.
- [x] Logout común y salida de cualquier navegación secundaria.
- [x] Registro público y recuperación simulada ocultos de la ruta aprobada.
- [x] Pruebas Flutter de resolución, navegación y aislamiento por rol.

F1 quedó implementada y validada local y remotamente el 2026-09-20. El siguiente incremento funcional es **escaneo y resolución QR real de solo lectura**:

1. [x] Confirmar en GitHub la ejecución remota de los gates de F1.
2. Implementar el siguiente vertical operativo:

```text
sesión y shell por rol
→ escaneo QR real de solo lectura
→ resolución de solo lectura
→ detalle operativo real
```

3. Antes de modificar entrega/devolución, cerrar las decisiones de política, idempotencia, tiempo y concurrencia y diseñar sus pruebas PostgreSQL.
4. Implementar entrega solo después de superar ese gate.
5. Implementar devolución solo después de demostrar la entrega concurrente.
6. Liberar a campo únicamente después de F9.

Este orden reduce el riesgo de seguir ampliando una demostración visual sobre reglas todavía indefinidas.
