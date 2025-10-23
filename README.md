# GPSMapApp

## Descripción
Aplicación Android que muestra un mapa de Google y permite añadir marcadores y capturar imágenes con la cámara. Incluye un menú principal y navegación hacia la pantalla del mapa.

## Vulnerabilidades Identificadas
- Receptor exportado (`BroadcastReceiver`) accesible externamente.
  - Impacto: ejecución no autorizada vía `Intent` y abuso de funcionalidades.
  - Remediación: `android:exported="false"` si no es necesario; o proteger con `android:permission` y validar origen/datos del `Intent`.
- Permisos de ubicación (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`) marcados como peligrosos.
  - Remediación: solicitar en tiempo de ejecución, mostrar rationale, evitar ubicación en segundo plano si no es imprescindible.
- Permiso de cámara (`CAMERA`) marcado como peligroso.
  - Remediación: solicitar en runtime, uso explícito por el usuario y saneo/borrado de archivos temporales.
- Permiso desconocido `com.example.gpsmapapp.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`.
  - Remediación: definir la `permission` en `AndroidManifest.xml` con `protectionLevel="signature"` si es interno, o eliminar si no se utiliza.
- Red y tráfico claro.
  - Observación: `cleartextTrafficPermitted=false` está configurado; mantener y revisar endpoints externos para que todo sea HTTPS.

- Reportes: `mobsf_reports/vulnerability_report.pdf`.
- Ver `vulnerabilities.md`.

## Mejoras Implementadas
- API Key externalizada en `strings.xml`; no se hardcodea en el Manifest.
- Captura de cámara con `FileProvider` y `EXTRA_OUTPUT` para evitar exponer rutas de archivo.
- `network_security_config` con `cleartextTrafficPermitted=false` para bloquear HTTP por defecto.
- Manejo de permisos con rationale y opción de abrir Ajustes.
- `android:exported="false"` en componentes sin `intent-filter`.

## Ejemplos de código de mitigación
- Solicitud robusta de permisos de ubicación (FINE + COARSE):

```java
ActivityCompat.requestPermissions(this,
    new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION},
    LOCATION_PERMISSION_REQUEST_CODE);
```

- Habilitar "Mi ubicación" si al menos uno de los permisos está concedido:

```java
if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
    ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
    mMap.setMyLocationEnabled(true);
    getCurrentLocation();
}
```

- Manejo de resultados de permisos con verificación por permiso:

```java
boolean fineGranted = false;
boolean coarseGranted = false;
for (int i = 0; i < permissions.length; i++) {
    if (Manifest.permission.ACCESS_FINE_LOCATION.equals(permissions[i])) {
        fineGranted = grantResults.length > i && grantResults[i] == PackageManager.PERMISSION_GRANTED;
    } else if (Manifest.permission.ACCESS_COARSE_LOCATION.equals(permissions[i])) {
        coarseGranted = grantResults.length > i && grantResults[i] == PackageManager.PERMISSION_GRANTED;
    }
}
if (fineGranted || coarseGranted) {
    if (mMap != null) {
        mMap.setMyLocationEnabled(true);
    }
    getCurrentLocation();
} else {
    boolean permanentlyDenied = !ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.ACCESS_FINE_LOCATION);
    if (permanentlyDenied) {
        Toast.makeText(this, "Permiso de ubicación denegado permanentemente. Habilítalo en Ajustes", Toast.LENGTH_LONG).show();
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:" + getPackageName()));
        startActivity(intent);
    } else {
        Toast.makeText(this, "Permisos de ubicación denegados", Toast.LENGTH_SHORT).show();
    }
}
```

- Seguridad al usar cámara y `FileProvider`:

```java
photoUri = FileProvider.getUriForFile(this, getPackageName() + ".fileprovider", photoFile);
takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoUri);
takePictureIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
// Tras usar la URI
revokeUriPermission(photoUri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
// Limpieza en cancelación
if (photoFile != null && photoFile.exists()) { photoFile.delete(); }
```

- Política de red segura en Manifest y `network_security_config`:

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

## Documentación
- [Vulnerabilidades](vulnerabilities.md)
- [Best Practices](best_practices.md)
- [Security Tips](security_tips.md)
- [Security Improvement Program](security_improvement_program.md)
- [Guía de análisis con MobSF](SECURITY_TESTING.md)

## Cómo Ejecutar la Aplicación de Forma Segura
1. Clonar el repositorio.
2. Configurar la clave de Google Maps:
   - Edita `app/src/main/res/values/strings.xml` (`google_maps_key`).
   - Verifica `AndroidManifest.xml` (`com.google.android.geo.API_KEY`).
3. Conectar un dispositivo o iniciar un emulador con Google Play Services.
4. Ejecutar:
   - `./gradlew.bat assembleDebug`
   - Instalar y probar en dispositivo/emulador.

## Reporte de Vulnerabilidades
- Genera el reporte con MobSF y guarda el PDF como `mobsf_reports/vulnerability_report.pdf`.
- También puedes guardar el JSON con `scripts/Run-MobSFScan.ps1`.

## Flujo de uso
- Pantalla principal (MainActivity): botón "Mapa" navega a la pantalla del mapa.
- Pantalla de mapa (MapsActivity):
  - Pulsación larga: añade marcador en la posición.
  - Botón "Añadir marcador": coloca marcador en tu ubicación actual.
  - Botón "Capturar foto": abre la cámara y muestra miniatura al regresar.
