# Best Practices

Este documento detalla las Buenas Prácticas aplicadas y/o recomendadas para la app.

## Código e infraestructura
- Uso de `network_security_config` para bloquear tráfico HTTP claro (`cleartextTrafficPermitted=false`).
- Preferencia de `HTTPS` en endpoints y bibliotecas de red; revisar dominios permitidos y excepciones.
- Evitar claves/secretos en `AndroidManifest.xml` o código; usar `strings.xml`/variables de entorno.
- Minimizar permisos: solicitar solo los estrictamente necesarios y en tiempo de ejecución.
- Configuración segura de `FileProvider` y `filepaths.xml`.
- Desactivar componentes `exported` innecesarios; revisar `activities`, `services` y `receivers`.
- Añadir validación de origen y contenido de `Intent` en receivers públicos.

## Datos sensibles
- No almacenar datos sensibles en texto plano.
- Cifrar datos en repositorio local si aplica (Room/SQLite con cifrado).
- Evitar logs con información sensible (usar niveles de log apropiados).

## Comunicación
- Validar certificados y evitar `TrustManager` permisivo.
- Considerar `SSL pinning` si se accede a APIs propias de alta sensibilidad.
- Usar políticas de tiempo de espera y reintentos seguros.

## Entrada del usuario
- Validar y sanitizar entradas para prevenir inyección (SQL/XSS en WebViews).

## Entrega y build
- Compilar en modo `release` con `minifyEnabled` y reglas de ProGuard/R8 apropiadas.
- Firmar el APK con keystore seguro; proteger claves de firma.

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
- Referencia: `mobsf_reports/vulnerability_report.pdf` y `reporte de vunerabilidades MobSF.pdf`.
- Para automatizar: considerar `scripts/Run-MobSFScan.ps1` para generar JSON y alimentar resúmenes.

## La app usa Google Maps; no incluye backend propio, por lo que el tráfico es principalmente hacia servicios de Google y controlado por el `network_security_config`.
- Revisar permisos de ubicación/cámara según flujos en la app; mostrar rationale.