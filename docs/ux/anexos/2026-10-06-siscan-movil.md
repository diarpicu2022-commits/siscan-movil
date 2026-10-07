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
