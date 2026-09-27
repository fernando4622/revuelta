# F9 — Acta de validación física y decisión de piloto

**Estado inicial:** `NO-GO`

Esta acta se completa durante una ejecución física. Una casilla sin evidencia
permanece pendiente; no se marca por inferencia ni por una prueba automatizada.

## 1. Candidato

| Campo | Valor |
|---|---|
| Commit | Pendiente |
| APK SHA-256 | Pendiente |
| Imagen API | Pendiente |
| Configuración | Laptop + hotspot, ventana 48 horas |
| Dispositivo/Android | Pendiente |
| Fecha/hora UTC | Pendiente |
| Resultado CI | Pendiente |

## 2. Responsables

| Responsabilidad | Nombre | Aceptación |
|---|---|---|
| Cafetería | Pendiente | Pendiente |
| Operación ReVuelta | Pendiente | Pendiente |
| Participante de prueba | Pendiente | Pendiente |
| Soporte | Pendiente | Pendiente |
| Autoridad de liberación | Pendiente | Pendiente |

Horario y vía de soporte: **Pendiente**.

Objetivo de recuperación aprobado: **Pendiente**.

## 3. Gate técnico

- [ ] Backend completo y PostgreSQL real pasan.
- [ ] Migración vacía y desde la versión anterior pasan.
- [ ] OpenAPI pasa.
- [ ] Flutter formato/análisis/pruebas pasan.
- [ ] APK del commit registrado se construye.
- [ ] Seguridad/secretos pasan en CI.
- [ ] Respaldo tiene checksum y fue restaurado en base aislada.
- [ ] Datos e historia restaurados coinciden.
- [ ] Rollback de aplicación fue demostrado.
- [ ] No existen defectos P0/P1 abiertos.

## 4. Recorridos físicos

| ID | Recorrido | Resultado | Evidencia/defecto |
|---|---|---|---|
| F9-PHY-01 | Acceso y denegación por cada rol | Pendiente | Pendiente |
| F9-PHY-02 | Alta/activación de cinco recipientes | Pendiente | Pendiente |
| F9-PHY-03 | Entrega con QR participante + QR recipiente | Pendiente | Pendiente |
| F9-PHY-04 | Dos recipientes activos para un participante | Pendiente | Pendiente |
| F9-PHY-05 | QR malformado, desconocido y repetido | Pendiente | Pendiente |
| F9-PHY-06 | Pérdida de respuesta/red durante entrega | Pendiente | Pendiente |
| F9-PHY-07 | Dos entregas concurrentes del mismo recipiente | Pendiente | Pendiente |
| F9-PHY-08 | Consulta del participante y vencimiento a 48 h | Pendiente | Pendiente |
| F9-PHY-09 | Devolución normal con ambos QR | Pendiente | Pendiente |
| F9-PHY-10 | Devolución tardía | Pendiente | Pendiente |
| F9-PHY-11 | Pérdida de respuesta/red durante devolución | Pendiente | Pendiente |
| F9-PHY-12 | Dos devoluciones concurrentes | Pendiente | Pendiente |
| F9-PHY-13 | Pendiente de lavado → lavado → disponible | Pendiente | Pendiente |
| F9-PHY-14 | Historial completo y correlación | Pendiente | Pendiente |
| F9-PHY-15 | Caída/recuperación de PostgreSQL | Pendiente | Pendiente |

Las incidencias `IN_USE → DAMAGED/LOST` no se ejecutan mientras siga abierto el
resultado de D-004 sobre la circulación activa.

## 5. Defectos

| ID | Severidad | Descripción | Disposición | Responsable |
|---|---|---|---|---|
| — | — | Sin registrar | — | — |

P0/P1 obliga a suspender. P2 exige una disposición expresa. P3 puede
programarse sin cambiar semántica de negocio.

## 6. Seguridad y privacidad

- [ ] No se usaron personas ni credenciales reales.
- [ ] Evidencia sin contraseñas, JWT, secretos o QR dinámicos.
- [ ] Llamadas directas respetan roles.
- [ ] El teléfono solo alcanzó la API por la red prevista.
- [ ] No hubo exposición o mutación no autorizada.

Revisor y aceptación: **Pendiente**.

## 7. Criterio de suspensión

Suspender ante P0/P1, acceso indebido, exposición de secretos, estado distinto
de la posesión física, restauración fallida, indisponibilidad superior al
objetivo aprobado o retiro de aceptación de Cafetería/ReVuelta.

## 8. Decisión

- [ ] `NO-GO`
- [ ] `READY FOR FIELD VALIDATION`
- [ ] `GO CONTROLADO`

Justificación: **Pendiente**.

Firma Cafetería: **Pendiente**.

Firma Operación ReVuelta: **Pendiente**.

Firma autoridad de liberación: **Pendiente**.
