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
