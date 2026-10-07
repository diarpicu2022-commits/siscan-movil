import 'package:flutter/material.dart';

import 'screens/components_screen.dart';
import 'theme/theme.dart';
import 'theme/tokens.dart';

void main() => runApp(const SiscanApp());

/// SISCAN — Secado Inteligente de Café. Paso 2: componente clave.
class SiscanApp extends StatelessWidget {
  const SiscanApp({super.key, this.sol = false, this.home});
  final bool sol;
  final Widget? home;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SISCAN',
        debugShowCheckedModeBanner: false,
        theme: SiscanTheme.of(sol ? SiscanTokens.sol : SiscanTokens.dia, sol: sol),
        home: home ?? const ComponentsScreen(),
      );
}
