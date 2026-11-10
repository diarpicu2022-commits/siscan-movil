import 'package:flutter/foundation.dart' show LicenseEntryWithLineBreaks, LicenseRegistry, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/contexto.dart';
import 'app/notificaciones.dart';
import 'app/preferencias.dart';
import 'app/shell.dart';
import 'core/momento.dart';
import 'core/theme/siscan_theme.dart';
import 'data/api.dart';
import 'data/auth.dart';
import 'data/estado.dart';

/// SISCAN — Secado Inteligente de Café. Sistema de diseño v2 (siscan-design-system).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // E9: el aviso de Lucide (íconos) entra al registro de licencias de Flutter, junto al resto del software de terceros.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const ['Lucide (íconos)'], await rootBundle.loadString('assets/sistema/iconos/LICENCIA-lucide.txt'));
  });
  final api = SiscanApi(), tema = TemaApp(reloj: _relojDelDia()), pref = Preferencias();
  await Future.wait([tema.cargar(), pref.cargar()]);
  try { await Notificaciones.iniciar(); } catch (_) {/* sin notificaciones la app sigue */}
  runApp(SiscanApp(api: api, estado: EstadoSecador(api)..iniciar(), auth: AuthController(), tema: tema, pref: pref));
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
  const SiscanApp({super.key, required this.api, required this.estado, required this.auth, required this.tema, required this.pref, this.inicio});
  final SiscanApi api;
  final EstadoSecador estado;
  final AuthController auth;
  final TemaApp tema;
  final Preferencias pref;
  /// Pantalla inicial para pruebas; por defecto, el arranque (carga → ingreso → pestañas).
  final Widget? inicio;

  @override
  Widget build(BuildContext context) => Siscan(
        api: api, estado: estado, auth: auth, tema: tema,
        child: pref.envolver(ListenableBuilder(
          listenable: tema,
          builder: (context, _) => MaterialApp(
            title: 'SISCAN',
            debugShowCheckedModeBanner: false,
            theme: siscanTheme(Brightness.light),
            darkTheme: siscanTheme(Brightness.dark),
            themeMode: tema.modo,
            // Cambio de tema sin interpolar colores: solo se anima transform y opacity (contrato del 2026-10-12).
            themeAnimationDuration: Duration.zero,
            locale: const Locale('es', 'CO'),
            supportedLocales: const [Locale('es', 'CO'), Locale('es')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: inicio ?? const Arranque(),
          ),
        )),
      );
}
