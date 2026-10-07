// Paso 6 · estados: sin conexión con lo guardado, dato viejo, vacío y sesión vencida (medido).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siscan/data/auth.dart';
import 'package:siscan/data/models.dart';
import 'package:siscan/data/overview_cache.dart';
import 'package:siscan/data/overview_controller.dart';
import 'package:siscan/data/repository.dart';
import 'package:siscan/main.dart';

import 'controles_test.dart' show inCard, wordpress;
import 'foundations_test.dart' show loadFonts;
import 'shell_test.dart' show phone, settle;

/// Repositorio vacío: secador sin actuadores, sin alertas, sin lecturas y sin lotes.
class EmptyRepo implements SiscanRepository {
  @override
  Future<Overview> overview() async => Overview(
        dryer: const Dryer(id: 1, code: 'SC-001', name: 'SISCAN — Secador 01', place: 'Chachagüí', drying: false),
        readings: const {}, actuators: const [], alerts: const [], alertCount: 0, fetchedAt: DateTime.now());
  @override
  Future<void> setActuator(int id, bool on, {required String auth}) async {}
}

void main() {
  test('Lo guardado se recupera sin red y TODO queda desactualizado (nada «Medido»)', () async {
    final cache = MemoryOverviewCache();
    final repo = DemoSiscanRepository();
    final c = OverviewController(repo, every: null, cache: cache);
    await c.load();
    expect(c.data!.offline, isFalse);
    expect(c.data!.isStale(c.data!.readings['TEMPERATURE_TOPE']!), isFalse);
    repo.fail = true;
    await c.load();
    expect(c.data!.offline, isTrue);
    expect(c.data!.readings.values.every(c.data!.isStale), isTrue);
    expect(c.data!.savedAt, isNotNull);
    expect(c.data!.activeBatch!.name, 'Lote B');
  });

  test('Sin red y sin nada guardado: error con mensaje humano; con lo guardado: «Modo offline»', () async {
    final c = OverviewController(DemoSiscanRepository(fail: true), every: null, cache: MemoryOverviewCache());
    await c.load();
    expect(c.data, isNull);
    expect(c.error, contains('Verifica la conexión'));
  });

  testWidgets('Inicio sin red: aviso «Modo offline», píldora, «Última lectura» y sin predicción', (tester) async {
    await loadFonts();
    await phone(tester);
    tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
    final cache = MemoryOverviewCache();
    final repo = DemoSiscanRepository();
    await tester.runAsync(() async => cache.save(await repo.overview()));
    repo.fail = true;
    await tester.pumpWidget(SiscanApp(repository: repo, cache: cache, refreshEvery: null));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Modo offline'), findsNWidgets(2)); // píldora de la barra + aviso
    expect(find.textContaining('Mostramos lo guardado'), findsOneWidget);
    expect(find.text('Medido'), findsNothing);
    expect(find.text('Última lectura'), findsWidgets);
    expect(find.text('Sin conexión no mostramos la predicción: puede haber cambiado.'), findsOneWidget);
    expect(find.text('Último estado conocido, sin conexión.'), findsOneWidget);
    expect(find.text('Desactualizado'), findsNothing); // sin red el sello es «Sin conexión»
    await expectLater(find.byType(SiscanApp), matchesGoldenFile('goldens/inicio-offline-390.png'));
  });

  testWidgets('Controles sin red: último estado conocido, sin poder pasar a manual ni mandar órdenes', (tester) async {
    await loadFonts();
    await phone(tester);
    tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
    final cache = MemoryOverviewCache();
    final repo = DemoSiscanRepository();
    await tester.runAsync(() async => cache.save(await repo.overview()));
    repo.fail = true;
    final auth = AuthController(client: wordpress(), store: MemoryCredentialStore());
    await tester.runAsync(() => auth.signIn('operador', 'abcd1234efgh5678ijkl9012'));
    await tester.pumpWidget(SiscanApp(repository: repo, cache: cache, auth: auth, refreshEvery: null));
    await settle(tester);
    await tester.tap(find.byKey(const Key('nav-controles')));
    await settle(tester);
    expect(find.textContaining('Sin conexión no se envían órdenes'), findsOneWidget);
    expect(inCard(1, find.text('Encendido')), findsOneWidget); // se ve el último estado, no «Bloqueado»
    await tester.tap(inCard(1, find.byKey(const Key('mode-manual'))));
    await settle(tester);
    expect(find.text('En modo manual'), findsNothing);
    expect(repo.commands, isEmpty);
  });

  testWidgets('Sesión vencida al mandar una orden: se cierra, vuelve a automático y lo explica', (tester) async {
    await loadFonts();
    await phone(tester);
    tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
    final repo = DemoSiscanRepository(expiredSession: true);
    final auth = AuthController(client: wordpress(), store: MemoryCredentialStore());
    await tester.runAsync(() => auth.signIn('operador', 'abcd1234efgh5678ijkl9012'));
    await tester.pumpWidget(SiscanApp(repository: repo, auth: auth, refreshEvery: null));
    await settle(tester);
    await tester.tap(find.byKey(const Key('nav-controles')));
    await settle(tester);
    await tester.tap(inCard(1, find.byKey(const Key('mode-manual'))));
    await settle(tester);
    await tester.tap(inCard(1, find.byKey(const Key('lever'))));
    await settle(tester);
    expect(auth.session, isNull);
    expect(find.text('Tu sesión venció o ya no tiene permiso. Ingresa de nuevo.'), findsOneWidget);
    expect(find.text('En modo manual'), findsNothing);
  });

  testWidgets('Vacío: sin actuadores, sin alertas y sin lecturas — cada pantalla lo dice', (tester) async {
    await loadFonts();
    await phone(tester);
    tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
    await tester.pumpWidget(SiscanApp(repository: EmptyRepo(), refreshEvery: null));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Sin lote activo'), findsOneWidget);
    expect(find.text('Sin lecturas del secador'), findsOneWidget);
    expect(find.text('El secador no ha registrado actuadores.'), findsOneWidget);
    expect(find.text('Sin alertas pendientes'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-alertas')));
    await settle(tester);
    expect(find.text('Sin alertas pendientes'), findsOneWidget);
  });
}
