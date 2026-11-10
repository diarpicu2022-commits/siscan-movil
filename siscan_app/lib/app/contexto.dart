import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/momento.dart';
import '../core/theme/siscan_theme.dart';
import '../core/ui/base.dart';
import '../data/api.dart';
import '../data/auth.dart';
import '../data/estado.dart';
import '../l10n/app_localizations.dart';

/// Lo que elige la persona en Más › Tema. `hora`: claro de 6:00 a 19:00 (hora de Colombia), oscuro de noche; la misma
/// regla que la escena (Momento), así el tema y el paisaje nunca se contradicen.
enum PreferenciaTema {
  claro('claro'),
  oscuro('oscuro'),
  hora('hora'),
  sistema('sistema');

  const PreferenciaTema(this.clave);
  /// Valor guardado en SharedPreferences `siscan_tema` (los tres primeros ya existían).
  final String clave;
  static PreferenciaTema desde(String? v) => values.firstWhere((p) => p.clave == v, orElse: () => sistema);
}

/// Tema elegido: claro, oscuro, según la hora o como el teléfono (pedido del profesor: poder cambiar de modo).
class TemaApp extends ChangeNotifier {
  TemaApp({RelojDelDia? reloj}) : reloj = reloj ?? RelojDelDia();

  /// Fuente única del momento del día (la comparte la escena de Inicio).
  final RelojDelDia reloj;
  PreferenciaTema _preferencia = PreferenciaTema.sistema;
  bool _escuchando = false;

  PreferenciaTema get preferencia => _preferencia;
  set preferencia(PreferenciaTema p) {
    _preferencia = p;
    // Solo «Según la hora» escucha al reloj: así no queda un temporizador vivo en los demás modos.
    if (p == PreferenciaTema.hora && !_escuchando) {
      reloj.addListener(notifyListeners);
      _escuchando = true;
    } else if (p != PreferenciaTema.hora && _escuchando) {
      reloj.removeListener(notifyListeners);
      _escuchando = false;
    }
    notifyListeners();
  }

  /// Lo que recibe MaterialApp.
  ThemeMode get modo => switch (_preferencia) {
        PreferenciaTema.claro => ThemeMode.light,
        PreferenciaTema.oscuro => ThemeMode.dark,
        PreferenciaTema.hora => reloj.momento.claro ? ThemeMode.light : ThemeMode.dark,
        PreferenciaTema.sistema => ThemeMode.system,
      };

  Future<void> cargar() async {
    try {
      preferencia = PreferenciaTema.desde((await SharedPreferences.getInstance()).getString('siscan_tema'));
    } catch (_) {}
  }

  Future<void> cambiar(PreferenciaTema p) async {
    preferencia = p;
    try { await (await SharedPreferences.getInstance()).setString('siscan_tema', p.clave); } catch (_) {}
  }

  @override
  void dispose() {
    if (_escuchando) reloj.removeListener(notifyListeners);
    super.dispose();
  }
}

/// Idioma elegido en Más › Idioma (anexo de idiomas, I1–I2). Los nombres van en su propio idioma; el saludo ayuda a
/// reconocerlo aunque la app esté en otro.
enum PreferenciaIdioma {
  es('es', 'Español', '¡Hola!', Locale('es', 'CO')),
  en('en', 'English', 'Hello!', Locale('en')),
  pt('pt', 'Português', 'Olá!', Locale('pt', 'BR')),
  sistema('sistema', '', '', null);

  const PreferenciaIdioma(this.clave, this.nombre, this.saludo, this.locale);
  /// Valor guardado en SharedPreferences `siscan_idioma`.
  final String clave;
  /// Endónimo: el idioma escrito en sí mismo (no se traduce).
  final String nombre, saludo;
  final Locale? locale;
  static PreferenciaIdioma desde(String? v) => values.firstWhere((p) => p.clave == v, orElse: () => sistema);
  /// Idioma soportado más cercano a un código (`fr` u otros que no estén → español, el idioma base de SISCAN).
  static PreferenciaIdioma deCodigo(String codigo) => switch (codigo) { 'en' => en, 'pt' => pt, _ => es };
}

/// Idioma de la app: `siscan_idioma` en el teléfono y, en Android 13+, el idioma por app del sistema (Ajustes › Idiomas
/// de apps), sincronizados por el canal `siscan/idioma` (LocaleManager). «Como el teléfono» es la lista vacía.
class IdiomaApp extends ChangeNotifier {
  IdiomaApp({MethodChannel? canal}) : _canal = canal ?? const MethodChannel('siscan/idioma');
  final MethodChannel _canal;
  PreferenciaIdioma _preferencia = PreferenciaIdioma.sistema;
  PreferenciaIdioma get preferencia => _preferencia;

  /// Lo que recibe MaterialApp: `null` sigue al teléfono.
  Locale? get locale => _preferencia.locale;

