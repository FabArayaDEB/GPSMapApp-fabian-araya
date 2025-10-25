# Security Tips

## Medidas puntuales de seguridad
- **Protección contra inyección (SQL/XPath):** No concatenar strings en consultas; usar parámetros/ORM.
- **Autenticación/Autorización:** Si se añade backend propio, usar tokens de corta duración (JWT) y scopes.
- **Protección MITM:** Forzar HTTPS; no aceptar certificados no confiables; evitar `NetworkSecurityConfig` permisivo.
- **Hardcoded Secrets:** Evitar claves en código/manifest; usar almacenamiento seguro y ofuscación.
- **WebView seguro:** Desactivar JavaScript si no es necesario; bloquear `file://` y depuración.
- **Permisos mínimos:** Revisar y reducir permisos declarados; pedir en tiempo de ejecución con rationale.

## como cada tip mejora la seguridad
- Parámetros en consultas previenen inyección por entradas maliciosas.
- Tokens y scopes limitan acceso y reducen impacto de credenciales expuestas.
- HTTPS estricto evita espionaje y manipulación de tráfico.
- Eliminar secretos hardcodeados dificulta extracción por ingeniería inversa.
- WebView endurecido reduce superficie de ataque de contenido remoto.
- Menos permisos disminuyen riesgos de abuso y exposición innecesaria.