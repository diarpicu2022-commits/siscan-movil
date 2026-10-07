// Paso 3 · esqueleto: navegación inferior, banda superior, temas y accesibilidad (medido).
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siscan/data/repository.dart';
import 'package:siscan/main.dart';
import 'package:siscan/theme/tokens.dart';
import 'package:siscan/widgets/landscape_band.dart';

import 'foundations_test.dart' show loadFonts;

Future<void> phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

SiscanApp demo({Key? key, bool sol = false, bool fail = false}) =>
    SiscanApp(key: key, sol: sol, repository: DemoSiscanRepository(fail: fail), refreshEvery: null);

void main() {
  testWidgets('El contenido ocupa la pantalla y la barra inferior solo su alto (≤ 100 px)', (tester) async {
    await phone(tester);
    await tester.pumpWidget(demo());
    await settle(tester);
    expect(tester.getRect(find.byType(SingleChildScrollView)).height, greaterThan(600));
    expect(tester.getRect(find.byKey(const Key('nav-inicio'))).height, lessThan(100));
  });

  testWidgets('La hoja del lote sube 28 px sobre la banda y se pinta encima', (tester) async {
    await phone(tester);
    await tester.pumpWidget(demo());
    await settle(tester);
    final band = tester.getRect(find.byType(LandscapeBand));
    final sheet = tester.getRect(find.byKey(const Key('batch-sheet')));
    expect(sheet.top, closeTo(band.bottom - 28, 1));
    final hit = tester.hitTestOnBinding(Offset(sheet.left + 40, band.bottom - 12));
    expect(hit.path.any((e) => e.target is RenderParagraph || e.target.toString().contains('RenderDecoratedBox')), isTrue);
  });

  testWidgets('Cuatro destinos en orden, cada uno ≥ 48 px', (tester) async {
    await phone(tester);
    await tester.pumpWidget(demo());
    await settle(tester);
    double lastX = -1;
    for (final (i, name) in ['inicio', 'controles', 'prediccion', 'alertas'].indexed) {
      final r = tester.getRect(find.byKey(Key('nav-$name')));
      expect(r.height, greaterThanOrEqualTo(48));
      expect(r.width, greaterThanOrEqualTo(48));
      expect(r.left, greaterThan(lastX));
      lastX = r.left;
      expect(find.descendant(of: find.byKey(Key('nav-$name')), matching: find.text(['Inicio', 'Controles', 'Predicción', 'Alertas'][i])), findsOneWidget);
    }
  });

  testWidgets('Tocar un destino lo activa (arcilla) y cambia el contenido', (tester) async {
    await phone(tester);
    await tester.pumpWidget(demo());
    await settle(tester);
    await tester.tap(find.byKey(const Key('nav-controles')));
    await settle(tester);
    expect(find.text('¿Está funcionando el equipo?'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Controles')).style!.color, SiscanTokens.dia.arcilla);
    expect(tester.widget<Text>(find.text('Inicio')).style!.color, SiscanTokens.dia.tierraSuave);
  });

  testWidgets('Alertas anuncia cuántas hay sin revisar (dato del backend)', (tester) async {
    final h = tester.ensureSemantics();
    await phone(tester);
    await tester.pumpWidget(demo());
    await settle(tester);
    expect(find.bySemanticsLabel('Alertas, 2 sin revisar'), findsOneWidget);
    h.dispose();
  });

  testWidgets('Ajustes cambia a Pleno sol (fondo más claro)', (tester) async {
    await phone(tester);
    await tester.pumpWidget(demo());
    await settle(tester);
    Color bg() => tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor!;
    expect(bg(), SiscanTokens.dia.pergamino);
    await tester.tap(find.byTooltip('Ajustes'));
    await settle(tester);
    await tester.tap(find.byType(Switch));
    await settle(tester);
    expect(bg(), SiscanTokens.sol.pergamino);
  });

  testWidgets('Sin conexión al cargar: la píldora y la hoja lo dicen, sin desbordes', (tester) async {
    await loadFonts();
    await phone(tester);
    await tester.pumpWidget(demo(fail: true));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.text('Intentar nuevamente'), findsOneWidget);
    expect(tester.renderObject<RenderParagraph>(find.text('Sin conexión')).didExceedMaxLines, isFalse);
  });

  testWidgets('Capturas del esqueleto a 390 × 844 (Día, Pleno sol y sin conexión)', (tester) async {
    await loadFonts();
    await phone(tester);
    for (final (name, app) in [('dia', demo(key: const ValueKey('dia'))), ('sol', demo(key: const ValueKey('sol'), sol: true)), ('sin-conexion', demo(key: const ValueKey('off'), fail: true))]) {
      await tester.pumpWidget(app);
      await settle(tester);
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(SiscanApp), matchesGoldenFile('goldens/esqueleto-$name-390.png'));
    }
  });
}
