# Anexo — APK SISCAN con el sistema de diseño v2 (2026-10-08)

Rama `feature/apk-sistema-v2` · app `siscan_app` (Flutter) · versión 0.2.0+3.

## 1. Encargo y contrato

Diego (2026-10-08): el sistema anterior «era una basura»; creó `siscan-design-system.zip` y pidió migrarlo **tal cual**
a la web, la APK y el reloj, «usando solo lo que tiene internamente y usando todo lo que contiene», y borrar el diseño
anterior sin dejar recuerdos. Decisiones suyas: borrar también anexos y capturas viejas; dato que el servidor no tiene →
componente real en estado «Sin dato»; el reloj actúa por el teléfono con sesión; una plataforma a la vez.

**Contrato:** el paquete del sistema (extraído en `C:\dev\siscan-ds-nuevo\siscan-design-system`). No se investigaron
referentes nuevos: el sistema ya es la dirección elegida por Diego, y las composiciones `AndroidIngreso`,
`AndroidInicio`, `AndroidPesaje`, `AndroidMas`, `HomeWidget` son la referencia de cada pantalla.

Usuarios: personal del secador (CISNA, Gobernación de Nariño) y caficultores que consultan; teléfono Android de gama
media, a pleno sol o de noche junto al secador; lectura rápida de humedad y estado, y acciones de riesgo (resistencias)
que deben ser deliberadas.

## 2. Qué salió del sistema y dónde vive en Flutter

| Sistema (paquete) | Flutter |
|---|---|
| `tokens.json` (colores claro/oscuro, tipo, espacio, radios, tamaños, movimiento, sombras) | `lib/core/theme/siscan_tokens.dart`, generado por `tools/generar_tokens_flutter.py` (no se escribe a mano) |
| Outfit + Plus Jakarta Sans (OFL) | `assets/fonts/nuevas/` |
| 67 iconos y el paisaje (día, atardecer, noche × aire, calor; encuadres móvil, ingreso, vacío, foto, tarjeta) | `assets/sistema/iconos`, `assets/sistema/paisaje`, exportados por `tools/exportar_svg_sistema.mjs` |
| Logo, símbolo, wordmark (claros y oscuros) | `assets/sistema/marca`; ícono adaptativo, ícono monocromo, ícono de notificación y pantalla de arranque nativa generados del símbolo claro sobre bosque |
| Componentes base (Card, Pill, LiveDot, Chip, Button, IconButton, Count, Field, Segmented, Switch, Checkbox, Progress, Toast) | `lib/core/ui/base.dart` |
| Datos (Sparkline, ReadingTile, Ring, MoistureCurve, EnergyCard, PredictionCard, Phases, MoistureScale) | `lib/core/ui/datos.dart` |
| Dominio (Landscape, ActuatorRow, HoldButton, SensorRow, AlertList, Health, DryerMap, StateLegend, ListItem, Empty, OrderLog) | `lib/core/ui/dominio.dart` |
| Marco Android (AppBar clara y bosque, barra inferior de 5 destinos, FAB) | `lib/core/ui/marco.dart` |
| HomeWidget 2×2 y 4×2 | `lib/app/widgets_inicio.dart`: se dibuja con los componentes y se entrega al widget nativo como imagen, así queda idéntico |

## 3. Pantallas

- **Carga** — bosque hondo con símbolo y wordmark claros, «Leyendo el secador…».
- **Ingreso** — paisaje móvil, logo en placa, hoja inferior; usuario + contraseña de aplicación (con explicación y
  enlace para crearla), Recordarme, ingreso con huella (si se activó) y «Ver el secador sin cuenta (solo lectura)».
- **Inicio** — AppBar bosque grande con saludo; anillo de humedad + estado + predicción de la tesis; aviso de conexión;
  4 lecturas; equipo; alertas recientes. Campana → **Alertas** (activas, avisos anteriores con «marcar como leído», salud
  del equipo con la red neuronal).
- **Lotes** — filtro Todos/Secador/Aire libre, lista, FAB «Nuevo lote». **Detalle**: fichas, curva de humedad,
  **Predicción de IA** (modelo de la tesis: Lewis, Page y Henderson-Pabis con bootstrap), **red neuronal** de la tesis
  (MLP 32×16, F1 0,90) por sensor, **segunda opinión de IA** (Groq, a pedido) y **proceso** en fases. **Nuevo lote**:
  nombre, sitio, variedad, protocolo, muestra, humedad inicial y objetivo, peso de retiro calculado en vivo.
- **Pesaje** — cifra grande con − / + (0,1 g; mantener repite), toque para escribirla, humedad resultante con su
  veredicto, rango de retiro, lista de pesajes (tocar → corregir o eliminar).
- **Equipo** — Automático / Manual (pide el modo y dice si el ESP32 lo confirmó), actuadores, **una resistencia solo se
  enciende manteniendo presionado** (aparece un HoldButton para la que se tocó), sensores con su estado y lo que ve la
  red neuronal.
