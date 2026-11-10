import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'siscan_tokens.dart';

/// Tema de la app con el sistema de diseño SISCAN v2 (claro y oscuro). Los widgets propios leen [SiscanColors]
/// con `context.c`; el ThemeData solo alinea lo que Material dibuja por su cuenta (selección, cursor, diálogos).
ThemeData siscanTheme(Brightness b) {
  final c = b == Brightness.dark ? SiscanColors.oscuro : SiscanColors.claro;
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    fontFamily: SiscanType.ui,
    scaffoldBackgroundColor: c.fondo,
    colorScheme: ColorScheme.fromSeed(seedColor: c.hoja, brightness: b, surface: c.superficie, primary: c.hoja, error: c.alerta),
    extensions: [c],
    textSelectionTheme: TextSelectionThemeData(cursorColor: c.esmeralda, selectionColor: c.esmeralda.withValues(alpha: .25), selectionHandleColor: c.esmeralda),
    dialogTheme: DialogThemeData(backgroundColor: c.superficie, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SiscanRadius.lg))),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()}),
    appBarTheme: AppBarTheme(systemOverlayStyle: b == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark),
  );
}

extension SiscanContexto on BuildContext {
  SiscanColors get c => Theme.of(this).extension<SiscanColors>()!;
  bool get oscuro => Theme.of(this).brightness == Brightness.dark;
  /// Movimiento reducido del sistema: todo queda quieto y legible.
  bool get sinMovimiento => MediaQuery.of(this).disableAnimations;
  List<BoxShadow> get sombraTarjeta => SiscanShadow.tarjeta(Theme.of(this).brightness);
  List<BoxShadow> get sombraFlotante => SiscanShadow.flotante(Theme.of(this).brightness);
  List<BoxShadow> get sombraActivo => SiscanShadow.activo(Theme.of(this).brightness);
}

/// `color-mix(in srgb, c pct%, base)` del sistema.
Color mezcla(Color c, double pct, Color base) => Color.lerp(base, c, pct)!;

/// Colores fijos por magnitud (02-datos: el técnico aprende a leer el color).
Color tono(SiscanColors c, String t) => switch (t) {
      'temperatura' || 'tope' => c.datoTemperatura,
      'humedad' => c.datoHumedad,
      'exterior' => c.datoExterior,
      'grano' => c.datoGrano,
      'solar' => c.datoSolar,
      'tiempo' => c.hoja,
      'potencia' || 'corriente' => c.pausa,
      'lima' => c.broteVivo,
      'pred' => c.prediccion,
      _ => c.tinta,
    };

/// Estados del secador (01-secado): color y fondo suave.
enum Estado { running, paused, alert, offline }

(Color, Color) colorEstado(SiscanColors c, Estado e) => switch (e) {
      Estado.running => (c.operando, c.operandoSuave),
      Estado.paused => (c.pausa, c.pausaSuave),
      Estado.alert => (c.alerta, c.alertaSuave),
      Estado.offline => (c.fuera, c.fueraSuave),
    };

/// Cifras como en campo: coma decimal y punto de miles («42,6», «1.500»). `null` → «—».
/// Reloj de pared de Colombia para mostrar: el secador está en Nariño, así que la hora se lee igual en cualquier
/// teléfono (un emulador en UTC o alguien de viaje ve la misma hora que el panel web). Los cálculos usan el instante.
DateTime co(DateTime d) => d.toUtc().subtract(const Duration(hours: 5));

String cifra(num? v, [int d = 1]) {
  if (v == null || (v is double && v.isNaN)) return '—';
  final s = v.abs().toStringAsFixed(d);
  final p = s.split('.');
  final ent = p[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  return (v < 0 ? '−' : '') + ent + (p.length > 1 ? ',${p[1]}' : '');
}

String dinero(num? v) => v == null ? r'$ —' : '\$ ${cifra(v, 0)}';
