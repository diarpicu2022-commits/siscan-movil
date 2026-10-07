# SISCAN móvil — anexo de diseño (2026-10-06)

## Contrato
`siscan-design-system.zip` (tokens Día / Pleno sol, tipografía, iconos, `plataformas.md`, vistas `InicioMovil`,
`ControlesMovil`, `LoginMovil`, `WidgetsMovil`, `HomeWidget`, `LockWidget`). Diego pidió usar el sistema tal cual, sin
investigación nueva ni direcciones alternativas: el sistema ya es la dirección elegida. Nada fuera de él sin permiso.
Stack: **Flutter** (decisión de Diego, 2026-10-06; se consideró Kotlin + Compose como Agenda y se descartó).

## Usuarios y tarea
Operador del secador y técnico del CISNA, junto al secador en Chachagüí o en oficina; mira de reojo, a veces a pleno
sol y con una mano: ¿cómo está el secado?, ¿funciona el equipo?, ¿cuánto falta?, ¿hay algo que revisar?

## Paso 1 · Tema y fundamentos (hecho)
- `tools/gen_tokens.py` genera `lib/theme/tokens.dart` desde `tokens.json`: 41 colores × 2 temas, 8 espacios, 5 radios
  (ningún color escrito a mano). `SiscanTokens` como `ThemeExtension`, `SiscanTheme.of(tokens, sol:)`.
- Fuentes del sistema convertidas de woff2 a ttf (fontTools): Fraunces variable (SOFT 100, WONK en el wordmark),
  Atkinson Hyperlegible Next y Mono con cifras tabulares. `SiscanType` con los 12 estilos + `lecturaCampo` (76 px).
- 27 iconos SVG del sistema, teñidos con el color del texto (`SiscanIcon`); 3 ilustraciones gouache.
- Verificación (`flutter test`): contraste medido de los tokens en los dos temas (texto ≥ 4.5 en las tres superficies;
  estados ≥ 4.5 sobre su suave, papel y pergamino; Pleno sol texto ≥ 12 y estados ≥ 8) y captura a 390 px con las
  fuentes reales (`test/goldens/fundamentos-*.png`). 8/8.
- Entorno: Flutter 3.47.6 (Dart 3.13.5), SDK de Android 36. El analizador de Dart falla con la «ñ» de la ruta: se
  trabaja por la unión `C:\dev\siscan` → esta carpeta.

## Pendiente legal (CLAUDE.md)
Política de datos y permisos (notificaciones, ubicación si se usa) antes de publicar; sin cuentas propias: el inicio de
sesión es el de WordPress del CISNA.

## Paso 2 · Componente clave (hecho)
Referencia: vistas del sistema renderizadas (`MoistureMeter`, `SensorReading`, `Provenance`, `StatusMark`,
`InicioMovil`). Construidos en `lib/widgets/`:
- `MoistureMeter` (lecho de secado, tamaño campo): agua `dato-agua` con borde ondulado que se encoge hacia el
  objetivo, lecho de granos en `arena` con contorno discontinuo para lo retirado, bandera `cafeto`, escala 0–50 cada 5,
  fases Húmedo/Secando/Cerca/Objetivo alcanzado (el agua pasa a `cafeto`), conteo desde la humedad inicial en 1.6 s
  (salta al valor con animaciones desactivadas), anuncio para lector de pantalla.
- `SensorReading`: regla de instrumento, hoja de icono 12 12 12 4, cifra mono, rango, sello + procedencia + frescura;
  desactualizado/sin conexión en `tierra-suave` sobre rayado y «Última lectura» / «No disponible».
- `ProvenanceChip` (6 trazos), `StatusMark` (suave, sólido, en línea; glifos dibujados, nunca caracteres).
Fallos propios encontrados con la captura: la cifra de 76 px se partía en cuatro líneas porque la columna de estado le
quitaba el ancho (ahora, por debajo de 420 px, estado/objetivo/procedencia van en una fila bajo la cifra; nueva prueba
de una sola línea); escala a 60 con marcas cada 10 (ahora 0–50 cada 5 como la referencia); el rayado del chip
«Desactualizado» se salía de su caja. `flutter test` 16/16 (fases, conteo 1.6 s, reducción de movimiento, semántica,
sin dato inventado, desactualizado en tierra-suave, cifra en una línea, capturas Día/Pleno sol sin desbordes).

