// Paso 2 del anexo 2026-10-12 (contrato C1): la cabecera de Inicio en 360, 390 y 412 px de ancho, en los tres momentos
// (day/dusk/night) y los dos temas (claro/oscuro). Por cada uno de los 18 casos:
//  · golden de la cabecera (test/capturas/cabecera/…);
//  · contraste MEDIDO SOBRE EL RENDER: se dibuja la cabecera, se vuelve transparente la tinta de cada texto y se
//    vuelve a dibujar; los píxeles de ese segundo render dentro de la caja de cada texto son el fondo real (escena,
//    vidrio, pill). Se compara el color del texto contra CADA píxel y se informa el peor (mín.) y el percentil 5;
//  · la campana: su color contra los píxeles de su botón de 44 × 44 fuera del glifo central de 24 × 24 (3:1, no texto);
//  · toque ≥ 44 px (MinimumTapTargetGuideline) y la escena fuera del árbol de semántica.
// Los resultados quedan en test/capturas/cabecera/contraste.tsv para el anexo.
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
import 'package:siscan/core/momento.dart';
import 'package:siscan/core/theme/siscan_tokens.dart';
import 'package:siscan/core/ui/base.dart';
import 'package:siscan/core/ui/dominio.dart';
import 'package:siscan/data/api.dart';
import 'package:siscan/data/auth.dart';
import 'package:siscan/data/estado.dart';
import 'package:siscan/main.dart';
import 'package:siscan/pantallas/cabecera_inicio.dart';

import 'pantallas_test.dart' show Escenario, cliente, horaDePrueba;

double _lum(Color c) {
  double f(double v) => v <= .03928 ? v / 12.92 : math.pow((v + .055) / 1.055, 2.4).toDouble();
  return .2126 * f(c.r) + .7152 * f(c.g) + .0722 * f(c.b);
}

double _ratio(Color a, Color b) {
  final x = _lum(a), y = _lum(b);
  return (math.max(x, y) + .05) / (math.min(x, y) + .05);
}

/// Qué se mide y con qué piso. `aaa`: la cifra (WCAG 1.4.6; texto grande ≥ 24 px → 4,5, normal → 7).
class _Objetivo {
  const _Objetivo(this.nombre, this.encontrar, {this.aaa = false});
  final String nombre;
  final bool Function(String) encontrar;
  final bool aaa;
}

final _objetivos = [
  _Objetivo('saludo', (s) => s.startsWith('¡Hola')),
  _Objetivo('subtítulo', (s) => s.contains('Secador') || s.contains('secando') || s.contains('lote')),
  // E8: la tarjeta lleva la composición de ActiveBatchHero (ficha del lote, cifra de 52 y «%», objetivo y lo que falta).
  _Objetivo('ficha lote', (s) => s.startsWith('Lote')),
  _Objetivo('cifra', (s) => RegExp(r'^\d+,\d$').hasMatch(s), aaa: true),
  _Objetivo('unidad', (s) => s == '%'),
  _Objetivo('rótulo', (s) => s == 'Humedad del grano'),
  _Objetivo('pill', (s) => s == 'Secando' || s == 'Terminado'),
  _Objetivo('objetivo · falta', (s) => s.startsWith('Objetivo')),
  _Objetivo('confianza', (s) => s.startsWith('Confianza')),
];

Future<void> _fuentes() async {
  for (final (familia, archivo) in [('Outfit', 'assets/fonts/nuevas/Outfit.ttf'), ('PlusJakartaSans', 'assets/fonts/nuevas/PlusJakartaSans.ttf')]) {
    await (FontLoader(familia)..addFont(rootBundle.load(archivo))).load();
  }
}

InlineSpan _transparente(InlineSpan s) => s is TextSpan
    ? TextSpan(text: s.text, style: (s.style ?? const TextStyle()).copyWith(color: const Color(0x00000000)), children: s.children?.map(_transparente).toList())
    : s;