- **Más** — perfil, Calibración (Gravimet y sensores), Mapa (mapa esquemático, leyenda, foto), Historial (energía
  solar/red por hora o día, y órdenes), Ubicación del secador, Reloj inteligente, Notificaciones, Ingreso con huella,
  Tema (claro, oscuro, como el teléfono), Tus datos y privacidad, Cerrar sesión.
- **Fuera de la app** — widgets 2×2 y 4×2; notificaciones (alertas con «Ver equipo», hora de pesar con «Registrar
  pesaje», lote listo) y el lote en curso en la pantalla de bloqueo, con una tarea cada 15 min de solo lectura.

## 4. Decisiones que no estaban escritas en el sistema

1. **Hora de Colombia siempre.** El servidor guarda hora de Colombia; la app la muestra igual en cualquier teléfono
   (un emulador en UTC mostraba 19:53 en vez de 14:53). Igual que el panel web.
2. **Una sola orden de mantener.** El sistema muestra un HoldButton; con tres resistencias apagadas salían tres. Ahora
   aparece uno, para la resistencia cuyo interruptor se tocó, con su nombre y potencia encima y el texto del sistema
   («Mantén presionado para encender»).
3. **Energía:** las tres cifras siguen la regla del sistema (`minmax(110px, 1fr)`): en 390 px quedan dos columnas y
   costo abajo, sin cortar «Red eléctrica».
4. **Mapa:** `flutter_svg` no admite `paint-order`; el borde de los nombres se dibuja como texto aparte debajo del
   relleno, que es lo que hace el CSS del sistema.
5. **Lector de pantalla:** cada `Semantics` que declara algo es contenedor; antes la campana se fundía con todo el
   encabezado y no se podía activar. El anillo se lee una sola vez.
6. **Textos de estado:** «El ESP32 todavía no ha reportado su modo» cuando nadie ha pedido nada; un lote en curso que
   ya llegó dice «Listo: retíralo»; el error dice qué pasó una sola vez.

## 5. Enmienda al contrato (aprobada por Diego, 2026-10-09)

**FAB en tema oscuro.** `.sc-fab` fija el texto en `#ffffff` sobre `esmeralda → hoja`; en oscuro esos verdes son claros
y el contraste medido era 2,02:1. Diego aprobó la propuesta: el texto y el icono del FAB toman `sobre-hoja`, como el
botón primario (blanco en claro, igual que el sistema; `#0F1D16` en oscuro). Medido después: pasa AA.

## 6. Verificación medida

- `flutter analyze`: sin problemas.
- `test/pantallas_test.dart` (45 casos): 21 pantallas y estados × claro y oscuro a 390 × 844, con **respuestas reales
  del servidor** guardadas en `test/fixtures/servidor` (producción + rutas del plugin 3.5.0) y un escenario «vivo» (las
  mismas respuestas con las fechas corridas a hoy y el lote 3 en curso, con sesión de Gestor de prueba). En cada una:
  render sin excepciones ni desbordes, **área táctil ≥ 44 × 44** (pauta de Flutter sobre el árbol de semántica) y
  **contraste AA medido sobre el render** (color real de cada texto contra el fondo muestreado en su caja; agrupa
  degradados y no mide lo tapado por la barra inferior). Además: HoldButton por interacción, nodos del lector de
  pantalla y widgets 2×2 y 4×2. **Resultado: 45 de 45** (tras la enmienda del punto 5).
- Emulador Pixel (1080 × 2400): recorrido completo por accesibilidad (`tools/emu.sh`), sin errores en logcat; capturas
  en `docs/ux/capturas/apk-v2/` (claro y oscuro). La variante de depuración apuntó a `pruebas/proxy-app.php` del plugin
  (rutas 3.5.0 con datos reales; el resto leído de producción, solo GET).
- Encontrado y corregido durante la verificación: hueco bajo el aviso (relleno del GridView), tarjetas de lectura
  infladas, contenido bajo la barra de estado en subpantallas, etiquetas del eje que se montaban, objetivo tapado por la
  burbuja, textos «Controlado por el protocolo» en vista pública, «copia guardada del Hoy», hora en UTC, campana sin
  nodo, anillo leído dos veces, tres HoldButton.
- **No medido:** widget real en el lanzador (se verificó su render, no el anclado), huella con sensor real,
  notificaciones en segundo plano durante horas, ESP32 confirmando el modo (depende del firmware que Diego flashea).

## 7. Legal

Política de datos v0.2 (8 oct 2026) en `docs/legal/politica-datos-app-siscan.md` y dentro de la app: huella,
notificaciones, ubicación solo a pedido con **divulgación destacada antes del permiso de Android**, IA, derechos
(cerrar sesión, borrar los datos del teléfono, revocar la contraseña de aplicación). Borrador técnico: lo revisa un
abogado antes de publicar. Pendiente antes de tiendas: contacto del responsable, URL pública, formulario de Seguridad de
los datos de Google Play y registro de consentimiento con versión (la app no pide datos personales nuevos).

## 8. Depende de

- **Plugin 3.5.0 subido** por Diego: sin él, predicción, red neuronal, Groq, modo y energía por hora aparecen en su
  estado «no disponible».
- Clave de Groq en el servidor (`siscan_groq_key`).
