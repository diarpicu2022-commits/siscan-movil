/// Componentes de datos del sistema SISCAN v2: Sparkline, ReadingTile, RingGauge, MoistureChart, EnergyCard,
/// PredictionCard, ProcessTimeline y MoistureScale (02-datos: reglas de gráfica).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/siscan_theme.dart';
import '../theme/siscan_tokens.dart';
import 'base.dart';

Path _suave(List<Offset> p) {
  final d = Path()..moveTo(p.first.dx, p.first.dy);
  for (var i = 1; i < p.length; i++) {
    final a = p[i - 1], b = p[i], mx = (a.dx + b.dx) / 2;
    d.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
  }
  return d;
}

/// Sparkline: línea de 24 h en el color de la magnitud con área al 12 % y último punto marcado.
class LineaTendencia extends StatelessWidget {
  const LineaTendencia({super.key, required this.datos, required this.color, this.alto = 28, this.vivo = false});
  final List<double> datos;
  final Color color;
  final double alto;
  final bool vivo;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: alto,
        child: datos.length < 2 ? null : CustomPaint(size: Size.infinite, painter: _Tendencia(datos, color, context.c.superficie)),
      );
}

class _Tendencia extends CustomPainter {
  _Tendencia(this.d, this.c, this.sup);
  final List<double> d;
  final Color c, sup;
  @override
  void paint(Canvas canvas, Size s) {
    final mn = d.reduce(math.min), mx = d.reduce(math.max), r = (mx - mn) == 0 ? 1 : mx - mn;
    const pad = 3.0;
    final p = [for (var i = 0; i < d.length; i++) Offset(pad + i / (d.length - 1) * (s.width - 2 * pad), pad + (1 - (d[i] - mn) / r) * (s.height - 2 * pad))];
    final linea = _suave(p);
    final area = Path.from(linea)..lineTo(p.last.dx, s.height)..lineTo(p.first.dx, s.height)..close();
    canvas.drawPath(area, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.withValues(alpha: .24), c.withValues(alpha: 0)]).createShader(Offset.zero & s));
    canvas.drawPath(linea, Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round);
    canvas.drawCircle(p.last, 5, Paint()..color = sup);
    canvas.drawCircle(p.last, 4, Paint()..color = c);
  }
  @override
  bool shouldRepaint(_Tendencia o) => o.d != d || o.c != c;
}

/// ReadingTile: ícono teñido, rótulo, lectura 24 y tendencia.
class LecturaTile extends StatelessWidget {
  const LecturaTile({super.key, required this.rotulo, required this.magnitud, required this.icono, this.valor, this.texto, this.unidad = '', this.decimales = 1, this.datos, this.vivo = false, this.sub});
  final String rotulo, magnitud, icono, unidad;
  final double? valor;
  final String? texto, sub;
  final int decimales;
  final List<double>? datos;
  final bool vivo;
  @override
  Widget build(BuildContext context) {
    final c = context.c, col = tono(c, magnitud);
    return Semantics(container: true, 
      label: '$rotulo: ${texto ?? cifra(valor, decimales)} $unidad${sub != null ? '. $sub' : ''}',
      child: ExcludeSemantics(child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: c.superficie, border: Border.all(color: c.linea), borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 30, height: 30, alignment: Alignment.center, decoration: BoxDecoration(color: mezcla(col, .13, c.superficie), borderRadius: BorderRadius.circular(10)),
              child: Icono(icono, size: 18, color: col)),
          const SizedBox(height: 4),
          Text(rotulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.tintaSuave)),
          const SizedBox(height: 4),
          Text.rich(TextSpan(children: [
            TextSpan(text: texto ?? cifra(valor, decimales), style: SiscanType.lectura.copyWith(fontSize: 24, height: 28 / 24, color: c.tinta)),
            TextSpan(text: ' $unidad', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.tintaSuave)),
          ])),
          if (sub != null) Text(sub!, maxLines: 2, style: TextStyle(fontSize: 11.5, color: c.tintaSuave)),
          if (datos != null && datos!.length > 1) Padding(padding: const EdgeInsets.only(top: 2), child: LineaTendencia(datos: datos!, color: col, vivo: vivo)),
        ]),
      )),
    );
  }
}

