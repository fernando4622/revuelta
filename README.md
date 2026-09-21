# ReVuelta

App para la gestión de contenedores reutilizables del piloto ITVer.

## Requisitos de desarrollo

- Docker Desktop con Docker Compose.
- Java 17 para ejecutar el backend Spring Boot 4.1.1 fuera de Docker. El Maven Wrapper incluido descarga Maven 3.9.6.
- Flutter 3.41.9 estable con Dart 3.11.5.

## Arranque local verificable

Desde la raíz del repositorio:

```powershell
docker compose --profile full up -d --build
docker compose ps
```

El API queda en `http://localhost:8080/api/v1` y su salud se consulta en `http://localhost:8080/actuator/health`.

Para ejecutar el backend sin Docker, inicia PostgreSQL y usa el perfil de desarrollo:

```powershell
cd services/revuelta-api
$env:SPRING_PROFILES_ACTIVE = 'dev'
.\mvnw.cmd spring-boot:run
```

En Linux o macOS, usa `./mvnw`.

Para la app móvil:

```powershell
cd apps/revuelta-mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

En un emulador Android normalmente se usa `http://10.0.2.2:8080/api/v1`. En un dispositivo físico se debe indicar una URL HTTPS accesible desde el dispositivo.

## Verificación local

```powershell
cd services/revuelta-api
.\mvnw.cmd verify

cd ../../apps/revuelta-mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test
```

El flujo automático equivalente vive en `.github/workflows/ci.yml`.

## Usuarios de prueba

Disponibles únicamente para desarrollo local:

| Experiencia | Usuario | Contraseña | Rol |
|---|---|---|---|
| Alumno / maestro | `student1` | `password123` | `PARTICIPANT` |
| Cafetería | `operator` | `password123` | `OPERATOR` |
| Operación ReVuelta | `admin` | `password123` | `ADMIN` |

La aplicación conserva el inicio de sesión. No existe selector libre de experiencia: el backend entrega el rol autenticado y la aplicación debe abrir el shell correspondiente.

Estas credenciales no son aptas para producción.

Las cuentas se cargan únicamente con el perfil Spring `dev`. Sin ese perfil, las migraciones comunes retiran las antiguas semillas conocidas y el arranque exige conexión PostgreSQL, `JWT_SECRET` y `QR_SIGNING_SECRET` mediante variables de entorno. Los dos secretos deben ser valores Base64 independientes; no reutilices la clave JWT para firmar QR.
