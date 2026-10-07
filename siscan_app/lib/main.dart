import 'package:flutter/material.dart';

import 'screens/foundations_screen.dart';
import 'theme/theme.dart';
import 'theme/tokens.dart';

void main() => runApp(const SiscanApp());

/// SISCAN — Secado Inteligente de Café. Paso 1: tema y fundamentos.
class SiscanApp extends StatelessWidget {
  const SiscanApp({super.key, this.sol = false});
  final bool sol;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SISCAN',
        debugShowCheckedModeBanner: false,
        theme: SiscanTheme.of(sol ? SiscanTokens.sol : SiscanTokens.dia, sol: sol),
        home: const FoundationsScreen(),
      );
}
