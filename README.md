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
- Edita tu clave en `app/src/main/res/values/google_maps_api.xml`.
- Verifica el `meta-data` en `app/src/main/AndroidManifest.xml`:
  - `android:name="com.google.android.geo.API_KEY"` debe contener clave.

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
- La foto capturada se maneja como miniatura en memoria (no se guarda archivo). Para guardar en almacenamiento.
- Permisos usados: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` y `CAMERA` (en tiempo de ejecución).