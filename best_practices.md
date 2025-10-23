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

## Ejemplos de implementación (snippets)
- Solicitud de permisos de ubicación robusta:
```java
ActivityCompat.requestPermissions(this,
    new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION},
    LOCATION_PERMISSION_REQUEST_CODE);
```

- Habilitar ubicación si FINE o COARSE están concedidos:
```java
if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
    ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
    mMap.setMyLocationEnabled(true);
    getCurrentLocation();
}
```

- Validación detallada en `onRequestPermissionsResult`:
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
    if (permanentlyDenied) {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:" + getPackageName()));
        startActivity(intent);
    }
}
```

- Uso seguro de FileProvider y limpieza de recursos:
```java
photoUri = FileProvider.getUriForFile(this, getPackageName() + ".fileprovider", photoFile);
takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoUri);
takePictureIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
revokeUriPermission(photoUri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
if (photoFile != null && photoFile.exists()) { photoFile.delete(); }
```

- Configuración de red:
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
- Referencia: `mobsf_reports/vulnerability_report.pdf` y `reporte de vunerabilidades MobSF.pdf`.
- Para automatizar: considerar `scripts/Run-MobSFScan.ps1` para generar JSON y alimentar resúmenes.

## La app usa Google Maps; no incluye backend propio, por lo que el tráfico es principalmente hacia servicios de Google y controlado por el `network_security_config`.
- Revisar permisos de ubicación/cámara según flujos en la app; mostrar rationale.