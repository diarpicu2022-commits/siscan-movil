import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/siscan_theme.dart';
import '../core/ui/base.dart';
import '../data/api.dart';
import '../data/auth.dart';
import '../data/estado.dart';

/// Tema elegido: claro, oscuro o como el teléfono (pedido del profesor: poder cambiar de modo).
class TemaApp extends ChangeNotifier {
  ThemeMode modo = ThemeMode.system;
  Future<void> cargar() async {
    try {
      final v = (await SharedPreferences.getInstance()).getString('siscan_tema');
      modo = switch (v) { 'claro' => ThemeMode.light, 'oscuro' => ThemeMode.dark, _ => ThemeMode.system };
      notifyListeners();
    } catch (_) {}
  }
  Future<void> cambiar(ThemeMode m) async {
    modo = m;
    notifyListeners();
    try { await (await SharedPreferences.getInstance()).setString('siscan_tema', switch (m) { ThemeMode.light => 'claro', ThemeMode.dark => 'oscuro', _ => 'sistema' }); } catch (_) {}
  }
}

/// Lo que comparten las pantallas: servidor, estado del secador, sesión y tema.
class Siscan extends InheritedWidget {
  const Siscan({super.key, required this.api, required this.estado, required this.auth, required this.tema, required super.child});
  final SiscanApi api;
  final EstadoSecador estado;
  final AuthController auth;
  final TemaApp tema;
  static Siscan of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Siscan>()!;
  @override
  bool updateShouldNotify(Siscan o) => false;

  /// Cabecera de la sesión o `null` (vista de solo lectura).
  String? get cabecera => auth.session?.canControl == true ? auth.session!.header : null;

  /// Escritura con aviso del resultado (Toast del sistema) y recarga del estado.
  Future<bool> hacer(BuildContext context, Future<void> Function(String auth) accion, String ok, {String? detalle}) async {
    final h = cabecera;
    if (h == null) {
      aviso(context, 'Ingresa con tu cuenta para hacer cambios', error: true);
      return false;
    }
    try {
      await accion(h);
      if (context.mounted) aviso(context, ok, detalle: detalle);
      estado.cargar();
      return true;
    } on ApiError catch (e) {
      if (context.mounted) aviso(context, e.mensaje, error: true);
      if (e.sinPermiso) auth.signOut();
      return false;
    }
  }
}

/// Reconstruye cuando cambia el estado del secador.
class ConEstado extends StatelessWidget {
  const ConEstado({super.key, required this.builder});
  final Widget Function(BuildContext, Base?) builder;
  @override
  Widget build(BuildContext context) {
    final e = Siscan.of(context).estado;
    return ListenableBuilder(listenable: e, builder: (ctx, _) => builder(ctx, e.base));
  }
}

/// Carga de pantalla (05-pantallas): «Cargando el estado del secador…» con esqueletos en superficie-fuerte.
class Cargando extends StatelessWidget {
  const Cargando({super.key, this.texto = 'Cargando el estado del secador…'});
  final String texto;
  @override
  Widget build(BuildContext context) => Semantics(container: true, 
        liveRegion: true, label: texto,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(texto, style: TextStyle(fontSize: 14, color: context.c.tintaSuave)),
          const SizedBox(height: 12),
          for (final h in [120.0, 80.0, 160.0]) Container(height: h, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: context.c.superficieFuerte, borderRadius: BorderRadius.circular(18))),
        ]),
      );
}

/// Error de servidor: «No fue posible cargar estos datos» + qué pasó en palabras + Reintentar. `automatico`: el estado
/// del secador se vuelve a pedir solo cada 30 s; los demás pedidos esperan al botón.
class ErrorCarga extends StatelessWidget {
  const ErrorCarga({super.key, this.detalle, required this.onReintentar, this.automatico = false});
  final String? detalle;
  final VoidCallback onReintentar;
  final bool automatico;
  @override
  Widget build(BuildContext context) {
    final codigo = RegExp(r'código (\d+)').firstMatch(detalle ?? '')?.group(1);
    final que = codigo != null ? 'El servidor respondió con un error (código $codigo).'
        : (detalle != null && !detalle!.startsWith('No fue posible cargar')) ? detalle! : 'No hubo respuesta del servidor.';
    return Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const TituloTarjeta(icono: 'aviso', titulo: 'No fue posible cargar estos datos'),
        Text('$que${automatico ? ' Se reintenta solo cada 30 s.' : ''}', style: TextStyle(fontSize: 14, color: context.c.tintaSuave)),
        const SizedBox(height: 12),
        Boton('Reintentar', icono: 'actualizar', onPressed: onReintentar),
      ]));
  }
}

/// Aviso de sin conexión (05-pantallas): «El secador no reporta desde las 07:12» en fuera-suave con Reintentar.
class AvisoSinConexion extends StatelessWidget {
  const AvisoSinConexion({super.key, required this.base, required this.onReintentar});
  final Base base;
  final VoidCallback onReintentar;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final texto = base.guardado ? 'Sin señal: ves la copia guardada (${corta(base.cargadoEn).toLowerCase()}).' : 'El secador no reporta desde ${base.ultimaT != null ? corta(base.ultimaT) : 'su instalación'}. Ves el último dato con su hora.';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(color: c.fueraSuave, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icono('wifiNo', size: 18, color: c.fuera), const SizedBox(width: 10),
        Expanded(child: Text(texto, style: TextStyle(fontSize: 13, color: c.tinta))),
        TextButton(onPressed: onReintentar, style: TextButton.styleFrom(minimumSize: const Size(44, 44)), child: Text('Reintentar', style: TextStyle(fontWeight: FontWeight.w700, color: c.hoja))),
      ]),
    );
  }
}
