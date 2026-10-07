import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'data/auth.dart';
import 'data/overview_cache.dart';
import 'data/overview_controller.dart';
import 'data/repository.dart';
import 'screens/controles_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/login_screen.dart';
import 'screens/prediccion_alertas.dart';
import 'theme/theme.dart';
import 'theme/tokens.dart';
import 'theme/typography.dart';

void main() => runApp(SiscanApp(repository: HttpSiscanRepository(), auth: AuthController(), cache: const PrefsOverviewCache(), restoreSession: true));

/// SISCAN — Secado Inteligente de Café. Paso 6: estados (sin conexión, dato viejo, vacío, sesión vencida).
class SiscanApp extends StatefulWidget {
  const SiscanApp({super.key, required this.repository, this.auth, this.cache, this.sol = false, this.home,
      this.refreshEvery = const Duration(seconds: 30), this.restoreSession = false});
  final SiscanRepository repository;
  final AuthController? auth;
  final OverviewCache? cache;
  final bool sol, restoreSession;
  final Widget? home;
  /// Cada cuánto se actualiza el Inicio; `null` lo desactiva (pruebas).
  final Duration? refreshEvery;

  @override
  State<SiscanApp> createState() => _SiscanAppState();
}

class _SiscanAppState extends State<SiscanApp> {
  late bool _sol = widget.sol;
  late final OverviewController _overview;
  late final AuthController _auth = widget.auth ?? AuthController(store: MemoryCredentialStore());

  @override
  void initState() {
    super.initState();
    _overview = OverviewController(widget.repository, every: widget.refreshEvery, cache: widget.cache);
    if (widget.home == null) _overview.start();
    if (widget.restoreSession) _auth.restore();
  }

  @override
  void dispose() {
    _overview.dispose();
    super.dispose();
  }

  Widget _account(BuildContext context) {
    final t = context.sc;
    final s = _auth.session;
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s == null ? 'Sin sesión' : s.displayName, style: SiscanType.cuerpoFuerte.copyWith(color: t.tierra)),
        Text(s == null ? 'Ingresa para controlar el equipo.' : (s.canControl ? 'Gestor del Secador' : 'Sin permiso para controlar el equipo'),
            style: SiscanType.nota.copyWith(color: t.tierraSuave)),
      ])),
      TextButton(
        style: TextButton.styleFrom(foregroundColor: t.arcilla, minimumSize: const Size(48, 48)),
        onPressed: () {
          Navigator.of(context).pop();
          if (s == null) {
            Navigator.of(context).push(MaterialPageRoute<bool>(builder: (_) => LoginScreen(auth: _auth)));
          } else {
            _auth.signOut();
          }
        },
        child: Text(s == null ? 'Ingresar' : 'Cerrar sesión', style: SiscanType.cuerpoFuerte.copyWith(fontSize: 15)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SISCAN',
        debugShowCheckedModeBanner: false,
        theme: SiscanTheme.of(_sol ? SiscanTokens.sol : SiscanTokens.dia, sol: _sol),
        home: widget.home ??
            ListenableBuilder(
              listenable: Listenable.merge([_overview, _auth]),
              builder: (context, _) => AppShell(
                sol: _sol,
                onSol: (v) => setState(() => _sol = v),
                sync: _overview.sync,
                alertCount: _overview.data?.alertCount ?? 0,
                account: Builder(builder: _account),
                pageBuilder: (tab, goTo) => switch (tab) {
                  AppTab.inicio => InicioScreen(controller: _overview, onSeeAlerts: () => goTo(AppTab.alertas)),
                  AppTab.controles => ControlesScreen(overview: _overview, auth: _auth),
                  AppTab.prediccion => PrediccionScreen(overview: _overview),
                  AppTab.alertas => AlertasScreen(overview: _overview),
                },
              ),
            ),
      );
}