void main() {
  setUpAll(_fuentes);
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
    ahora = DateTime.now;
  });

  final filas = <String>['ancho\tmomento\ttema\telemento\ttexto\ttamaño\tpiso\tmín\tp5\tresultado'];
  final fallas = <String>[];
  final geometria = <String>['ancho\tmomento\ttema\tpantalla\tescena\ttarjeta_arriba\ttarjeta_abajo\ttarjeta_alto\tlibre_sobre_barra'];

  for (final ancho in [360.0, 390.0, 412.0]) {
    for (final m in Momento.values) {
      for (final tema in [Brightness.light, Brightness.dark]) {
        final nombre = '${ancho.round()}-${m.variante}-${tema == Brightness.light ? 'claro' : 'oscuro'}';
        testWidgets('Cabecera $nombre', (t) async {
          SharedPreferences.setMockInitialValues({});
          ahora = () => horaDePrueba;
          final sem = t.ensureSemantics();
          const dpr = 3.0;
          t.view.devicePixelRatio = dpr;
          // Alto de la primera vista de un teléfono real de cada ancho (360 × 640, 390 × 844, 412 × 915).
          final altoPantalla = const {360: 640.0, 390: 844.0, 412: 915.0}[ancho.round()]!;
          t.view.physicalSize = Size(ancho * dpr, altoPantalla * dpr);
          t.view.padding = const FakeViewPadding(top: 24 * dpr); // barra de estado de Android
          t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
          // Lote en curso con la predicción también en curso (5 h 40 y confianza 75), para que se dibujen y se midan
          // «faltan ~X» en hoja y la confianza: con el fixture tal cual (objetivo alcanzado) no aparecen.
          final base = cliente(Escenario.vivo);
          final api = SiscanApi(client: MockClient((r) async {
            final res = await base.get(r.url);
            if (!r.url.path.contains('prediction')) return res;
            final d = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>..['estado'] = 'EN_CURSO'..['horasRestantes'] = 5.67;
            return http.Response.bytes(utf8.encode(jsonEncode(d)), 200, headers: {'content-type': 'application/json; charset=utf-8'});
          }));
          final estado = EstadoSecador(api, cada: null);
          final auth = AuthController(client: MockClient((_) async => http.Response('{}', 401)), store: MemoryCredentialStore());
          final tm = TemaApp()..preferencia = tema == Brightness.dark ? PreferenciaTema.oscuro : PreferenciaTema.claro;
          await t.runAsync(() async {
            estado.iniciar();
            await Future<void>.delayed(const Duration(milliseconds: 300));
          });
          final b = estado.base!;
          expect(b.lote, isNotNull, reason: 'el escenario vivo tiene el lote 3 en curso');
          await t.pumpWidget(SiscanApp(api: api, estado: estado, auth: auth, tema: tm, pref: Preferencias(),
              inicio: Scaffold(body: Align(alignment: Alignment.topCenter, child: RepaintBoundary(child: Builder(builder: (context) => ColoredBox(
                // El fondo de la página: lo que el vidrio tiene detrás bajo el borde de la escena.
                color: Theme.of(context).scaffoldBackgroundColor,
                child: CabeceraInicio(
                  base: b, saludo: '¡Hola, Diego!', subtitulo: '${b.nombreSecador} · ${b.lote!['name']} secando',
                  alertas: b.alertas.length, onAlertas: () {}, momento: m,
                ),
              )))))));
          for (var i = 0; i < 6; i++) {
            await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
            await t.pump(const Duration(milliseconds: 400));
          }
          await t.pump(const Duration(seconds: 1));

          final cab = find.byType(CabeceraInicio);
          await expectLater(cab, matchesGoldenFile('capturas/cabecera/$nombre.png'));

          // La escena no aparece en el árbol de semántica (ExcludeSemantics) y el toque mínimo se cumple.
          expect(find.descendant(of: find.byType(Paisaje), matching: find.byType(ExcludeSemantics)), findsOneWidget);
          await expectLater(t, meetsGuideline(const MinimumTapTargetGuideline(size: Size(44, 44), link: 'CLAUDE.md · toque ≥ 44 px')));
          // Orden de lectura (TalkBack): logo, campana, saludo, subtítulo y tarjeta, cada uno en su nodo.
          final etiquetas = <String>[];
          void leer(SemanticsNode n) {
            if (n.label.trim().isNotEmpty) etiquetas.add(n.label);
            for (final h in n.debugListChildrenInOrder(DebugSemanticsDumpOrder.traversalOrder)) { leer(h); }
          }
          leer(t.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!);
          int pos(bool Function(String) f) => etiquetas.indexWhere(f);
          final iSaludo = pos((e) => e.startsWith('¡Hola')), iSub = pos((e) => e.startsWith(b.nombreSecador)),
              iAlertas = pos((e) => e.startsWith('Alertas')), iAnillo = pos((e) => e.contains('Humedad del grano'));
          expect([iAlertas, iSaludo, iSub, iAnillo].every((i) => i >= 0), isTrue, reason: '$etiquetas');
          expect(iAlertas < iSaludo && iSaludo < iSub && iSub < iAnillo, isTrue, reason: 'orden de lectura: $etiquetas');
          expect(etiquetas.where((e) => e.contains(b.nombreSecador) && e.contains('Objetivo')), isEmpty, reason: 'subtítulo fundido con la tarjeta: $etiquetas');

          // E8: la tarjeta no tapa el secador más que antes (pisa la escena solo E1 = 32) y cabe entera en la primera vista
          // por encima de la barra inferior (80 de alto con su relleno).
          final tarjeta = t.getRect(find.byType(TarjetaLoteVidrio));
          final escena = MedidasCabecera.escena(ancho);
          expect(tarjeta.top, closeTo(escena - MedidasCabecera.solape, .5), reason: 'solape distinto de E1');
          geometria.add('${ancho.round()}\t${m.variante}\t${tema.name}\t${altoPantalla.round()}\t${escena.toStringAsFixed(1)}\t'
              '${tarjeta.top.toStringAsFixed(1)}\t${tarjeta.bottom.toStringAsFixed(1)}\t${tarjeta.height.toStringAsFixed(1)}\t${(altoPantalla - 80 - tarjeta.bottom).toStringAsFixed(1)}');
          expect(tarjeta.bottom + 80, lessThanOrEqualTo(altoPantalla), reason: 'la tarjeta no cabe en la primera vista');

          final campana = t.getRect(find.byType(BotonIcono));
          expect(campana.width >= SiscanSize.toque && campana.height >= SiscanSize.toque, isTrue, reason: 'campana $campana');

          Future<(ByteData, int)> captura() async {
            final img = (await t.runAsync(() => captureImage(t.element(find.byType(MaterialApp)))))!;
            return ((await t.runAsync(() => img.toByteData(format: ui.ImageByteFormat.rawRgba)))!, img.width);
          }
          Color px(ByteData d, int w, int x, int y) {
            final i = (y * w + x) * 4;
            return Color.fromARGB(255, d.getUint8(i), d.getUint8(i + 1), d.getUint8(i + 2));
          }
          String r2(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

          // 1) Campana: contra el render tal cual, fuera del glifo.
          final (conTinta, w) = await captura();
          final iconoW = find.descendant(of: find.byType(BotonIcono), matching: find.byType(Icono)).evaluate().first.widget as Icono;
          final glifo = Rect.fromCenter(center: campana.center, width: 24, height: 24);
          final fondoCampana = <double>[];
          for (var y = (campana.top * dpr).ceil(); y < (campana.bottom * dpr).floor(); y += 2) {
            for (var x = (campana.left * dpr).ceil(); x < (campana.right * dpr).floor(); x += 2) {
              if (glifo.contains(Offset(x / dpr, y / dpr))) continue;
              // El contador de alertas (arriba a la derecha) no es fondo de la campana.
              if (x / dpr > campana.right - 22 && y / dpr < campana.top + 24) continue;
              fondoCampana.add(_ratio(iconoW.color!, px(conTinta, w, x, y)));
            }
          }
          fondoCampana.sort();
          final cMin = fondoCampana.first, cP5 = fondoCampana[(fondoCampana.length * .05).floor()];
          final okC = cMin >= 3;
          filas.add('${ancho.round()}\t${m.variante}\t${tema.name}\tcampana\t(ícono)\t24\t3,00\t${r2(cMin)}\t${r2(cP5)}\t${okC ? 'pasa' : 'FALLA'}');
          if (!okC) fallas.add('$nombre campana ${r2(cMin)}:1');

          // 2) Textos: se vuelve transparente la tinta y se dibuja otra vez para ver el fondo real detrás de cada letra.
          final parrafos = <RenderParagraph, InlineSpan>{};
          void buscar(RenderObject o) {
            if (o is RenderParagraph) parrafos[o] = o.text;
            o.visitChildren(buscar);
          }
          t.renderObject(cab).visitChildren(buscar);
          for (final p in parrafos.keys) {
            p.text = _transparente(p.text);
          }
          t.binding.scheduleFrame();
          await t.pump();
          final (sinTinta, _) = await captura();
          parrafos.forEach((p, original) => p.text = original);
          await t.pump();

          final medidos = <String>{};
          parrafos.forEach((p, original) {
            final texto = original.toPlainText().trim();
            final obj = _objetivos.where((o) => o.encontrar(texto)).firstOrNull;
            if (obj == null || medidos.contains(obj.nombre)) return;
            medidos.add(obj.nombre);
            final r = p.localToGlobal(Offset.zero) & p.size;
            // Fondo real detrás de las letras: donde el píxel cambia entre el render con tinta y el render sin tinta,
            // el render sin tinta es exactamente lo que queda detrás.
            final fondos = <Color>[];
            for (var y = (r.top * dpr).ceil(); y < (r.bottom * dpr).floor(); y += 2) {
              for (var x = (r.left * dpr).ceil(); x < math.min(r.right * dpr, w.toDouble()).floor(); x += 2) {
                final fondo = px(sinTinta, w, x, y), tinta = px(conTinta, w, x, y);
                if ((fondo.r - tinta.r).abs() + (fondo.g - tinta.g).abs() + (fondo.b - tinta.b).abs() < 24 / 255) continue;
                fondos.add(fondo);
              }
            }
            // Cada tramo con color propio («faltan ~X» va en hoja) se mide aparte contra el mismo fondo.
            final tramos = <TextStyle>[];
            void tramo(InlineSpan sp, TextStyle base) {
              if (sp is! TextSpan) return;
              final st = base.merge(sp.style);
              if ((sp.text ?? '').trim().isNotEmpty && tramos.every((x) => x.color != st.color || x.fontSize != st.fontSize)) tramos.add(st);
              for (final h in sp.children ?? const <InlineSpan>[]) {
                tramo(h, st);
              }
            }
            tramo(original, const TextStyle());
            for (final (i, st) in tramos.indexed) {
              final ratios = [for (final f in fondos) _ratio(Color.alphaBlend(st.color!, f), f)]..sort();
              final tam = st.fontSize ?? 14, grande = tam >= 24 || (tam >= 18.66 && (st.fontWeight?.value ?? 400) >= 700);
              final piso = obj.aaa ? (grande ? 4.5 : 7.0) : (grande ? 3.0 : 4.5);
              final mn = ratios.first, p5 = ratios[(ratios.length * .05).floor()];
              final ok = mn >= piso;
              final el = tramos.length > 1 ? '${obj.nombre} · tramo ${i + 1}' : obj.nombre;
              filas.add('${ancho.round()}\t${m.variante}\t${tema.name}\t$el\t$texto\t${tam.toStringAsFixed(0)}\t${r2(piso)}\t${r2(mn)}\t${r2(p5)}\t${ok ? 'pasa' : 'FALLA'}');
              if (!ok) fallas.add('$nombre $el «$texto» ${r2(mn)}:1 < ${r2(piso)}');
            }
          });
          sem.dispose();
          for (final o in _objetivos.where((o) => o.nombre != 'confianza')) {
            expect(medidos, contains(o.nombre), reason: 'no se encontró «${o.nombre}» en la cabecera');
          }
        });
      }
    }
  }

  tearDownAll(() {
    final dir = Directory('test/capturas/cabecera')..createSync(recursive: true);
    File('${dir.path}/contraste.tsv').writeAsStringSync('${filas.join('\n')}\n');
    File('${dir.path}/geometria.tsv').writeAsStringSync('${geometria.join('\n')}\n');
    // ignore: avoid_print
    print('Contraste medido: ${filas.length - 1} mediciones, ${fallas.length} fallas.\n${fallas.join('\n')}');
    expect(fallas, isEmpty, reason: fallas.join('\n'));
  });
}
