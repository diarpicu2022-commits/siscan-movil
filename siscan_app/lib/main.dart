import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/contexto.dart';
import 'app/notificaciones.dart';
import 'app/preferencias.dart';
import 'app/shell.dart';
import 'core/theme/siscan_theme.dart';
import 'data/api.dart';
import 'data/auth.dart';
import 'data/estado.dart';

/// SISCAN — Secado Inteligente de Café. Sistema de diseño v2 (siscan-design-system).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = SiscanApi(), tema = TemaApp(), pref = Preferencias();
  await Future.wait([tema.cargar(), pref.cargar()]);
  try { await Notificaciones.iniciar(); } catch (_) {/* sin notificaciones la app sigue */}
  runApp(SiscanApp(api: api, estado: EstadoSecador(api)..iniciar(), auth: AuthController(), tema: tema, pref: pref));
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
            locale: const Locale('es', 'CO'),
            supportedLocales: const [Locale('es', 'CO'), Locale('es')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: inicio ?? const Arranque(),
          ),
        )),
      );
}
