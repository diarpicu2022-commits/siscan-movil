// Paso 1 · verificación medida: contraste de los pares de texto del sistema en los dos temas (AA ≥ 4.5, Pleno sol
// texto ≥ 12 y estados ≥ 8 según el README) y captura de la hoja de fundamentos a 390 px con las fuentes reales.
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siscan/main.dart';
import 'package:siscan/data/repository.dart';
import 'package:siscan/screens/foundations_screen.dart';
import 'package:siscan/theme/tokens.dart';

double _lum(Color c) {
  double ch(double v) => v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double contrast(Color a, Color b) {
  final x = _lum(a), y = _lum(b);
  return (max(x, y) + 0.05) / (min(x, y) + 0.05);
}

Future<void> loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final l = FontLoader(family);
    for (final f in files) {
      l.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$f').readAsBytesSync())));
    }
    await l.load();
  }
  await load('Fraunces', ['Fraunces-Variable.ttf', 'Fraunces-Variable-Italic.ttf']);
  await load('AtkinsonNext', ['AtkinsonHyperlegibleNext-400.ttf', 'AtkinsonHyperlegibleNext-500.ttf', 'AtkinsonHyperlegibleNext-700.ttf']);
  await load('AtkinsonMono', ['AtkinsonHyperlegibleMono-400.ttf', 'AtkinsonHyperlegibleMono-500.ttf', 'AtkinsonHyperlegibleMono-600.ttf']);
}

void main() {
  for (final (name, t) in [('Día', SiscanTokens.dia), ('Pleno sol', SiscanTokens.sol)]) {
    test('$name · texto tierra y tierra-suave ≥ 4.5:1 sobre pergamino, papel y arena', () {
      for (final bg in [t.pergamino, t.papel, t.arena]) {
        expect(contrast(t.tierra, bg), greaterThanOrEqualTo(4.5));
        expect(contrast(t.tierraSuave, bg), greaterThanOrEqualTo(4.5));
      }
    });
    test('$name · cada color de estado ≥ 4.5:1 sobre su *-suave, papel y pergamino', () {
      for (final (fg, soft) in [(t.cafeto, t.cafetoSuave), (t.panela, t.panelaSuave), (t.oxido, t.oxidoSuave), (t.bruma, t.brumaSuave), (t.anil, t.anilSuave), (t.arcilla, t.arcillaSuave)]) {
        for (final bg in [soft, t.papel, t.pergamino]) {
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: '$fg sobre $bg');
        }
      }
    });
    test('$name · texto sobre monte y sobre arcilla ≥ 4.5:1', () {
      expect(contrast(t.sobreMonte, t.monte), greaterThanOrEqualTo(4.5));
      expect(contrast(t.sobreArcilla, t.arcilla), greaterThanOrEqualTo(4.5));
    });
  }
  test('Pleno sol · texto ≥ 12:1 y estados ≥ 8:1 sobre pergamino', () {
    const t = SiscanTokens.sol;
    expect(contrast(t.tierra, t.pergamino), greaterThanOrEqualTo(12));
    for (final c in [t.cafeto, t.panela, t.oxido, t.bruma, t.anil]) {
      expect(contrast(c, t.pergamino), greaterThanOrEqualTo(8), reason: '$c');
    }
  });

  testWidgets('Captura de fundamentos a 390 px (Día y Pleno sol)', (tester) async {
    await loadFonts();
    tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    for (final sol in [false, true]) {
      await tester.pumpWidget(SiscanApp(sol: sol, home: const FoundationsScreen(), repository: DemoSiscanRepository(), refreshEvery: null));
      await tester.pumpAndSettle();
      await expectLater(find.byType(SiscanApp), matchesGoldenFile('goldens/fundamentos-${sol ? 'sol' : 'dia'}-390.png'));
    }
    expect(tester.takeException(), isNull);
  });
}
