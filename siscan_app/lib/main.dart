import 'package:flutter/foundation.dart' show LicenseEntryWithLineBreaks, LicenseRegistry, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/contexto.dart';
import 'app/notificaciones.dart';
import 'app/preferencias.dart';
import 'app/shell.dart';
import 'core/formato.dart';
import 'core/momento.dart';
import 'core/theme/siscan_theme.dart';
import 'data/api.dart';
import 'data/auth.dart';
import 'data/estado.dart';
import 'l10n/app_localizations.dart';

/// SISCAN — Secado Inteligente de Café. Sistema de diseño v2 (siscan-design-system).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // E9: el aviso de Lucide (íconos) entra al registro de licencias de Flutter, junto al resto del software de terceros.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const ['Lucide (íconos)'], await rootBundle.loadString('assets/sistema/iconos/LICENCIA-lucide.txt'));
  });
  final api = SiscanApi(), tema = TemaApp(reloj: _relojDelDia()), pref = Preferencias(), idioma = IdiomaApp();
  await Future.wait([tema.cargar(), pref.cargar(), idioma.cargar(), prepararFormato()]);
  try { await Notificaciones.iniciar(); } catch (_) {/* sin notificaciones la app sigue */}
  runApp(SiscanApp(api: api, estado: EstadoSecador(api)..iniciar(), auth: AuthController(), tema: tema, pref: pref, idioma: idioma));
}

/// Solo para pruebas, nunca en la versión publicada: `--dart-define=SISCAN_HORA=18:58:30` arranca el reloj del día a esa
/// hora de Colombia y lo deja correr, para ver en un equipo el cruce de las 19:00 (tema y escena) sin tocar la hora del
/// sistema. Sin la definición, o en release, es el reloj real.
RelojDelDia _relojDelDia() {
  const hora = String.fromEnvironment('SISCAN_HORA');
  if (kReleaseMode || hora.isEmpty) return RelojDelDia();
  final p = hora.split(':').map(int.parse).toList();
  final ahora = DateTime.now(), c = co(ahora);
  // Pared de Colombia (UTC−5) → instante.
  final objetivo = DateTime.utc(c.year, c.month, c.day, p[0], p[1], p.length > 2 ? p[2] : 0).add(const Duration(hours: 5));
  final desfase = objetivo.difference(ahora.toUtc());
  return RelojDelDia(ahora: () => DateTime.now().add(desfase));
}

class SiscanApp extends StatelessWidget {
  SiscanApp({super.key, required this.api, required this.estado, required this.auth, required this.tema, required this.pref, IdiomaApp? idioma, this.inicio})
      : idioma = idioma ?? IdiomaApp();
  final SiscanApi api;
  final EstadoSecador estado;
  final AuthController auth;
  final TemaApp tema;
  final Preferencias pref;
  final IdiomaApp idioma;
  /// Pantalla inicial para pruebas; por defecto, el arranque (carga → ingreso → pestañas).
  final Widget? inicio;

  @override
  Widget build(BuildContext context) => Siscan(
        api: api, estado: estado, auth: auth, tema: tema, idioma: idioma,
        child: pref.envolver(ListenableBuilder(
          listenable: Listenable.merge([tema, idioma]),
          builder: (context, _) => MaterialApp(
            title: 'SISCAN',
            debugShowCheckedModeBanner: false,
            theme: siscanTheme(Brightness.light),
            darkTheme: siscanTheme(Brightness.dark),
            themeMode: tema.modo,
            // Cambio de tema sin interpolar colores: solo se anima transform y opacity (contrato del 2026-10-12).
            themeAnimationDuration: Duration.zero,
            // Idiomas (anexo 2026-10-15): el elegido en Más › Idioma o, con «Como el teléfono», el del sistema. Un idioma
            // del teléfono que SISCAN no tiene cae en español, el idioma base.
            locale: idioma.locale,
            supportedLocales: const [Locale('es', 'CO'), Locale('es'), Locale('en'), Locale('pt', 'BR'), Locale('pt')],
            localeResolutionCallback: (l, _) => PreferenciaIdioma.deCodigo(l?.languageCode ?? 'es').locale,
            localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
            // Las funciones de formato no tienen contexto: aquí se les dice el idioma ya resuelto.
            builder: (context, hijo) {
              idiomaFormato = Localizations.localeOf(context).languageCode;
              return hijo!;
            },
            home: inicio ?? const Arranque(),
          ),
        )),
      );
}
