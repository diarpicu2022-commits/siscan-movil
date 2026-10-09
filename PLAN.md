# SISCAN móvil — plan

Decisión de Diego (2026-10-06): cada proyecto de la materia lleva APK de Android y app de smartwatch.

## Contrato de diseño (desde 2026-10-08)

`siscan-design-system.zip` (esta carpeta; extraído en `C:\dev\siscan-ds-nuevo`) es el **sistema de diseño SISCAN v2**
que creó Diego: Outfit + Plus Jakarta Sans, bosque/salvia/esmeralda/hoja/brote/lima/café/predicción, temas claro y
oscuro, componentes `components/*` y composiciones `AndroidInicio`, `AndroidPesaje`, `AndroidMas`, `AndroidIngreso`,
`HomeWidget`, `WearApp`… Se migra **tal cual**, usando solo lo que contiene y todo lo que contiene. El diseño anterior
(Fraunces/Atkinson, «Controles · Predicción · Alertas») se borró por pedido de Diego.

## Orden (una plataforma a la vez, se para a mostrar)

1. Web (panel en WordPress, plugin 3.5.0) — hecho; anexo en el repo de la tesis.
2. **APK** (`siscan_app`) — hecho en `feature/apk-sistema-v2`; anexo `docs/ux/anexos/2026-10-08-apk-siscan-sistema-v2.md`.
3. Reloj Wear OS (`siscan_reloj`) con el sistema v2; sus acciones van por el teléfono con la sesión. Al migrarlo se
   borran el anexo y las capturas del reloj anterior.

## Backend

WordPress REST `https://cisna.narino.gov.co/wp-json/secador/v1` (plugin `secador-cafe-api`). Las rutas de predicción,
red neuronal, opinión de IA, energía por hora y modo de control llegan con el plugin **3.5.0**, que sube Diego.
