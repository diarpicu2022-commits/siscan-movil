# Anexo — SISCAN en el reloj (Wear OS) con el sistema de diseño v2 (2026-10-09)

Rama `feature/reloj-sistema-v2` · `siscan_reloj` (app 0.2.0 + módulo `esfera`) · puente en `siscan_app` 0.2.1.

## Contrato

`07-smartwatch.md` y los componentes `WatchFrame`, `WatchArc`, `WatchMonitor`, `WatchReadings`, `WatchActuators`,
`WatchPrediction`, `WatchBatches`, `WatchWeigh`, `WatchAlert`, `WatchConfirm`, `WatchAmbient`, `WatchTile`, `WatchFace`
(composiciones `WearApp`, `WearAcciones`, `WearEsfera`). Decisión de Diego: el reloj actúa **por el teléfono con sesión**.

## Qué hay

- **App** (Compose): Monitoreo → Lecturas → Equipo → Predicción → Lotes → Pesaje, deslizando entre tarjetas; la corona
  desplaza las listas y ajusta el peso. Alerta a pantalla completa (roja/ámbar, vibración 1 o 2 pulsos), confirmación con
  check dibujado (se cierra a los 2 s), siempre activo en contornos, cargando y sin conexión.
- **Fuera de la app:** Tarjeta (Tile), cuatro complicaciones (humedad en anillo, temperatura, alertas, lote) y la esfera
  en Watch Face Format.
- **Puente:** el reloj pide la orden al teléfono (capa de datos, capacidad `siscan_puente`); `PuenteReloj.kt` la envía con
  la sesión guardada (cifrada con Android Keystore, solo con «Recordarme») y origen `WATCH`. El reloj no guarda claves.
- Recursos generados, no a mano: `tools/generar_reloj.py` (tokens oscuros, 67 iconos como VectorDrawable, fuentes) y
  `tools/generar_esfera.py` (esfera, fuentes fijas Outfit 300/600 y Jakarta 400/700).
- Se borró el diseño anterior del reloj (tema, pantallas, fuentes, símbolo, anexo y capturas).

## Decisiones fuera del texto del sistema

1. Escala: 1 px de la esfera de 224 = 1 dp (se ajusta la densidad al ancho del reloj, respetando el tamaño de letra).
2. Botones de 36/40 px del sistema (− / +, «Guardar») con área táctil de 48.
3. Nombres largos del servidor («Ventiladores») en una línea que baja de 13,5 a 11,5 antes de cortarse.
4. Encender una resistencia exige mantener presionado su chip (misma regla de seguridad que la app y la web).
5. Sin indicador de páginas: el borde inferior es del arco. Hora curva sin fondo.
6. La hora del reloj es la del reloj; los datos del secador, en hora de Colombia.
7. **Esfera en siempre activo:** el sistema pide la hora solo en contorno; Watch Face Format no dibuja contornos en la
   hora (probado con TimeText y con PartText + Outline): va rellena en Outfit 300, tinta-suave. La app sí la dibuja en
   contorno. La fecha no va en mayúsculas (el formato no lo permite).

## Verificación

- Pruebas unitarias del estado: 4/4. Lint sin errores. App, esfera y teléfono compilan en publicación.
- Emulador Wear OS (454 px, API 36) con `pruebas/proxy-app.php` (datos reales + rutas 3.5.0; escenario `/vivo` con fechas
  a hoy, lote en curso y una alerta de prueba). Capturas en `docs/ux/capturas/reloj-v2/`.
- Encontrado y corregido: estado de páginas que se perdía tras una confirmación, alerta que reaparecía (clave con hora),
  nombres partidos, fila de pesaje fuera del círculo, cápsula de la hora, esfera rechazada por el tipo de reserva de las
  complicaciones, complicaciones dentro de un Group que no se dibujaban, vibración en API 30, vista previa de la Tarjeta,
  servidor de prueba que perdía el último byte.
- **No verificado:** reloj ↔ teléfono de punta a punta (el emulador no se puede emparejar sin una cuenta de Google); se
  probó cada lado: el reloj sin teléfono dice «El teléfono no está cerca…», el puente compila. Pendiente en el reloj y el
  teléfono reales de Diego. Tampoco: internet real en el emulador del reloj (no tiene salida).

## Pendiente de Diego

- Probar en sus dispositivos: ingresar en el teléfono con «Recordarme» → en el reloj, encender el ventilador y registrar
  un pesaje.
- Sigue pendiente la enmienda del FAB oscuro de la APK (2,02:1).
