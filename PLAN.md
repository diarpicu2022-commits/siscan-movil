# SISCAN móvil — plan (2026-10-06)

Decisión de Diego (2026-10-06): **cada uno de los tres proyectos de la materia lleva APK de Android y app de
smartwatch.**

| Proyecto | Android | Smartwatch | Web |
|---|---|---|---|
| SISCAN (secador de café, tesis) | esta carpeta: app Flutter + widgets | SISCAN en Wear OS (esta carpeta) | rehacer `Documents/Tesis/secador-cafe/wordpress-pages/panel-siscan.html` con el sistema |
| Agenda / CampusWatch | `App Smartwacht/` (proyecto en `Documents/Proyectos personales`, UI nueva con `agenda-design-system`) | CampusWatch | — |
| NotaScan | APK pendiente | reloj pendiente | (escritorio ya hecho) |

## Contrato de diseño

`siscan-design-system.zip` (en esta carpeta) es el contrato: tokens Día / Pleno sol, Fraunces + Atkinson Hyperlegible
Next/Mono, iconos propios, `plataformas.md` (ThemeExtension de Flutter, `home_widget`, navegación Inicio · Controles ·
Predicción · Alertas, tamaño «campo»), vistas de referencia `InicioMovil`, `ControlesMovil`, `LoginMovil`,
`WidgetsMovil`, `HomeWidget`, `LockWidget`. Diego pidió no gastar en investigación nueva: el sistema ya está diseñado;
nada fuera de él sin su permiso.

## Backend (real, sin crear uno nuevo)

WordPress REST `https://cisna.narino.gov.co/wp-json/secador/v1`: lectura pública (`/secadores`, `/drying-batches`,
`/drying-batches/{id}/curve|summary|readings`, `/readings`, `/actuators`, `/weather/{id}`, `/energy/{id}`); escribir
(actuadores, lotes) exige sesión de WordPress con el permiso «Gestor del Secador» → la app pedirá iniciar sesión solo
para los controles.

## Pasos (cada uno se muestra y espera visto bueno)

1. Entorno: Flutter estable + SDK de Android (ya instalado) · proyecto `siscan_app` · tokens como `ThemeExtension`
   (Día y Pleno sol) y fuentes del sistema.
2. Componente clave: lecho de humedad (`MoistureMeter`) + lectura de sensor con procedencia.
3. Esqueleto: navegación inferior Inicio · Controles · Predicción · Alertas con la banda `monte`.
4. Inicio con datos reales (lote activo → humedad → temperatura → tiempo → predicción → equipo → alertas).
5. Controles (palanca, modo manual, resistencia guardada), Predicción, Alertas, inicio de sesión.
6. Estados: cargando, vacío, error, sin conexión («Modo offline»), dato viejo.
7. Widgets de inicio y de bloqueo (`home_widget`) + APK firmado.
8. Smartwatch SISCAN (Wear OS).
9. Web nueva del panel con el sistema.

Legal (según CLAUDE.md): política de datos y permisos (ubicación, notificaciones) se anotan en el anexo y se hacen
antes de publicar.

## Pendiente (pedido del profe, 2026-10-07)
Modo oscuro + elegir tema, e idioma es/en (app y web). Ver `Proyectos Finales/PENDIENTES-PROFE.md`.