  Future<void> cargar() async {
    String? guardada;
    try { guardada = (await SharedPreferences.getInstance()).getString('siscan_idioma'); } catch (_) {}
    var p = PreferenciaIdioma.desde(guardada);
    // Si la persona cambió el idioma de SISCAN en Ajustes de Android con la app cerrada, gana el del sistema.
    // `null`: Android 12 o anterior (no hay idioma por app) o sin canal; `''`: el sistema dice «como el teléfono».
    try {
      final delSistema = await _canal.invokeMethod<String>('leer');
      if (delSistema != null) {
        p = delSistema.isEmpty ? PreferenciaIdioma.sistema : PreferenciaIdioma.deCodigo(delSistema.split('-').first);
      }
    } catch (_) {/* sin canal (pruebas o plataforma sin LocaleManager): queda la preferencia propia */}
    _preferencia = p;
    notifyListeners();
  }

  /// Idioma del teléfono (no el de la app): con un idioma por app puesto en Android 13+, Flutter ve el de la app.
  Future<PreferenciaIdioma> delTelefono() async {
    try {
      final e = await _canal.invokeMethod<String>('sistema');
      if (e != null && e.isNotEmpty) return PreferenciaIdioma.deCodigo(e.split(',').first.split('-').first);
    } catch (_) {}
    return PreferenciaIdioma.deCodigo(WidgetsBinding.instance.platformDispatcher.locale.languageCode);
  }

  Future<void> cambiar(PreferenciaIdioma p) async {
    _preferencia = p;
    notifyListeners();
    try { await (await SharedPreferences.getInstance()).setString('siscan_idioma', p.clave); } catch (_) {}
    await _fijarEnSistema(p);
  }

  /// «Borrar los datos de este teléfono»: quita la preferencia y vuelve a seguir al teléfono.
  Future<void> olvidar() async {
    _preferencia = PreferenciaIdioma.sistema;
    notifyListeners();
    try { await (await SharedPreferences.getInstance()).remove('siscan_idioma'); } catch (_) {}
    await _fijarEnSistema(PreferenciaIdioma.sistema);
  }

  Future<void> _fijarEnSistema(PreferenciaIdioma p) async {
    try { await _canal.invokeMethod<void>('fijar', {'etiqueta': p.locale?.toLanguageTag() ?? ''}); } catch (_) {}
  }
}

/// Lo que comparten las pantallas: servidor, estado del secador, sesión, tema e idioma.
class Siscan extends InheritedWidget {
  const Siscan({super.key, required this.api, required this.estado, required this.auth, required this.tema, required this.idioma, required super.child});
  final SiscanApi api;
  final EstadoSecador estado;
  final AuthController auth;
  final TemaApp tema;
  final IdiomaApp idioma;
  static Siscan of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Siscan>()!;
  @override
  bool updateShouldNotify(Siscan o) => false;

  /// Cabecera de la sesión o `null` (vista de solo lectura).
  String? get cabecera => auth.session?.canControl == true ? auth.session!.header : null;

  /// Escritura con aviso del resultado (Toast del sistema) y recarga del estado.
  Future<bool> hacer(BuildContext context, Future<void> Function(String auth) accion, String ok, {String? detalle}) async {
    final h = cabecera;
    if (h == null) {
      aviso(context, AppLocalizations.of(context).ingresaParaCambios, error: true);
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
  const Cargando({super.key, this.texto});
  final String? texto;
  @override
  Widget build(BuildContext context) => Semantics(container: true, 
        liveRegion: true, label: texto ?? AppLocalizations.of(context).cargandoSecador,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(texto ?? AppLocalizations.of(context).cargandoSecador, style: TextStyle(fontSize: 14, color: context.c.tintaSuave)),
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
    final codigo = RegExp(r'(?:código|code) (\d+)').firstMatch(detalle ?? '')?.group(1);
    final t = AppLocalizations.of(context);
    final que = codigo != null ? t.errorServidorCodigo(codigo)
        : (detalle != null && !detalle!.startsWith('No fue posible cargar')) ? detalle! : t.errorSinRespuesta;
    return Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TituloTarjeta(icono: 'aviso', titulo: t.errorCargaTitulo),
        Text('$que${automatico ? t.errorReintentaSolo : ''}', style: TextStyle(fontSize: 14, color: context.c.tintaSuave)),
        const SizedBox(height: 12),
        Boton(t.reintentar, icono: 'actualizar', onPressed: onReintentar),
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
    final c = context.c, t = AppLocalizations.of(context);
    final texto = base.guardado ? t.avisoCopiaGuardada(corta(base.cargadoEn).toLowerCase()) : t.avisoNoReportaDesde(base.ultimaT != null ? corta(base.ultimaT) : t.avisoSuInstalacion);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(color: c.fueraSuave, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icono('wifiNo', size: 18, color: c.fuera), const SizedBox(width: 10),
        Expanded(child: Text(texto, style: TextStyle(fontSize: 13, color: c.tinta))),
        TextButton(onPressed: onReintentar, style: TextButton.styleFrom(minimumSize: const Size(44, 44)), child: Text(t.reintentar, style: TextStyle(fontWeight: FontWeight.w700, color: c.hoja))),
      ]),
    );
  }
}