/// RingGauge: anillo de avance con banda objetivo opcional y texto al centro.
class Anillo extends StatelessWidget {
  const Anillo({super.key, required this.valor, required this.texto, this.rotulo, this.size = 132, this.grosor, this.color, this.color2, this.pista, this.colorTexto, this.colorRotulo});
  final double valor;
  final String texto;
  final String? rotulo;
  final double size;
  final double? grosor;
  final Color? color, color2, pista, colorTexto, colorRotulo;
  @override
  Widget build(BuildContext context) {
    final c = context.c, sw = grosor ?? math.max(8, (size / 11).roundToDouble());
    return Semantics(container: true, 
      label: '${rotulo ?? ''} $texto'.trim(), value: '${valor.clamp(0, 100).round()} % del avance',
      // La etiqueta ya dice cifra y rótulo: los textos dibujados dentro no se leen dos veces.
      child: ExcludeSemantics(child: SizedBox(width: size, height: size, child: Stack(alignment: Alignment.center, children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: valor.clamp(0, 100) / 100), duration: context.sinMovimiento ? Duration.zero : SiscanMotion.lenta, curve: SiscanMotion.entrada,
          builder: (_, v, _) => CustomPaint(size: Size.square(size), painter: _Anillo(v, sw, pista ?? c.superficieFuerte, color ?? c.broteVivo, color2 ?? c.lima)),
        ),
        Padding(
          padding: EdgeInsets.all(sw + 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            FittedBox(child: Text(texto, style: TextStyle(fontSize: math.max(16, (size / 5.4).roundToDouble()), height: 1.12, fontWeight: FontWeight.w800, letterSpacing: -.3,
                fontFeatures: const [FontFeature.tabularFigures()], color: colorTexto ?? c.tinta))),
            if (rotulo != null) Text(rotulo!, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w600, color: colorRotulo ?? c.tintaSuave)),
          ]),
        ),
      ]))),
    );
  }
}

class _Anillo extends CustomPainter {
  _Anillo(this.v, this.sw, this.pista, this.c1, this.c2);
  final double v, sw;
  final Color pista, c1, c2;
  @override
  void paint(Canvas canvas, Size s) {
    final r = Rect.fromCircle(center: s.center(Offset.zero), radius: (s.width - sw) / 2);
    canvas.drawArc(r, 0, math.pi * 2, false, Paint()..color = pista..style = PaintingStyle.stroke..strokeWidth = sw);
    if (v <= 0) return;
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, Paint()
      ..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, c2]).createShader(r)
      ..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_Anillo o) => o.v != v || o.c1 != c1;
}

/// MoistureChart: curva del grano con área 24 % → 0 %, banda objetivo 10–12 %, puntos y última etiqueta en bosque;
/// la predicción (si la hay) sigue punteada en violeta.
class CurvaHumedad extends StatelessWidget {
  const CurvaHumedad({super.key, required this.datos, required this.etiquetas, this.prediccion = const [], this.alto = 250, this.resumen});
  final List<double> datos, prediccion;
  final List<String> etiquetas;
  final double alto;
  final String? resumen;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (datos.length < 2) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Text(datos.isEmpty ? 'Sin pesajes todavía: la curva aparece con la primera muestra gravimétrica.' : 'Un solo pesaje: la curva aparece con el segundo.',
          style: TextStyle(fontSize: 14, color: c.tintaSuave)));
    }
    final texto = resumen ?? 'La humedad del grano bajó de ${cifra(datos.first)} % a ${cifra(datos.last)} %; objetivo 10 – 12 %.';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Semantics(container: true, label: texto, child: SizedBox(height: alto, width: double.infinity, child: CustomPaint(painter: _Curva(datos, prediccion, etiquetas, c)))),
      const SizedBox(height: 12),
      Wrap(spacing: 16, runSpacing: 6, children: [
        _Leyenda(muestra: Container(width: 12, height: 8, decoration: BoxDecoration(color: c.datoGrano, borderRadius: BorderRadius.circular(2))), texto: 'Humedad del grano (gravimétrico)'),
        if (prediccion.isNotEmpty) _Leyenda(muestra: SizedBox(width: 12, child: Divider(color: c.prediccion, thickness: 2)), texto: 'Predicción IA'),
        _Leyenda(muestra: SizedBox(width: 12, child: Divider(color: c.objetivo, thickness: 2)), texto: 'Objetivo'),
      ]),
    ]);
  }
}

