# Security Improvement Program

## Objetivo
Se diseno un programa estructurado para evaluar y mejorar la seguridad del proyecto.

## Proceso de revisión periódica
1. Build semanal de `app-debug.apk` y análisis estático en MobSF (Docker).
2. Revisión de permisos, componentes `exported`, dependencias y configuración de red.
3. Registro de hallazgos en `vulnerabilities.md` y exportación de `vulnerability_report.pdf`.
4. Corregir severidades de vulnerabilidades según SLA (Critical, High, Medium, Low).

## Métricas clave
- Número total de vulnerabilidades por severidad.
- Porcentaje de permisos reducidos o justificados.
- modificar dependencias y actualizarlas.
- Uso de HTTPS y ausencia de tráfico en claro.

## Plan de acción para mejoras futuras
- Integrar `mobsfscan` (SAST) en CI para escaneo de fuente.
- Añadir reglas de R8/ProGuard y revisar ofuscación.
- Modificar `AndroidManifest.xml` para eliminar `android:exported="true"` en componentes no necesarios.
- Revisar y actualizar bibliotecas de red.
