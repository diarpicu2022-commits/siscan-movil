/// Momento del día: la única regla de hora de SISCAN (03-ilustración). Decide la variante de la escena (`day`,
/// `dusk`, `night`) y el tema «Según la hora» (claro de día y al atardecer, oscuro de noche). Se calcula en hora de
/// Colombia con el reloj del teléfono: no usa ubicación ni red.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'theme/siscan_theme.dart' show co;

enum Momento {
  dia('day'),
  atardecer('dusk'),
  noche('night');

  const Momento(this.variante);

  /// Nombre de la variante en los SVG del sistema (`assets/sistema/paisaje/<variante>-…`).
  final String variante;

  /// Tema «Según la hora»: claro de 6:00 a 19:00 (día y atardecer), oscuro de noche.
  bool get claro => this != Momento.noche;

  /// Límites en hora de Colombia: día 6–17, atardecer 17–19, noche el resto.
  static const limites = [6, 17, 19];

  static Momento de(DateTime t) {
    final h = co(t).hour;
    return h >= 6 && h < 17 ? dia : h >= 17 && h < 19 ? atardecer : noche;
  }

  /// Instante (UTC) del siguiente cambio de momento, estrictamente después de `t`.
  static DateTime proximoCambio(DateTime t) {
    final c = co(t); // pared de Colombia codificada como UTC
    for (var d = 0; d < 2; d++) {
      for (final h in limites) {
        final pared = DateTime.utc(c.year, c.month, c.day + d, h);
        if (pared.isAfter(c)) return pared.add(const Duration(hours: 5));
      }
    }
    throw StateError('sin límite en 48 h'); // inalcanzable: siempre hay un 6:00 al día siguiente
  }
}

/// Fuente única del momento en vivo. Solo programa el temporizador mientras alguien la escucha (el tema en «Según la
/// hora», la escena de Inicio), y al volver a primer plano revisa la hora por si el sistema retrasó el temporizador.
class RelojDelDia extends ChangeNotifier with WidgetsBindingObserver {
  RelojDelDia({DateTime Function()? ahora}) : _ahora = ahora ?? DateTime.now {
    _momento = Momento.de(_ahora());
  }

  final DateTime Function() _ahora;
  late Momento _momento;
  Timer? _timer;
  bool _observando = false;

  Momento get momento => _momento;

  /// Hay un temporizador esperando el siguiente límite (solo mientras alguien escucha).
  bool get programado => _timer != null;

  /// Vuelve a leer la hora; avisa solo si cambió el momento. Reprograma el siguiente límite.
  void revisar() {
    final m = Momento.de(_ahora());
    if (m != _momento) {
      _momento = m;
      notifyListeners();
    }
    _programar();
  }

  void _programar() {
    _timer?.cancel();
    _timer = null;
    if (!hasListeners) return;
    final ahora = _ahora();
    // Un segundo de margen: el temporizador puede llegar unos milisegundos antes del límite.
    final espera = Momento.proximoCambio(ahora).difference(ahora) + const Duration(seconds: 1);
    _timer = Timer(espera, revisar);
  }

  @override
  void addListener(VoidCallback listener) {
    final primero = !hasListeners;
    super.addListener(listener);
    if (primero) {
      if (!_observando) {
        WidgetsBinding.instance.addObserver(this);
        _observando = true;
      }
      revisar();
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _timer?.cancel();
      _timer = null;
      if (_observando) {
        WidgetsBinding.instance.removeObserver(this);
        _observando = false;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) revisar();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_observando) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
