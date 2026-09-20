# ReVuelta

App para la gestión de contenedores reutilizables del piloto ITVer.

## Usuarios de prueba

Disponibles únicamente para desarrollo local:

| Experiencia | Usuario | Contraseña | Rol |
|---|---|---|---|
| Alumno / maestro | `student1` | `password123` | `PARTICIPANT` |
| Cafetería | `operator` | `password123` | `OPERATOR` |
| Operación ReVuelta | `admin` | `password123` | `ADMIN` |

La aplicación conserva el inicio de sesión. No existe selector libre de experiencia: el backend entrega el rol autenticado y la aplicación debe abrir el shell correspondiente.

Estas credenciales no son aptas para producción.
