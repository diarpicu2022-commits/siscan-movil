# Anexo UX — Escena del secador en Inicio y en el reloj, y tema «Según la hora» · 2026-10-12

Rama `feature/invernadero-y-tema-por-hora`, creada desde `feature/reloj-sistema-v2` (PR #3, que ya incluye la de la APK,
PR #2). **Son PR apilados**: este se abre contra `feature/reloj-sistema-v2` o, cuando #2 y #3 entren a `develop`, se
rebasa sobre `develop`. Piezas: `siscan_app` (Inicio, Más › Tema) y `siscan_reloj` (pantalla nueva «El secador»).

Estado (2026-10-15): **pasos 1 a 5 hechos y aprobados; enmiendas E6–E10 aplicadas. Paso 6 (estados) hecho: el plan está
completo y espera el visto bueno final antes de abrir el PR** (lo que falta para el PR está en `CONTINUAR.md`). El tema del reloj quedó decidido el 2026-10-15: opción **A** (ver «Contrato › Decisión del reloj»). Enmiendas del
2026-10-15 aprobadas por Diego en «Contrato › Enmiendas».

---

## 1. Encuadre

### Usuarios (fase 1)

| | Teléfono | Reloj |
|---|---|---|
| Quién | Caficultor o técnico del CISNA que opera el secador del prototipo (hoy, Diego en su residencia); gestor que lo revisa a distancia | El mismo operador, en el cafetal o en otra tarea |
| Necesidad | Saber si el grano va bien y cuánto falta; actuar si algo falla | Saberlo de un vistazo sin sacar el teléfono |
| Experiencia técnica | Media-baja en campo; alta en el gestor | Igual |
| Edad, género, cultura | Adultos de 20 a 60+ años, hombres y mujeres, zona rural de Nariño, español de Colombia; lectura de cifras con coma decimal | Igual |
| Habilidad | Conoce el secado a fondo (sabe qué es 11 %); no tiene por qué saber de sensores | Igual |
| Condiciones | Exterior a pleno sol (6–17 h), atardecer, y revisiones de noche cuando el secado es eléctrico; manos con tierra o guantes; señal intermitente | Muñeca, 1–2 s de atención, a veces de noche; pantalla redonda de 192–227 dp |

### Comunicación (fase 2)

- **Qué debe comunicar Inicio**: «este es *tu* secador, ahora mismo» (la escena con la luz de la hora y el ventilador o la
  resistencia encendidos) y, encima, la respuesta a «¿cómo va el grano?»: humedad, estado, objetivo, cuánto falta y con
  qué confianza.
- **Decisión dominante**: seguir esperando o intervenir. La cifra de humedad y la pill de estado mandan; la escena es
  cabecera de lectura voluntaria (invita, ubica, confirma que el equipo está como uno cree) sobre una tarea obligada.
- **Qué NO va**: la escena nunca tapa ni compite con la cifra; nada de escena en tablas, gráficas, ajustes ni alertas
  (03-ilustración); en el reloj, nada de escena en siempre activo; ni personas ni mascotas.
- **Tema por hora**: comunica «la app acompaña el día»; la regla debe ser predecible (horas fijas, iguales a la escena).

### Restricción dominante

Legibilidad de la cifra y del saludo/campana **sobre una ilustración que cambia de luz** (cielo claro de día, durazno al
atardecer, casi negro de noche), en el mismo tema o en el contrario si la persona fijó Claro u Oscuro.

---

## 2. Materiales (antes de diseñar)

- **Tipografía**: Outfit (cifras, títulos) y Plus Jakarta Sans (texto) del sistema v2. Comprobado: empaquetadas en la app
  (`siscan_app/pubspec.yaml` → `assets/fonts/nuevas/Outfit.ttf`, `PlusJakartaSans.ttf`) y en el reloj
  (`siscan_reloj/app/src/main/res/font/outfit.ttf`, `plus_jakarta_sans.ttf`). Ninguna fuente del sistema operativo.
- **Imagen**: solo la escena `Landscape` del sistema, ya exportada a SVG: 27 archivos en
  `siscan_app/assets/sistema/paisaje/` (`day|dusk|night` × `completo` con y sin `aire`/`calor`, `movil`, `ingreso`,
  `tarjeta`, `foto`, `vacio`). Es dibujo propio del sistema (licencia del proyecto). Para el reloj falta un encuadre
  cuadrado centrado en el secador (paso del reloj). No hay fotos de personas ni lugares reales.

---

## 3. Referentes consultados (2026-10-12)

Capturas en `docs/ux/anexos/ref/2026-10-12-*.png` (Playwright 1.64, Chromium, escala 2×).

### Fuentes de la lista de pantalla

| Fuente | Estado | Cuenta |
|---|---|---|
| `styles.refero.design` | Consultada; la búsqueda respondió «Search is temporarily unavailable» (`ref/2026-10-12-refero-frosted-glass.png`). Además cataloga sitios web de producto, no apps móviles ni relojes. | **No** |
| `motionsites.ai` | Consultada (`ref/2026-10-12-motionsites-backgrounds.png`) | Sí |
| Pinterest | 2026-10-12: **no accesible** (extensión de Chrome sin conectar). **2026-10-15: consultada** con la sesión de Diego en Chrome (`ref/2026-10-15-pinterest-*.jpg`); ver «Referentes añadidos el 2026-10-15» | **Sí** (desde 2026-10-15) |
| `mobbin.com` | 2026-10-12: no accesible (extensión sin conectar). **2026-10-15: no accesible**: la extensión ya conecta, pero `mobbin.com/search/apps/ios?content_type=screens&q=weather app home` redirige a la portada con «Log in» / «Join for free»: no hay sesión de Mobbin en ese Chrome. La segunda búsqueda («smart home device status») no se intentó porque choca con el mismo muro de acceso | **No** |
| `ui.aceternity.com` | Consultada (`ref/2026-10-12-aceternity-componentes.png`); su catálogo son efectos web (haces, brillos, tarjetas 3D). Nada sobre escena ilustrada con tarjeta en móvil ni sobre Wear OS | **No** |
| Emil Kowalski | Consultada (`ref/2026-10-12-emil-you-dont-need-animations.png`) | Sí |
| Taste Skill | Cargada `design-taste-frontend`; sitio consultado (`ref/2026-10-12-tasteskill.png`) | Sí |

**Actualización 2026-10-15: 4 de 7 aportan** (se suma Pinterest). Mobbin pide una cuenta que no hay en el navegador.
**Excepción explícita, 2026-10-15: Diego acepta 4 de 7 fuentes para esta pieza** («las 4 fuentes estaban bien»,
comunicado por el agente coordinador). No se buscan más para este trabajo; la regla de 6 sigue valiendo para las piezas
siguientes. Lo que sigue es el registro original del 2026-10-12.

**Solo 3 de las 7 fuentes de la lista aportan a esta pieza**; la regla pide 6. No se rellena: Refero no tenía búsqueda,
Pinterest y Mobbin dependen de la sesión en Chrome y Aceternity no habla de esto. Se completó con documentación oficial
(permitida en el encargo), pero eso **no sustituye** la cuota de la lista. Para cumplirla antes del paso 2: Diego conecta
la extensión de Chrome y se consultan Mobbin (búsquedas «weather app home», «smart home device status») y Pinterest
(«illustrated header mobile card overlap», «wear os illustration»).

### Observación → decisión → límite

**Sistema SISCAN v2 y la web (la fuente de lo que le gustó a Diego)**
- `ref/2026-10-12-ds-activebatchhero-1200-oscuro.png`, `ref/…-ds-landscape.png` — En escritorio la tarjeta de vidrio
  ocupa la izquierda y el secador queda a la derecha con `xMaxYMax slice`: escena y dato se ven a la vez.
  → **Tomo** la composición «escena + tarjeta de vidrio que la pisa» y el encuadre anclado abajo a la derecha, donde
  está el secador. → No copio la rejilla de 360 px + 1fr: no existe en 390 px.
- `ref/2026-10-12-ds-activebatchhero-390-claro.png` — **En móvil el componente de la web colapsa a una columna y la
  tarjeta tapa casi toda la escena**: el secador no se ve; queda una franja de cielo y pasto. → Por eso la decisión 1 de
  Diego (tarjeta **sobre el borde inferior** de la escena) es la correcta: la escena va arriba a sangre (sin margen
  lateral, detrás de la barra de estado) y la tarjeta sube a montarse sobre su último tercio. → No reproduzco el
  colapso de la web en el teléfono.
- `ref/2026-10-12-ds-landscape.png` — El cielo de `day` es casi blanco verdoso arriba; `dusk`, durazno; `night`, casi
  negro. El tercio superior de la escena está libre (cielo, nubes, sol o luna). → El saludo y la campana van en esa banda
  de cielo y **su color sale de la variante de la escena, no del tema**: tinta oscura sobre `day`/`dusk`, `sobre-bosque`
  sobre `night`. Con «Según la hora» coinciden; con Claro fijado de noche, la escena es nocturna aunque la página sea
  clara. → Nada de velo degradado oscuro encima del cielo para «arreglar» contraste: se mide y se elige tinta.
- `ref/2026-10-12-ds-androidinicio.png` — Inicio del sistema: banda `bosque` con anillo, pill, objetivo, «Listo en ~5 h
  40» y «Confianza alta». → El contenido de la tarjeta es exactamente ese (lo que hoy hace `_Heroe`), ahora sobre vidrio.
  → La banda bosque desaparece; no se conservan las dos.
- `ref/2026-10-12-ds-watchmonitor.png`, `ref/…-ds-watchambient.png` y `07-smartwatch.md` — El reloj va siempre en oscuro
  sobre negro; Monitoreo es arco + cifra + objetivo + chip; siempre activo es solo contorno. → «El secador» es una página
  aparte en el paginador; Monitoreo no se toca; en ambiente se ve el `Ambiente()` de siempre. → No meto la escena detrás
  del arco de Monitoreo.

**motionsites.ai** — `https://motionsites.ai/backgrounds` (`ref/2026-10-12-motionsites-backgrounds.png`)
- Las escenas que mejor sostienen texto (la llanura con la figura, la colina con mariposas) dejan el sujeto en el tercio
  inferior y el cielo arriba como campo limpio para el titular. → Encuadre de Inicio: el secador en el tercio inferior
  derecho, el cielo para saludo y campana, la tarjeta sobre el pasto. → No copio el movimiento perpetuo de video: la
  escena queda quieta salvo el aire del ventilador que ya define el sistema (04-movimiento) y se apaga con «reducir
  movimiento».

**Emil Kowalski** — `https://emilkowal.ski/ui/you-dont-need-animations`
- Cuanto más a menudo se ve una animación, menos debe existir; lo que no tiene trabajo, fuera. → El cambio de tema no
  se interpola (`themeAnimationDuration: Duration.zero`): el lerp de colores de `MaterialApp` anima color, no
  `transform`/`opacity`, y el cambio manual se hace a propósito. El cruce automático de las 19:00 ocurre dos veces al día
  y casi nunca con la app abierta. → No agrego fundido de escena entre momentos en este trabajo.

**Taste Skill** — `https://tasteskill.dev` y skill `design-taste-frontend` §4.11, §5, §8
- «Page theme lock» y paridad de jerarquía entre temas; el vidrio exige borde interior y un respaldo sólido. → El
  vidrio de la tarjeta usa lo que ya define el sistema (superficie al 86 %, borde blanco al 60 % en claro y 8 % en
  oscuro); el desenfoque se mide en el paso 2 y, si cuesta cuadros en gama baja, queda el respaldo sólido al 86 % que ya
  da contraste por sí solo. → La escena es imagen, no una sección con otro tema: no rompe el «theme lock».

**Wear OS — Color** — `https://developer.android.com/design/ui/wear/guides/styles/color` (`ref/2026-10-12-wearos-color.png`)
- «Build from black»: los relojes se diseñan sobre fondo negro, y la guía dice que las interfaces de reloj deben
  funcionar de día y de noche con tokens propios, no con un tema claro. → **No hay tema claro en el reloj** (coincide con
  07-smartwatch). → Esto contradice la decisión 3 para el reloj: ver «Pendiente de decisión».

**Wear OS — Formas de pantalla** — `https://developer.android.com/training/wearables/design/screen-shapes`
(`ref/2026-10-12-wearos-formas-de-pantalla.png`)
- Diseñar primero para 192 dp redondo, márgenes en porcentaje, corte en 225 dp. → El encuadre de «El secador» es
  cuadrado y se recorta en círculo; la placa de la cifra va dentro del 70 % central y con margen inferior en porcentaje;
  se prueba en 192 y 227 dp. → No dibujo para una sola pantalla de 224 px como la maqueta.

**Wear OS — Siempre activo** — `https://developer.android.com/training/wearables/always-on`
(`ref/2026-10-12-wearos-siempre-activo.png`)
- Desde Wear OS 6, las apps con `targetSdk 36` (la nuestra) quedan siempre activas por defecto, atenuadas, y se
  actualizan como poco una vez por minuto. → La raíz ya cambia todo a `Ambiente()` en modo ambiente; «El secador» no
  dibuja la escena ahí. → Nada de vectores grandes encendidos en ambiente (pantalla OLED, quemado).

**AndroidX AppCompat — modo noche automático** — `https://developer.android.com/reference/androidx/appcompat/app/AppCompatDelegate`
- El modo noche por hora de AppCompat está marcado como obsoleto, usa la ubicación (si hay permiso) para calcular el
  amanecer y el atardecer, y sin permiso cae en horas fijas. → Nuestro «Según la hora» usa horas fijas de Colombia
  (6:00 y 19:00) y **no pide ubicación**. En Nariño (~1° N) el sol sale y se pone casi a la misma hora todo el año
  (≈ 5:50–6:15 y 18:00–18:20), así que las horas fijas no pierden precisión real. → No uso `MODE_NIGHT_AUTO_TIME` ni
  cálculo solar.

### Referentes añadidos el 2026-10-15 (Pinterest, con la sesión de Diego en Chrome)

Búsquedas hechas: «illustrated header mobile card overlap» (la que pedía el anexo; dio seis resultados de cabeceras web
y onboarding, ninguno de una tarjeta de datos sobre una escena en el teléfono, así que se registra y no cuenta; no se
guardó captura), «weather app illustration landscape header ui» (`ref/2026-10-15-pinterest-weather-busqueda.jpg`) y
«mobile app home illustration header overlapping card» (`ref/2026-10-15-pinterest-header-card-busqueda.jpg`).

**«Weather card» (Dribbble, vía Pinterest)**: `https://co.pinterest.com/pin/311381761732317704/`
(`ref/2026-10-15-pinterest-weather-card-dribbble.jpg`)
- Seis tarjetas de clima, una escena por hora y tiempo (sol, nubes, nieve, noche), y la temperatura **siempre en blanco**
  arriba a la izquierda, sobre el cielo. En la escena amarilla de sol y en la celeste, el «23°» y el «18°» casi
  desaparecen; en las de noche se leen bien. → **Lo tomo como contraejemplo**: una sola tinta para todas las luces
  falla justo en la de día. Por eso el saludo y la campana toman la tinta de la variante (tokens claros en `day`/`dusk`,
  oscuros en `night`) y **la cifra no va sobre el cielo**, va en la superficie de vidrio, que es casi opaca. → No copio
  el formato cerrado (escena dentro de una caja con franja de datos debajo): en Inicio la escena es a sangre.

**Travel App Design (Paperpillar, vía YDJ Blog en Pinterest)**: `https://co.pinterest.com/pin/460141286949733390/`
(`ref/2026-10-15-pinterest-paperpillar-travel.jpg`)
- Paisaje ilustrado a sangre en el teléfono: el titular en tinta oscura sobre el cielo libre del tercio superior, el
  sujeto (granja, vacas) en el tercio inferior y la acción (botón) montada sobre el pasto del primer plano, **sin tapar
  al sujeto**. → **Lo tomo** para la zonificación: saludo y campana en el cielo, el secador entero en el tercio
  inferior y la tarjeta montada solo sobre la franja de pasto y patas, debajo de las bandejas. → No copio el titular
  centrado, el botón naranja ni las nubes detrás del texto.

**Consecuencia medida**: en el lienzo de 1200 × 600 el secador ocupa x ≈ 600–1150 e y ≈ 400–600; sus bandejas terminan
en y ≈ 545. La observación de arriba («la tarjeta sube a montarse sobre su último tercio») **no es posible sin tapar el
secador**: el último tercio de la escena *es* el secador. C1 pide «sobre el borde inferior», y eso se cumple con un
solape de 32 px (space-8). No es enmienda del contrato; es la lectura medida de C1, y queda aquí para que Diego la vea.

---

## 4. Design Read

```text
Registro y audiencia: Producto (app de campo y reloj) para quien opera el secador; la escena es cabecera voluntaria sobre una tarea obligada.
Escena de uso: exterior con sol fuerte, atardecer y revisión nocturna; teléfono de gama media; 1–2 s en el reloj.
Tesis visual: el secador real del cafetal, con la luz de esta hora, sostiene en su borde la cifra del grano.
Jerarquía y decisión: humedad + estado (seguir o intervenir) > objetivo y cuánto falta > confianza > escena.
Materiales: Outfit/Plus Jakarta Sans, tokens v2, Landscape day/dusk/night, vidrio del sistema, sin movimiento nuevo.
Repertorio: escena = dónde y cuándo (una sola vez por pantalla); tarjeta de vidrio = el dato; pill = estado; anillo = avance; placa (reloj) = la cifra.
Puntos de entrada: el secador iluminado (con aire o calor) y la cifra grande que lo pisa.
Riesgo que se evita: el héroe de foto genérica con degradado negro encima y texto blanco; la banda verde repetida.
```

---

## 5. Contrato de diseño (firmado por las decisiones de Diego del 2026-10-12)

Hereda todo el sistema SISCAN v2 (`C:\dev\siscan-ds-nuevo\siscan-design-system`): tokens de color claro/oscuro,
Outfit + Plus Jakarta Sans y su escala, radios (tarjeta 20–24, chip y pill completos), sombras, duraciones y curvas de
04-movimiento, iconos del paquete. Nada de color, tipo, espaciado o efecto fuera de eso.

**C1 · Teléfono, Inicio «como la web».** `Paisaje` a sangre en la cabecera (detrás de la barra de estado), encuadre
anclado abajo a la derecha sobre el secador (`xMaxYMax`). La tarjeta de vidrio del lote (anillo de humedad, pill,
objetivo, predicción y confianza: el contenido actual de `_Heroe`) se monta sobre el borde inferior de la escena, como
`ActiveBatchHero`. Reemplaza la banda bosque. Variante = `Momento` en vivo; `aire` si hay ventilador encendido con lote
activo; `calor` si hay resistencia encendida. Saludo y campana en la banda de cielo, con tinta elegida por la variante
de la escena y **contraste medido sobre el render** en los tres momentos y los dos temas (AA de piso; la cifra AAA).
Sin lote activo: `EstadoVacio` del sistema. Vidrio = superficie 86 % + borde del sistema; desenfoque 14 si rinde.

**C2 · Reloj, pantalla «El secador».** Página propia del paginador. Escena recortada a la esfera con un encuadre
cuadrado nuevo centrado en el secador; cifra de humedad en una placa abajo; variante por `Momento`. Monitoreo no cambia.
En ambiente no hay escena (solo contornos, 07-smartwatch). Recurso Android elegido por medición (vector drawable,
`ImageVector` o mapa de bits por variante): se reporta tamaño del APK y tiempo de dibujo antes de decidir.

**C3 · Tema «Según la hora»** (ajustada el 2026-10-15 por la decisión A del reloj). **Solo en el teléfono**: selector
Claro · Oscuro · Según la hora · Como el teléfono. El reloj no tiene selector ni tema claro; en el reloj «la hora»
gobierna únicamente la variante de la escena de «El secador» (C2). Regla única: claro mientras
`Momento` es día o atardecer (6:00–19:00 hora de Colombia), oscuro de noche; cambia solo al cruzar el límite, sin
reiniciar. Una sola fuente de verdad (`Momento` / `RelojDelDia`), la misma de la escena. Solo el reloj del dispositivo;
no pide ubicación. El cambio de tema no interpola colores.

**C4 · Idioma (es/en/pt).** Fuera de alcance aquí: va después, en otra rama (`feature/idiomas`). Debe traducir también
«Según la hora», el saludo y los textos de la escena.

**Fuera de alcance**: animaciones nuevas, fundido entre momentos, escena en otras pantallas, idiomas, cambios a la web.

### Enmiendas · 2026-10-15 (aprobadas por Diego, comunicadas por el agente coordinador)

Diego: «haz lo que veas que quede mejor, si tenemos emulador revisa, y las 4 fuentes estaban bien».

- **E1 · Solape de la tarjeta (lectura definitiva de C1).** La tarjeta pisa la escena **32 px (space-8)**, sobre el pasto
  y las patas del secador, debajo de las bandejas. «Sobre el último tercio» queda descartado porque taparía el secador.
- **E2 · Campana sobre la escena en `tinta`.** Solo cuando está sobre la escena: `BotonIcono` recibe un `colorIcono`
  opcional que por defecto no cambia nada, y la cabecera le pasa la `tinta` del tema de la luz. En las demás pantallas
  la campana sigue en `tinta-suave` / `sobre-bosque`.
- **E3 · Luna y cúpula como en el sistema.** La causa no era una máscara ni el encuadre: flutter_svg descarta el alfa
  escrito dentro de `rgba()`. Se corrigieron los 27 SVG de la escena (5.490 colores) con `tools/svg_rgba_a_opacidad.py`,
  que pasa `rgba()` a hexadecimal más `*-opacity`. El dibujo del sistema no cambia, y el encuadre de C1 tampoco.
- **E4 · Investigación.** 4 de 7 fuentes aceptadas para esta pieza (excepción fechada en §3).
- **E6 · Placa del reloj centrada (enmienda a C2, 2026-10-15).** Diego: «dale, centrada y la luna, sigue con el paso 5».
  La placa de «El secador» va centrada sobre las montañas (40–60 % del alto), dentro del 70 % central, en lugar de
  «abajo», que tapaba el centro de la cúpula. Aplicada en `Secador.kt` y medida (ver «Paso 4 › E6»).
- **E7 · Luna para «Oscuro» (aprobada por Diego el 2026-10-15: «la a, sigue con el paso 5»; comunicada por el agente
  coordinador).** Se añadió `moon` de Lucide al paquete de íconos de la app, como `assets/sistema/iconos/luna.svg`:
  - Origen: `lucide-static` **1.57.0** (versión publicada el 2026-10-15, según `registry.npmjs.org/lucide-static/latest`),
    `https://unpkg.com/lucide-static@1.57.0/icons/moon.svg`, cotejado carácter por carácter con
    `https://raw.githubusercontent.com/lucide-icons/lucide/1.57.0/icons/moon.svg` (mismo trazado). Licencia **ISC**
    («Copyright (c) 2026 Lucide Icons and Contributors»). Se leyó el contenido con WebFetch y se transcribió; no se
    descargó ni se ejecutó ningún archivo.
  - Ajuste: `stroke-width` de 2 a **1,75**, caja de 24, `stroke="currentColor"`, extremos y uniones redondeados, como el
    resto del paquete. El archivo lleva un comentario con el origen.
  - Aviso de licencia: `assets/sistema/iconos/LICENCIA-lucide.txt`, con el ISC de Lucide y el MIT de Feather (Lucide
    deriva parte de sus íconos de Feather; no se confirmó si `moon` está en esa lista y se incluyeron los dos).
    **Pendiente legal que ya existía**: los demás íconos del paquete también salen de Lucide y la app no mostraba su
    licencia. El archivo ya la incluye; falta mostrarla en la app (por ejemplo, en Más › Privacidad o en la página de
    licencias) y revisarlo con la política.
  - Uso: «Oscuro» en Más › Tema; goldens `06t` regenerados (la luna se dibuja con el mismo peso que el sol).
  - **En el sistema de diseño (`C:\dev\siscan-ds-nuevo`) también hay que añadirla**: es la fuente de los íconos de la app
    (`tools/exportar_svg_sistema.mjs` exporta `ICON_NAMES`). Una nueva exportación borraría `luna.svg` de la app si el
    paquete no la trae. No se tocó ese repositorio.
  - Registro original del bloqueo: el paquete del sistema no la trae: sus 68 íconos (`components/bundle.local.js`, `ICON_NAMES`) incluyen `sol`, `nube` y
  `nubeSol`, pero ninguna luna. La luna de la escena es parte del dibujo `Landscape`, no un ícono. Como pidió el
  coordinador, no se dibujó ni se trajo uno de fuera. Opciones: (a) `moon` de Lucide, la familia de la que sale el
  paquete (trazo 1,75 en caja de 24), entrando por una enmienda al paquete del sistema; (b) dibujarla con la misma
  construcción (círculo menos círculo, como la luna de la escena), también como enmienda al paquete; (c) dejar `nube`.
- **E8 · La cifra manda en la tarjeta de Inicio (enmienda a C1, 2026-10-15).** Diego: «sí, visto bueno, y haz los
  arreglos convenientes». La tarjeta de vidrio toma la composición de `ActiveBatchHero`:
  - arriba, ficha del lote (sc-chip) y píldora de estado;
  - «Humedad del grano» (13/600) y la cifra con `.sc-bhero-v .sc-read`: Outfit 52/56, interletra −0,03 em, «%» a 22/700
    en tinta-suave. Peso 700, porque Flutter no tiene 750;
  - «Objetivo 10 – 12 % · **faltan ~X**» (resaltado en hoja), «Último pesaje …» (paso 6), la barra sc-progress en lugar
    del anillo y, si la predicción está en curso, la confianza.
  El anillo de C1 queda reemplazado.
- **E9 · Licencia de Lucide en la app (2026-10-15).** Más › «Acerca de y licencias» (`PantallaLicencias`) muestra completo
  `LICENCIA-lucide.txt` (ISC de Lucide y MIT de Feather) y lleva a «Ver todas las licencias» (`showLicensePage`), donde
  el aviso también está registrado con `LicenseRegistry` (`main.dart`). Se cierra el pendiente legal de los íconos.
- **E10 · Luna en el sistema de diseño (2026-10-15).** `C:\dev\siscan-ds-nuevo` **no es un repositorio git**, así que no
  hay rama `feature/icono-luna`. Los íconos solo existen dentro de los compilados `components/bundle.js` y
  `components/bundle.local.js` (objeto `I`; `ICON_NAMES` sale de sus claves). En los dos se añadió
  `luna: [pth('M20.985 12.486…')]` junto a `nube`, con un comentario de origen (lucide-static 1.57.0, ISC, URL). No se
  regeneró nada más: el paquete no trae fuente de íconos ni proceso de compilación en esa carpeta. Comprobado: los dos
  archivos pasan `node --check`, el paquete pasa de 68 a 69 íconos y el componente `Icon` del sistema la dibuja con el
  mismo trazo que `sol` y `nube` (render con Edge sin ventana). Copia de los dos compilados de antes del cambio en la
  carpeta temporal de la sesión, no en el repositorio. Falta en el sistema: añadir el aviso de licencia de Lucide a su
  documentación y, si algún día tiene fuente de íconos, la entrada ahí.
- **E5 · Emulador.** Se usó el AVD `Agenda_Pixel` (Android 16, 1080 × 2400, 60 Hz) para captura real, tiempo de cuadro y
  árbol de accesibilidad (ver Verificación).

### Decisión del reloj · 2026-10-15: opción A

**Decidido por Diego el 2026-10-15** (comunicado a esta sesión por el agente coordinador): **opción A**. En el reloj,
«la hora» gobierna solo la escena de «El secador» (día / atardecer / noche); la interfaz sigue oscura sobre negro, como
dicen 07-smartwatch y la guía de Wear OS. El selector de cuatro opciones es solo del teléfono (C3 ajustada). Las
opciones B y C quedan descartadas. `Momento.kt` sirve tal como está; en el reloj no se toca el tema.

Registro original del planteamiento (2026-10-12):

La decisión 3 pide «Según la hora» también en el reloj y el encargo dice que el reloj «ya tiene tema claro/oscuro con
selector Claro / Oscuro / Como el reloj». **No es así en el código actual**: `Tokens.kt` es solo oscuro («el reloj va
siempre en oscuro sobre negro»), no hay selector, y el anexo del 2026-10-09 dice que se borró el tema anterior del
reloj (el claro existía en el commit 1190e91, dirección A, antes del sistema v2). Además 07-smartwatch exige «siempre
tema oscuro sobre negro» y la guía de Wear OS dice lo mismo. Opciones:

- **A (recomendada)**: en el reloj, «la hora» gobierna solo la escena de «El secador» (día/atardecer/noche); la
  interfaz sigue oscura sobre negro. Se cumple el sistema y la guía, y la coherencia con el teléfono la da la escena.
- **B**: enmienda fechada a 07-smartwatch para un tema claro en el reloj con los tokens claros del sistema, más selector
  Claro · Oscuro · Según la hora · Como el reloj. Cuesta batería en OLED, va contra la guía de Wear OS y hay que medir
  contraste de todo el reloj otra vez.
- **C**: el reloj sigue el tema que eligió la persona en el teléfono (por la capa de datos), y solo aplica claro/oscuro
  a la placa de «El secador». Intermedia, pero añade una dependencia del teléfono.

(Hasta el 2026-10-15, en el reloj solo existía la regla compartida `Momento.kt`, que servía igual para A, B y C.)

---

## 6. Descartes

- **Viñeta aparte** (escena pequeña en una tarjeta debajo del héroe): repite el «lote activo con viñeta» de
  03-ilustración y deja la banda bosque; dos formas para el mismo trabajo.
- **Escena de fondo en Monitoreo del reloj**: compite con el arco y con la cifra de 34–56 px; Monitoreo es la lectura
  obligada y queda limpia.
- **Solo en la tarjeta (Tile) del reloj**: ProtoLayout no dibuja vectores complejos con fidelidad y la tarjeta tiene que
  cargar en milisegundos; la escena iría como mapa de bits fijo y sin variante en vivo.
- **Solo escena, sin tarjeta superpuesta**: la cifra quedaría debajo, fuera de la primera vista en 390 × 844, y se pierde
  justo lo que le gustó de la web.
- **Velo degradado negro sobre la escena para el texto blanco**: es el héroe de fábrica; se resuelve eligiendo tinta por
  variante y midiendo.
- **Modo noche automático de AppCompat**: obsoleto y con ubicación; horas fijas bastan en Nariño.

---

## 7. Plan de pasos (cada uno se muestra y espera visto bueno)

1. **Tokens/lógica** — regla `Momento` compartida y modo «Según la hora» en `TemaApp`; equivalente en el reloj. ✔
2. **Componente clave** — cabecera de Inicio: escena + tarjeta de vidrio + saludo/campana; contraste medido sobre el
   render en day/dusk/night × claro/oscuro. ✔ 2026-10-15, aprobado con las enmiendas E1–E5.
3. **Esqueleto** — Inicio completo con la cabecera nueva (lecturas, equipo, alertas debajo), sin la banda bosque.
   ✔ 2026-10-15, aprobado por Diego el mismo día («dale, sigue con el paso 4»; comunicado por el agente coordinador).
4. **Resto de componentes** (✔ aprobado el 2026-10-15, con E6) — selector de tema con cuatro opciones (no caben en el segmentado de 390 px: lista de
   opción única en la hoja); exportar el encuadre cuadrado del secador y la pantalla «El secador» del reloj con su placa;
   medir el recurso (tamaño y tiempo de dibujo). ✔ 2026-10-15, aprobado (con E6 y E7).
5. **Pantalla completa** — teléfono y reloj integrados; capturas. ✔ 2026-10-15, aprobado.
6. **Estados** — sin lote (vacío), cargando, error, sin conexión/dato viejo sobre la escena, sin permiso (solo lectura),
   ambiente en el reloj. ✔ 2026-10-15, esperando visto bueno.

---

## 8. Verificación

### Paso 1 (hecha el 2026-10-12)

- `flutter analyze` (con `tools/analizar.ps1`, copia ASCII en `C:\dev\siscan-build`): **0 avisos**.
- `flutter test test/momento_test.dart`: **20/20**. Casos 5:59:59, 6:00, 16:59:59, 17:00, 18:59:59, 19:00, 0:00, 23:59;
  `claro` en 5:59/6:00/18:59/19:00; independencia de la zona del teléfono; `Paisaje.momento` delega; próximo cambio
  (incluido fin de mes); el modo del tema en los cuatro límites; los demás modos no dejan temporizador; guardar/leer
  `hora`; **cruce en vivo**: a las 18:59:30 la app está clara, a los 29 s sigue clara, al llegar el temporizador
  (19:00:01) pasa a oscura sin reiniciar; y al volver de segundo plano con la hora ya cruzada, revisa y cambia.
- `flutter test test/pantallas_test.dart`: **43/45**. Fallan `04v-pesaje` claro y oscuro por diferencia de golden de
  0,60 % en las fechas del historial de pesajes (las del fixture se muestran relativas a hoy). **Ya fallaba igual en la
  rama base** sin estos cambios (probado en una copia con los archivos de `HEAD`: 0,59–0,60 %). No es de este trabajo,
  pero queda anotado: hay que fijar el reloj de esa prueba o regenerar el golden.
- Reloj: `gradlew :app:testDebugUnitTest :app:assembleDebug` → **BUILD SUCCESSFUL**; `MomentoTest` 5/5, `EstadoTest` 4/4.

### Paso 2 (hecha el 2026-10-15)

Qué se construyó, cláusula por cláusula de C1:
- Escena `Paisaje` a sangre y detrás de la barra de estado, anclada abajo a la derecha (`Alignment.bottomRight`, el
  `xMaxYMax` de la web). Alto total = 0,9375 × ancho: con recorte, la escala es alto/600 y se ve el lienzo desde
  x = 560, así el secador (x ≈ 600–1150) entra entero en 360, 390 y 412 px. La primera versión contaba la barra de
  estado aparte, y el secador salía cortado por la izquierda: se vio en el golden y se corrigió.
- Variante en vivo por `Momento` (escucha `RelojDelDia` de `TemaApp`, la misma fuente del tema); `aire` si hay un
  ventilador encendido con lote activo, `calor` si hay una resistencia encendida. Escena dentro de `ExcludeSemantics`
  (comprobado en la prueba).
- Banda de cielo: logo, campana (44 × 44), saludo en `saludo` (Outfit 28/700) y subtítulo en `apoyo` 13/600. La tinta
  sale de la variante: la banda se envuelve en el tema del sistema que corresponde a la luz (claro en `day`/`dusk`,
  oscuro en `night`), así texto, campana y contador cambian juntos y no dependen del tema de la persona. La barra de
  estado del sistema también sigue la variante. Sin velo ni degradado encima del cielo.
- Tarjeta de vidrio `TarjetaLoteVidrio` (sc-bhero-card): superficie al 86 %, borde blanco al 60 % (8 % en oscuro),
  radio lg 20, sombra de tarjeta, desenfoque 14; relleno space-4; contenido de `_Heroe` (anillo de 132, pill,
  «Objetivo 10 – 12 %», predicción y confianza) con los colores del sistema para superficie (tinta, tinta-suave,
  predicción) en vez de los de la banda bosque. Pisa la escena 32 px (space-8), sobre el pasto y las patas.
- Sin lote: hoy no se dibuja la tarjeta; el `EstadoVacio` va en el paso 6 (estados).

Medición (script `siscan_app/test/cabecera_inicio_test.dart`, ejecutado en `C:\dev\siscan-build`):
- **Método de contraste**: se dibuja la cabecera, se vuelve transparente la tinta de cada texto y se dibuja otra vez.
  Los píxeles que cambian entre los dos renders son las letras; en esos píxeles, el render sin tinta es exactamente lo
  que hay detrás (escena, vidrio o pill). Se compara el color del texto contra cada uno y se toma **el peor** (mín.).
  La campana se mide contra los píxeles de su botón de 44 × 44 fuera del glifo central y del contador (3:1, 1.4.11).
  La primera pasada medía toda la caja del párrafo y daba 1,00:1 en «Humedad del grano» porque la caja tocaba el trazo
  del anillo: era un error del método, no del diseño, y se corrigió con la máscara de letras.
- **18 renders** (360/390/412 × day/dusk/night × claro/oscuro), **144 mediciones, 0 fallas**. Peor caso por elemento:

| Elemento | Piso | Peor medido | Dónde |
|---|---|---|---|
| Campana (ícono) | 3,00 | **3,08** | 390 · dusk · claro (los tres anchos dan 3,08 en dusk) |
| Saludo 28/700 | 3,00 | 5,34 | 390 · night (el borde del halo de la luna) |
| Subtítulo 13/600 | 4,50 | 7,95 | dusk |
| Cifra 24/800 (AAA) | 4,50 (AAA grande; 7,00 normal) | 13,91 | day · oscuro |
| Rótulo «Humedad del grano» 11 | 4,50 | 5,81 | claro |
| Pill «Secando» 12/700 | 4,50 | 5,26 | claro |
| «Objetivo 10 – 12 %» 15/700 | 4,50 | 13,91 | oscuro |
| Predicción 13 | 4,50 | 5,81 | claro |

  Por cruce (peor de los tres anchos): day claro: campana 4,37 · saludo 10,36 · cifra 14,34 · pill 5,26;
  day oscuro: 4,37 · 10,36 · 13,91 · 6,45; dusk claro: 3,08 · 7,95 · 14,34 · 5,26; dusk oscuro: 3,08 · 7,95 · 13,91 ·
  6,45; night claro: 15,67 · 5,34 · 14,34 · 5,26; night oscuro: 15,67 · 5,34 · 13,91 · 6,45. Detalle completo en
  `siscan_app/test/capturas/cabecera/contraste.tsv`.
- **La cifra cumple AAA incluso con el piso de texto normal (7:1)**: 13,91 en el peor caso.
- **Toque**: `MinimumTapTargetGuideline` 44 × 44 pasa en los 18; la campana mide 44 × 44.
- **Goldens**: `siscan_app/test/capturas/cabecera/<ancho>-<day|dusk|night>-<claro|oscuro>.png` (18), con el fondo de
  página detrás de la tarjeta.
- `flutter analyze`: **0 avisos**. Batería completa: **81 pasan, 2 fallan**: los dos `04v-pesaje` (claro y oscuro), los
  mismos que ya fallaban antes de esta rama por las fechas del historial. No son de este paso, pero siguen ahí.

Fallos, márgenes y pendientes del paso 2 tal como se entregó (sin maquillar; los que se resolvieron el mismo día van
marcados y su nueva medición está en «Paso 2 · re-medición»):
- **[Resuelto por E2]** **Campana al atardecer: 3,08:1**, apenas encima del piso de 3:1. Usa `tinta-suave` (lo que dibuja `BotonIcono`)
  sobre el cielo durazno. Pasa, pero sin margen. Propuesta para que Diego decida (no se aplicó porque toca un
  componente base): que `BotonIcono` sobre escena use `tinta` (≈ 7,5:1 calculado sobre el mismo píxel peor; sin render todavía).
- **[Resuelto por E3]** **Logo contra el halo de la luna** (night, sobre todo a 390): el disco y el halo caen justo a la derecha de
  «SISCAN». El logo está exento de 1.4.3 y no se midió; a ojo se lee, pero queda anotado. El saludo ya no lo toca
  (mín. 5,34:1).
- **[Medido en emulador; gama baja sigue pendiente]** **Desenfoque 14 en gama baja: sin medir.** No había teléfono ni emulador Android conectado (solo Windows y Edge en
  `flutter devices`). Queda pendiente medirlo con `flutter run --profile` en un equipo real; si cuesta cuadros, se
  quita el `BackdropFilter` y queda la superficie al 86 %, que ya da el contraste medido por sí sola.
- **Razón titular/cuerpo**: 28/13 = 2,2× (la cifra es de 24). Está por debajo del 6× del protocolo del agente, que
  piensa en piezas de lectura voluntaria; aquí la tarjeta es de lectura obligada y la escala viene del contrato (la del
  sistema). Se informa, no se fuerza.
- **Goldens desincronizados de antes**: la copia ASCII tiene `04v-pesaje`, `15-privacidad` y `16-reloj` regenerados el
  2026-10-08 y el árbol real conserva los confirmados en git (`tools/analizar.ps1` excluye `capturas`). No se tocaron:
  hay que decidir cuáles valen y copiarlos en un sentido.
- **Movimiento**: ninguno nuevo. El aire del ventilador sigue siendo el del SVG fijo (fuera de alcance).

### Paso 2 · re-medición tras E2 y E3 (2026-10-15)

- **E3, causa comprobada**: el mismo SVG `night` en Edge headless (Chromium, el motor del sistema) tiene un halo tenue,
  luna creciente y cúpula transparente; en Flutter el halo salía casi opaco, la luna como un eclipse y la cúpula maciza.
  En el SVG no hay `mask` ni `clipPath`: la luna es un círculo claro (r 30) con otro del color del cielo encima (r 26)
  y el halo es un `radialGradient` con `stop-color="rgba(230,240,220,0.1)"`. Sin ese 0,1, el halo aclara el cielo y el
  círculo «del color del cielo» se ve negro. Lámina: `ref/2026-10-15-luna-chromium-antes-despues.png` (Chromium ·
  Flutter antes · Flutter después, mismo encuadre).
- **Que la corrección no cambia el dibujo**: Chromium, antes contra después, en `day-aire`, `dusk-aire-calor` y
  `night-aire-calor` (1200 × 600): diferencia máxima de 1/255 y ningún píxel por encima de 2 (redondeo del hexadecimal).
- Diferencia menor que queda: las tres líneas de aire dentro de la cúpula (trazos `#ffd9a8` al 80 %) se ven más débiles
  en Flutter que en Chromium. Observada, sin investigar.
- **Contraste, 18 renders, 144 mediciones, 0 fallas.** Peor caso nuevo: **campana 7,62:1** (antes 3,08), saludo
  7,95:1 (dusk; de noche sube de 5,34 a 12,26 porque el halo ya no aclara el cielo), subtítulo 7,95, cifra 13,91 (AAA),
  rótulo del anillo 5,81, pill 5,26, objetivo 13,91, predicción 5,81. Por cruce, campana / saludo: day 10,82 / 10,36;
  dusk 7,62 / 7,95; night 15,67 / 12,26 (iguales en claro y oscuro, porque la banda de cielo sigue la luz).
- **Orden de lectura** (nuevo en la prueba): campana antes que saludo, saludo antes que subtítulo, subtítulo antes que
  el anillo, y el subtítulo nunca fundido con la tarjeta. Pasa en los 18.

### Paso 3 · Inicio con la cabecera (2026-10-15)

Qué cambió:
- `PantallaInicio` monta `CabeceraInicio` en lugar de `BarraApp` bosque y `_Heroe` (borrado). Debajo, sin cambios:
  aviso de sin conexión, lecturas, equipo y alertas; sin lote, el `EstadoVacio` del sistema. Cargando y error muestran
  la escena y el saludo sin tarjeta (el detalle de esos estados es del paso 6).
- `CuerpoPantalla` (marco) acepta `franjaDesde`: en Inicio, la franja opaca bajo la hora no se pinta mientras detrás de
  la hora pase la escena, y aparece cuando la escena sale por arriba. La franja lleva su propio estilo de barra de
  estado según el tema. **Fallo encontrado en el emulador y corregido**: sin eso, al desplazar, la hora quedaba en
  íconos oscuros sobre el fondo oscuro.
- **Accesibilidad, fallo encontrado en el emulador y corregido**: el subtítulo y la tarjeta se fundían en un solo nodo
  que se leía antes que el saludo, y el tooltip de `BotonIcono` subía «Alertas» al contenedor de toda la cabecera.
  Ahora saludo, subtítulo y tarjeta son nodos propios, y el tooltip de `BotonIcono` queda fuera del árbol semántico
  (`excludeFromSemantics`; el botón ya se anuncia con su etiqueta). **Este último cambio es del componente base y vale
  para todas las barras con íconos.** No cambia nada visible.
- Arnés `pantallas_test.dart`: el reloj del día queda fijo en las 10:00 de Colombia para que las capturas de Inicio no
  dependan de la hora a la que se corran.

Medición:
- `flutter analyze`: **0 avisos**. Batería completa (`C:\dev\siscan-build`): **81 pasan, 2 fallan** (los `04v-pesaje`
  de siempre, por fechas; no se regeneraron).
- Goldens regenerados, claro y oscuro: `02-inicio`, `02v-inicio-vivo`, `20-estado-vacio` y `21-estado-error` (Inicio), y
  `01-ingreso`, `04-pesaje-vacio` y `08-mapa` (cambian solo por E3: la cúpula y el pasto ahora translúcidos; se
  comprobó en el diff aislado de `08-mapa`). Al regenerarse, cada una pasó también el contraste AA medido sobre el
  render y el toque de 44 × 44 de la pantalla entera (en el arnés, el golden se comprueba primero y, si falla, lo demás
  no se ejecuta).
- Antes/después: `docs/ux/capturas/invernadero/2026-10-15-inicio-antes-despues.png`. Costo de C1 que conviene ver: a
  390 × 844 la cabecera baja las lecturas unos 290 px; la tarjeta del lote y la primera fila de lecturas siguen en la
  primera vista y Equipo queda debajo.
- **Emulador `Agenda_Pixel`** (Android 16, 1080 × 2400, 420 dpi, 60 Hz), APK de perfil `android-x64`, datos reales del
  servidor (secador sin reportar desde agosto, así que sale el aviso «Sin señal»). Es día en Colombia, el emulador está
  en tema oscuro y la cabecera muestra la escena `day` con tinta de cielo: el cruce «tema contrario» de C1, en vivo.
  - Capturas: `docs/ux/capturas/invernadero/2026-10-15-emulador-inicio-arriba.png` y `…-emulador-inicio-desplazado.png`.
  - Orden de lectura con `uiautomator` (lo que recibe TalkBack): logo · «Alertas» (botón) · «¡Hola!» · subtítulo ·
    tarjeta · anillo «100 % del avance, Humedad del grano 10,6 %» · aviso. La escena no aparece.
    `…-emulador-orden-de-lectura.txt`. **TalkBack no se activó** (sería cambiar los ajustes de accesibilidad del
    dispositivo): se verificó el árbol, no la voz.
  - **Fluidez del desenfoque 14** (SurfaceFlinger `--latency` de la capa de Flutter, 3 tandas de 6 gestos con la
    cabecera en pantalla, 378 intervalos): con desenfoque, mediana 16,61 ms, p90 18,04, p99 33,36, máx. 53,38, **7 vsync
    perdidos (1,9 %)**. Control con la misma app **sin** desenfoque (compilado solo en la copia ASCII y restaurado
    después): mediana 16,74, p90 18,02, p99 32,51, máx. 67,77, **5 vsync perdidos (1,3 %)**. La diferencia está dentro del
    ruido: **en el emulador el desenfoque no tiene un costo medible y se queda**. El emulador usa la GPU del computador,
    así que **un Android de gama baja real sigue pendiente**.

### Paso 4 · Resto de componentes (2026-10-15)

**Teléfono, C3: selector de tema.**
- El sistema no tiene un control de opción única. Se armó `ListaOpcionUnica` (`lib/core/ui/dominio.dart`) con piezas
  que sí existen: la fila sc-li (ListItem, 60 de alto), la marca de sc-check en círculo (borde línea-fuerte; elegida,
  relleno hoja y check en sobre-hoja) y el foco visible de sc-check (contorno esmeralda de 3, puesto 6 por fuera de la
  fila para no pisar el ícono ni la marca). Cada fila se anuncia como opción de un grupo excluyente, marcada o no.
- Opciones en la hoja de Más › Tema: Claro («Siempre claro», `sol`), Oscuro («Siempre oscuro», `nube`, la pareja que ya
  usaba la hoja), Según la hora («Claro de 6:00 a 19:00, oscuro de noche (hora de Colombia)», `reloj`) y Como el
  teléfono («Sigue el ajuste del sistema», `config`). Elegir aplica y cierra, como antes.
- Prueba (`pantallas_test.dart`, «Más › Tema», claro y oscuro): goldens `06t-tema-claro`, `06t-tema-oscuro` y
  `06t-tema-foco-claro` (foco de teclado); **contraste AA medido sobre el render dentro de la hoja, 0 fallas**; toque
  ≥ 44 en toda la pantalla; cuatro nodos en grupo excluyente, una sola marcada y con acción de toque; **con Tab se llega
  a «Según la hora» y Enter la elige** (la preferencia queda en `hora` y Más lo dice). `medirContraste` acepta ahora
  `solo:` para medir dentro de una hoja modal (lo de detrás queda bajo el velo y no se lee).

**Reloj, C2 con la opción A: «El secador».**
- Página propia del paginador, la segunda (un deslizamiento después de Monitoreo, que no cambió). Las páginas siguientes
  y el salto desde una alerta se corrieron un lugar. Escena a pantalla completa recortada a la esfera, variante por
  `Momento` en vivo (`momentoEnVivo()`), interfaz oscura sobre negro. En ambiente la página no existe: la raíz dibuja
  `Ambiente()`. Sobre la escena, la hora lleva su banda en `bosque` (`TimeText` con fondo solo en esta página), porque
  el cielo de día es claro.
- Placa: ícono `grano` en dato-grano + cifra en Outfit 34 (el mínimo del sistema en el reloj) con «%» en tinta-suave,
  sobre `bosque`, en píldora. Primera versión: su borde inferior en el borde del círculo del 70 % central. **Desde E6
  (2026-10-15): centrada, sobre las montañas.** Lector: un solo nodo,
  «Humedad del grano 10,6 %»; la escena no se lee. Variante de depuración: `--es momento day|dusk|night` fija el
  momento para las capturas, igual que `api`.
- Encuadre `540 40 560 560` del lienzo 1200 × 600: la cúpula entera (x 600–1040) y el sol o la luna arriba a la derecha.
  Se probaron `610 180 420 420`, `600 160 440 440` y `630 200 400 400` (cortan la cúpula) y `520 0 600 600`.

**Recurso del reloj: medido y elegido por las cifras.** Dos opciones, las dos sacadas de la misma escena corregida
(E3): VectorDrawable generado con `tools/svg_escena_a_vector.py` (unos 2.180 trazados por momento, con degradados) y
WebP de 454 px calidad 95 (`tools/generar_escena_reloj.py`, Edge sin ventana; reproduce los archivos con diferencia 0).

| | VectorDrawable | WebP 454 px |
|---|---|---|
| Recurso dentro del APK, por momento | 58,5 KB comprimido (376 KB sin comprimir) + 2,3 KB de degradados | 19,6–24,3 KB |
| APK release (base sin escena: 3.302.369 B) | 3.489.985 B (**+183,2 KB**) | 3.372.452 B (**+68,4 KB**) |
| Primera carga y dibujo en el reloj, mediana (máx.) | **234,7 ms** (818 ms) | **14,9 ms** (16,3 ms) |
| Al volver a la página, mediana (máx.) | **99,3 ms** (149 ms) | **0,5 ms** (1,9 ms) |

Banco en `src/debug` (`BancoEscenaActivity`, no existe en la release): 3 momentos × 8 repeticiones por opción en el AVD
`Reloj_WearOS` (Wear OS 36, 454 × 454, 320 dpi). A 60 Hz un cuadro dura 16,7 ms: el vector perdería unos 6 cuadros cada
vez que se entra a la página. **Se eligió WebP** (unas 200 veces más rápido y 2,7 veces más liviano). Los vectores
quedan solo en `src/debug/res` para poder repetir el banco. Release final: 3.371.160 B (+68.791 B). No se midió
`ImageVector` en Kotlin aparte: en Compose, `painterResource` sobre un VectorDrawable ya arma un `ImageVector` y lo
rasteriza con el mismo pintor, así que su dibujo cuesta lo mismo; solo se ahorraría la lectura del XML.

**Verificación del reloj (medida):**
- `gradlew :app:testDebugUnitTest :app:assembleDebug`: **BUILD SUCCESSFUL**; pruebas 11/11 (Estado 4, Momento 5,
  Secador 2: un recurso por momento y encuadre cuadrado). `assembleRelease` con la revisión de lint de publicación:
  BUILD SUCCESSFUL.
- Capturas reales del emulador a **227 dp** (454 px a 320 dpi) y **192 dp** (`wm density 378`, restaurada después) en
  day/dusk/night. A 192 dp la página se ve proporcionalmente igual, porque `Esfera` escala el diseño de 224 a la pantalla.
- **Contraste sobre el render** (`siscan_reloj/verificar_secador.py`; fondo = color más frecuente de la placa o de la
  banda, tinta = núcleo del glifo), 24 mediciones, **0 fallas**: cifra **18,34:1** (pasa AAA aun con el piso de texto
  normal, 7:1); «%» 9,24:1; ícono 7,90:1 (mínimo 3); hora 9,24:1 sobre su banda en los tres momentos. Primera pasada
  con error de método: la caja de la hora tomaba cielo junto a la banda; se ajustó a los dígitos.
- **Ambiente, sin quemado**: con «El secador» abierto, el reloj pasó a ambiente (`KEYCODE_SLEEP`,
  `mWakefulness=Dozing`) y se ve solo `Ambiente()`: **2,61 % de píxeles encendidos, luminancia media 0,55 %, 0 píxeles
  de color de la escena**.
- **Fluidez** (`dumpsys gfxinfo`, 10 idas y vueltas): Monitoreo ↔ El secador, 809 cuadros, 4,2 % lentos, p50 22 ms,
  p95 32 ms; control Lecturas ↔ Equipo (sin escena), 531 cuadros, 7,5 % lentos, p50 21 ms, p95 34 ms. La escena no
  empeora la fluidez; el emulador de Wear es lento en general (GPU p50 18 ms).
- Lector (uiautomator): en la página solo aparece «Humedad del grano 10,6 %». Antes de corregir salían también «10,6» y
  «%» sueltos; se cambió a `clearAndSetSemantics`.
- Capturas en `docs/ux/capturas/invernadero/reloj/`; mediciones en `…/2026-10-15-reloj-contraste-y-ambiente.tsv` y
  `…/2026-10-15-reloj-banco-escena.tsv`.

**Decisión pendiente para Diego: dónde va la placa.** El dibujo termina en y = 600, así que en cualquier cuadrado el
secador queda entre el 62 % y el 89 % del alto. Una placa con la cifra al mínimo del sistema (Outfit 34, unos
46 × 125 dp), «abajo» y dentro del 70 % central (como dice el contrato y como está implementado), **tapa el centro de la
cúpula**: del secador se ven los extremos, las patas y el panel. Bajarla no sirve: más abajo el círculo es más angosto
que la placa y la recorta, y en el punto más bajo posible (90 %) sigue tapando la parte baja de la cúpula. Alternativa
probada en el reloj: **la placa centrada, sobre las montañas (40–60 % del alto)**, también dentro del 70 % central. El
secador se ve entero y la cifra se lee igual (`ref/2026-10-15-reloj-placa-contrato-vs-centrada.png`: contrato de día y
de noche, y luego la centrada de día y de noche). **Recomendación: la centrada.** Contradice el «abajo» de C2, así que
no se aplicó sin permiso.

#### E6 · Placa centrada: medición (2026-10-15)

- `Secador.kt`: la placa queda centrada en la página (`Alignment.Center`) y el secador, entre el 62 % y el 89 % del alto,
  se ve entero en los tres momentos (`docs/ux/capturas/invernadero/reloj/2026-10-15-reloj-lamina.png`).
- `verificar_secador.py` ya no usa cajas fijas: busca la placa en cada captura (el bloque bosque por debajo de la banda
  de la hora) y separa por columnas ícono, cifra y unidad, lejos de las puntas redondeadas. Antes de usarlo se
  comprobó contra las capturas anteriores: reproduce los mismos valores (7,90 / 18,34 / 9,24). La primera versión de la
  detección tomaba escena en las puntas; se corrigió.
- Capturas nuevas en el emulador a 227 y 192 dp, en day/dusk/night: **24 mediciones, 0 fallas**. Cifra 18,34:1 (AAA,
  también contra 7:1), «%» 9,24:1, ícono 7,90:1, hora 9,24:1 sobre su banda. Ambiente: 2,52 % de píxeles encendidos,
  luminancia media 0,53 %, 0 píxeles de color de la escena. Detalle en `…/reloj/2026-10-15-reloj-contraste-y-ambiente.tsv`
  (reemplaza al de la placa abajo; las capturas de la placa abajo quedan en la lámina comparativa de `ref/`).
- Reloj: `gradlew :app:testDebugUnitTest :app:assembleDebug` → BUILD SUCCESSFUL.

### Paso 5 · Pantalla completa (2026-10-15)

**Teléfono, de punta a punta en el emulador `Agenda_Pixel`** (APK de perfil con datos reales del servidor):
- Para ver el cruce de las 19:00 sin tocar la hora del sistema, `main.dart` acepta, solo fuera de la versión publicada
  (`kReleaseMode`), `--dart-define=SISCAN_HORA=18:58:30`. El reloj del día de la app arranca a esa hora de Colombia y
  sigue corriendo.
- Recorrido: al abrir, Inicio con la cabecera (atardecer; el emulador está en oscuro y el tema era «Como el teléfono»)
  → Más › Tema (luna en «Oscuro») → «Según la hora» → Inicio en **claro con escena de atardecer** (18:58) → sin tocar
  nada, pasadas las 19:00 la app cambia sola a **oscuro con escena de noche**, y la barra de estado pasa a íconos claros.
  La primera captura del cruce (a los 93 s) llegó todavía antes del límite: el desfase se calcula cuando arranca el
  proceso y el temporizador espera 1 s de margen. La siguiente (a los 111 s) ya muestra el cruce.
- Capturas: `docs/ux/capturas/invernadero/paso5/2026-10-15-telefono-{1-inicio-al-abrir, 2-hoja-tema,
  3-inicio-1858-segun-la-hora, 4-inicio-1900-cruce, 5-inicio-despues-de-las-1900}.png` y la lámina
  `…/2026-10-15-telefono-recorrido.png`.

**Reloj, en el AVD `Reloj_WearOS`**: Monitoreo → El secador → Monitoreo, deslizando
(`…/paso5/2026-10-15-reloj-{1-monitoreo, 2-el-secador, 3-de-vuelta-en-monitoreo}.png`, lámina
`…/2026-10-15-reloj-recorrido.png`). La escena sigue el momento en vivo, sin forzar: el emulador marcaba 02:11 GMT del 16,
es decir 21:11 del 15 en Colombia, y salió `night`, como debe. La primera pasada salió corrida porque el saludo de
bienvenida de Wear OS se comió un deslizamiento y deslizar a la derecha desde Monitoreo cierra la app; se repitió.

**Prueba comparativa del protocolo**: `ref/2026-10-15-comparativa.png`, a la misma altura y sin rótulos:
`ActiveBatchHero` de la web arriba; abajo, Paperpillar, el Inicio nuevo (captura real del emulador) y «Weather card».
- ¿Se señala en dos segundos como «la que no hizo un diseñador»? **No**: comparte el dibujo del sistema y la composición
  escena + tarjeta montada en el borde se sostiene junto a Paperpillar.
- ¿Es la más pobre de las cuatro? **No**, pero **junto a `ActiveBatchHero` pierde en el dato**: allí la humedad va a 52 px
  con barra de avance y «faltan ~5 h 40 min»; en el teléfono es 24 px dentro del anillo y la escena manda sobre la cifra.
  Arreglarlo cambia el contenido que fija C1 (el anillo de `_Heroe`): queda como propuesta para Diego, sin aplicar.
  Propuesta concreta: llevar a la tarjeta del teléfono la composición de la web (cifra en `display` a 48–52 con «%» en
  tinta-suave, barra de avance y «faltan…»), ya medida en la web.
- ¿Hay algo nuestro que copiaría? **Sí**: la escena con la luz de la hora en vivo, la tinta del cielo según la luz y no
  según el tema, y el cruce de las 19:00 sin reiniciar.

**Verificación medida**:
- `flutter analyze`: 0 avisos. Batería del teléfono: **83 pasan, 2 fallan** (los `04v-pesaje` de siempre, por fechas).
- Reloj: `gradlew :app:testDebugUnitTest :app:assembleDebug` → BUILD SUCCESSFUL, 11/11.
- Árboles sincronizados: `lib`, `assets` y `test` iguales; solo difieren los goldens `04v`/`15`/`16` desde el 2026-10-08.
- Emuladores cerrados al terminar (`adb devices` vacío).

### Arreglos E8–E10 (2026-10-15): medición

- **E8**, en `cabecera_inicio_test.dart`, con la predicción en curso para que se dibujen «faltan ~X» y la confianza:
  - **198 mediciones de contraste sobre el render, 0 fallas.** Cifra 13,91:1 en el peor caso (pasa AAA incluso contra
    7:1). «faltan ~X» en hoja 7,21:1. Confianza 5,43:1. Ficha del lote 5,61:1. Píldora 5,26:1. «%» 5,81:1.
  - Geometría (`test/capturas/cabecera/geometria.tsv`): la tarjeta mide 223 px y **sigue pisando la escena solo 32 px**
    (no tapa más el secador). **Cabe entera en la primera vista**: en 360 × 640 quedan 31,5 px libres sobre la barra
    inferior; en 390 × 844, 207,4; en 412 × 915, 257,8.
  - Toques ≥ 44 en los 18 cruces.
  - Lector: «Humedad del grano 10,6 %» sigue siendo un solo nodo; la prueba «Lector de pantalla» pasa.
  - Lámina antes / después con la web: `ref/2026-10-15-e8-tarjeta-antes-despues-web.png`.
- **E9**: golden `15l-licencias` en claro y oscuro, con contraste AA y toques medidos. El aviso se refluyó a un párrafo por
  línea (se comprobó que las palabras son las mismas) para que no se corte en el teléfono.
- **E10**: ver arriba.

### Paso 6 · Estados (2026-10-15)

**Teléfono** (goldens en claro y oscuro, cada uno con contraste AA sobre el render y toques medidos por el arnés):

| Estado | Golden | Qué se ve |
|---|---|---|
| Cargando | `22-estado-cargando` | escena y saludo, «Leyendo el secador…», esqueletos del sistema |
| Error | `21-estado-error` | «No se pudo leer el secador» en el subtítulo (antes decía «Leyendo el secador…») y la tarjeta de error con «Reintentar» |
| Sin lote | `20-estado-vacio` | `EstadoVacio` **sin su propia escena** (salía repetida bajo la cabecera; la escena va una sola vez por pantalla) |
| Copia guardada (sin señal) | `23-estado-copia-guardada` | tarjeta con el dato y «Último pesaje …», aviso «Sin señal: ves la copia guardada (hoy · 10:00)» |
| Dato viejo (el secador no reporta) y solo lectura | `02-inicio` | escena **sin aire ni calor** (no se sabe si el equipo sigue así), aviso «El secador no reporta desde…», «Vista de solo lectura» en Equipo |

- **Fallo propio encontrado y corregido**: sin tarjeta (cargando), «Cargando el estado del secador…» se dibujaba sobre el
  pasto con **2,26:1**. La cabecera reservaba el solape aunque no hubiera tarjeta. Ahora, sin tarjeta, lo de abajo empieza
  donde termina la escena.
- **Hora de las pruebas fija**: los textos de fecha (`corta`, `hace`, `minutosDesde`, la hora de la copia guardada) leían
  `DateTime.now()` directamente. Ahora usan `ahora()` de `estado.dart`, que en la app es el reloj del teléfono y en las
  pruebas queda fija a las 10:00 del 15 de octubre. **Así deja de fallar `04v-pesaje`**, que dependía de la fecha desde
  antes de esta rama: se regeneró (historial del 8 al 13 de octubre respecto de la hora fija). Batería: **91/91, dos
  corridas seguidas**.
- Lámina: `docs/ux/capturas/invernadero/paso6/paso6-telefono-estados.png`.

**Reloj** (capturas reales en el AVD `Reloj_WearOS`; los dos primeros estados se provocaron con un servidor inalcanzable,
`--es api http://10.255.255.1/x`, solo en depuración, y la app de prueba reinstalada para no tener copia):

| Estado | Captura |
|---|---|
| Cargando («Leyendo el secador…», con el símbolo) | `paso6/2026-10-15-reloj-cargando.png` |
| Sin conexión y sin copia (ámbar, «Reintentar») | `paso6/2026-10-15-reloj-sin-conexion.png` |
| Dato viejo (Monitoreo con «Sin conexión · 19 ago») | `paso6/2026-10-15-reloj-dato-viejo-monitoreo.png` |
| Sin red con copia guardada | `paso6/2026-10-15-reloj-copia-sin-red.png` |
| Ambiente | `paso6/2026-10-15-reloj-ambiente.png` |

- Contraste (`verificar_secador.py --estados`, cajas del árbol de accesibilidad): **14 textos, 0 fallas**; el más bajo
  es el chip «Sin conexión · 19 ago», con 8,77:1. Ambiente: 2,47 % de píxeles encendidos y 0 de color de la escena.
- Observación: «sin red con copia» y «el secador no reporta» se ven iguales en el reloj; los dos dicen «Sin conexión ·
  19 ago». Es lo que ya hacía el reloj; distinguirlos queda como mejora posible.

**Verificación final**: `flutter analyze` 0 avisos; batería del teléfono **91/91** (dos veces); reloj
`gradlew :app:testDebugUnitTest :app:assembleDebug` BUILD SUCCESSFUL, 11/11; **los dos árboles idénticos** (incluidos
los goldens `15-privacidad` y `16-reloj`, que estaban distintos desde el 2026-10-08: se copiaron los de la copia ASCII,
que son los que pasan con el código actual); emuladores cerrados.

### Prevista

- Paso 6: capturas a 390 px de ancho (y 360 y 412) en el emulador y goldens; contraste muestreado sobre el render
  del saludo, la campana, la cifra y la pill en los 6 cruces momento × tema; toque ≥ 44 px (48 en el reloj); recorrido
  con TalkBack (la escena es `ExcludeSemantics`); reloj en 192 y 227 dp redondos y en ambiente; tamaño del APK y tiempo
  de dibujo de la escena en el reloj.
- Prueba comparativa: Inicio nuevo junto a `ActiveBatchHero` de la web y dos referentes de Mobbin, sin rótulos, en
  `ref/2026-10-xx-comparativa.png`.

---

## 9. Legal (privacidad)

- «Según la hora» y la escena usan **solo el reloj del dispositivo** (hora convertida a Colombia). No piden ubicación,
  no usan red para esto y no guardan nada fuera del teléfono. La preferencia se guarda en el teléfono
  (`SharedPreferences`, clave `siscan_tema`, valores `claro|oscuro|hora|sistema`) y se borra con «Borrar los datos de este teléfono» (`Preferencias.borrarTodo` quita `siscan_tema`; el tema en memoria vuelve a leerse al abrir la app).
- La política de tratamiento de datos (`docs/legal/politica-datos-app-siscan.md`) debe nombrar la preferencia de tema entre los datos locales; no
  hace falta pedir consentimiento nuevo (no es dato personal ni sensible). Si en el reloj se adopta la opción C (seguir
  el tema del teléfono por la capa de datos), se añade a la política que esa preferencia viaja entre los dos equipos de
  la misma persona.
- Marco: Ley 1581 de 2012 y Decreto 1377 de 2013. Los textos legales siguen siendo borradores técnicos que revisa un
  abogado antes de publicarse.

---

## 10. Siguiente trabajo anotado

- **Idioma es/en/pt** en otra rama, después de esta (C4).
- Golden `04v-pesaje` dependiente de la fecha (ver Verificación).