## Paso 3 · Esqueleto (hecho)
Referencia `InicioMovil`: banda `monte` con el wordmark «SISCAN» (Fraunces SOFT 100 + WONK) y `ConnectionStatus`
sobre oscuro; paisaje «loma» de 84 px en capas planas de pinturas (lomas y una hilera de cafetos que se mece despacio,
quieto con movimiento reducido); el contenido sube 28 px sobre la banda; navegación inferior en `papel` con Inicio ·
Controles · Predicción · Alertas (destinos de 56 px, activo en `arcilla` sobre `arcilla-suave`, contador de alertas en
`oxido` anunciado al lector de pantalla). Pleno sol: interruptor en **Ajustes** (hoja desde el icono de usuario de la
banda; el sistema pide «un interruptor en Ajustes» y la referencia no tiene pantalla de Ajustes — ahí irá también el
inicio de sesión). Los destinos muestran qué traerá cada paso.
Fallos propios encontrados con pruebas y capturas: la barra inferior ocupaba toda la pantalla y dejaba el contenido en
0 px (su columna se estiraba); en «Modo offline» la barra superior se desbordaba 43 px (la píldora ahora cede ancho);
la hoja quedaba **debajo** de la banda y le cortaba la esquina y el título (en un `CustomScrollView` la primera
sección se pinta encima; ahora banda y contenido van en una columna); «%» suelto en otra línea (espacio de no
separación). `flutter test` 24/24, con pruebas nuevas para cada uno; capturas Día, Pleno sol (fondo medido #FFFDF8) y
offline.

## Paso 4 · Inicio con datos reales (hecho)
Capa de datos (`lib/data/`): modelos de plataformas.md y `HttpSiscanRepository` sobre el backend real
(`/secadores`, `/readings`, `/api/actuators`, `/api/device/status/1`, `/drying-batches` y su `/summary`), con
mensajes humanos si falla; `OverviewController` actualiza cada 30 s y conserva el último dato bueno.
Inicio en el orden del sistema: lote (etiqueta de costal) → humedad (lecho, procedencia «Estimado · gravimetría»)
→ temperatura y tiempo (fila doble como `InicioMovil`) → humedad del recinto → predicción (regla de confianza en
`anil`) → equipo → alertas (las 3 más recientes y «Ver las N alertas» lleva a Alertas). Estados: cargando (hojas en
reposo), error con «Intentar nuevamente».
Datos reales de hoy: el secador SC-001 **no tiene lote activo** (último: «Lote juco», 10.6 % final) y sus lecturas son
del **19 de agosto** → se muestran como «Última lectura» y desactualizadas. **El backend no publica predicción** (el
modelo de la tesis está en `ml/` sin servicio): la tarjeta lo dice y no inventa cifras. Las alertas vienen truncadas
desde la base («…revisa l»); se corrige en el backend, no en la app.
Fallos propios: la píldora decía «Conectado» con datos de agosto (ahora «Secador sin reportar» cuando ninguna lectura
es reciente: la conexión es con el secador, no solo con el servidor); «Apagado» llevaba un visto bueno (ahora un aro
neutro, estado `apagado`); el controlador se creaba al cerrar la app y dejaba una carga pendiente. Pruebas: respuestas
reales guardadas (`test/fixtures/`, 2026-10-06) para leer el backend sin red; `flutter test` 30/30 (lectura real,
desactualizado, sin red, Inicio real y con lote de ejemplo en el orden exacto, navegación a Alertas).

## Paso 5 · Controles, Predicción, Alertas e Ingresar (hecho)
- **Controles** (referencia `ControlesMovil` / `ActuatorControl`): palanca 132 × 60 con «ENC/APAG», perilla con estrías
  y sombra dura, palabra de estado grande, selector Automático/Manual. En automático la palanca está bloqueada
  («Controlado por el protocolo»); manual contornea la tarjeta en `panela` (2 px). Resistencias: un toque no las
  enciende, **mantener presionado 1.5 s** sí (relleno `panela` mientras se sostiene) y avisan de verificar el
  ventilador; apagar es inmediato. Transiciones «Encendiendo… / Apagando…» y error con instrucción. La orden va al
  backend real (`PUT /api/actuators/{id}` con la sesión). El backend no guarda «modo»: en la app, manual es el permiso
  para mandar a mano y exige sesión. Si el secador no reporta, se avisa que la orden se cumplirá al reconectarse.
- **Ingresar** (referencia `LoginMovil`): usuario de WordPress del CISNA + **contraseña de aplicación** (WordPress la
  trae activada en el servidor; revocable; no es la contraseña normal), verificada con `/wp/v2/users/me` y el permiso
  `manage_secador` (el mismo que exige el backend). «Recordarme» la guarda cifrada en el teléfono
  (`flutter_secure_storage`); «Cerrar sesión» la borra. Enlace para crearla en WordPress. Mirar el secador no pide cuenta.
- **Predicción**: tiempo restante con su rango y la regla de confianza, datos considerados y la advertencia de que es
  una estimación (confirmar con la balanza). Hoy sin predicción del backend: lo dice.
- **Alertas** (referencia `AlertItem`): de la más grave a la más leve; crítica en `oxido-suave` con contorno. El backend
  publica solo las 3 más recientes y el total: la pantalla lo dice («el historial completo está en el panel web»).
Fallos propios: la casilla «Recordarme» quedaba sobre una caja con color que ocultaba su respuesta al toque (la hoja
del formulario ahora es una superficie Material); el selector Automático/Manual se desbordaba 32 px con letra ancha
(el texto cede); «mantener presionado» no se registraba porque competía con el desplazamiento (ahora escucha el dedo
directamente). `flutter test` 40/40.
Legal: la app guarda en el teléfono solo la contraseña de aplicación, y solo si se pide; se declara en la política.
