import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Procedencia de un dato. Ninguna cifra aparece sin ella; el chip lleva el mismo trazo que el dato en los gráficos.
enum Provenance { medido, estimado, prediccion, objetivo, desactualizado, noDisponible }

extension ProvenanceText on Provenance {
  String get word => switch (this) {
        Provenance.medido => 'Medido',
        Provenance.estimado => 'Estimado',
        Provenance.prediccion => 'Predicción',
        Provenance.objetivo => 'Objetivo',
        Provenance.desactualizado => 'Desactualizado',
        Provenance.noDisponible => 'No disponible',
      };
}

({Color ink, Color bg, Color swatch, Color line}) provenanceStyle(SiscanTokens t, Provenance k) => switch (k) {
      Provenance.medido => (ink: t.tierra, bg: t.arena, swatch: t.tierra, line: t.papel),
      Provenance.estimado => (ink: t.bruma, bg: t.brumaSuave, swatch: t.bruma, line: t.papel),
      Provenance.prediccion => (ink: t.anil, bg: t.anilSuave, swatch: t.anil, line: t.papel),
      Provenance.objetivo => (ink: t.cafeto, bg: t.cafetoSuave, swatch: t.cafeto, line: t.papel),
      Provenance.desactualizado => (ink: t.tierraSuave, bg: t.arena, swatch: t.papel, line: t.tierraSuave),
      Provenance.noDisponible => (ink: t.tierraSuave, bg: t.papel, swatch: t.papel, line: t.tierraSuave),
    };

/// Chip de procedencia: miniatura del trazo + palabra (+ fuente opcional: «DHT22 · hace 3 s»).
class ProvenanceChip extends StatelessWidget {
  const ProvenanceChip(this.kind, {super.key, this.label, this.source});
  final Provenance kind;
  final String? label, source;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final st = provenanceStyle(t, kind);
    final text = SiscanType.tabla.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: st.ink, height: 1.1);
    return Container(
      padding: const EdgeInsets.fromLTRB(3, 3, 8, 3),
      decoration: BoxDecoration(
        color: st.bg,
        borderRadius: BorderRadius.circular(SiscanRadius.etiqueta),
        border: kind == Provenance.noDisponible ? null : Border.all(color: Color.lerp(st.bg, st.ink, .25)!),
      ),
      foregroundDecoration: kind == Provenance.noDisponible ? _DashedBorder(color: t.lineaFuerte) : null,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 34, height: 20,
          decoration: BoxDecoration(color: st.swatch, borderRadius: BorderRadius.circular(3)),
          child: CustomPaint(painter: ProvenanceStroke(kind, st.line, hatch: kind == Provenance.desactualizado ? t.arena : null)),
        ),
        const SizedBox(width: 6),
        Text(label ?? kind.word, style: text),
        if (source != null) ...[
          Container(width: 1, height: 14, margin: const EdgeInsets.symmetric(horizontal: 7), color: st.ink.withValues(alpha: .35)),
          Text(source!, style: text.copyWith(fontWeight: FontWeight.w400)),
        ],
      ]),
    );
  }
}

/// El trazo de cada procedencia (el mismo que usan los gráficos): continuo con puntos, discontinuo, punteado, raya-punto.
class ProvenanceStroke extends CustomPainter {
  ProvenanceStroke(this.kind, this.color, {this.hatch});
  final Provenance kind;
  final Color color;
  final Color? hatch;

  @override
  void paint(Canvas c, Size s) {
    c.clipRRect(RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(3)));
    final p = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final pts = [Offset(s.width * .15, s.height * .72), Offset(s.width * .42, s.height * .45), Offset(s.width * .6, s.height * .56), Offset(s.width * .86, s.height * .26)];
    if (hatch != null) {
      final h = Paint()..color = hatch!..strokeWidth = 1.2;
      for (double x = -s.height; x < s.width; x += 5) {
        c.drawLine(Offset(x, s.height), Offset(x + s.height, 0), h);
      }
    }
    switch (kind) {
      case Provenance.medido:
        c.drawPath(Path()..addPolygon(pts, false), p);
        for (final q in [pts[1], pts[3]]) {
          c.drawCircle(q, 1.8, Paint()..color = color);
        }
      case Provenance.estimado:
        _dash(c, pts, p, 4, 3);
        c.drawRect(Rect.fromCenter(center: pts[2], width: 4, height: 4), Paint()..color = color);
      case Provenance.prediccion:
        c.drawLine(pts[0], pts[1], p);
        _dash(c, pts.sublist(1), p..strokeWidth = 2.2, 1, 3.2);
      case Provenance.objetivo:
        final y = s.height * .62;
        _dash(c, [Offset(s.width * .1, y), Offset(s.width * .7, y)], p, 5, 2.5);
        c.drawLine(Offset(s.width * .78, y + 4), Offset(s.width * .78, s.height * .18), p);
        c.drawPath(Path()..moveTo(s.width * .78, s.height * .18)..lineTo(s.width * .94, s.height * .28)..lineTo(s.width * .78, s.height * .4)..close(), Paint()..color = color);
      case Provenance.desactualizado:
        c.drawPath(Path()..addPolygon(pts.sublist(0, 3), false), p);
        _dash(c, [pts[2], pts[3]], p, 1.5, 2.5);
      case Provenance.noDisponible:
        final y = s.height * .5;
        _dash(c, [Offset(s.width * .08, y), Offset(s.width * .92, y)], p, 2, 2.5);
        c.drawLine(Offset(s.width * .4, s.height * .25), Offset(s.width * .6, s.height * .75), p);
        c.drawLine(Offset(s.width * .6, s.height * .25), Offset(s.width * .4, s.height * .75), p);
    }
  }

  void _dash(Canvas c, List<Offset> pts, Paint p, double on, double off) {
    final path = Path()..addPolygon(pts, false);
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += on + off) {
        c.drawPath(m.extractPath(d, (d + on).clamp(0, m.length)), p);
      }
    }
  }

  @override
  bool shouldRepaint(ProvenanceStroke o) => o.kind != kind || o.color != color;
}

class _DashedBorder extends Decoration {
  const _DashedBorder({required this.color});
  final Color color;
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _DashedPainter(color);
}

class _DashedPainter extends BoxPainter {
  _DashedPainter(this.color);
  final Color color;
  @override
  void paint(Canvas c, Offset o, ImageConfiguration cfg) {
    final r = RRect.fromRectAndRadius((o & cfg.size!).deflate(.5), const Radius.circular(SiscanRadius.etiqueta));
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1;
    for (final ui.PathMetric m in (Path()..addRRect(r)).computeMetrics()) {
      for (double d = 0; d < m.length; d += 7) {
        c.drawPath(m.extractPath(d, d + 4), p);
      }
    }
  }
}
