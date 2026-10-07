import 'package:flutter/material.dart';

/// Las tres voces del sistema, cada una con un trabajo (tokens.json → type.groups):
/// Fraunces (editorial, SOFT 100), Atkinson Hyperlegible Next (interfaz) y Mono (instrumento: toda cifra medible).
abstract final class SiscanType {
  static const _editorial = 'Fraunces';
  static const _interfaz = 'AtkinsonNext';
  static const _instrumento = 'AtkinsonMono';
  static const _soft = [FontVariation('SOFT', 100), FontVariation('opsz', 72)];
  static const _tabular = [FontFeature.tabularFigures()];

  // Editorial
  static const display = TextStyle(fontFamily: _editorial, fontSize: 56, height: 60 / 56, fontWeight: FontWeight.w600,
      letterSpacing: -0.56, fontVariations: [FontVariation('SOFT', 100), FontVariation('wght', 560), FontVariation('opsz', 144)]);
  static const titulo = TextStyle(fontFamily: _editorial, fontSize: 34, height: 40 / 34, fontWeight: FontWeight.w600,
      fontVariations: [FontVariation('SOFT', 100), FontVariation('wght', 560), FontVariation('opsz', 72)]);
  static const seccion = TextStyle(fontFamily: _editorial, fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600,
      fontVariations: [FontVariation('SOFT', 100), FontVariation('wght', 600), FontVariation('opsz', 36)]);
  static const cita = TextStyle(fontFamily: _editorial, fontSize: 18, height: 26 / 18, fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w400, fontVariations: _soft);

  // Interfaz
  static const cuerpo = TextStyle(fontFamily: _interfaz, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400);
  static const cuerpoFuerte = TextStyle(fontFamily: _interfaz, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w700);
  /// Rótulo de instrumento: se escribe en MAYÚSCULAS espaciadas (usar [rotulo]).
  static const etiqueta = TextStyle(fontFamily: _interfaz, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, letterSpacing: 0.96);
  static const nota = TextStyle(fontFamily: _interfaz, fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w400);

  // Instrumento (cifras tabulares siempre)
  static const lecturaXl = TextStyle(fontFamily: _instrumento, fontSize: 64, height: 1, fontWeight: FontWeight.w500, letterSpacing: -1.92, fontFeatures: _tabular);
  /// Variante «campo» del sistema para móvil: lectura dominante de 76 px.
  static const lecturaCampo = TextStyle(fontFamily: _instrumento, fontSize: 76, height: 1, fontWeight: FontWeight.w500, letterSpacing: -2.28, fontFeatures: _tabular);
  static const lectura = TextStyle(fontFamily: _instrumento, fontSize: 36, height: 40 / 36, fontWeight: FontWeight.w500, letterSpacing: -0.72, fontFeatures: _tabular);
  static const lecturaS = TextStyle(fontFamily: _instrumento, fontSize: 20, height: 24 / 20, fontWeight: FontWeight.w500, fontFeatures: _tabular);
  static const tabla = TextStyle(fontFamily: _instrumento, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, fontFeatures: _tabular);
}

/// Texto de rótulo de instrumento (MAYÚSCULAS espaciadas, exclusivo de rótulos y del código de lote).
String rotulo(String s) => s.toUpperCase();
