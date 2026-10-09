import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Sesión para SISCAN en el reloj: el reloj no guarda credenciales y le pide las órdenes y los pesajes al teléfono
/// (PuenteReloj.kt). Aquí se entrega la cabecera de la sesión, que el lado nativo cifra con el Android Keystore.
/// Solo con «Recordarme»: sin él, la sesión vive mientras la app está abierta y el reloj no puede usarla.
abstract final class SesionReloj {
  static const _canal = MethodChannel('siscan/reloj');
  static const api = String.fromEnvironment('SISCAN_API', defaultValue: 'https://cisna.narino.gov.co/wp-json/secador/v1');
  static bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> guardar(String cabecera) async {
    if (!_android) return;
    try { await _canal.invokeMethod('guardar', {'cabecera': cabecera, 'api': api}); } catch (_) {/* sin puente: el reloj solo lee */}
  }

  static Future<void> borrar() async {
    if (!_android) return;
    try { await _canal.invokeMethod('borrar'); } catch (_) {}
  }
}
