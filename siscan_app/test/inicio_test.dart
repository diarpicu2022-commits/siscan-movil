// Paso 4 · Inicio: lectura del backend real (respuestas guardadas del 2026-10-06) y la pantalla con y sin lote activo.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siscan/data/models.dart';
import 'package:siscan/data/repository.dart';
import 'package:siscan/main.dart';

import 'foundations_test.dart' show loadFonts;
import 'shell_test.dart' show phone, settle;

http.Client realBackend() => MockClient((req) async {
      final p = req.url.path.split('secador/v1/').last;
      final f = switch (p) {
        'secadores' => 'secadores',
        'readings' => 'readings',
        'api/actuators' => 'actuators',
        'api/device/status/1' => 'status',
        'drying-batches' => 'batches',
        _ => null,
      };
      if (f == null) return http.Response('{}', 404);
      return http.Response.bytes(File('test/fixtures/$f.json').readAsBytesSync(), 200, headers: {'content-type': 'application/json; charset=utf-8'});
    });

void main() {
  test('Lee el backend real: secador, lecturas más recientes por tipo, actuadores, alertas y lotes', () async {
    final o = await HttpSiscanRepository(client: realBackend()).overview();
    expect(o.dryer.code, 'SC-001');
    expect(o.dryer.place, contains('Chachagui'));
    expect(o.readings.containsKey('TEMPERATURE_TOPE'), isTrue);
    expect(o.readings['TEMPERATURE_TOPE']!.label, 'Temperatura interior');
    expect(o.actuators.map((a) => a.name), containsAll(['Ventiladores', 'Calefactor 1']));
    expect(o.actuators.where((a) => a.kind == ActuatorKind.heater).length, 3);
    expect(o.alertCount, greaterThan(0));
    expect(o.alerts.first.level, AlertLevel.critical);
    expect(o.activeBatch, isNull); // el secador no está secando
    expect(o.lastBatch!.name, 'Lote juco');
    expect(o.lastBatch!.currentMoisture, closeTo(10.6, .05));
  });

  test('Lecturas de agosto: se marcan desactualizadas (nunca como actuales)', () async {
    final o = await HttpSiscanRepository(client: realBackend()).overview();
    expect(o.isStale(o.readings['TEMPERATURE_TOPE']!), isTrue);
  });

  test('Sin red: un mensaje humano, nunca técnico', () async {
    final repo = HttpSiscanRepository(client: MockClient((_) async => throw const SocketException('x')));
    expect(repo.overview(), throwsA(isA<ApiException>().having((e) => e.message, 'mensaje', contains('Verifica la conexión'))));
  });

  testWidgets('Inicio con los datos reales: sin lote activo, último lote, lecturas desactualizadas, equipo y alertas', (tester) async {
    await loadFonts();
    await phone(tester);
    tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
    await tester.runAsync(() async {
      await tester.pumpWidget(SiscanApp(repository: HttpSiscanRepository(client: realBackend()), refreshEvery: null));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Sin lote activo'), findsOneWidget);
    expect(find.textContaining('LOTE JUCO'), findsWidgets);
    expect(find.text('Última lectura'), findsWidgets);
    expect(find.text('Ventiladores'), findsOneWidget);
    expect(find.text('La predicción aparece cuando hay un lote secando.'), findsOneWidget);
    expect(find.textContaining('Tormenta eléctrica'), findsWidgets);
    expect(find.text('Secador sin reportar'), findsOneWidget); // nunca «Conectado» con datos de agosto
    expect(find.text('Conectado'), findsNothing);
    await expectLater(find.byType(SiscanApp), matchesGoldenFile('goldens/inicio-real-390.png'));
  });

  testWidgets('Inicio con un lote secando (ejemplo): lote → humedad → temperatura → tiempo → predicción → equipo → alertas', (tester) async {
    await loadFonts();
    await phone(tester);
    tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
    await tester.pumpWidget(SiscanApp(repository: DemoSiscanRepository(), refreshEvery: null));
    await settle(tester);
    expect(tester.takeException(), isNull);
    double y(Finder f) => tester.getTopLeft(f.first).dy;
    final order = [find.text('LOTE B'), find.text('HUMEDAD DEL CAFÉ'), find.text('TEMPERATURA'), find.text('TIEMPO'), find.text('Predicción de IA'), find.text('Equipo'), find.text('¿Hay algo que deba revisar?')];
    for (var i = 1; i < order.length; i++) {
      if (i == 3) {
        // Temperatura y Tiempo comparten fila (referencia InicioMovil): el orden va de izquierda a derecha.
        expect(y(order[3]), y(order[2]));
        expect(tester.getTopLeft(order[3]).dx, greaterThan(tester.getTopLeft(order[2]).dx));
        continue;
      }
      expect(y(order[i]), greaterThan(y(order[i - 1])), reason: 'orden en la posición $i');
    }
    expect(find.textContaining('87'), findsWidgets);
    await expectLater(find.byType(SiscanApp), matchesGoldenFile('goldens/inicio-lote-390.png'));
  });

  testWidgets('«Ver las alertas» lleva a la pestaña Alertas', (tester) async {
    await phone(tester);
    tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
    await tester.pumpWidget(SiscanApp(repository: DemoSiscanRepository(), refreshEvery: null));
    await settle(tester);
    await tester.tap(find.text('Ver las 2 alertas'));
    await settle(tester);
    expect(find.text('Paso 5: avisos del secador, del más grave al más leve.'), findsOneWidget);
  });
}
