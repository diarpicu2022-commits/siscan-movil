// Regla única del momento del día y tema «Según la hora» (anexo 2026-10-12-invernadero-y-tema-por-hora, paso 1).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siscan/app/contexto.dart';
import 'package:siscan/core/momento.dart';
import 'package:siscan/core/ui/dominio.dart';

/// Hora de pared de Colombia (UTC−5, sin horario de verano) → instante.
DateTime col(int h, [int m = 0, int s = 0, int dia = 12]) => DateTime.utc(2026, 10, dia, h, m, s).add(const Duration(hours: 5));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Momento.de: límites en hora de Colombia', () {
    final casos = <(DateTime, Momento, String)>[
      (col(5, 59, 59), Momento.noche, '5:59:59'),
      (col(6), Momento.dia, '6:00'),
      (col(16, 59, 59), Momento.dia, '16:59:59'),
      (col(17), Momento.atardecer, '17:00'),
      (col(18, 59, 59), Momento.atardecer, '18:59:59'),
      (col(19), Momento.noche, '19:00'),
      (col(0), Momento.noche, '0:00'),
      (col(23, 59), Momento.noche, '23:59'),
    ];
    for (final (t, m, n) in casos) {
      test('$n → ${m.name}', () => expect(Momento.de(t), m));
    }
    test('claro solo de 6:00 a 19:00', () {
      expect(Momento.de(col(5, 59)).claro, isFalse);
      expect(Momento.de(col(6)).claro, isTrue);
      expect(Momento.de(col(18, 59)).claro, isTrue);
      expect(Momento.de(col(19)).claro, isFalse);
    });
    test('no depende de la zona del teléfono: el mismo instante en hora local da lo mismo', () {
      expect(Momento.de(col(19).toLocal()), Momento.noche);
      expect(Momento.de(col(6).toLocal()), Momento.dia);
    });
    test('Paisaje.momento delega en la misma regla', () {
      expect(Paisaje.momento(col(5, 59)), 'night');
      expect(Paisaje.momento(col(6)), 'day');
      expect(Paisaje.momento(col(17)), 'dusk');
      expect(Paisaje.momento(col(19)), 'night');
    });
  });

  group('Momento.proximoCambio', () {
    test('de noche antes del amanecer → 6:00 del mismo día', () => expect(Momento.proximoCambio(col(5, 59)), col(6)));
    test('justo en un límite → el siguiente, no el mismo', () => expect(Momento.proximoCambio(col(6)), col(17)));
    test('18:59 → 19:00', () => expect(Momento.proximoCambio(col(18, 59)), col(19)));
    test('después de las 19:00 → 6:00 del día siguiente', () => expect(Momento.proximoCambio(col(19)), col(6, 0, 0, 13)));
    test('fin de mes', () => expect(Momento.proximoCambio(DateTime.utc(2026, 10, 31, 20).add(const Duration(hours: 5))),
        DateTime.utc(2026, 11, 1, 6).add(const Duration(hours: 5))));
  });

  group('TemaApp «Según la hora»', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('claro a las 18:59, oscuro a las 19:00, claro a las 6:00 y oscuro a las 5:59', () {
      for (final (t, modo) in [(col(18, 59), ThemeMode.light), (col(19), ThemeMode.dark), (col(6), ThemeMode.light), (col(5, 59), ThemeMode.dark)]) {
        final tema = TemaApp(reloj: RelojDelDia(ahora: () => t))..preferencia = PreferenciaTema.hora;
        expect(tema.modo, modo, reason: '$t');
        tema.dispose();
      }
    });

    test('los demás modos no dependen de la hora ni dejan temporizador', () {
      final reloj = RelojDelDia(ahora: () => col(22));
      final tema = TemaApp(reloj: reloj)..preferencia = PreferenciaTema.claro;
      expect(tema.modo, ThemeMode.light);
      expect(reloj.programado, isFalse);
      tema.preferencia = PreferenciaTema.sistema;
      expect(tema.modo, ThemeMode.system);
      tema.preferencia = PreferenciaTema.hora;
      expect(reloj.programado, isTrue);
      tema.preferencia = PreferenciaTema.oscuro;
      expect(reloj.programado, isFalse);
      tema.dispose();
    });

    test('se guarda y se lee como «hora»; un valor desconocido cae en «sistema»', () async {
      final tema = TemaApp(reloj: RelojDelDia(ahora: () => col(12)));
      await tema.cambiar(PreferenciaTema.hora);
      expect((await SharedPreferences.getInstance()).getString('siscan_tema'), 'hora');
      final otro = TemaApp(reloj: RelojDelDia(ahora: () => col(12)));
      await otro.cargar();
      expect(otro.preferencia, PreferenciaTema.hora);
      SharedPreferences.setMockInitialValues({'siscan_tema': 'raro'});
      final tercero = TemaApp(reloj: RelojDelDia(ahora: () => col(12)));
      await tercero.cargar();
      expect(tercero.preferencia, PreferenciaTema.sistema);
      for (final t in [tema, otro, tercero]) {
        t.preferencia = PreferenciaTema.claro;
        t.dispose();
      }
    });

    testWidgets('cruza las 19:00 en vivo y la app pasa a oscuro sin reiniciar', (t) async {
      var ahora = col(18, 59, 30);
      final tema = TemaApp(reloj: RelojDelDia(ahora: () => ahora))..preferencia = PreferenciaTema.hora;
      var avisos = 0;
      tema.addListener(() => avisos++);
      await t.pumpWidget(ListenableBuilder(
        listenable: tema,
        builder: (_, _) => MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          themeMode: tema.modo,
          themeAnimationDuration: Duration.zero,
          home: Builder(builder: (c) => Text(Theme.of(c).brightness.name, textDirection: TextDirection.ltr)),
        ),
      ));
      expect(find.text('light'), findsOneWidget);
      // 29 s después todavía es atardecer: nada cambia.
      ahora = col(18, 59, 59);
      await t.pump(const Duration(seconds: 29));
      expect(find.text('light'), findsOneWidget);
      expect(avisos, 0);
      // Llega el temporizador del límite (30 s + 1 s de margen): ya son las 19:00:01.
      ahora = col(19, 0, 1);
      await t.pump(const Duration(seconds: 2));
      await t.pump();
      expect(tema.modo, ThemeMode.dark);
      expect(find.text('dark'), findsOneWidget);
      expect(avisos, 1);
      // Al volver de segundo plano con la hora ya cruzada (temporizador retrasado), revisa y cambia.
      ahora = col(6, 0, 5, 13);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.pump();
      expect(find.text('light'), findsOneWidget);
      expect(avisos, 2);
      tema.preferencia = PreferenciaTema.claro; // suelta el temporizador antes de cerrar la prueba
      tema.dispose();
    });
  });
}
