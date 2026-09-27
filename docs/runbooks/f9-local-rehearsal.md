# F9 — Ensayo técnico local y preparación de campo

**Estado:** procedimiento aprobado para laptop + hotspot. No autoriza por sí
solo un piloto real.

## 1. Objetivo

Reproducir el candidato de ReVuelta, ejecutar la verificación automática,
demostrar respaldo/restauración y rollback sin destruir datos, y preparar la
evidencia para la aceptación física.

## 2. Condiciones previas

- Docker Desktop está iniciado.
- Java 17 y Flutter 3.41.9 están disponibles para verificaciones locales.
- El teléfono está conectado al hotspot de la laptop.
- El firewall permite TCP 8080 únicamente en la red del ensayo.
- Los cinco QR estáticos de prueba están disponibles.
- No se usan credenciales ni datos de personas reales.

El perfil `dev` y sus cuentas conocidas solo se permiten en este ensayo local.

## 3. Identificar el candidato

El candidato debe ser un commit sin cambios rastreados pendientes. `output/`
puede contener artefactos locales, pero nunca se agrega automáticamente a Git.

```powershell
git status --short
git rev-parse HEAD
```

## 4. Verificación automática

Backend con Java 17:

```powershell
cd services/revuelta-api
.\mvnw.cmd verify
```

Contrato:

```powershell
npx --yes @redocly/cli@2.53.3 lint services/revuelta-api/src/main/resources/openapi.yaml --extends=minimal
```

Flutter:

```powershell
cd apps/revuelta-mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test
```

El run de GitHub Actions del mismo commit debe aprobar backend, contrato,
seguridad y móvil. No se sustituye un fallo local o de CI por una observación
manual.

## 5. Arranque del staging local

Desde la raíz:

```powershell
docker compose --profile full up -d --build
docker compose ps
```

Validar:

```powershell
Invoke-RestMethod http://localhost:8080/actuator/health/liveness
Invoke-RestMethod http://localhost:8080/actuator/health/readiness
```

Ambos estados deben ser `UP`.

## 6. Respaldo y restauración aislada

```powershell
.\tools\f9\Test-F9DatabaseRecovery.ps1
```

El procedimiento:

- crea un respaldo con SHA-256 fuera del repositorio;
- crea una base nueva con prefijo `revuelta_f9_restore_`;
- restaura sin sobrescribir `revuelta_db`;
- compara usuarios, recipientes, circulaciones, eventos y migraciones;
- conserva el respaldo, la base restaurada y el manifiesto para inspección.

No se obtiene evidencia válida solo por crear el archivo: restauración y
comparación deben terminar correctamente.

## 7. Ensayo de rollback de aplicación

Debe existir una API levantada que represente la versión anterior. Después:

```powershell
.\tools\f9\Test-F9ApplicationRollback.ps1
```

El procedimiento conserva el ID de la imagen anterior, construye la candidata,
detiene temporalmente la API Compose, valida candidata y anterior sobre el
esquema actual mediante salud, login y lectura autenticada, y finalmente vuelve
a iniciar la API normal. No revierte migraciones ni modifica historia.

Si la versión anterior no arranca sobre el esquema actual, el resultado es
`NO-GO`; se requiere un forward-fix o una estrategia compatible aprobada.

## 8. APK para el hotspot

Sustituir `<IP_LAPTOP>` por la dirección IPv4 del adaptador hotspot:

```powershell
cd apps/revuelta-mobile
flutter build apk --debug --dart-define=API_BASE_URL=http://<IP_LAPTOP>:8080/api/v1
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

`adb reverse` sirve para un teléfono conectado por USB, pero no prueba que
otros teléfonos del hotspot puedan alcanzar la laptop.

## 9. Manifiesto de candidato

Después de construir el APK y levantar la API:

```powershell
.\tools\f9\New-F9ReleaseManifest.ps1
```

El manifiesto se escribe en la carpeta temporal del sistema e incluye commit,
checksum del APK, imagen API y configuración aprobada. Conserva `NO-GO` hasta
la aceptación física y los bloqueos expresos.

## 10. Prueba física y decisión

Completar `docs/testing/f9-field-acceptance.md`. Las capturas no deben mostrar
tokens, contraseñas ni payloads QR dinámicos. Registrar únicamente referencias
opacas, hora UTC, resultado y correlación cuando sea necesaria.

La salida máxima del ensayo sin responsables/firma es
`READY FOR FIELD VALIDATION`; nunca `GO CONTROLADO`.

## 11. Recuperación ante fallo del ensayo

1. No borrar el volumen PostgreSQL ni el respaldo.
2. Confirmar que `docker compose --profile full up -d revuelta-api` recupera la
   API normal.
3. Verificar liveness, readiness y consulta autenticada.
4. Conservar la base restaurada y logs para diagnóstico.
5. Registrar P0/P1 si hay pérdida, corrupción, acceso indebido o discrepancia
   entre posesión física y estado del servidor.