class _Leyenda extends StatelessWidget {
  const _Leyenda({required this.muestra, required this.texto});
  final Widget muestra;
  final String texto;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [muestra, const SizedBox(width: 6), Text(texto, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.c.tintaSuave))]);
}

class _Curva extends CustomPainter {
  _Curva(this.d, this.pred, this.et, this.c);
  final List<double> d, pred;
  final List<String> et;
  final SiscanColors c;
  TextPainter _t(String s, TextStyle st) => TextPainter(text: TextSpan(text: s, style: st), textDirection: TextDirection.ltr)..layout();
  @override
  void paint(Canvas canvas, Size s) {
    const l = 40.0, r = 14.0, t = 22.0, b = 30.0;
    final todos = d.length + pred.length;
    final maxV = math.max(55.0, ((d.reduce(math.max) / 10).ceil() * 10).toDouble());
    double x(int i) => l + i / (todos - 1) * (s.width - l - r);
    double y(double v) => t + (1 - v / maxV) * (s.height - t - b);
    final eje = TextStyle(fontSize: 11, color: c.tintaSuave, fontFamily: SiscanType.ui);
    for (var tk = 0.0; tk <= maxV; tk += maxV > 30 ? 10 : 5) {
      canvas.drawLine(Offset(l, y(tk)), Offset(s.width - r, y(tk)), Paint()..color = c.linea);
      final tp = _t('${tk.round()} %', eje);
      tp.paint(canvas, Offset(l - 8 - tp.width, y(tk) - tp.height / 2));
    }
    canvas.drawRect(Rect.fromLTRB(l, y(12), s.width - r, y(10)), Paint()..color = c.objetivo.withValues(alpha: .14));
    final dash = Paint()..color = c.objetivo..strokeWidth = 1.6;
    for (var xx = l; xx < s.width - r; xx += 11) { canvas.drawLine(Offset(xx, y(12)), Offset(math.min(xx + 6, s.width - r), y(12)), dash); }
    final obj = _t('Objetivo 10 – 12 %', TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.objetivo, fontFamily: SiscanType.ui));
    obj.paint(canvas, Offset(l + 6, y(12) - obj.height - 3));
    final q = [for (var i = 0; i < d.length; i++) Offset(x(i), y(d[i]))];
    final linea = _suave(q);
    final area = Path.from(linea)..lineTo(q.last.dx, y(0))..lineTo(q.first.dx, y(0))..close();
    canvas.drawPath(area, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.datoGrano.withValues(alpha: .24), c.datoGrano.withValues(alpha: 0)]).createShader(Offset.zero & s));
    canvas.drawPath(linea, Paint()..color = c.datoGrano..style = PaintingStyle.stroke..strokeWidth = 2.8..strokeCap = StrokeCap.round);
    if (pred.isNotEmpty) {
      final pq = [q.last, for (var i = 0; i < pred.length; i++) Offset(x(d.length + i), y(pred[i]))];
      final pp = _suave(pq);
      for (final m in pp.computeMetrics()) { for (var dd = 0.0; dd < m.length; dd += 8) { canvas.drawPath(m.extractPath(dd, dd + 2), Paint()..color = c.prediccion..style = PaintingStyle.stroke..strokeWidth = 2.4..strokeCap = StrokeCap.round); } }
      canvas.drawCircle(pq.last, 4.5, Paint()..color = c.superficie);
      canvas.drawCircle(pq.last, 4.5, Paint()..color = c.prediccion..style = PaintingStyle.stroke..strokeWidth = 2.4);
    }
    for (var i = 0; i < q.length; i++) {
      final ult = i == q.length - 1;
      canvas.drawCircle(q[i], ult ? 6 : 3.6, Paint()..color = ult ? c.datoGrano : c.superficie);
      canvas.drawCircle(q[i], ult ? 6 : 3.6, Paint()..color = ult ? c.superficie : c.datoGrano..style = PaintingStyle.stroke..strokeWidth = ult ? 3 : 2);
    }
    // Etiquetas del eje x sin encimarse: si dos chocan se omite la anterior (la última siempre queda).
    final marcas = <(TextPainter, double)>[];
    for (var i = 0; i < et.length && i < todos; i++) {
      if (et[i].isEmpty) continue;
      final tp = _t(et[i], eje);
      final px = (x(i) - tp.width / 2).clamp(0.0, s.width - tp.width);
      while (marcas.isNotEmpty && marcas.last.$2 + marcas.last.$1.width + 8 > px) { marcas.removeLast(); }
      marcas.add((tp, px));
    }
    for (final (tp, px) in marcas) { tp.paint(canvas, Offset(px, s.height - tp.height - 4)); }
    final tag = _t('${cifra(d.last)} %', TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c.sobreBosque, fontFamily: SiscanType.ui));
    final cx = math.min(q.last.dx, s.width - r - 34), cy = math.max(18.0, q.last.dy - 30);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: math.max(64, tag.width + 16), height: 26), const Radius.circular(8)), Paint()..color = c.bosque);
    tag.paint(canvas, Offset(cx - tag.width / 2, cy - tag.height / 2));
  }
  @override
  bool shouldRepaint(_Curva o) => o.d != d || o.c != c;
}

