// Verificación medida de la app con el sistema de diseño v2: cada pantalla se dibuja con respuestas reales del
// servidor (test/fixtures/servidor, guardadas de cisna.narino.gov.co y del plugin 3.5.0) en tema claro y oscuro, a
// 390 × 844, y sobre ese render se comprueban el contraste de texto (WCAG AA) y el área táctil mínima (44 × 44).
// Con --update-goldens las capturas quedan en test/capturas/ para el anexo.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui' show CheckedState;

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
import 'package:siscan/core/formato.dart';
import 'package:siscan/core/momento.dart';
import 'package:siscan/core/theme/siscan_theme.dart' show cifra, co, siscanTheme;
import 'package:siscan/core/ui/base.dart' show Boton, Ficha, Segmentado, TituloTarjeta;
import 'package:siscan/core/ui/dominio.dart' show ElementoLista, FilaSensor, ListaOpcionUnica;
import 'package:siscan/core/ui/marco.dart';
import 'package:siscan/data/api.dart';
import 'package:siscan/data/auth.dart';
import 'package:siscan/data/estado.dart';
import 'package:siscan/l10n/app_localizations.dart';
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
enum Escenario { real, vivo, vacio, error, cargando, copia }

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
  final corrimiento = ahora().subtract(const Duration(minutes: 2)).difference(ultima);
  return MockClient((r) async {
    // cargando: el servidor no responde nunca; copia: sin señal (500) con una copia guardada de una carga anterior.
    if (e == Escenario.cargando) return Completer<http.Response>().future;
    if (e == Escenario.error || e == Escenario.copia) return http.Response('{"message":"error"}', 500);
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

/// La hora de todas las capturas: 10:00 de Colombia del 15 de octubre de 2026 (la misma del reloj del día del arnés).
final horaDePrueba = DateTime.utc(2026, 10, 15, 15);

Future<void> _fuentes() async {
  for (final (familia, archivo) in [('Outfit', 'assets/fonts/nuevas/Outfit.ttf'), ('PlusJakartaSans', 'assets/fonts/nuevas/PlusJakartaSans.ttf')]) {
    final f = FontLoader(familia)..addFont(rootBundle.load(archivo));
    await f.load();
  }
}

/// Pantalla dentro del marco real (barra inferior cuando es una pestaña).
Widget _conMarco(Widget p, Pestana? pestana) => pestana == null ? p : Scaffold(body: p, bottomNavigationBar: BarraInferior(activa: pestana, onCambio: (_) {}));

Future<void> _montar(WidgetTester t, Widget pantalla, {required Brightness tema, Escenario escenario = Escenario.real, bool sesion = false, Pestana? pestana,
    PreferenciaIdioma idioma = PreferenciaIdioma.sistema, double ancho = 390, double alto = 844}) async {
  SharedPreferences.setMockInitialValues({});
  ahora = () => horaDePrueba;
  // rootBundle guarda en caché el Future del aviso de licencia; si lo creó otra prueba (el barrido de Más abre Acerca de
  // muchas veces), su zona de prueba ya terminó y el FutureBuilder se queda en «Cargando…». Cada montaje lo lee de nuevo.
  rootBundle.evict(PantallaLicencias.archivo);
  if (escenario == Escenario.copia) {
    // Una carga buena anterior deja su copia en el teléfono; después el servidor falla.
    await t.runAsync(() async {
      await EstadoSecador(SiscanApi(client: cliente(Escenario.real)), cada: null).cargar();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
  }
  t.view.physicalSize = Size(ancho * 3, alto * 3);
  t.view.devicePixelRatio = 3;
  t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  // El teléfono de prueba está en español de Colombia y con reloj de 24 h (el entorno de pruebas arranca en en-US y 12 h).
  t.platformDispatcher.localesTestValue = const [Locale('es', 'CO')];
  t.platformDispatcher.alwaysUse24HourFormatTestValue = true;
  final api = SiscanApi(client: cliente(escenario));
  final estado = EstadoSecador(api, cada: null);
  final auth = AuthController(client: MockClient((_) async => http.Response('{}', 401)), store: MemoryCredentialStore());
  if (sesion) auth.session = const AuthSession(user: 'gestor', displayName: 'Gestor de prueba', header: 'Basic prueba', canControl: true);
  // La escena de Inicio sigue la hora: el reloj del día se fija a las 10:00 de Colombia para que la captura no dependa
  // de la hora a la que se corra la prueba (la cabecera en los tres momentos se mide en cabecera_inicio_test.dart).
  final tm = TemaApp(reloj: RelojDelDia(ahora: () => horaDePrueba))..preferencia = tema == Brightness.dark ? PreferenciaTema.oscuro : PreferenciaTema.claro;
  await t.runAsync(() async {
    estado.iniciar();
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  // Canal del idioma por app de Android simulado: teléfono en español de Colombia, sin idioma propio para SISCAN.
  t.binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('siscan/idioma'), (c) async => c.method == 'sistema' ? 'es-CO' : null);
  addTearDown(() => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('siscan/idioma'), null));
  final ia = IdiomaApp();
  if (idioma != PreferenciaIdioma.sistema) await t.runAsync(() => ia.cambiar(idioma));
  await t.pumpWidget(SiscanApp(api: api, estado: estado, auth: auth, tema: tm, pref: Preferencias(), idioma: ia, inicio: _conMarco(pantalla, pestana)));
  // Imágenes, SVG y pedidos asíncronos de cada pantalla (predicción, curva…) se resuelven con tiempo real.
  for (var i = 0; i < 6; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await t.pump(const Duration(milliseconds: 400));
  }
  for (final e in find.byType(Image).evaluate()) {
    await t.runAsync(() => precacheImage((e.widget as Image).image, e));
  }
  await t.pump(const Duration(seconds: 1));
  // Lecturas del paquete con FutureBuilder (el aviso de licencia en Acerca de): se espera con tiempo real a que lleguen,
  // hasta 5 s, en vez de suponer que bastan los 900 ms de arriba (en una batería larga a veces no bastaban).
  bool cargando() => ['Cargando…', 'Loading…', 'Carregando…'].any((x) => find.text(x).evaluate().isNotEmpty);
  for (var i = 0; i < 50 && cargando(); i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await t.pump(const Duration(milliseconds: 100));
  }
}


double _lum(Color c) {
  double f(double v) => v <= .03928 ? v / 12.92 : math.pow((v + .055) / 1.055, 2.4).toDouble();
  return .2126 * f(c.r) + .7152 * f(c.g) + .0722 * f(c.b);
}
double _ratio(Color a, Color b) { final x = _lum(a), y = _lum(b); return (math.max(x, y) + .05) / (math.min(x, y) + .05); }

/// Contraste medido sobre el render: para cada texto visible, su color (compuesto sobre el fondo) contra el color de
/// fondo más frecuente dentro de su caja. Devuelve los que no llegan a AA (4,5; 3 en texto grande).
/// `solo`: mide únicamente los textos dentro de ese widget (una hoja modal: lo de detrás queda bajo el velo y no se lee).
Future<List<String>> medirContraste(WidgetTester t, {Finder? solo}) async {
  final dentro = solo == null ? null : {for (final e in find.descendant(of: solo, matching: find.byType(RichText)).evaluate()) e.renderObject};
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
    if (o is RenderParagraph && (dentro == null || dentro.contains(o))) {
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

// --- Paso 3 de idiomas: medición de Más en los tres idiomas. ---

/// Alto de la captura de la página Más completa (la prueba exige que no sobre desplazamiento) y del barrido (alto de
/// sobra para que la lista perezosa construya todo y se mida entero).
const _altoMas = 1080.0, _altoBarrido = 2600.0;

/// Una fila por texto medido (queda en test/capturas/idiomas-mas.tsv para el anexo). `n` es el orden del texto dentro de
/// su componente en esa pantalla: el mismo `n` en es, en y pt es el mismo texto traducido, para comparar líneas.
final _medidasMas = <String>['idioma\tancho\tpantalla\tcomponente\tn\texige una línea\ttexto\tancho del texto\tdisponible\tlibre\tlíneas\tresultado'];
final _vistos = <String>{};

/// Palabras partidas dentro de FilaSensor (Calibración › Sensores): pasa igual en español, antes de este paso, porque el
/// valor y la píldora dejan poco ancho al nombre. Es un defecto previo del componente compartido, no de la traducción:
/// se registra aparte (test/capturas/idiomas-mas-partidas.tsv) como decisión para Diego y no hace fallar el barrido.
final _partidasPrevias = <String>{'idioma\tancho\tpantalla\ttexto partido'};

/// Subpáginas con golden en inglés y portugués (las de más riesgo de desborde según el barrido).
const _conGolden = {'mas-tema', 'ubicacion', 'privacidad-borrar', 'historial'};

typedef _Accion = Future<void> Function(WidgetTester t);

Future<void> _esperar(WidgetTester t) async {
  for (var i = 0; i < 4; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await t.pump(const Duration(milliseconds: 400));
  }
}

/// Más y todo lo que se abre desde ella: (nombre, pantalla, pestaña, con sesión, qué abrir encima).
List<(String, Widget Function(), Pestana?, bool, _Accion?)> _pantallasMas(AppLocalizations l) {
  Widget mas() => PantallaMas(onIngresar: () {});
  const geo = MethodChannel('flutter.baseflow.com/geolocator');
  return [
    ('mas', mas, Pestana.mas, false, null),
    ('mas-sesion', mas, Pestana.mas, true, null),
    ('mas-tema', mas, Pestana.mas, false, (t) async { await t.tap(find.text(l.masTema).first); await t.pumpAndSettle(); }),
    ('mas-idioma', mas, Pestana.mas, false, (t) async { await t.tap(find.text(l.idioma).first); await t.pumpAndSettle(); }),
    ('calibracion', () => const PantallaCalibracion(), null, true, null),
    ('calibracion-sensores', () => const PantallaCalibracion(), null, true, (t) async { await t.tap(find.text(l.calSensores).first); await _esperar(t); }),
    ('calibracion-corregir', () => const PantallaCalibracion(), null, true, (t) async {
      await t.tap(find.text(l.calSensores).first);
      await _esperar(t);
      await t.tap(find.byType(FilaSensor).first);
      await t.pumpAndSettle();
    }),
    ('mapa', () => const PantallaMapa(), null, false, null),
    ('historial', () => const PantallaHistorial(), null, false, null),
    ('historial-7d', () => const PantallaHistorial(), null, false, (t) async { await t.tap(find.text(l.hist7d)); await _esperar(t); }),
    ('ubicacion', () => const PantallaUbicacion(), null, true, null),
    // El aviso previo al permiso de ubicación: Android dice «sin permiso todavía» (denied = 0).
    ('ubicacion-aviso', () => const PantallaUbicacion(), null, true, (t) async {
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(geo, (c) async => c.method == 'checkPermission' ? 0 : null);
      await t.tap(find.text(l.ubicUsarMia));
      for (var i = 0; i < 4; i++) { await t.pump(const Duration(milliseconds: 300)); }
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(geo, null);
    }),
    ('reloj', () => const PantallaReloj(), null, false, null),
    ('licencias', () => const PantallaLicencias(), null, false, null),
    ('privacidad', () => const PantallaPrivacidad(), null, true, null),
    ('privacidad-borrar', () => const PantallaPrivacidad(), null, true, (t) async {
      await t.scrollUntilVisible(find.text(l.privBorrar), 300, scrollable: find.byType(Scrollable).first);
      await t.ensureVisible(find.text(l.privBorrar));
      await t.pumpAndSettle();
      await t.tap(find.text(l.privBorrar));
      await t.pumpAndSettle();
    }),
  ];
}

/// Mide los textos de la pantalla: ninguno recortado (con «…» o por maxLines) y una sola línea en los componentes que el
/// diseño pide de una línea. Devuelve las fallas y registra el ancho y el margen de cada texto.
/// Textos dibujados con rasgos del español (para pantallas en inglés). Quedan fuera los nombres propios (I6) y lo que
/// trae el servidor (I4), que se reconocen por la lista de abajo.
final _rasgosEs = RegExp(r'[ñ¿¡]|ción\b|\b(el|la|los|las|del|con|sin|para|por|una|está|todavía|aún|hace|hoy|ayer)\b', caseSensitive: false);
const _permitidosEs = ['Nariño', 'Cenicafé', 'Chachagüí', 'Sandoná', 'Secado Inteligente de Café', 'juco', 'Motilón', 'Castillo', 'Caturra', 'Tabi',
    'Secador', 'Lote', 'Protocolo', 'Aire libre', 'secador solar', 'sin actuadores', 'El Motilón', 'El Motilon',
    'Subsecretaría de Innovación', 'Gobernación de Nariño'];
List<String> _espanolSuelto(WidgetTester t) {
  final vistos = <String>{};
  for (final e in find.byType(RichText).evaluate()) {
    final x = (e.widget as RichText).text.toPlainText().trim();
    if (x.isEmpty || !_rasgosEs.hasMatch(x)) continue;
    var limpio = x;
    // Sin distinguir mayúsculas: algunos nombres del servidor llegan en mayúsculas («LOTE EL MOTILON»).
    // De la más larga a la más corta: si «Nariño» saliera primero, «Gobernación de Nariño» ya no coincidiría.
    for (final p in [..._permitidosEs]..sort((a, b) => b.length.compareTo(a.length))) { limpio = limpio.replaceAll(RegExp(RegExp.escape(p), caseSensitive: false), ''); }
    if (_rasgosEs.hasMatch(limpio)) vistos.add(x);
  }
  return vistos.toList();
}

List<String> _revisarTextos(WidgetTester t, String cod, double ancho, String pantalla, {bool registrar = true}) {
  final fallas = <String>[];
  final deSensor = {for (final e in find.descendant(of: find.byType(FilaSensor), matching: find.byType(RichText)).evaluate()) e.renderObject};
  for (final e in find.byType(RichText).evaluate()) {
    final p = e.renderObject! as RenderParagraph;
    final texto = p.text.toPlainText();
    if (p.didExceedMaxLines) fallas.add('recortado: «$texto»');
    // Ninguna palabra partida por la mitad: cada salto de línea cae después de un espacio o de un guion.
    final tp = TextPainter(text: p.text, textDirection: TextDirection.ltr, textScaler: p.textScaler, maxLines: p.maxLines)..layout(maxWidth: p.constraints.maxWidth);
    for (final m in tp.computeLineMetrics().skip(1)) {
      final corte = tp.getPositionForOffset(Offset(1, m.baseline - m.ascent + 1)).offset;
      if (corte > 0 && corte < texto.length && !RegExp(r'[\s\-–—/]').hasMatch(texto[corte - 1])) {
        final partida = '${texto.substring(0, corte)}|${texto.substring(corte)}';
        if (deSensor.contains(p)) {
          if (registrar) _partidasPrevias.add('$cod\t${ancho.toInt()}\t$pantalla\t$partida');
        } else {
          fallas.add('palabra partida: «$partida»');
        }
      }
    }
    tp.dispose();
  }
  Iterable<RenderParagraph> parrafos(Finder de, {bool primero = false, bool Function(RenderParagraph)? si}) sync* {
    for (final el in de.evaluate()) {
      final hijos = find.descendant(of: find.byElementPredicate((x) => identical(x, el)), matching: find.byType(RichText)).evaluate()
          .map((x) => x.renderObject! as RenderParagraph).where((p) => si == null || si(p)).toList();
      if (primero) { if (hijos.isNotEmpty) yield hijos.first; } else { yield* hijos; }
    }
  }
  // (componente, textos, exige una línea). Exigen una línea los que el sistema recorta con «…» o cuyo ritmo depende de
  // una línea (barra superior, filas de lista y de la hoja, segmentado, fichas, título de la hoja y botones de diálogo).
  // El título de tarjeta y el botón ya parten en dos líneas en español a 360 px (p. ej. «Forma de calibrar · Lote juco»,
  // «Revocar la contraseña de aplicación»): el diseño lo permite; se registran para comparar con en/pt, sin exigir.
  final grupos = <(String, Iterable<RenderParagraph>, bool)>[
    ('barra superior', parrafos(find.byType(BarraApp), primero: true), true),
    ('fila de lista', parrafos(find.byType(ElementoLista), primero: true), true),
    ('segmentado', parrafos(find.byWidgetPredicate((w) => w is Segmentado)), true),
    ('ficha', parrafos(find.byType(Ficha)), true),
    ('opción de la hoja', parrafos(find.byWidgetPredicate((w) => w is ListaOpcionUnica), si: (p) => p.text.style?.fontSize == 15), true),
    ('título de la hoja', parrafos(find.byType(BottomSheet), si: (p) => p.text.style?.fontSize == 22), true),
    ('botón de diálogo', parrafos(find.byType(TextButton)), true),
    ('título de tarjeta', parrafos(find.byType(TituloTarjeta), primero: true), false),
    ('botón', parrafos(find.byType(Boton)), false),
  ];
  for (final (comp, ps, exige) in grupos) {
    var n = 0;
    for (final p in ps) {
      final texto = p.text.toPlainText();
      if (texto.trim().isEmpty) continue;
      final disp = p.constraints.maxWidth, w = p.getMaxIntrinsicWidth(double.infinity);
      final dispTxt = disp.isFinite ? disp.toStringAsFixed(1) : 'sin límite', libreTxt = disp.isFinite ? (disp - w).toStringAsFixed(1) : '—';
      final tp = TextPainter(text: p.text, textDirection: TextDirection.ltr, textScaler: p.textScaler)..layout(maxWidth: disp);
      final lineas = tp.computeLineMetrics().length;
      tp.dispose();
      n++;
      if (exige && lineas != 1) fallas.add('$comp en $lineas líneas: «$texto» (${w.toStringAsFixed(1)} de ${disp.toStringAsFixed(1)})');
      if (registrar && _vistos.add('$cod|$ancho|$pantalla|$comp|$n')) {
        _medidasMas.add('$cod\t${ancho.toInt()}\t$pantalla\t$comp\t$n\t${exige ? 'sí' : 'no'}\t$texto\t${w.toStringAsFixed(1)}\t$dispTxt\t$libreTxt\t$lineas\t${lineas == 1 ? 'una línea' : '$lineas líneas'}');
      }
    }
  }
  return fallas;
}

void main() {
  setUpAll(() async {
    WidgetController.hitTestWarningShouldBeFatal = true;
    await _fuentes();
    await prepararFormato();
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
    ahora = DateTime.now;
  });

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
    ('15l-licencias', () => const PantallaLicencias(), null, Escenario.real, false),
    ('16-reloj', () => const PantallaReloj(), null, Escenario.real, false),
    ('20-estado-vacio', () => PantallaInicio(irA: (_) {}), Pestana.inicio, Escenario.vacio, false),
    ('21-estado-error', () => PantallaInicio(irA: (_) {}), Pestana.inicio, Escenario.error, false),
    ('22-estado-cargando', () => PantallaInicio(irA: (_) {}), Pestana.inicio, Escenario.cargando, false),
    ('23-estado-copia-guardada', () => PantallaInicio(irA: (_) {}), Pestana.inicio, Escenario.copia, false),
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

  // Paso 4 (C3): el tema con cuatro opciones en una lista de opción única, por toque, lector y teclado.
  for (final tema in Brightness.values) {
    final sufijo = tema == Brightness.dark ? 'oscuro' : 'claro';
    testWidgets('Más › Tema: lista de opción única ($sufijo)', (t) async {
      final h = t.ensureSemantics();
      await _montar(t, PantallaMas(onIngresar: () {}), tema: tema, pestana: Pestana.mas);
      await t.tap(find.text('Tema'));
      await t.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/06t-tema-$sufijo.png'));
      await expectLater(t, meetsGuideline(_toque));
      expect(await medirContraste(t, solo: find.byType(BottomSheet)), isEmpty, reason: 'Contraste AA medido sobre el render');
      // Lector: cuatro opciones de un grupo excluyente, una sola marcada (la del tema actual).
      final nodos = [for (final o in ['Claro', 'Oscuro', 'Según la hora', 'Como el teléfono']) t.getSemantics(find.bySemanticsLabel(RegExp('^$o' r'\. ')))];
      expect(nodos.every((n) => n.flagsCollection.isInMutuallyExclusiveGroup), isTrue);
      expect(nodos.where((n) => n.flagsCollection.isChecked == CheckedState.isTrue).length, 1);
      expect(nodos[tema == Brightness.dark ? 1 : 0].flagsCollection.isChecked, CheckedState.isTrue);
      expect(nodos.every((n) => n.getSemanticsData().hasAction(SemanticsAction.tap)), isTrue);
      // Teclado: con Tab se llega a «Según la hora» (foco visible) y Enter la elige.
      final destino = t.getRect(find.text('Según la hora'));
      var llego = false;
      for (var i = 0; i < 12 && !llego; i++) {
        await t.sendKeyEvent(LogicalKeyboardKey.tab);
        await t.pump();
        final foco = FocusManager.instance.primaryFocus?.context?.findRenderObject();
        if (foco is RenderBox && foco.hasSize) {
          final r = foco.localToGlobal(Offset.zero) & foco.size;
          llego = r.top <= destino.center.dy && r.bottom >= destino.center.dy;
        }
      }
      expect(llego, isTrue, reason: 'Tab llega a «Según la hora»');
      if (tema == Brightness.light) await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/06t-tema-foco-claro.png'));
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      final temaApp = Siscan.of(t.element(find.byType(PantallaMas))).tema;
      expect(temaApp.preferencia, PreferenciaTema.hora);
      expect(find.text('Según la hora'), findsOneWidget, reason: 'la hoja se cerró y Más dice el tema elegido');
      temaApp.preferencia = PreferenciaTema.claro; // suelta el temporizador del reloj del día antes de terminar
      h.dispose();
    });
  }

  // --- Idiomas (anexo 2026-10-15, paso 2): la tubería ARB de punta a punta con Más › Idioma y la barra inferior. ---
  final idiomas = [(PreferenciaIdioma.es, 'es'), (PreferenciaIdioma.en, 'en'), (PreferenciaIdioma.pt, 'pt')];
  for (final (idioma, cod) in idiomas) {
    for (final tema in Brightness.values) {
      final sufijo = tema == Brightness.dark ? 'oscuro' : 'claro';
      testWidgets('Más › Idioma en $cod ($sufijo)', (t) async {
        final h = t.ensureSemantics();
        await _montar(t, PantallaMas(onIngresar: () {}), tema: tema, pestana: Pestana.mas, idioma: idioma);
        final titulo = {'es': 'Idioma', 'en': 'Language', 'pt': 'Idioma'}[cod]!;
        await t.tap(find.text(titulo).first);
        await t.pumpAndSettle();
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/06i-idioma-$cod-$sufijo.png'));
        await expectLater(t, meetsGuideline(_toque));
        expect(await medirContraste(t, solo: find.byType(BottomSheet)), isEmpty, reason: 'Contraste AA medido sobre el render');
        // Los idiomas en su propio nombre, sin importar el idioma de la app; una sola opción marcada (la elegida).
        final nodos = [for (final o in ['Español', 'English', 'Português']) t.getSemantics(find.bySemanticsLabel(RegExp('^$o' r'\. ')))];
        expect(nodos.where((n) => n.flagsCollection.isChecked == CheckedState.isTrue).length, 1);
        expect(nodos[idiomas.indexWhere((x) => x.$1 == idioma)].flagsCollection.isChecked, CheckedState.isTrue);
        h.dispose();
      });
    }
  }

  testWidgets('Más › Idioma: elegir English cambia la app al instante, se guarda y avisa a Android', (t) async {
    final llamadas = <MethodCall>[];
    await _montar(t, PantallaMas(onIngresar: () {}), tema: Brightness.light, pestana: Pestana.mas);
    // Después de montar: `_montar` pone su propio canal simulado y este lo reemplaza para contar las llamadas.
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('siscan/idioma'), (c) async {
      llamadas.add(c);
      return c.method == 'sistema' ? 'es-CO' : null;
    });
    expect(find.text('Pesaje'), findsOneWidget);
    await t.tap(find.text('Idioma').first);
    await t.pumpAndSettle();
    expect(find.text('Ahora: Español'), findsOneWidget, reason: '«Como el teléfono» dice el idioma real del teléfono');
    await t.tap(find.text('English'));
    await t.pumpAndSettle();
    expect(find.text('Weighing'), findsOneWidget, reason: 'la barra inferior cambió sin reiniciar');
    expect(find.text('Language'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getString('siscan_idioma'), 'en');
    expect(llamadas.where((c) => c.method == 'fijar').map((c) => (c.arguments as Map)['etiqueta']), contains('en'));
    // «Borrar los datos» olvida el idioma: vuelve a seguir al teléfono y Android recibe la lista vacía.
    await Siscan.of(t.element(find.byType(PantallaMas))).idioma.olvidar();
    await t.pumpAndSettle();
    expect(find.text('Pesaje'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getString('siscan_idioma'), isNull);
    expect((llamadas.last.arguments as Map)['etiqueta'], '');
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('siscan/idioma'), null);
  });

  test('IdiomaApp: si la persona cambió el idioma de SISCAN en Ajustes de Android, gana el del sistema', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'siscan_idioma': 'es'});
    final canal = const MethodChannel('siscan/idioma-prueba');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(canal, (c) async => c.method == 'leer' ? 'pt-BR' : null);
    final ia = IdiomaApp(canal: canal);
    await ia.cargar();
    expect(ia.preferencia, PreferenciaIdioma.pt);
    // Android 12 o anterior: el canal devuelve null y queda la preferencia propia.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(canal, (c) async => null);
    await ia.cargar();
    expect(ia.preferencia, PreferenciaIdioma.es);
  });

  test('Formato por idioma: números, fechas y horas (I5)', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final binding = TestWidgetsFlutterBinding.instance;
    ahora = () => horaDePrueba; // 10:00 del 15 oct en Colombia
    final d = DateTime.parse('2026-08-19T14:53:00-05:00');
    String todo(String cod, bool h24) {
      idiomaFormato = cod;
      binding.platformDispatcher.alwaysUse24HourFormatTestValue = h24;
      return '${cifra(1500.5)} | ${cifra(-0.75, 2)} | ${dia(d)} | ${hm(d)} | ${corta(horaDePrueba)}';
    }
    final filas = <String>[];
    for (final cod in ['es', 'en', 'pt']) {
      for (final h24 in [true, false]) { filas.add('$cod ${h24 ? '24h' : '12h'}: ${todo(cod, h24)}'); }
    }
    // ignore: avoid_print
    print(filas.join('\n'));
    // Entre la fecha y el punto medio va un espacio no separable (paso 4a): la hora baja entera si no cabe.
    expect(filas[0], 'es 24h: 1.500,5 | −0,75 | 19 ago | 14:53 | Hoy\u00A0· 10:00');
    expect(filas[2], startsWith('en 24h: 1,500.5 | −0.75 | Aug 19 | 14:53 | Today\u00A0· 10:00'));
    expect(filas[4], startsWith('pt 24h: 1.500,5 | −0,75 | 19 de ago. | 14:53 | Hoje\u00A0· 10:00'));
    expect(filas[1], matches(RegExp(r'2:53\sp\.m\.')), reason: 'español de Colombia en 12 h (con espacio fino, como CLDR)');
    expect(filas[5], contains('14:53'), reason: 'portugués de Brasil: 24 h aunque el teléfono esté en 12 h (CLDR pt-BR)');
    expect(filas[3], contains('2:53'), reason: 'inglés en 12 h');
    expect(filas[3], contains('PM'));
    idiomaFormato = 'es';
    binding.platformDispatcher.clearAlwaysUse24HourTestValue();
    ahora = DateTime.now;
  });

  testWidgets('Barra inferior a 360 px en los tres idiomas: cada etiqueta en una línea y dentro de su destino', (t) async {
    final filas = <String>['idioma\tetiqueta\tancho del texto\tancho del destino\tlibre\tlíneas\tresultado'];
    for (final (idioma, cod) in idiomas) {
      await _montar(t, PantallaMas(onIngresar: () {}), tema: Brightness.light, pestana: Pestana.mas, idioma: idioma, ancho: 360);
      final barra = find.byType(BarraInferior);
      final destino = t.getSize(find.descendant(of: barra, matching: find.byType(InkWell)).first).width;
      for (final e in find.descendant(of: barra, matching: find.byType(RichText)).evaluate()) {
        final p = e.renderObject! as RenderParagraph;
        final texto = p.text.toPlainText();
        if (texto.trim().isEmpty || RegExp(r'^\d+$').hasMatch(texto)) continue; // el contador de alertas no es etiqueta
        final tp = TextPainter(text: p.text, textDirection: TextDirection.ltr, textScaler: p.textScaler)..layout(maxWidth: p.constraints.maxWidth);
        final lineas = tp.computeLineMetrics().length;
        tp.dispose();
        final ancho = p.getMaxIntrinsicWidth(double.infinity);
        final cabe = lineas == 1 && ancho <= destino;
        filas.add('$cod\t$texto\t${ancho.toStringAsFixed(1)}\t${destino.toStringAsFixed(1)}\t${(destino - ancho).toStringAsFixed(1)}\t$lineas\t${cabe ? 'cabe' : 'NO CABE'}');
        // Decisión de Diego (2026-10-17): «Aparelhos» en portugués; desde entonces las tres lenguas deben caber en una línea.
        expect(cabe, isTrue, reason: '«$texto» no cabe en su destino ($lineas líneas, ${ancho.toStringAsFixed(1)} de ${destino.toStringAsFixed(1)})');
        // Peor caso: la misma etiqueta con el estilo del destino activo (11,5 a 800, más ancho que el inactivo a 600).
        final activo = TextPainter(text: TextSpan(text: texto, style: p.text.style!.copyWith(fontWeight: FontWeight.w800)), textDirection: TextDirection.ltr, textScaler: p.textScaler)..layout();
        filas.add('$cod (activo)\t$texto\t${activo.width.toStringAsFixed(1)}\t${destino.toStringAsFixed(1)}\t${(destino - activo.width).toStringAsFixed(1)}\t1\t${activo.width <= destino ? 'cabe' : 'NO CABE'}');
        expect(activo.width <= destino, isTrue, reason: '«$texto» activo no cabe (${activo.width.toStringAsFixed(1)} de ${destino.toStringAsFixed(1)})');
        activo.dispose();
      }
      expect(t.takeException(), isNull);
    }
    File('test/capturas/idiomas-barra-360.tsv').writeAsStringSync('${filas.join('\n')}\n');
    await expectLater(find.byType(BarraInferior), matchesGoldenFile('capturas/06i-barra-360-pt.png'));
  });

  // --- Idiomas, paso 3 (anexo 2026-10-15 · 10): la página Más completa en los tres idiomas. ---
  // Goldens de la página entera a 360 px (el ancho más chico): toda la lista cabe en el alto de la captura.
  for (final (idioma, cod) in idiomas) {
    for (final tema in Brightness.values) {
      final sufijo = tema == Brightness.dark ? 'oscuro' : 'claro';
      testWidgets('Más completa en $cod ($sufijo), 360 px', (t) async {
        final h = t.ensureSemantics();
        await _montar(t, PantallaMas(onIngresar: () {}), tema: tema, pestana: Pestana.mas, idioma: idioma, ancho: 360, alto: _altoMas);
        final lista = t.state<ScrollableState>(find.byType(Scrollable).first).position;
        expect(lista.maxScrollExtent, 0, reason: 'la página Más entera se ve en la captura (${lista.maxScrollExtent} de sobra)');
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/06m-mas-$cod-$sufijo.png'));
        expect(t.takeException(), isNull, reason: 'Sin errores de render ni desbordes');
        await expectLater(t, meetsGuideline(_toque));
        expect(await medirContraste(t), isEmpty, reason: 'Contraste AA medido sobre el render');
        // Ningún texto de la página queda en español fuera de los nombres propios (I6): se coteja con el ARB del idioma.
        final l = lookupAppLocalizations(idioma.locale!);
        for (final x in [l.masCalibracion, l.masMapa, l.masHistorial, l.masUbicacion, l.masReloj, l.masNotificaciones, l.masHuella, l.masTema, l.idioma, l.masAcerca, l.masPrivacidad, l.masIngresar]) {
          expect(find.text(x), findsOneWidget, reason: '«$x» en la página Más ($cod)');
        }
        h.dispose();
      });
    }
  }

  // Barrido de Más y de todo lo que se abre desde ella: tres idiomas × 360/390/412, sin desbordes ni recortes, una
  // línea donde el diseño la exige (con su margen medido) y, a 360 px, toques ≥ 44 y contraste AA en los dos temas.
  for (final (idioma, cod) in idiomas) {
    for (final ancho in const [360.0, 390.0, 412.0]) {
      testWidgets('Más y sus subpáginas en $cod a ${ancho.toInt()} px: sin desbordes y una línea donde va una línea', (t) async {
        final l = lookupAppLocalizations(idioma.locale!);
        final temas = ancho == 360 ? Brightness.values : const [Brightness.light];
        final fallas = <String>[];
        for (final tema in temas) {
          for (final (nombre, pantalla, pestana, sesion, abrir) in _pantallasMas(l)) {
            final h = t.ensureSemantics();
            await t.pumpWidget(const SizedBox()); // sin esto, la hoja o el diálogo de la pantalla anterior seguiría abierto
            await _montar(t, pantalla(), tema: tema, pestana: pestana, sesion: sesion, idioma: idioma, ancho: ancho, alto: _altoBarrido);
            if (abrir != null) await abrir(t);
            final ex = t.takeException();
            if (ex != null) fallas.add('$nombre ($tema): $ex');
            final modal = [find.byType(AlertDialog), find.byType(BottomSheet)].where((f) => f.evaluate().isNotEmpty).firstOrNull;
            fallas.addAll([for (final f in _revisarTextos(t, cod, ancho, nombre, registrar: tema == Brightness.light)) '$nombre: $f']);
            if (ancho == 360) {
              await expectLater(t, meetsGuideline(_toque), reason: '$nombre ($tema)');
              fallas.addAll([for (final f in await medirContraste(t, solo: modal)) '$nombre ($tema) contraste: $f']);
            }
            h.dispose();
          }
        }
        // Decisión de Diego (2026-10-18): «Fixada à mão». Desde entonces ningún título se parte a media palabra en ningún
        // idioma ni ancho (antes, «Localizaç|ão» en pt a 360 quedaba como pendiente explícito).
        expect(fallas, isEmpty, reason: fallas.join('\n'));
      });
    }
  }

  // --- Idiomas, paso 4a (anexo 2026-10-15 · 11): Inicio con la escena del secador y los componentes compartidos. ---
  // Golden de la parte de arriba (escena, cifra y mosaicos) en inglés y portugués, en los dos temas, a 360 px.
  for (final (idioma, cod) in idiomas.skip(1)) {
    for (final tema in Brightness.values) {
      final sufijo = tema == Brightness.dark ? 'oscuro' : 'claro';
      testWidgets('Inicio en $cod ($sufijo), 360 px', (t) async {
        final h = t.ensureSemantics();
        await _montar(t, PantallaInicio(irA: (_) {}), tema: tema, pestana: Pestana.inicio, idioma: idioma, ancho: 360);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/07i-inicio-$cod-$sufijo.png'));
        expect(t.takeException(), isNull, reason: 'Sin errores de render ni desbordes');
        // Ningún texto de Inicio queda en español fuera de los nombres propios (I6): se coteja con el ARB del idioma.
        final l = lookupAppLocalizations(idioma.locale!);
        // La barra de avance no dibuja texto: su etiqueta es para el lector de pantalla.
        expect(find.bySemanticsLabel(l.avanceObjetivo), findsWidgets, reason: 'barra de avance en $cod');
        for (final x in [l.humedadGrano, l.reintentar, l.inicioTempInterior, l.inicioHumedadRelativa, l.inicioExterior, l.inicioPotenciaTotal]) {
          expect(find.text(x), findsWidgets, reason: '«$x» en Inicio ($cod)');
        }
        h.dispose();
      });
    }
  }

  // Barrido de Inicio entero: tres idiomas × 360/390/412, sin desbordes ni recortes y, a 360, toques y contraste AA.
  for (final (idioma, cod) in idiomas) {
    for (final ancho in const [360.0, 390.0, 412.0]) {
      testWidgets('Inicio en $cod a ${ancho.toInt()} px: sin desbordes', (t) async {
        final temas = ancho == 360 ? Brightness.values : const [Brightness.light];
        final fallas = <String>[];
        for (final tema in temas) {
          final h = t.ensureSemantics();
          await t.pumpWidget(const SizedBox());
          await _montar(t, PantallaInicio(irA: (_) {}), tema: tema, pestana: Pestana.inicio, idioma: idioma, ancho: ancho, alto: _altoBarrido);
          final ex = t.takeException();
          if (ex != null) fallas.add('inicio ($tema): $ex');
          fallas.addAll([for (final f in _revisarTextos(t, cod, ancho, 'inicio', registrar: false)) 'inicio: $f']);
          if (ancho == 360) {
            await expectLater(t, meetsGuideline(_toque), reason: 'inicio ($tema)');
            fallas.addAll([for (final f in await medirContraste(t)) 'inicio ($tema) contraste: $f']);
          }
          h.dispose();
        }
        expect(fallas, isEmpty, reason: fallas.join('\n'));
      });
    }
  }

  // --- Idiomas, paso 4b: Lotes, ficha del lote, nuevo lote y Pesaje en tres idiomas. ---
  // Pantallas que pasa el 4b (y las del 4a), con lo que hace falta para montarlas.
  final pantallas4 = <(String, Widget Function(), Pestana?, Escenario, bool)>[
    ('inicio', () => PantallaInicio(irA: (_) {}), Pestana.inicio, Escenario.real, false),
    ('lotes', () => PantallaLotes(onIngresar: () {}), Pestana.lotes, Escenario.real, false),
    ('lote', () => const PantallaLote(id: 3), null, Escenario.real, false),
    ('nuevo-lote', () => const PantallaNuevoLote(), null, Escenario.real, true),
    ('pesaje-vacio', () => PantallaPesaje(onIngresar: () {}), Pestana.pesaje, Escenario.real, false),
    ('pesaje', () => PantallaPesaje(onIngresar: () {}), Pestana.pesaje, Escenario.vivo, true),
    // Paso 4c: Equipo (sin sesión y con sesión en modo manual), Alertas e Ingreso.
    ('equipo', () => PantallaEquipo(onIngresar: () {}), Pestana.equipo, Escenario.real, false),
    ('equipo-sesion', () => PantallaEquipo(onIngresar: () {}), Pestana.equipo, Escenario.vivo, true),
    ('alertas', () => const PantallaAlertas(), null, Escenario.real, false),
    ('ingreso', () => PantallaIngreso(onListo: () {}), null, Escenario.real, false),
  ];

  // Red para textos que quedaron en español: en inglés, ningún texto dibujado puede tener rasgos del español, salvo
  // nombres propios (I6) y lo que trae el servidor (I4: nombres de lote, secador y protocolo, título y detalle de alertas).
  for (final (idioma, cod) in idiomas) {
    for (final ancho in const [360.0, 390.0, 412.0]) {
      testWidgets('Paso 4 en $cod a ${ancho.toInt()} px: sin desbordes${cod == 'en' ? ' ni español suelto' : ''}', (t) async {
        final temas = ancho == 360 ? Brightness.values : const [Brightness.light];
        final fallas = <String>[];
        for (final tema in temas) {
          for (final (nombre, pantalla, pestana, escenario, sesion) in pantallas4) {
            final h = t.ensureSemantics();
            await t.pumpWidget(const SizedBox());
            await _montar(t, pantalla(), tema: tema, pestana: pestana, escenario: escenario, sesion: sesion, idioma: idioma, ancho: ancho, alto: _altoBarrido);
            final ex = t.takeException();
            if (ex != null) fallas.add('$nombre ($tema): $ex');
            fallas.addAll([for (final f in _revisarTextos(t, cod, ancho, nombre, registrar: false)) '$nombre: $f']);
            if (ancho == 360) {
              await expectLater(t, meetsGuideline(_toque), reason: '$nombre ($tema)');
              fallas.addAll([for (final f in await medirContraste(t)) '$nombre ($tema) contraste: $f']);
            }
            if (cod == 'en' && tema == Brightness.light) fallas.addAll([for (final x in _espanolSuelto(t)) '$nombre: español suelto «$x»']);
            h.dispose();
          }
        }
        // «Aire libre» a 360 px se resolvió con la opción A de Diego (2026-11-09): el filtro de Lotes sin íconos bajo 380 px.
        expect(fallas, isEmpty, reason: fallas.join('\n'));
      });
    }
  }

  // Goldens del 4b en inglés y portugués a 360 px: la ficha del lote (la más densa) y Pesaje con lote activo.
  for (final (idioma, cod) in idiomas.skip(1)) {
    for (final (nombre, pantalla, pestana, escenario, sesion) in pantallas4.where((p) => const {'lote', 'pesaje', 'equipo-sesion', 'ingreso'}.contains(p.$1))) {
      testWidgets('$nombre en $cod (claro), 360 px', (t) async {
        await _montar(t, pantalla(), tema: Brightness.light, pestana: pestana, escenario: escenario, sesion: sesion, idioma: idioma, ancho: 360);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/07l-$nombre-$cod-claro.png'));
        expect(t.takeException(), isNull);
      });
    }
  }

  // Alternativas para la ficha de Ubicación en portugués, medidas en la tarjeta real a 360 px: el título «Localização»
  // cabe si la ficha deja libre su ancho. Quedan para que Diego decida con la revisión nativa (no se abrevia por cuenta propia).
  testWidgets('Ubicación en pt a 360 px: la ficha elegida y las alternativas medidas', (t) async {
    await _montar(t, const PantallaUbicacion(), tema: Brightness.light, sesion: true, idioma: PreferenciaIdioma.pt, ancho: 360);
    final l = lookupAppLocalizations(const Locale('pt'));
    final tarjeta = find.ancestor(of: find.text(l.ubicTarjeta), matching: find.byType(TituloTarjeta));
    final titulo = t.renderObject<RenderParagraph>(find.descendant(of: tarjeta, matching: find.text(l.ubicTarjeta)));
    final ficha = t.renderObject<RenderParagraph>(find.descendant(of: find.descendant(of: tarjeta, matching: find.byType(Ficha)), matching: find.byType(RichText)));
    final anchoTitulo = titulo.getMaxIntrinsicWidth(double.infinity);
    // Lo que el título y el texto de la ficha se reparten (el resto de la fila es fijo: ícono, márgenes, ícono de la ficha).
    final reparto = titulo.constraints.maxWidth + ficha.getMaxIntrinsicWidth(double.infinity);
    final filas = <String>['ficha\tancho de la ficha\tqueda para el título\tancho de «${l.ubicTarjeta}»\tlibre\tresultado'];
    for (final alt in [l.ubicFijada, 'Definida manualmente', 'Fixada manualmente', 'Definida à mão', 'Manual', l.ubicPorIp]) {
      final tp = TextPainter(text: TextSpan(text: alt, style: ficha.text.style), textDirection: TextDirection.ltr, textScaler: ficha.textScaler)..layout();
      final queda = reparto - tp.width;
      filas.add('$alt\t${tp.width.toStringAsFixed(1)}\t${queda.toStringAsFixed(1)}\t${anchoTitulo.toStringAsFixed(1)}\t${(queda - anchoTitulo).toStringAsFixed(1)}\t${queda >= anchoTitulo ? 'cabe' : 'NO CABE'}');
      tp.dispose();
    }
    File('test/capturas/idiomas-ubicacion-pt-360.tsv').writeAsStringSync('${filas.join('\n')}\n');
    expect(filas[1], endsWith('\tcabe'), reason: 'la ficha elegida por Diego (2026-10-18) debe dejar entero «${l.ubicTarjeta}»');
    expect(filas.last, endsWith('\tcabe'), reason: 'la otra ficha (${l.ubicPorIp}) también');
  });

  // Calibración › Sensores: el nombre de la magnitud ya se parte a media palabra en español a 360 px (defecto previo de
  // FilaSensor, ver idiomas-mas-partidas.tsv) y la píldora «Sin calibrar» traducida es más ancha y lo empeora en en/pt.
  // Se mide el texto de la píldora (estilo de la píldora chica: 11,5 a 700) contra el español, para la decisión de Diego.
  test('Calibración › Sensores: ancho de la píldora «Sin calibrar» por idioma y alternativas', () {
    const estilo = TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 11.5, height: 16 / 12, fontWeight: FontWeight.w700);
    double ancho(String x) { final tp = TextPainter(text: TextSpan(text: x, style: estilo), textDirection: TextDirection.ltr)..layout(); final w = tp.width; tp.dispose(); return w; }
    final base = ancho('Sin calibrar');
    final filas = <String>['idioma\tpíldora\tancho\tfrente al español\tresultado'];
    // Diego (2026-10-18): mientras se decide E11, la traducción más corta que sea fiel («Uncalibrated», «Sem ajuste»).
    final actual = {for (final c in ['es', 'en', 'pt']) c: lookupAppLocalizations(Locale(c)).calSinCalibrar};
    for (final (cod, x) in [('es', actual['es']!), ('en (actual)', actual['en']!), ('pt (actual)', actual['pt']!), ('en (descartada)', 'Not calibrated'), ('en (alternativa)', 'To calibrate'),
        ('pt (descartada)', 'Sem calibração'), ('pt (alternativa)', 'Não calibrado'), ('pt (alternativa)', 'Pendente')]) {
      final w = ancho(x);
      filas.add('$cod\t$x\t${w.toStringAsFixed(1)}\t${(w - base) >= 0 ? '+' : ''}${(w - base).toStringAsFixed(1)}\t${w <= base ? 'no empeora' : 'empeora'}');
    }
    File('test/capturas/idiomas-calibracion-pildora.tsv').writeAsStringSync('${filas.join('\n')}\n');
    expect(ancho(actual['pt']!), lessThanOrEqualTo(base), reason: 'la píldora en portugués no debe ser más ancha que la española');
  });

  testWidgets('Más: goldens de las subpáginas con más riesgo en inglés y portugués (360 px)', (t) async {
    for (final (idioma, cod) in idiomas.skip(1)) {
      final l = lookupAppLocalizations(idioma.locale!);
      for (final (nombre, pantalla, pestana, sesion, abrir) in _pantallasMas(l).where((p) => _conGolden.contains(p.$1))) {
        await t.pumpWidget(const SizedBox());
        await _montar(t, pantalla(), tema: Brightness.light, pestana: pestana, sesion: sesion, idioma: idioma, ancho: 360);
        if (abrir != null) await abrir(t);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('capturas/06m-$nombre-$cod-claro.png'));
        expect(t.takeException(), isNull);
      }
    }
  });

  test('leerCifra: lee lo que escribe la persona con los separadores del idioma (I5)', () {
    idiomaFormato = 'es';
    expect(leerCifra('1.250,5'), 1250.5);
    expect(leerCifra('−0,75'), -0.75);
    idiomaFormato = 'en';
    expect(leerCifra('1,250.5'), 1250.5);
    expect(leerCifra('250.4'), 250.4);
    idiomaFormato = 'pt';
    expect(leerCifra('250,4'), 250.4);
    expect(leerCifra('abc'), isNull);
    idiomaFormato = 'es';
  });

  tearDownAll(() {
    if (_medidasMas.length > 1) File('test/capturas/idiomas-mas.tsv').writeAsStringSync('${_medidasMas.join('\n')}\n');
    if (_medidasMas.length > 1) File('test/capturas/idiomas-mas-partidas.tsv').writeAsStringSync('${_partidasPrevias.join('\n')}\n');
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
