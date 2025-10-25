# Buenas Prácticas de Seguridad en Android

- Minimiza permisos peligrosos; solicita en runtime y justifica con rationale.
- Evita hardcodear secretos; usa `strings.xml`, almacenamiento seguro y configuración por entorno.
- Usa `FileProvider` para compartir archivos con URIs seguras.
- Bloquea tráfico en claro; exige HTTPS y valida certificados.
- Firma de release con keystore segura; evita distribuir builds debug.

## Observaciones específicas del proyecto (derivadas de MobSF)
- Exported Components: hay al menos 1 `BroadcastReceiver` exportado.
  - Acción: si no es necesario, poner `android:exported="false"`; si es público, proteger con `android:permission` y validar `Intent`.
- Permisos peligrosos: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `CAMERA`.
  - Acción: pedir en runtime con rationale, limitar uso en segundo plano, iniciar cámara solo por acción explícita del usuario.
- Red: mantener `HTTPS` y el bloqueo de tráfico en claro; revisar excepciones de `Network Security Config` por dominio.
- Permiso personalizado desconocido: `com.example.gpsmapapp.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`.
  - Acción: definir en `AndroidManifest.xml` con `protectionLevel="signature"` si es interno o eliminar si no se usa.
- Firma/Build: el APK analizado está firmado con keystore de debug.
  - Acción: para entrega, usar firma de `release` con keystore gestionada y segura.

## Evidencias
- Referencia: `reporte de vunerabilidades MobSF.pdf`.
