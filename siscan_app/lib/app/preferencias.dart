import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/ui/base.dart';
import 'notificaciones.dart';

/// Preferencias del teléfono: notificaciones y huella. Solo en este teléfono.
class Preferencias extends ChangeNotifier {
  bool notificaciones = false, huella = false;
  static final _auth = LocalAuthentication();

  static Preferencias of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_PrefScope>()!.notifier!;
  Widget envolver(Widget child) => _PrefScope(notifier: this, child: child);

  Future<void> cargar() async {
    try {
      final p = await SharedPreferences.getInstance();
      notificaciones = p.getBool('siscan_notif') ?? false;
      huella = p.getBool('siscan_huella') ?? false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _guardar(String k, bool v) async { try { await (await SharedPreferences.getInstance()).setBool(k, v); } catch (_) {} }

  /// Pide el permiso del sistema antes de activar (se explica antes de pedirlo: sección Notificaciones de la política).
  Future<void> cambiarNotificaciones(BuildContext context, bool v) async {
    if (v) {
      final ok = await Notificaciones.pedirPermiso();
      if (!ok) { if (context.mounted) aviso(context, 'Android no dio permiso para notificaciones. Actívalo en los ajustes del teléfono.', error: true); return; }
      await Notificaciones.programar();
    } else {
      await Notificaciones.cancelar();
    }
    notificaciones = v;
    await _guardar('siscan_notif', v);
    notifyListeners();
  }

  /// Activa el ingreso con huella solo después de verificarla una vez con el sensor del teléfono.
  Future<void> cambiarHuella(BuildContext context, bool v) async {
    if (v) {
      final puede = await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
      if (!puede) { if (context.mounted) aviso(context, 'Este teléfono no tiene huella configurada.', error: true); return; }
      if (!await verificarHuella('Confirma tu huella para activar el ingreso rápido')) return;
    }
    huella = v;
    await _guardar('siscan_huella', v);
    notifyListeners();
  }

  static Future<bool> verificarHuella(String motivo) async {
    try {
      return await _auth.authenticate(localizedReason: motivo, biometricOnly: true);
    } catch (_) {
      return false;
    }
  }

  Future<void> borrarTodo(BuildContext context) async {
    await Notificaciones.cancelar();
    notificaciones = false;
    huella = false;
    try { final p = await SharedPreferences.getInstance(); await p.remove('siscan_notif'); await p.remove('siscan_huella'); await p.remove('siscan_tema'); await p.remove('siscan_vistos'); } catch (_) {}
    notifyListeners();
  }
}

class _PrefScope extends InheritedNotifier<Preferencias> {
  const _PrefScope({required super.notifier, required super.child});
}