/// EnergyCard: solar, red y costo; barras por hora (solar abajo en degradado, red arriba).
class TarjetaEnergia extends StatelessWidget {
  const TarjetaEnergia({super.key, this.titulo = 'Consumo energético y costo', this.solar, this.red, this.costo, this.tarifa, this.barras = const [], this.derecha, this.nota});
  final String titulo;
  final double? solar, red, costo, tarifa;
  final List<(String, double, double)> barras;
  final Widget? derecha;
  final String? nota;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final mx = barras.isEmpty ? 1.0 : math.max(1e-9, barras.map((b) => b.$2 + b.$3).reduce(math.max));
    Widget stat(String k, String ic, Color col, String v, String u, Color fondo) => (Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icono(ic, size: 16, color: col), const SizedBox(width: 6), Flexible(child: Text(k, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: col)))]),
            const SizedBox(height: 4),
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text.rich(TextSpan(children: [
              TextSpan(text: v, style: TextStyle(fontSize: 17, height: 22 / 17, fontWeight: FontWeight.w800, color: c.tinta, fontFeatures: const [FontFeature.tabularFigures()])),
              TextSpan(text: ' $u', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: c.tintaSuave)),
            ]))),
          ]),
        ));
    final stats = [
      stat('Solar', 'sol', c.datoSolar, cifra(solar), 'kWh', c.superficieHoja),
      stat('Red eléctrica', 'enchufe', c.datoExterior, cifra(red, 2), 'kWh', c.fondo),
      stat('Costo', 'moneda', c.tintaSuave, dinero(costo), 'COP', c.fondo),
    ];
    return Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TituloTarjeta(icono: 'rayo', titulo: titulo, derecha: derecha),
      // .sc-energy-stats: grid auto-fit minmax(110px, 1fr), gap 12 → tantas columnas como quepan de 110 px.
      LayoutBuilder(builder: (context, k) {
        const gap = SiscanSpace.s3, minimo = 110.0;
        final cols = ((k.maxWidth + gap) / (minimo + gap)).floor().clamp(1, stats.length);
        final ancho = (k.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(spacing: gap, runSpacing: gap, children: [for (final w in stats) SizedBox(width: ancho, child: w)]);
      }),
      const SizedBox(height: 16),
      if (barras.isNotEmpty) Semantics(container: true, 
        label: 'Energía por periodo: solar abajo, red eléctrica arriba',
        child: SizedBox(height: 110, child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final (i, b) in barras.indexed) Expanded(child: Column(children: [
            Expanded(child: Align(alignment: Alignment.bottomCenter, child: SizedBox(width: 9, child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (b.$3 > 0) Flexible(flex: math.max(1, (b.$3 / mx * 1000).round()), child: Container(decoration: BoxDecoration(color: c.datoElectrica.withValues(alpha: .9), borderRadius: BorderRadius.circular(5)))),
              if (b.$3 > 0 && b.$2 > 0) const SizedBox(height: 2),
              if (b.$2 > 0) Flexible(flex: math.max(1, (b.$2 / mx * 1000).round()), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.lima, c.broteVivo])))),
              if (b.$2 + b.$3 < mx) Spacer(flex: math.max(1, ((mx - b.$2 - b.$3) / mx * 1000).round())),
            ])))),
            const SizedBox(height: 5),
            SizedBox(height: 15, child: OverflowBox(maxWidth: 60, child: Text(i % (barras.length > 12 ? 4 : 1) == 0 ? b.$1 : '', softWrap: false, style: TextStyle(fontSize: 11, color: c.tintaSuave)))),
          ])),
        ])),
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 16, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
        _Leyenda(muestra: Container(width: 12, height: 8, decoration: BoxDecoration(color: c.datoSolarRelleno, borderRadius: BorderRadius.circular(2))), texto: 'Solar'),
        _Leyenda(muestra: Container(width: 12, height: 8, decoration: BoxDecoration(color: c.datoElectrica, borderRadius: BorderRadius.circular(2))), texto: 'Red eléctrica'),
        if (tarifa != null) Text('Tarifa ${dinero(tarifa)}/kWh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.tintaSuave)),
      ]),
      if (nota != null) Pie(nota!),
    ]));
  }
}

