import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'screens/placeholder_page.dart';
import 'theme/theme.dart';
import 'theme/tokens.dart';
import 'widgets/connection_status.dart';

void main() => runApp(const SiscanApp());

/// SISCAN — Secado Inteligente de Café. Paso 3: esqueleto (navegación y temas).
class SiscanApp extends StatefulWidget {
  const SiscanApp({super.key, this.sol = false, this.home, this.sync = SyncStatus.conectado});
  final bool sol;
  final Widget? home;
  final SyncStatus sync;

  @override
  State<SiscanApp> createState() => _SiscanAppState();
}

class _SiscanAppState extends State<SiscanApp> {
  late bool _sol = widget.sol;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SISCAN',
        debugShowCheckedModeBanner: false,
        theme: SiscanTheme.of(_sol ? SiscanTokens.sol : SiscanTokens.dia, sol: _sol),
        home: widget.home ??
            AppShell(
              sol: _sol,
              onSol: (v) => setState(() => _sol = v),
              sync: widget.sync,
              alertCount: 2,
              pages: const {
                AppTab.inicio: PlaceholderPage(tab: AppTab.inicio),
                AppTab.controles: PlaceholderPage(tab: AppTab.controles),
                AppTab.prediccion: PlaceholderPage(tab: AppTab.prediccion),
                AppTab.alertas: PlaceholderPage(tab: AppTab.alertas),
              },
            ),
      );
}
