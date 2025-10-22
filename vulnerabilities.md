# Vulnerabilities Report

## evindencias 

- App Score (MobSF): ver PDF
- peligros: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `CAMERA`, `INTERNET`, `ACCESS_NETWORK_STATE`
- Certificado: firmado con keystore de debug (desarrollo)
- Reportes: `mobsf_reports/vulnerability_report.pdf` y `reporte de vunerabilidades MobSF.pdf`

## vulnerabilidades descubiertas por mobSF

### 1. Receiver exportado accesible externamente
- **Descripcion:** Se detectó al menos un `BroadcastReceiver` exportado (`exported=true`), invocable por otras apps.
- **Severidad:** Medium–High (según lógica en `onReceive`).
- **Impacto:** Apps externas podrían activar flujos internos o abusar de funcionalidades.
- **cambios:** Enviar un `Intent` explícito/implícito al receiver con datos esperados.
- **correccion:**
  - Si no es necesario: `android:exported="false"`.
  - Si debe ser público: proteger con `android:permission`, validar origen del `Intent` y listas blancas de acciones/datos.

### 2. Permisos de ubicacion peligrosos
- **Descripcion:** `ACCESS_FINE_LOCATION` y `ACCESS_COARSE_LOCATION` declarados.
- **Severidad:** Medium.
- **Impacto:** Riesgo de acceso a ubicacion sensible sin consentimiento adecuado.
- **correccion:** Solicitar en runtime con rationale, limitar uso en segundo plano, revisar necesidad real del permiso.

### 3. Permiso de cámara peligroso
- **Descripcion:** `CAMERA` declarado como peligroso.
- **Severidad:** Medium.
- **Impacto:** Posible captura/uso indebido si no se gestiona correctamente.
- **correcion:** Solicitar en runtime, iniciar captura solo por acción explícita del usuario, limpiar imágenes temporales.

### 4. Politica de tráfico en claro
- **Descripcion:** Se observa `cleartextTrafficPermitted=false` (correcto). Mantener configuración.
- **Severidad:** baja.
- **Impacto** Bloquea HTTP, obliga HTTPS; reducir superficie de MITM.
- **correccion** Verificar endpoints externos, añadir `Network Security Config` por dominio si se requiere excepción temporal.

### 5. Permiso personalizado desconocido
- **Descripcion:** `com.example.gpsmapapp.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` aparece como permiso desconocido.
- **Severidad:** baja a media.
- **Impacto:** Inconsistencias de seguridad si no está definido.
- **correccion:** Definir la `permission` en `AndroidManifest.xml` con `protectionLevel="signature"` para uso interno, o eliminar si no se utiliza.

## Evidencias
- PDF MobSF: `vulnerability_report.pdf`
- Panel de MobSF: Exported Components (1 receiver), Application Permissions (6), App Score y firmas.
- Capturas de pantalla de MobSF (si aplica)
- reportes: `vulnerability_report.pdf`