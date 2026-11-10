// Verificación medida de la app con el sistema de diseño v2: cada pantalla se dibuja con respuestas reales del
// servidor (test/fixtures/servidor, guardadas de cisna.narino.gov.co y del plugin 3.5.0) en tema claro y oscuro, a
// 390 × 844, y sobre ese render se comprueban el contraste de texto (WCAG AA) y el área táctil mínima (44 × 44).
// Con --update-goldens las capturas quedan en test/capturas/ para el anexo.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siscan/app/contexto.dart';
import 'package:siscan/app/preferencias.dart';
import 'package:siscan/app/widgets_inicio.dart';
import 'package:siscan/core/theme/siscan_theme.dart' show co, siscanTheme;
import 'package:siscan/core/ui/marco.dart';
import 'package:siscan/data/api.dart';
import 'package:siscan/data/auth.dart';
import 'package:siscan/data/estado.dart';
import 'package:siscan/main.dart';
import 'package:siscan/pantallas/alertas.dart';
import 'package:siscan/pantallas/equipo.dart';
import 'package:siscan/pantallas/ingreso.dart';
import 'package:siscan/pantallas/inicio.dart';
import 'package:siscan/pantallas/lotes.dart';
import 'package:siscan/pantallas/mas.dart';
import 'package:siscan/pantallas/pesaje.dart';

/// Escenario: «real» (el servidor tal como está: secador sin reportar desde agosto) o «vivo» (los mismos datos con las
/// fechas corridas a hoy y el lote 3 en curso), para ver el estado en vivo y los controles con sesión.
enum Escenario { real, vivo, vacio, error }

String _clave(Uri u) => '${u.path.replaceFirst(RegExp(r'^.*/secador/v1/'), '')}${u.hasQuery ? '?${u.query}' : ''}'.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');

/// Corre todas las fechas «AAAA-MM-DD HH:MM:SS» para que la última lectura quede hace 2 minutos.
String _correrFechas(String json, Duration d) => json.replaceAllMapped(RegExp(r'"(\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2})"'), (m) {
      final f = co(DateTime.parse('${m[1]!.replaceFirst(' ', 'T')}-05:00').add(d));
      String p(int v) => v.toString().padLeft(2, '0');
      return '"${f.year}-${p(f.month)}-${p(f.day)} ${p(f.hour)}:${p(f.minute)}:${p(f.second)}"';
    });

http.Client cliente(Escenario e) {
  final dir = Directory('test/fixtures/servidor');
  final ultima = DateTime.parse('2026-08-19T14:53:49-05:00');
  final corrimiento = DateTime.now().subtract(const Duration(minutes: 2)).difference(ultima);
  return MockClient((r) async {
    if (e == Escenario.error) return http.Response('{"message":"error"}', 500);
    if (r.method != 'GET') return http.Response('{}', 200);
    final f = File('${dir.path}/${_clave(r.url)}.json');
    if (!f.existsSync()) return http.Response('{"code":"rest_no_route"}', 404);
    var cuerpo = f.readAsStringSync();
    if (e == Escenario.vacio && _clave(r.url).startsWith('drying_batches_secadorId')) cuerpo = '[]';
    // La foto del secador es una imagen por red: la prueba no tiene internet, así que se ve el estado «Sin foto todavía».
    if (_clave(r.url) == 'secadores') cuerpo = cuerpo.replaceAll(RegExp(r'"photoUrl":"[^"]*"'), '"photoUrl":null');
    if (e == Escenario.vivo) {
      cuerpo = _correrFechas(cuerpo, corrimiento);
      if (_clave(r.url).startsWith('drying_batches')) {
        final d = jsonDecode(cuerpo);
        void abrir(dynamic b) { if (b is Map && b['id'] == 3) { b['status'] = 'RUNNING'; b['endedAt'] = null; } }
        if (d is List) { d.forEach(abrir); } else if (d is Map) { abrir(d['batch']); }
        cuerpo = jsonEncode(d);
      }
    }
    return http.Response.bytes(utf8.encode(cuerpo), 200, headers: {'content-type': 'application/json; charset=utf-8'});
  });
}

