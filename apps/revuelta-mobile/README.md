# ReVuelta Mobile

Cliente Flutter de ReVuelta. La versión de referencia para desarrollo y CI es Flutter 3.41.9 estable con Dart 3.11.5.

La URL del API se configura al compilar o ejecutar:

```text
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

Ejemplos habituales:

- escritorio/web local: `http://localhost:8080/api/v1`;
- emulador Android: `http://10.0.2.2:8080/api/v1`;
- dispositivo físico: URL HTTPS accesible desde el dispositivo.

Comprobaciones:

```text
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test
```
