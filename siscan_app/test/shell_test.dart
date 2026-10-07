// Paso 3 · esqueleto: navegación inferior, banda superior, temas y accesibilidad (medido).
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siscan/main.dart';
import 'package:siscan/theme/tokens.dart';
import 'package:siscan/widgets/connection_status.dart';
import 'package:siscan/widgets/landscape_band.dart';

import 'foundations_test.dart' show loadFonts;

void main() {
  setUp(() {});

  Future<void> phone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('El contenido ocupa la pantalla y la barra inferior solo su alto (≤ 100 px)', (tester) async {
    await phone(tester);
    await tester.pumpWidget(const SiscanApp());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.getRect(find.byType(SingleChildScrollView)).height, greaterThan(600));
    expect(tester.getRect(find.byKey(const Key('nav-inicio'))).height, lessThan(100));
  });

  testWidgets('La hoja del contenido sube 28 px sobre la banda y se pinta encima (el título no queda tapado)', (tester) async {
    await phone(tester);
    await tester.pumpWidget(const SiscanApp());
    await tester.pump(const Duration(seconds: 2));
    final band = tester.getRect(find.byType(LandscapeBand));
    final title = tester.getRect(find.text('¿Cómo está el secado?'));
    expect(title.top, greaterThan(band.bottom - 28 + 8)); // el título empieza dentro de la hoja, bajo su relleno
    // La hoja se pinta encima: un toque en su esquina superior le llega a ella, no a la banda.
    final hit = tester.hitTestOnBinding(Offset(40, band.bottom - 20));
    expect(hit.path.any((e) => e.target is RenderParagraph || e.target.toString().contains('RenderDecoratedBox')), isTrue);
  });

  testWidgets('Cuatro destinos en orden, cada uno ≥ 48 px de alto y ancho', (tester) async {
    await phone(tester);
    await tester.pumpWidget(const SiscanApp());
    await tester.pump(const Duration(seconds: 2));
    final labels = ['Inicio', 'Controles', 'Predicción', 'Alertas'];
    double lastX = -1;
    for (final (i, name) in ['inicio', 'controles', 'prediccion', 'alertas'].indexed) {
      final r = tester.getRect(find.byKey(Key('nav-$name')));
      expect(r.height, greaterThanOrEqualTo(48));
      expect(r.width, greaterThanOrEqualTo(48));
      expect(r.left, greaterThan(lastX));
      lastX = r.left;
      expect(find.text(labels[i]), findsOneWidget);
    }
  });

  testWidgets('Tocar un destino lo activa (arcilla) y cambia el contenido', (tester) async {
    await phone(tester);
    await tester.pumpWidget(const SiscanApp());
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('¿Cómo está el secado?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-controles')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('¿Está funcionando el equipo?'), findsOneWidget);
    final label = tester.widget<Text>(find.text('Controles'));
    expect(label.style!.color, SiscanTokens.dia.arcilla);
    expect(tester.widget<Text>(find.text('Inicio')).style!.color, SiscanTokens.dia.tierraSuave);
  });

  testWidgets('Alertas anuncia cuántas hay sin revisar al lector de pantalla', (tester) async {
    final h = tester.ensureSemantics();
    await phone(tester);
    await tester.pumpWidget(const SiscanApp());
    await tester.pump(const Duration(seconds: 2));
    expect(find.bySemanticsLabel('Alertas, 2 sin revisar'), findsOneWidget);
    h.dispose();
  });

  testWidgets('Ajustes cambia a Pleno sol (fondo más claro) y vuelve a Día', (tester) async {
    await phone(tester);
    await tester.pumpWidget(const SiscanApp());
    await tester.pump(const Duration(seconds: 2));
    Color bg() => tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor!;
    expect(bg(), SiscanTokens.dia.pergamino);
    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byType(Switch));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(bg(), SiscanTokens.sol.pergamino);
  });

  testWidgets('Modo offline: la píldora lo dice entera en la barra superior, sin desbordes', (tester) async {
    await loadFonts();
    await phone(tester);
    for (final st in SyncStatus.values) {
      await tester.pumpWidget(SiscanApp(sync: st));
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull, reason: '$st');
    }
    await tester.pumpWidget(const SiscanApp(sync: SyncStatus.offline));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Modo offline'), findsOneWidget);
    final txt = tester.renderObject<RenderParagraph>(find.text('Modo offline'));
    expect(txt.didExceedMaxLines, isFalse);
  });

  testWidgets('Capturas del esqueleto a 390 × 844 (Día, Pleno sol y offline)', (tester) async {
    await loadFonts();
    await phone(tester);
    for (final (name, app) in [('dia', const SiscanApp(key: ValueKey('dia'))), ('sol', const SiscanApp(key: ValueKey('sol'), sol: true)), ('offline', const SiscanApp(key: ValueKey('off'), sync: SyncStatus.offline))]) {
      await tester.pumpWidget(app);
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(SiscanApp), matchesGoldenFile('goldens/esqueleto-$name-390.png'));
    }
  });
}
