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

## Código de mitigación ejemplificado

- Solicitar permisos de ubicación de forma robusta:
```java
ActivityCompat.requestPermissions(this,
    new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION},
    LOCATION_PERMISSION_REQUEST_CODE);
```

- Habilitar ubicación cuando se conceda FINE o COARSE:
```java
if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
    ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
    mMap.setMyLocationEnabled(true);
    getCurrentLocation();
}
```

- Verificar permisos concedidos en `onRequestPermissionsResult`:
```java
boolean fineGranted = false, coarseGranted = false;
for (int i = 0; i < permissions.length; i++) {
    if (Manifest.permission.ACCESS_FINE_LOCATION.equals(permissions[i])) {
        fineGranted = grantResults.length > i && grantResults[i] == PackageManager.PERMISSION_GRANTED;
    } else if (Manifest.permission.ACCESS_COARSE_LOCATION.equals(permissions[i])) {
        coarseGranted = grantResults.length > i && grantResults[i] == PackageManager.PERMISSION_GRANTED;
    }
}
if (fineGranted || coarseGranted) {
    if (mMap != null) { mMap.setMyLocationEnabled(true); }
    getCurrentLocation();
} else {
    boolean permanentlyDenied = !ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.ACCESS_FINE_LOCATION);
    // Abrir Ajustes si está denegado permanentemente
}
```

- Uso seguro de FileProvider y limpieza de recursos de cámara:
```java
photoUri = FileProvider.getUriForFile(this, getPackageName() + ".fileprovider", photoFile);
takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoUri);
takePictureIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
// Tras usar la URI
revokeUriPermission(photoUri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
// Limpieza si se cancela o falla
if (photoFile != null && photoFile.exists()) { photoFile.delete(); }
```

- Política de red segura:
```xml
<application
    android:usesCleartextTraffic="false"
    android:networkSecurityConfig="@xml/network_security_config">
```

```xml
<network-security-config>
    <base-config cleartextTrafficPermitted="false" />
</network-security-config>
```

## Evidencias
- PDF MobSF: `vulnerability_report.pdf`
- Panel de MobSF: Exported Components (1 receiver), Application Permissions (6), App Score y firmas.
- Capturas de pantalla de MobSF (si aplica)
- reportes: `vulnerability_report.pdf`