Future<void> _fuentes() async {
  for (final (familia, archivo) in [('Outfit', 'assets/fonts/nuevas/Outfit.ttf'), ('PlusJakartaSans', 'assets/fonts/nuevas/PlusJakartaSans.ttf')]) {
    final f = FontLoader(familia)..addFont(rootBundle.load(archivo));
    await f.load();
  }
}

/// Pantalla dentro del marco real (barra inferior cuando es una pestaña).
Widget _conMarco(Widget p, Pestana? pestana) => pestana == null ? p : Scaffold(body: p, bottomNavigationBar: BarraInferior(activa: pestana, onCambio: (_) {}));

Future<void> _montar(WidgetTester t, Widget pantalla, {required Brightness tema, Escenario escenario = Escenario.real, bool sesion = false, Pestana? pestana}) async {
  SharedPreferences.setMockInitialValues({});
  t.view.physicalSize = const Size(1170, 2532);
  t.view.devicePixelRatio = 3;
  t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  final api = SiscanApi(client: cliente(escenario));
  final estado = EstadoSecador(api, cada: null);
  final auth = AuthController(client: MockClient((_) async => http.Response('{}', 401)), store: MemoryCredentialStore());
  if (sesion) auth.session = const AuthSession(user: 'gestor', displayName: 'Gestor de prueba', header: 'Basic prueba', canControl: true);
  final tm = TemaApp()..modo = tema == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  await t.runAsync(() async {
    estado.iniciar();
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await t.pumpWidget(SiscanApp(api: api, estado: estado, auth: auth, tema: tm, pref: Preferencias(), inicio: _conMarco(pantalla, pestana)));
  // Imágenes, SVG y pedidos asíncronos de cada pantalla (predicción, curva…) se resuelven con tiempo real.
  for (var i = 0; i < 6; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await t.pump(const Duration(milliseconds: 400));
  }
  for (final e in find.byType(Image).evaluate()) {
    await t.runAsync(() => precacheImage((e.widget as Image).image, e));
  }
  await t.pump(const Duration(seconds: 1));
}


double _lum(Color c) {
  double f(double v) => v <= .03928 ? v / 12.92 : math.pow((v + .055) / 1.055, 2.4).toDouble();
  return .2126 * f(c.r) + .7152 * f(c.g) + .0722 * f(c.b);
}
double _ratio(Color a, Color b) { final x = _lum(a), y = _lum(b); return (math.max(x, y) + .05) / (math.min(x, y) + .05); }

/// Contraste medido sobre el render: para cada texto visible, su color (compuesto sobre el fondo) contra el color de
/// fondo más frecuente dentro de su caja. Devuelve los que no llegan a AA (4,5; 3 en texto grande).
Future<List<String>> medirContraste(WidgetTester t) async {
  final img = (await t.runAsync(() => captureImage(t.element(find.byType(MaterialApp)))))!;
  final datos = (await t.runAsync(() => img.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
  final w = img.width, h = img.height, dpr = img.width / (t.view.physicalSize.width / t.view.devicePixelRatio);
  Color px(int x, int y) { final i = (y * w + x) * 4; return Color.fromARGB(255, datos.getUint8(i), datos.getUint8(i + 1), datos.getUint8(i + 2)); }
  final fallas = <String>[];
  // Lo que queda detrás de la barra inferior no se ve: no se mide (se mediría el fondo de la barra).
  final barra = find.byType(BarraInferior).evaluate().isEmpty ? null : t.getRect(find.byType(BarraInferior));
  final deBarra = {for (final e in find.descendant(of: find.byType(BarraInferior), matching: find.byType(RichText)).evaluate()) e.renderObject};
  bool enBarra(RenderObject o) => deBarra.contains(o);
  void visitar(RenderObject o) {
    if (o is RenderParagraph) {
      final r = o.localToGlobal(Offset.zero) & o.size;
      if (barra != null && r.bottom > barra.top + 1 && !enBarra(o)) { o.visitChildren(visitar); return; }
      final caja = Rect.fromLTRB(r.left * dpr, r.top * dpr, r.right * dpr, r.bottom * dpr).intersect(Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()));
      if (caja.width > 2 && caja.height > 2) {
        // Píxeles de la caja agrupados por tono (5 bits por canal): un degradado no se reparte en cientos de colores.
        final pix = <Color>[];
        for (var y = caja.top.ceil(); y < caja.bottom.floor(); y += 2) {
          for (var x = caja.left.ceil(); x < caja.right.floor(); x += 2) { pix.add(px(x, y)); }
        }
        if (pix.isNotEmpty) {
          o.text.visitChildren((span) {
            if (span is TextSpan && (span.text ?? '').trim().isNotEmpty && span.style?.color != null) {
              final st = span.style!;
              // Fondo: el grupo más frecuente sin contar el núcleo de las letras (píxeles casi iguales al color del texto).
              final grupos = <int, List<Color>>{};
              for (final p in pix) {
                final d = (p.r - st.color!.r).abs() + (p.g - st.color!.g).abs() + (p.b - st.color!.b).abs();
                if (d < .05) continue;
                final k = ((p.r * 255).round() >> 3) << 10 | ((p.g * 255).round() >> 3) << 5 | ((p.b * 255).round() >> 3);
                (grupos[k] ??= []).add(p);
              }
              if (grupos.isEmpty) return true;
              final g = grupos.values.reduce((a, b) => a.length >= b.length ? a : b);
              final fondo = Color.from(alpha: 1, red: g.map((c) => c.r).reduce((a, b) => a + b) / g.length,
                  green: g.map((c) => c.g).reduce((a, b) => a + b) / g.length, blue: g.map((c) => c.b).reduce((a, b) => a + b) / g.length);
              final col = Color.alphaBlend(st.color!, fondo);
              final tam = st.fontSize ?? 14, grande = tam >= 24 || (tam >= 18.66 && (st.fontWeight?.value ?? 400) >= 700);
              final rr = _ratio(col, fondo);
              if (rr < (grande ? 3 : 4.5)) fallas.add('«${span.text!.trim()}» ${rr.toStringAsFixed(2)}:1 (${tam}px) texto ${col.toARGB32().toRadixString(16)} fondo ${fondo.toARGB32().toRadixString(16)}');
            }
            return true;
          });
        }
      }
    }
    o.visitChildren(visitar);
  }
  visitar(t.binding.renderViews.first);
  return fallas;
}

/// Solo para pruebas de depuración (árbol de semántica).
Future<void> montarParaDepurar(WidgetTester t, Widget w, Pestana? pestana) => _montar(t, w, tema: Brightness.light, pestana: pestana);

/// Piso del proyecto: 44 × 44 (CLAUDE.md de Diego); el texto en AA.
const _toque = MinimumTapTargetGuideline(size: Size(44, 44), link: 'CLAUDE.md · toque ≥ 44 px');

void main() {
  setUpAll(_fuentes);
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues());

  final casos = <(String, Widget Function(), Pestana?, Escenario, bool)>[
    ('00-carga', () => const PantallaCarga(), null, Escenario.real, false),
    ('01-ingreso', () => PantallaIngreso(onListo: () {}), null, Escenario.real, false),
    ('02-inicio', () => PantallaInicio(irA: (_) {}), Pestana.inicio, Escenario.real, false),
    ('02v-inicio-vivo', () => PantallaInicio(irA: (_) {}), Pestana.inicio, Escenario.vivo, true),
    ('03-lotes', () => PantallaLotes(onIngresar: () {}), Pestana.lotes, Escenario.real, false),
    ('04-pesaje-vacio', () => PantallaPesaje(onIngresar: () {}), Pestana.pesaje, Escenario.real, false),
    ('04v-pesaje', () => PantallaPesaje(onIngresar: () {}), Pestana.pesaje, Escenario.vivo, true),
    ('05-equipo', () => PantallaEquipo(onIngresar: () {}), Pestana.equipo, Escenario.real, false),
    ('05v-equipo-sesion', () => PantallaEquipo(onIngresar: () {}), Pestana.equipo, Escenario.vivo, true),
    ('06-mas', () => PantallaMas(onIngresar: () {}), Pestana.mas, Escenario.real, false),
    ('07-lote', () => const PantallaLote(id: 3), null, Escenario.real, false),
    ('08-mapa', () => const PantallaMapa(), null, Escenario.real, false),
    ('09-historial', () => const PantallaHistorial(), null, Escenario.real, false),
    ('10-alertas', () => const PantallaAlertas(), null, Escenario.real, false),
    ('12-nuevo-lote', () => const PantallaNuevoLote(), null, Escenario.real, true),
    ('13-calibracion', () => const PantallaCalibracion(), null, Escenario.real, true),
    ('14-ubicacion', () => const PantallaUbicacion(), null, Escenario.real, true),
    ('15-privacidad', () => const PantallaPrivacidad(), null, Escenario.real, false),
    ('16-reloj', () => const PantallaReloj(), null, Escenario.real, false),
    ('20-estado-vacio', () => PantallaInicio(irA: (_) {}), Pestana.inicio, Escenario.vacio, false),
    ('21-estado-error', () => PantallaInicio(irA: (_) {}), Pestana.inicio, Escenario.error, false),
  ];

  testWidgets('Equipo: encender una resistencia exige mantener presionado (un solo botón, para la que se tocó)', (t) async {
    final h = t.ensureSemantics();
    await _montar(t, PantallaEquipo(onIngresar: () {}), tema: Brightness.light, escenario: Escenario.vivo, sesion: true, pestana: Pestana.equipo);
    expect(find.textContaining('Mantén presionado'), findsNothing);
    await t.tap(find.bySemanticsLabel('Calefactor 3').last);
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Mantén presionado para encender'), findsOneWidget);
    expect(find.textContaining('Calefactor 3 · 1.500 W'), findsOneWidget);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/05w-equipo-mantener-claro.png'));
    h.dispose();
  });

  testWidgets('Widgets de inicio (2×2 y 4×2) con el HomeWidget del sistema', (t) async {
    for (final (nombre, chico, tam) in [('widget-2x2', true, const Size(156, 156)), ('widget-4x2', false, const Size(330, 156))]) {
      final api = SiscanApi(client: cliente(Escenario.real));
      final e = EstadoSecador(api, cada: null);
      SharedPreferences.setMockInitialValues({});
      await t.runAsync(() => e.cargar());
      t.view.physicalSize = tam * 3;
      t.view.devicePixelRatio = 3;
      await t.pumpWidget(MaterialApp(debugShowCheckedModeBanner: false, theme: siscanTheme(Brightness.dark), home: Material(color: const Color(0xFF7A8F80), child: WidgetHome(base: e.base!, chico: chico))));
      for (final el in find.byType(Image).evaluate()) { await t.runAsync(() => precacheImage((el.widget as Image).image, el)); }
      await t.pump(const Duration(seconds: 1));
      await expectLater(find.byType(WidgetHome), matchesGoldenFile('capturas/$nombre.png'));
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('Lector de pantalla: cada control tiene su propio nodo (no se funde con el encabezado)', (t) async {
    final h = t.ensureSemantics();
    await _montar(t, PantallaInicio(irA: (_) {}), tema: Brightness.light, pestana: Pestana.inicio);
    final campana = t.getSemantics(find.bySemanticsLabel(RegExp(r'^Alertas$')));
    expect(campana.flagsCollection.isButton, isTrue, reason: 'La campana es un botón');
    expect(campana.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    expect(find.bySemanticsLabel(RegExp(r'^Humedad del grano 10,6 %$')), findsOneWidget, reason: 'El anillo se lee aparte');
    for (final destino in ['Inicio', 'Lotes', 'Pesaje', 'Equipo', 'Más']) {
      expect(find.bySemanticsLabel(RegExp('^$destino')), findsWidgets, reason: 'Destino $destino en la barra inferior');
    }
    h.dispose();
  });

  for (final tema in Brightness.values) {
    final sufijo = tema == Brightness.dark ? 'oscuro' : 'claro';
    group('Tema $sufijo', () {
      for (final (nombre, pantalla, pestana, escenario, sesion) in casos) {
        testWidgets(nombre, (t) async {
          final h = t.ensureSemantics();
          await _montar(t, pantalla(), tema: tema, escenario: escenario, sesion: sesion, pestana: pestana);
          await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/$nombre-$sufijo.png'));
          expect(t.takeException(), isNull, reason: 'Sin errores de render ni desbordes');
          await expectLater(t, meetsGuideline(_toque));
          final fallas = await medirContraste(t);
          expect(fallas, isEmpty, reason: 'Contraste AA medido sobre el render');
          h.dispose();
        });
      }
    });
  }
}
