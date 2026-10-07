// Paso 5 · Controles, inicio de sesión, Predicción y Alertas (medido).
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siscan/data/auth.dart';
import 'package:siscan/data/repository.dart';
import 'package:siscan/main.dart';
import 'package:siscan/theme/tokens.dart';
import 'package:siscan/widgets/actuator_control.dart';

import 'foundations_test.dart' show loadFonts;
import 'shell_test.dart' show phone, settle;

/// WordPress simulado: `/users/me` responde según la contraseña de aplicación.
http.Client wordpress({bool gestor = true}) => MockClient((req) async {
      final auth = req.headers['Authorization'] ?? '';
      if (auth != 'Basic ${base64Encode(utf8.encode('operador:abcd1234efgh5678ijkl9012'))}') return http.Response('{"code":"invalid"}', 401);
      return http.Response(jsonEncode({'name': 'Operador CISNA', 'capabilities': {'manage_secador': gestor, 'read': true}}), 200);
    });

Future<(DemoSiscanRepository, AuthController)> openControls(WidgetTester tester, {bool signedIn = false, bool failCommands = false}) async {
  await loadFonts();
  await phone(tester);
  tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
  final repo = DemoSiscanRepository(failCommands: failCommands);
  final auth = AuthController(client: wordpress(), store: MemoryCredentialStore());
  if (signedIn) await tester.runAsync(() => auth.signIn('operador', 'abcd 1234 efgh 5678 ijkl 9012'));
  await tester.pumpWidget(SiscanApp(repository: repo, auth: auth, refreshEvery: null));
  await settle(tester);
  await tester.tap(find.byKey(const Key('nav-controles')));
  await settle(tester);
  return (repo, auth);
}

Finder inCard(int id, Finder f) => find.descendant(of: find.byKey(Key('actuator-$id')), matching: f);

void main() {
  test('Contraseña de aplicación: entra con permiso de Gestor, quita los espacios y recuerda solo si se pide', () async {
    final a = AuthController(client: wordpress(), store: MemoryCredentialStore());
    expect(await a.signIn('operador', 'mala'), 'El usuario o la contraseña de aplicación no son correctos.');
    expect(await a.signIn('operador', 'abcd 1234 efgh 5678 ijkl 9012', remember: true), isNull);
    expect(a.session!.canControl, isTrue);
    expect((a.store as MemoryCredentialStore).saved, ('operador', 'abcd1234efgh5678ijkl9012'));
    await a.signOut();
    expect((a.store as MemoryCredentialStore).saved, isNull);
  });

  test('Sin el permiso «Gestor del Secador» lo dice', () async {
    final a = AuthController(client: wordpress(gestor: false), store: MemoryCredentialStore());
    expect(await a.signIn('operador', 'abcd1234efgh5678ijkl9012'), contains('Gestor del Secador'));
  });

  testWidgets('En automático la palanca está bloqueada: tocarla no manda nada', (tester) async {
    final (repo, _) = await openControls(tester, signedIn: true);
    expect(find.text('Controlado por el protocolo'), findsWidgets);
    await tester.tap(inCard(1, find.byKey(const Key('lever'))));
    await settle(tester);
    expect(repo.commands, isEmpty);
  });

  testWidgets('Pasar a manual sin sesión abre «Ingresar»; con la cuenta correcta queda en manual', (tester) async {
    await openControls(tester);
    await tester.tap(inCard(1, find.byKey(const Key('mode-manual'))));
    await settle(tester);
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('login-user')), 'operador');
    await tester.enterText(find.byKey(const Key('login-pass')), 'abcd 1234 efgh 5678 ijkl 9012');
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('login-submit')));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await settle(tester);
    expect(find.text('En modo manual'), findsOneWidget);
  });

  testWidgets('Manual: el ventilador se apaga con un toque, muestra «Apagando…» y manda la orden', (tester) async {
    final (repo, _) = await openControls(tester, signedIn: true);
    await tester.tap(inCard(1, find.byKey(const Key('mode-manual'))));
    await settle(tester);
    await tester.tap(inCard(1, find.byKey(const Key('lever'))));
    await tester.pump(const Duration(milliseconds: 100));
    expect(inCard(1, find.text('Apagando…')), findsOneWidget);
    await settle(tester);
    expect(repo.commands, [(1, false)]);
  });

  testWidgets('Resistencia: un toque no la enciende; mantener presionado 1.5 s sí (y avisa del ventilador)', (tester) async {
    final (repo, _) = await openControls(tester, signedIn: true);
    await tester.tap(inCard(3, find.byKey(const Key('mode-manual'))));
    await settle(tester);
    expect(inCard(3, find.textContaining('Verifica que el ventilador esté encendido')), findsOneWidget);
    expect(inCard(3, find.text('Mantén presionado para encender')), findsOneWidget);
    final lever = inCard(3, find.byKey(const Key('lever')));
    await tester.tap(lever);
    await settle(tester);
    expect(repo.commands, isEmpty);
    // Soltar a los 0.8 s no basta.
    var g = await tester.startGesture(tester.getCenter(lever));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await g.up();
    await settle(tester);
    expect(repo.commands, isEmpty);
    // Sostener 1.5 s sí (cuadro a cuadro, como en el teléfono).
    g = await tester.startGesture(tester.getCenter(lever));
    for (var i = 0; i < 17; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await g.up();
    await settle(tester);
    expect(repo.commands, [(3, true)]);
  });

  testWidgets('Si el secador no responde, la tarjeta dice «Error» con la instrucción', (tester) async {
    await openControls(tester, signedIn: true, failCommands: true);
    await tester.tap(inCard(1, find.byKey(const Key('mode-manual'))));
    await settle(tester);
    await tester.tap(inCard(1, find.byKey(const Key('lever'))));
    await settle(tester);
    expect(inCard(1, find.text('Error')), findsOneWidget);
    expect(inCard(1, find.textContaining('Verifica la conexión del dispositivo')), findsOneWidget);
  });

  testWidgets('Manual se ve desde lejos: contorno panela de 2 px', (tester) async {
    await openControls(tester, signedIn: true);
    await tester.tap(inCard(1, find.byKey(const Key('mode-manual'))));
    await settle(tester);
    final box = tester.widget<AnimatedContainer>(inCard(1, find.byType(AnimatedContainer)).first);
    final border = (box.decoration! as BoxDecoration).border! as Border;
    expect(border.top.color, SiscanTokens.dia.panela);
    expect(border.top.width, 2);
    expect(find.byType(ActuatorControl), findsNWidgets(3));
  });

  testWidgets('Capturas: Controles (resistencia en manual), Predicción y Alertas a 390 px', (tester) async {
    await openControls(tester, signedIn: true);
    await tester.tap(inCard(3, find.byKey(const Key('mode-manual'))));
    await settle(tester);
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(SiscanApp), matchesGoldenFile('goldens/controles-390.png'));
    for (final tab in ['prediccion', 'alertas']) {
      await tester.tap(find.byKey(Key('nav-$tab')));
      await settle(tester);
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(SiscanApp), matchesGoldenFile('goldens/$tab-390.png'));
    }
  });

  testWidgets('Captura de Ingresar a 390 × 844', (tester) async {
    await openControls(tester);
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    await tester.tap(inCard(1, find.byKey(const Key('mode-manual'))));
    await settle(tester);
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(SiscanApp), matchesGoldenFile('goldens/ingresar-390.png'));
  });
}
