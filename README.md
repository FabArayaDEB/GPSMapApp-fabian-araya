GPSMapApp

Descripciin breve
- App que muestra un mapa de Google y permite anadir marcadors y capturar imgenes con la camara. Incluye un menu principal y navegación hacia la pantalla del mapa.

Funcionaliades
- Mapa con `SupportMapFragment` mostrando la ubicación actual (si el permiso esta concedido).
- Añadir marcador con pulsación larga sobre el mapa.
- boton para anadir un marcador en la ubicación actual.
- Botón para capturar foto con la cámara; se muestra una miniatura en la pantalla de mapa.

pasos
- Android Studio (Arctic Fox o superior) y SDK de Android configurado.
- Dispositivo o emulador con Google Play Services.
- Clave de API de Google Maps habilitada para Android.

Configuración de la API de Google Maps
- Edita tu clave en `app/src/main/res/values/strings.xml` (atributo `google_maps_key`).
- Verifica el `meta-data` en `app/src/main/AndroidManifest.xml`:
  - `android:name="com.google.android.geo.API_KEY"` debe referenciar `@string/google_maps_key`.

Pasos para ejecutar
1) Clonar el repositorio.
2) Configurar la clave de Google Maps como se indica arriba.
3) Conectar un dispositivo o iniciar un emulador con Google Play Services.

Flujo de uso
- Pantalla principal (MainActivity): botón "Mapa" navega a la pantalla del mapa.
- Pantalla de mapa (MapsActivity):
  - Pulsación larga: añade marcador en la posición.
  - Botón "Añadir marcador": coloca marcador en tu ubicación actual.
  - Botón "Capturar foto": abre la cámara y muestra una miniatura al regresar.

Notas
- La foto capturada ahora se guarda como imagen de tamaño completo usando `FileProvider` y `EXTRA_OUTPUT`. Se muestra en la vista previa desde una `content://` URI segura.
- Permisos usados: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` y `CAMERA` (en tiempo de ejecución). Si el usuario los deniega permanentemente, se ofrece ir a Ajustes.

Mejoras de seguridad implementadas
- API Key externalizada en `strings.xml`; no se hardcodea en el Manifest.
- Captura de cámara con `FileProvider` y `EXTRA_OUTPUT` para evitar exponer rutas de archivo.
- `network_security_config` con `cleartextTrafficPermitted=false` para bloquear HTTP por defecto.
- Manejo de permisos con racional (explicación previa) y opción de abrir Ajustes cuando se deniega permanentemente.
- `android:exported="false"` en componentes sin `intent-filter`.

Configuración necesaria
- Reemplaza `REEMPLAZA_AQUI_TU_API_KEY` en `app/src/main/res/values/strings.xml`.
- Si requieres HTTP para pruebas, ajusta `app/src/main/res/xml/network_security_config.xml` para permitir dominios específicos temporalmente.