/// PredictionCard: tiempo restante en Outfit, rango, confianza y datos considerados.
class TarjetaPrediccion extends StatelessWidget {
  const TarjetaPrediccion({super.key, required this.valor, this.rango, this.confianza, this.ficha = 'Modelo de la tesis', this.entradas = const [], this.compacta = false, this.pie});
  final String valor;
  final Widget? rango;
  final int? confianza;
  final String ficha;
  final List<(String, String)> entradas;
  final bool compacta;
  final String? pie;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final conf = confianza == null ? null : confianza! >= 75 ? 'alta' : confianza! >= 50 ? 'media' : 'baja';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: c.linea), borderRadius: BorderRadius.circular(SiscanRadius.lg), boxShadow: context.sombraTarjeta,
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0, .6], colors: [mezcla(c.prediccion, .07, c.superficie), c.superficie])),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TituloTarjeta(icono: 'ia', titulo: 'Predicción de IA', derecha: Ficha(conf != null ? 'Confianza $conf' : ficha, tono: 'pred')),
        Text('Tiempo restante estimado', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.tintaSuave)),
        const SizedBox(height: 2),
        Text(valor, style: TextStyle(fontFamily: SiscanType.display, fontSize: 34, height: 40 / 34, fontWeight: FontWeight.w700, color: c.tinta)),
        const SizedBox(height: 2),
        if (rango != null) DefaultTextStyle(style: TextStyle(fontSize: 13, color: c.tintaSuave, fontFamily: SiscanType.ui), child: rango!),
        if (confianza != null) ...[
          const SizedBox(height: 16),
          Row(children: [Expanded(child: Text('Confianza de la predicción', style: TextStyle(fontSize: 12.5, color: c.tintaSuave))), Text('$confianza %', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.prediccion))]),
          const SizedBox(height: 6),
          Progreso(valor: confianza!.toDouble(), prediccion: true, etiqueta: 'Confianza de la predicción'),
        ],
        if (!compacta && entradas.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Datos considerados', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.tintaSuave)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final e in entradas) Ficha(e.$1, tono: 'neutral', icono: e.$2)]),
        ],
        if (pie != null) Pie(pie!),
      ]),
    );
  }
}

enum EstadoFase { hecha, ahora, pendiente }

