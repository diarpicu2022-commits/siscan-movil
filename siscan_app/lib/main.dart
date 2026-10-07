import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'data/overview_controller.dart';
import 'data/repository.dart';
import 'screens/inicio_screen.dart';
import 'screens/placeholder_page.dart';
import 'theme/theme.dart';
import 'theme/tokens.dart';

void main() => runApp(SiscanApp(repository: HttpSiscanRepository()));

/// SISCAN — Secado Inteligente de Café. Paso 4: Inicio con los datos reales del secador.
class SiscanApp extends StatefulWidget {
  const SiscanApp({super.key, required this.repository, this.sol = false, this.home, this.refreshEvery = const Duration(seconds: 30)});
  /// Cada cuánto se actualiza el Inicio; `null` lo desactiva (pruebas).
  final SiscanRepository repository;
  final bool sol;
  final Widget? home;
  final Duration? refreshEvery;

  @override
  State<SiscanApp> createState() => _SiscanAppState();
}

class _SiscanAppState extends State<SiscanApp> {
  late bool _sol = widget.sol;
  late final OverviewController _overview;

  @override
  void initState() {
    super.initState();
    _overview = OverviewController(widget.repository, every: widget.refreshEvery);
    if (widget.home == null) _overview.start();
  }

  @override
  void dispose() {
    _overview.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SISCAN',
        debugShowCheckedModeBanner: false,
        theme: SiscanTheme.of(_sol ? SiscanTokens.sol : SiscanTokens.dia, sol: _sol),
        home: widget.home ??
            ListenableBuilder(
              listenable: _overview,
              builder: (context, _) => AppShell(
                sol: _sol,
                onSol: (v) => setState(() => _sol = v),
                sync: _overview.sync,
                alertCount: _overview.data?.alertCount ?? 0,
                pageBuilder: (tab, goTo) => switch (tab) {
                  AppTab.inicio => InicioScreen(controller: _overview, onSeeAlerts: () => goTo(AppTab.alertas)),
                  _ => PlaceholderPage(tab: tab),
                },
              ),
            ),
      );
}
