# QR estáticos de envases de demostración

Este directorio contiene cinco etiquetas QR generadas contra la API local de ReVuelta para los envases `RV-DEMO-001` a `RV-DEMO-005`.

Los SVG son imprimibles y su contenido es el payload estático, firmado y versionado que reconoce el backend. Si se elimina el volumen de PostgreSQL, cambia `QR_SIGNING_SECRET` o se rota un QR, hay que regenerarlos:

```powershell
.\tools\provision-demo-container-qrs.ps1
```

El script es idempotente: reutiliza los envases existentes, activa los que aún estén en `REGISTERED` y vuelve a obtener el payload vigente. Requiere el perfil Docker completo levantado en `http://localhost:8080`.
