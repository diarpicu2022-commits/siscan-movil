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