/// ProcessTimeline (vertical en el móvil): fases con ✓ y hora, la actual con halo y «En curso».
class Fases extends StatelessWidget {
  const Fases({super.key, required this.fases});
  final List<(String, EstadoFase, String)> fases;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(container: true, 
      label: 'Proceso del lote',
      child: Column(children: [
        for (final (i, f) in fases.indexed) IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(width: 24, child: Stack(alignment: Alignment.topCenter, children: [
            if (i < fases.length - 1) Positioned(top: 12, bottom: -12, child: Container(width: 3, color: f.$2 == EstadoFase.pendiente || fases[i + 1].$2 == EstadoFase.pendiente ? c.superficieFuerte : c.hoja)),
            Container(width: 24, height: 24, alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: f.$2 == EstadoFase.hecha ? c.hoja : c.superficie,
                  border: Border.all(color: f.$2 == EstadoFase.pendiente ? c.superficieFuerte : c.hoja, width: 3),
                  boxShadow: f.$2 == EstadoFase.ahora ? [BoxShadow(color: c.brote, spreadRadius: 5)] : null),
              child: f.$2 == EstadoFase.hecha ? const Icono('check', size: 12, color: Colors.white) : f.$2 == EstadoFase.ahora ? Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: c.hoja)) : null),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(f.$1, style: TextStyle(fontSize: 14, fontWeight: f.$2 == EstadoFase.ahora ? FontWeight.w800 : FontWeight.w600, color: f.$2 == EstadoFase.ahora ? c.hoja : f.$2 == EstadoFase.hecha ? c.tinta : c.tintaSuave)),
            Text(f.$3, style: TextStyle(fontSize: 11.5, fontWeight: f.$2 == EstadoFase.ahora ? FontWeight.w600 : FontWeight.w400, color: f.$2 == EstadoFase.ahora ? c.hoja : c.tintaSuave)),
          ]))),
        ])),
      ]),
    );
  }
}

/// MoistureScale: barra de húmedo a sobresecado con la zona objetivo y la marca del valor actual.
class EscalaHumedad extends StatelessWidget {
  const EscalaHumedad({super.key, required this.valor});
  final double valor;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    const lo = 6.0, hi = 56.0;
    double pos(double x) => (1 - (x - lo) / (hi - lo)).clamp(0, 1).toDouble();
    final zona = valor > 30 ? 'Húmedo' : valor > 20 ? 'Oreado' : valor > 12 ? 'Secando' : valor >= 10 ? 'Objetivo alcanzado' : 'Sobresecado';
    return Semantics(container: true, 
      label: 'Escala de humedad: ${cifra(valor)} %, zona $zona',
      child: ExcludeSemantics(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 38),
        LayoutBuilder(builder: (_, k) => SizedBox(height: 14, child: Stack(clipBehavior: Clip.none, children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), gradient: LinearGradient(
              colors: [c.cafe, const Color(0xFF8A5532), c.pergamino, c.pergamino, c.operando, c.operando, c.pausa], stops: const [0, .28, .66, .86, .88, .92, .97]))),
          Positioned(left: pos(12) * k.maxWidth, width: (pos(10) - pos(12)) * k.maxWidth, top: -6, bottom: -6,
              child: Container(decoration: BoxDecoration(border: Border.all(color: c.objetivo, width: 2), borderRadius: BorderRadius.circular(6)))),
          Positioned(left: pos(valor) * k.maxWidth - 2, top: -8, child: Container(width: 4, height: 30, decoration: BoxDecoration(color: c.tinta, borderRadius: BorderRadius.circular(2)))),
          Positioned(left: (pos(valor) * k.maxWidth - 30).clamp(0, k.maxWidth - 60).toDouble(), top: -36, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3), decoration: BoxDecoration(color: c.bosque, borderRadius: BorderRadius.circular(8)),
              child: Text('${cifra(valor)} %', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.sobreBosque)))),
        ]))),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          for (final t in ['Húmedo 53 %', 'Oreado', 'Secando']) Text(t, style: TextStyle(fontSize: 12, color: c.tintaSuave)),
          Text('10 – 12 %', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.operando)),
        ]),
        const SizedBox(height: 8),
        Text.rich(TextSpan(text: 'Zona actual: ', style: TextStyle(fontSize: 14, color: c.tinta), children: [TextSpan(text: zona, style: const TextStyle(fontWeight: FontWeight.w700))])),
      ])),
    );
  }
}
