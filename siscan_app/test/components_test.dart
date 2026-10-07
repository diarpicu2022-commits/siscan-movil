// Paso 2 · componente clave: comportamiento medido y capturas a 390 px.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siscan/main.dart';
import 'package:siscan/theme/theme.dart';
import 'package:siscan/theme/tokens.dart';
import 'package:siscan/widgets/moisture_meter.dart';
import 'package:siscan/widgets/sensor_reading.dart';
import 'package:siscan/widgets/siscan_icon.dart';
import 'package:siscan/widgets/status_mark.dart';

import 'foundations_test.dart' show loadFonts;

Widget host(Widget child, {bool reduce = false}) => MaterialApp(
      theme: SiscanTheme.of(SiscanTokens.dia, sol: false),
      home: MediaQuery(data: MediaQueryData(size: const Size(390, 900), disableAnimations: reduce), child: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child))),
    );

void main() {
  test('Fases del lecho: húmedo, secando, cerca, alcanzado', () {
    expect(phaseOf(40, 11), DryingPhase.humedo);
    expect(phaseOf(14.5, 11), DryingPhase.secando);
    expect(phaseOf(12.5, 11), DryingPhase.cerca);
    expect(phaseOf(10.8, 11), DryingPhase.alcanzado);
  });

  testWidgets('La cifra baja desde la humedad inicial hasta la actual en 1.6 s', (tester) async {
    await tester.pumpWidget(host(const MoistureMeter(current: 14.5, initial: 52)));
    expect(find.textContaining('52.0', findRichText: true), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.textContaining('52.0', findRichText: true), findsNothing);
    expect(find.textContaining('14.5', findRichText: true), findsNothing);
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.textContaining('14.5', findRichText: true), findsOneWidget);
  });

  testWidgets('La cifra dominante va en una sola línea a 390 px (76 px de alto)', (tester) async {
    await loadFonts();
    await tester.pumpWidget(host(const MoistureMeter(current: 14.5, initial: 52), reduce: true));
    expect(tester.getSize(find.byKey(const Key('moisture-value'))).height, lessThanOrEqualTo(80));
  });

  testWidgets('Con animaciones desactivadas salta al valor final', (tester) async {
    await tester.pumpWidget(host(const MoistureMeter(current: 14.5, initial: 52), reduce: true));
    expect(find.textContaining('14.5', findRichText: true), findsOneWidget);
  });

  testWidgets('Lector de pantalla: el lecho se anuncia con valor, objetivo y fase', (tester) async {
    final h = tester.ensureSemantics();
    await tester.pumpWidget(host(const MoistureMeter(current: 14.5, initial: 52), reduce: true));
    expect(find.bySemanticsLabel(RegExp(r'Humedad del café: 14\.5 por ciento, objetivo 11 por ciento, Secando')), findsOneWidget);
    h.dispose();
  });

  testWidgets('Sensor sin conexión: sin cifra inventada, «No disponible» y sello de sin conexión', (tester) async {
    await tester.pumpWidget(host(const SensorReading(name: 'Flujo de aire', glyph: SiscanGlyph.aire, value: null, unit: 'm/s', status: SiscanStatus.sinConexion)));
    expect(find.text('No disponible'), findsOneWidget);
    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.textContaining('Rango esperado'), findsNothing);
  });

  testWidgets('Sensor desactualizado: cifra en tierra-suave y «Última lectura» (nunca como dato actual)', (tester) async {
    await tester.pumpWidget(host(const SensorReading(name: 'Temperatura exterior', glyph: SiscanGlyph.solar, value: 17.8, unit: '°C', status: SiscanStatus.desactualizado)));
    expect(find.text('Última lectura'), findsOneWidget);
    Color? color;
    for (final r in tester.widgetList<RichText>(find.byType(RichText))) {
      r.text.visitChildren((span) {
        if (span is TextSpan && span.text == '17.8') color = span.style?.color;
        return true;
      });
    }
    expect(color, SiscanTokens.dia.tierraSuave);
  });

  testWidgets('Capturas del componente a 390 px (Día y Pleno sol) sin desbordes', (tester) async {
    await loadFonts();
    tester.view.physicalSize = const Size(390 * 3, 2700 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    for (final sol in [false, true]) {
      await tester.pumpWidget(SiscanApp(sol: sol));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(SiscanApp), matchesGoldenFile('goldens/componentes-${sol ? 'sol' : 'dia'}-390.png'));
    }
  });
}
