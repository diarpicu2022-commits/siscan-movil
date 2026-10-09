import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../core/theme/siscan_theme.dart';
import '../core/theme/siscan_tokens.dart';
import '../core/ui/base.dart';
import '../core/ui/datos.dart';
import '../data/estado.dart';
import 'comun.dart';

/// Widgets de la pantalla de inicio (HomeWidget del sistema, 2×2 y 4×2). Se dibujan con los componentes del sistema y
/// se entregan al widget nativo como imagen: quedan idénticos al diseño. Un widget no es tiempo real: el punto «En vivo»
/// solo late si el secador reporta; si no, queda hueco y se dice desde cuándo.
abstract final class WidgetsInicio {
  static final toque = ValueNotifier<String?>(null);
  static bool _escuchando = false;
  static bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static void escuchar(EstadoSecador e) {
    if (!_android || _escuchando) return;
    _escuchando = true;
    HomeWidget.initiallyLaunchedFromHomeWidget().then((u) { if (u != null) toque.value = u.host; });
    HomeWidget.widgetClicked.listen((u) { if (u != null) toque.value = u.host; });
    e.addListener(() { final b = e.base; if (b != null && !b.guardado) publicar(b); });
    if (e.base != null) publicar(e.base!);
  }

  static Future<void> publicar(Base b) async {
    if (!_android) return;
    try {
      final w = WidgetHome(base: b, chico: true), m = WidgetHome(base: b, chico: false);
      await HomeWidget.renderFlutterWidget(_Tema(child: w), key: 'img_s', logicalSize: const Size(156, 156), pixelRatio: 3);
      await HomeWidget.renderFlutterWidget(_Tema(child: m), key: 'img_m', logicalSize: const Size(330, 156), pixelRatio: 3);
      await HomeWidget.saveWidgetData('descripcion', _descripcion(b));
      for (final p in ['MoistureWidgetProvider', 'BatchWidgetProvider']) { await HomeWidget.updateWidget(androidName: p); }
    } catch (_) {/* el widget conserva la última imagen */}
  }

  static String _descripcion(Base b) {
    final l = b.lote;
    if (l == null) return 'SISCAN: sin lotes registrados.';
    return 'SISCAN, ${l['name']}: humedad del grano ${cifra(l['lastMoisturePct'] as num?)} por ciento. ${b.estado.$2}.';
  }
}

class _Tema extends StatelessWidget {
  const _Tema({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => MediaQuery(data: const MediaQueryData(), child: Theme(data: siscanTheme(Brightness.dark), child: Directionality(textDirection: TextDirection.ltr, child: child)));
}

/// HomeWidget del sistema: degradado bosque, símbolo claro, lote y punto en vivo; 2×2 con la cifra grande y 4×2 con el
/// anillo y tres datos (temperatura, humedad relativa y predicción de la tesis).
class WidgetHome extends StatelessWidget {
  const WidgetHome({super.key, required this.base, required this.chico});
  final Base base;
  final bool chico;
  @override
  Widget build(BuildContext context) {
    final c = SiscanColors.oscuro;
    final l = base.lote, hum = (l?['lastMoisturePct'] as num?)?.toDouble();
    final vivo = base.estado.$1 != Estado.offline;
    final temp = base.ultima('TEMPERATURE_TOPE'), hr = base.ultima('HUMIDITY_TOPE');
    Widget dato(String ic, String t) => Row(children: [Icono(ic, size: 14, color: c.lima), const SizedBox(width: 6), Flexible(child: Text(t, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFF4F2EA))))]);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: LinearGradient(begin: const Alignment(-.5, -1), end: const Alignment(.5, 1), colors: [const Color(0xFF23422F), c.bosqueHondo])),
      child: DefaultTextStyle(
        style: const TextStyle(fontFamily: SiscanType.ui, color: Color(0xFFF4F2EA), decoration: TextDecoration.none),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Image.asset('assets/sistema/marca/siscan-simbolo-claro.png', width: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(l?['name'] as String? ?? 'SISCAN', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700))),
            PuntoVivo(color: c.broteVivo, vivo: false, hueco: !vivo),
          ]),
          const SizedBox(height: 10),
          if (chico) ...[
            const Spacer(),
            Text(hum == null ? '—' : '${cifra(hum)} %', style: const TextStyle(fontFamily: SiscanType.display, fontSize: 34, height: 38 / 34, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(vivo ? 'humedad del grano' : 'sin conexión · ${dia(base.ultimaT)}', style: const TextStyle(fontSize: 12, color: Color(0xFFC8D6CD))),
          ] else Expanded(child: Row(children: [
            Anillo(valor: l == null ? 0 : avanceLote(l), texto: hum == null ? '—' : '${cifra(hum)} %', size: 84, grosor: 8, pista: Colors.white.withValues(alpha: .14), colorTexto: Colors.white),
            const SizedBox(width: 16),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              dato('termometro', temp == null ? '— °C' : '${cifra(temp.$2)} °C'),
              const SizedBox(height: 6),
              dato('gotas', hr == null ? '— % HR' : '${cifra(hr.$2, 0)} % HR'),
              const SizedBox(height: 6),
              dato('reloj', !vivo ? 'Sin conexión · ${dia(base.ultimaT)}' : l?['status'] == 'RUNNING' ? 'Secando' : 'Lote terminado'),
            ])),
          ])),
        ]),
      ),
    );
  }
}
