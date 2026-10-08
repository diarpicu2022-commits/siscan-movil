# SISCAN en el reloj · direcciones para elegir (2026-10-07)

El sistema de diseño SISCAN no define reloj (ni tema, ni pantallas, ni referencias). Según el protocolo, antes de
construir se proponen direcciones y **Diego elige**. Nada de esto está implementado.

Quién lo usa: el operador del secador, en la finca, con las manos ocupadas (volteando café, cargando bultos), a pleno sol.
Pregunta dominante: «¿cómo va el secado y tengo que hacer algo?». Lectura obligada y de reojo: claridad antes que adorno.
Datos disponibles (lecturas públicas del servidor): humedad del lote y objetivo, temperatura, estado del equipo, alertas.
No hay predicción en el servidor (el reloj no la inventa).

## A · «Medidor de lecho» (recomendada)
- Esfera en `monte` muy oscuro (la banda de la app), con el **lecho de café** del `MoistureMeter` enrollado como anillo:
  agua por retirar en `dato-agua`, objetivo como muesca `cafeto`.
- Centro: la humedad en Atkinson Hyperlegible Mono (la cifra más grande), «Objetivo 11 %» y el estado con su glifo
  (✓ objetivo alcanzado, ▲ revisar). Abajo, «Actualizado 14:10».
- Al deslizar: equipo (ventilador/resistencias, solo estado; ninguna orden desde el reloj) y la alerta más grave.
- Tile: humedad + objetivo + hora. Complicación: humedad (RANGED_VALUE 0–60 %).
- Por qué: es la firma visual de SISCAN (el lecho) y responde la pregunta dominante de un vistazo.

## B · «Pleno sol»
- Esfera clara (tema «Pleno sol»: fondo blanco, tintas ≥ 12:1) para leer bajo sol directo; números enormes, sin anillo.
- Solo dos datos: humedad y alerta. Más legible al sol; menos identidad y más consumo de batería (pantalla clara).

## C · «Avisos primero»
- Sin pantalla de inicio propia: el reloj solo recibe **notificaciones** de SISCAN (objetivo alcanzado, temperatura alta,
  secador sin reportar) con vibración y una tarjeta de detalle. Requiere que el servidor envíe avisos (hoy no lo hace).

Recomendación: **A**, con un interruptor «Pleno sol» como en la app. Falta decidir también si el reloj puede **mandar
órdenes** (sugerencia: no; las resistencias de 1500 W exigen mantener presionado en el teléfono).

---

## Contrato de diseño (Diego, 2026-10-08: «A · Medidor de lecho», con tema claro y oscuro)

Código: `siscan_reloj/` (Wear OS, Compose para Wear Material 3, independiente del teléfono: consulta el servidor por
Wi‑Fi o LTE del reloj; solo lecturas públicas, **ninguna orden** desde el reloj).

| Cláusula | Qué manda |
|---|---|
| C1 Colores claro | Tema «Día» del sistema tal cual: fondo `pergamino` #F3EADA, superficie `papel`, riel `arena`, tinta `tierra`, tinta suave `tierra-suave`, agua `dato-agua`, objetivo `cafeto`, aviso `panela`, alerta `oxido`. |
| C2 Colores oscuro | Derivado del bloque `monte` (decisión 2026-10-08 «derivarlo de cada sistema»): fondo #0F1F15, superficie #1B3524, riel `monte` #24452F, tintas `sobre-monte` #F3EADA y `sobre-monte-suave` #B9C9B4; acentos aclarados para AA sobre oscuro: agua #8CC3D3, cafeto #8FD19E, panela #F0C46A, óxido #F2A193. |
| C3 Tipos | Cifra en Atkinson Hyperlegible Mono 40 sp (lo más grande); nombre del lote en Fraunces 600 18 sp; apoyo Atkinson Next 500 15 sp; rótulos Atkinson 700 13 sp con espaciado. Mismos archivos de fuente que la app. |
| C4 Repertorio | **Anillo de lecho** (único trabajo: avance del secado hacia el objetivo; solo en Humedad y la Tarjeta) · **glifos** del sistema ✓ ● ○ ▲ (único trabajo: estado; se distinguen por forma, no solo por color) · **píldoras** (único trabajo: elegir tema). Nada más. |
| C5 Páginas | Humedad → Equipo → Alerta → Tema, en paginador vertical con la corona (un gesto = una página). |
| C6 Honestidad del dato | «Actualizado HH:MM» solo si la última lectura tiene ≤ 15 min (regla de la app); si no, «Sin reportes · 19 ago» en panela, igual en app y Tarjeta. Sin señal se muestra lo último guardado. |
| C7 Superficies | Tarjeta: humedad + estado + lote + frescura con el arco del lecho, respetando el tema elegido. Complicación: humedad (RANGED_VALUE 0–60 %, SHORT_TEXT «10.6%»). |

### Enmienda propia, fechada (2026-10-08)
- La línea «Objetivo 11 %» y el estado se fundieron en una sola («11 % alcanzado», «Secando · meta 11 %»): con las dos
  la esfera tenía cinco líneas y la del pie se cortaba. Mismo contenido, una línea menos.
- Equipo: el estado por fila pasó a glifo + nombre completo, con el resumen en palabras arriba («Todo apagado»), y la
  fecha del último estado al rótulo. Con «Apagado» escrito en cada fila los nombres se cortaban («Calefact…») y la
  cuarta fila quedaba fuera del círculo.

## Verificación (2026-10-08, emulador Wear OS redondo 454 px, densidad 2.0, datos reales del servidor)

Medida, no a ojo:
- **Contraste sobre el render** (`agenda-android/tools/verificacion/medir_reloj.py`), las 4 páginas en los 2 temas:
  piso claro 5.11:1 («Sin reportes · 19 ago» en panela), piso oscuro 9.60:1; la cifra 13.54:1 (claro) y 14.34:1 (oscuro).
  Toques ≥ 48 dp: sin fallos (píldoras de Tema). **FALLOS: ninguno** en las 8.
- **Cajas contra el círculo** (`siscan_reloj/verificar_cajas.py`, nuevo): cada texto entero dentro de la esfera, sin «…»,
  y presencia de los textos esperados (detecta desbordes que no se dibujan). 8 de 8 sin fallos. Antes de la enmienda
  fallaba Equipo: nombres cortados y pie ausente; lo encontró la captura, y la comprobación ahora lo exige.
- **Pruebas unitarias** `EstadoTest` (2): lote terminado con humedad final y avance completo; lote en curso preferido y
  alerta más grave primero. `lintDebug` sin errores.
- **Tarjeta** añadida en el emulador: se dibuja con el arco y ya no presenta el dato viejo como fresco (antes decía
  «Actualizado 08:43»; corregido).

Capturas: `docs/ux/capturas/reloj/siscan-{claro,oscuro}-{humedad,equipo,alerta,tema}.png`, `siscan-claro-tarjeta.png`.

Pendiente, declarado:
- Probarlo en el Galaxy Watch real de Diego (pleno sol, batería) y la complicación sobre una esfera real.
- Estado «revisar» (▲) con una alerta activa real: hoy el servidor no tiene alertas sin leer de nivel crítico; está
  cubierto por la prueba unitaria, no por captura.
- Idioma (es/en/pt): con el resto de proyectos, en la fase de tema e idioma.
