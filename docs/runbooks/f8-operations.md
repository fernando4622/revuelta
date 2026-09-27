# Runbook operativo F8

**Estado:** APROBADO para el runtime local/piloto demostrable.
**Alcance:** diagnóstico, contención y recuperación básica de API + PostgreSQL.
**No autoriza:** salida a campo, respaldo/restauración ni rollback productivo; esos gates pertenecen a F9.

## 1. Señales disponibles

| Señal | Acceso | Uso |
|---|---|---|
| `/actuator/health/liveness` | público, solo estado agregado | confirma que el proceso responde |
| `/actuator/health/readiness` | público, solo estado agregado | confirma que API y base están listas |
| `/actuator/prometheus` | solo `ADMIN` | métricas técnicas sin PII ni payloads QR |
| `X-Correlation-ID` | cada respuesta | correlaciona respuesta y log estructurado |
| logs de `revuelta-api` | operador del runtime | operación, resultado, código, HTTP y duración |

Nunca pegar en tickets o chats contraseñas, bearer tokens, secretos JWT/QR ni payloads QR completos.

## 2. Verificación rápida

Desde PowerShell:

```powershell
Invoke-RestMethod http://localhost:8080/actuator/health/liveness
Invoke-RestMethod http://localhost:8080/actuator/health/readiness
docker compose --profile full ps
docker compose --profile full logs --tail 100 revuelta-api
```

Resultado normal: ambos probes muestran `UP`; PostgreSQL y API están en ejecución. Readiness `DOWN` con liveness `UP` indica una dependencia no disponible, normalmente PostgreSQL.

Para consultar métricas localmente, autenticar una cuenta `ADMIN`, mantener el token solo en memoria y enviarlo en `Authorization: Bearer ...`. Una cuenta `PARTICIPANT` u `OPERATOR` debe recibir `403`; una llamada sin sesión debe recibir `401`.

## 3. Alertas mínimas

Estas reglas son el contrato para el sistema de monitoreo que se conecte al piloto. No requieren elegir un proveedor en F8.

| Alerta | Umbral | Consulta/señal |
|---|---|---|
| Readiness caída | dos minutos consecutivos | probe HTTP de readiness distinto de `200` |
| Base/pool no disponible | cualquier incremento en 5 min | `increase(hikaricp_connections_timeout_total[5m]) > 0` o logs `dependency_unavailable` |
| Errores servidor | 5 o más en 5 min | `sum(increase(http_server_requests_seconds_count{status=~"5.."}[5m])) >= 5` |
| Fallos de autenticación | 20 o más en 5 min | `sum(increase(revuelta_authentication_failures_total[5m])) >= 20` |
| Conflictos anómalos | al menos 10 mutaciones y más de 25% son `409` en 10 min | `sum(increase(revuelta_mutations_total{status="409"}[10m])) / sum(increase(revuelta_mutations_total[10m])) > 0.25` junto con denominador `>= 10` |

Las métricas son observaciones; PostgreSQL y el historial append-oriented siguen siendo la fuente de verdad.

## 4. Diagnóstico y contención

1. Capturar hora, endpoint, rol, código HTTP y `X-Correlation-ID`; no capturar el cuerpo enviado si contiene credenciales o QR.
2. Revisar liveness y readiness.
3. Buscar el `correlationId` en el log JSON y confirmar `operation`, `outcome`, `errorCode`, `httpStatus` y `durationMs`.
4. Si readiness falla, comprobar primero el contenedor PostgreSQL y luego los mensajes `dependency_unavailable`/timeouts del pool.
5. Si crecen los `401`, verificar expiración, `iss`, `aud` y `kid`; no desactivar validaciones ni ampliar permisos.
6. Si crecen los `409`, identificar la operación. Los replays y carreras pueden producir conflictos válidos: no modificar filas ni historia manualmente.
7. Ante un resultado móvil incierto, refrescar la consulta correspondiente. No repetir automáticamente entrega, devolución, generación/resolución QR ni lavado.

Contención segura: pausar nuevas operaciones en los dispositivos y conservar el runtime/datos para diagnóstico. No borrar volúmenes, no editar tablas y no rotar secretos sin un procedimiento coordinado.

## 5. Recuperación de dependencia

Para una interrupción local deliberada de PostgreSQL:

```powershell
docker compose --profile full stop postgres
Invoke-RestMethod http://localhost:8080/actuator/health/liveness
Invoke-WebRequest http://localhost:8080/actuator/health/readiness -SkipHttpErrorCheck
docker compose --profile full start postgres
Invoke-RestMethod http://localhost:8080/actuator/health/readiness
```

Se espera liveness `UP`, readiness no disponible durante la interrupción y recuperación automática de readiness al volver PostgreSQL. Después, autenticar el rol adecuado y consultar un recurso ya persistido; no ejecutar una mutación como prueba si basta una lectura.

Si la API no se recupera después de que PostgreSQL esté saludable:

```powershell
docker compose --profile full restart revuelta-api
docker compose --profile full logs --tail 200 revuelta-api
```

Escalar cuando readiness no se recupere en cinco minutos, se repitan errores `5xx`, haya evidencia de corrupción/invariante rota o sea necesaria cualquier edición de datos. Registrar correlaciones y la ventana temporal, no secretos.

## 6. Rotación de firma JWT

1. Generar fuera del repositorio un secreto Base64 de al menos 256 bits y un `kid` nuevo.
2. Mover la clave activa anterior a `JWT_PREVIOUS_KEYS` y configurar la nueva en `JWT_ACTIVE_KEY_ID`/`JWT_ACTIVE_SECRET`.
3. Reiniciar la API y comprobar que emite con el nuevo `kid` y acepta temporalmente tokens anteriores.
4. Mantener el solapamiento como máximo cuatro horas; después retirar la clave anterior y reiniciar.
5. Verificar login y una lectura autorizada por rol. Nunca imprimir o registrar los secretos.

La rotación no revoca una sesión individual. Aprovisionamiento, revocación anticipada y proveedor institucional siguen fuera de F8.
