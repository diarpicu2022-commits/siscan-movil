import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// Tema de SISCAN: Material solo como soporte; todo color sale de [SiscanTokens] (Día o Pleno sol).
abstract final class SiscanTheme {
  static ThemeData of(SiscanTokens t, {required bool sol}) {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: t.arcilla, onPrimary: t.sobreArcilla,
      secondary: t.monte, onSecondary: t.sobreMonte,
      error: t.oxido, onError: t.sobreOxido,
      surface: t.papel, onSurface: t.tierra,
      surfaceContainerLowest: t.pergamino, surfaceContainerHighest: t.arena,
      outline: t.lineaFuerte, outlineVariant: t.linea,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: t.pergamino,
      fontFamily: 'AtkinsonNext',
      extensions: [t],
      textTheme: TextTheme(
        displayLarge: SiscanType.display.copyWith(color: t.tierra),
        headlineMedium: SiscanType.titulo.copyWith(color: t.tierra),
        titleLarge: SiscanType.seccion.copyWith(color: t.tierra),
        bodyLarge: SiscanType.cuerpo.copyWith(color: t.tierra),
        bodyMedium: SiscanType.cuerpo.copyWith(color: t.tierra),
        labelSmall: SiscanType.etiqueta.copyWith(color: t.tierraSuave),
        bodySmall: SiscanType.nota.copyWith(color: t.tierraSuave),
      ),
      focusColor: t.foco,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}

extension SiscanContext on BuildContext {
  SiscanTokens get sc => Theme.of(this).extension<SiscanTokens>()!;
}
