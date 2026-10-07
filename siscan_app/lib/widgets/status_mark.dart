import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Estados del sistema: el estado nunca depende solo del color (glifo + palabra).
enum SiscanStatus { normal, advertencia, critico, error, sinConexion, desactualizado, resuelta, info, apagado }

enum StatusVariant { suave, solido, linea }

({Color tone, Color soft, String word}) statusStyle(SiscanTokens t, SiscanStatus s) => switch (s) {
      SiscanStatus.normal => (tone: t.cafeto, soft: t.cafetoSuave, word: 'Normal'),
      SiscanStatus.advertencia => (tone: t.panela, soft: t.panelaSuave, word: 'Advertencia'),
      SiscanStatus.critico => (tone: t.oxido, soft: t.oxidoSuave, word: 'Crítico'),
      SiscanStatus.error => (tone: t.oxido, soft: t.oxidoSuave, word: 'Error'),
      SiscanStatus.sinConexion => (tone: t.tierraSuave, soft: t.arena, word: 'Sin conexión'),
      SiscanStatus.desactualizado => (tone: t.tierraSuave, soft: t.arena, word: 'Desactualizado'),
      SiscanStatus.resuelta => (tone: t.tierraSuave, soft: t.arena, word: 'Resuelta'),
      SiscanStatus.info => (tone: t.bruma, soft: t.brumaSuave, word: 'Informativa'),
      SiscanStatus.apagado => (tone: t.tierraSuave, soft: t.arena, word: 'Apagado'),
    };

/// Glifo de estado dibujado (✓ círculo, ▲ advertencia, ■ "!" crítico, ⊘ sin conexión, reloj, punto informativo).
class StatusGlyph extends StatelessWidget {
  const StatusGlyph(this.status, {super.key, required this.color, required this.ink, this.size = 16});
  final SiscanStatus status;
  final Color color; // relleno del sello
  final Color ink; // trazo interior
  final double size;
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _GlyphPainter(status, color, ink));
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.s, this.fill, this.ink);
  final SiscanStatus s;
  final Color fill, ink;
  @override
  void paint(Canvas c, Size z) {
    final w = z.width, r = w / 2, ctr = Offset(r, r);
    final f = Paint()..color = fill;
    final p = Paint()..color = ink..style = PaintingStyle.stroke..strokeWidth = w * .12..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final dot = Paint()..color = ink;
    void bang(double top, double bottom) {
      c.drawLine(Offset(r, top), Offset(r, bottom), p);
      c.drawCircle(Offset(r, w * .74), w * .065, dot);
    }
    switch (s) {
      case SiscanStatus.advertencia:
        final tri = Path()..moveTo(r, w * .06)..lineTo(w * .97, w * .9)..lineTo(w * .03, w * .9)..close();
        c.drawPath(tri, f..strokeJoin = StrokeJoin.round);
        bang(w * .36, w * .56);
      case SiscanStatus.critico || SiscanStatus.error:
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .06, w * .06, w * .88, w * .88), Radius.circular(w * .14)), f);
        bang(w * .26, w * .5);
      case SiscanStatus.sinConexion:
        c.drawCircle(ctr, r, f);
        c.drawLine(Offset(w * .3, w * .7), Offset(w * .7, w * .3), p);
      case SiscanStatus.desactualizado:
        c.drawCircle(ctr, r, f);
        c.drawLine(ctr, Offset(r, w * .28), p);
        c.drawLine(ctr, Offset(w * .68, w * .6), p);
      case SiscanStatus.apagado:
        // Actuador apagado: aro vacío (en reposo), nunca un visto bueno.
        c.drawCircle(ctr, r, f);
        c.drawCircle(ctr, w * .22, Paint()..color = ink..style = PaintingStyle.stroke..strokeWidth = w * .12);
      case SiscanStatus.info:
        c.drawCircle(ctr, r, f);
        c.drawCircle(ctr, w * .2, dot);
      case SiscanStatus.normal || SiscanStatus.resuelta:
        c.drawCircle(ctr, r, f);
        final ck = Path()..moveTo(w * .29, w * .52)..lineTo(w * .44, w * .66)..lineTo(w * .72, w * .36);
        c.drawPath(ck, p);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter o) => o.s != s || o.fill != fill || o.ink != ink;
}

/// Sello de estado: glifo + palabra. Suave (por defecto), sólido (cuando el estado ES el mensaje) o en línea.
class StatusMark extends StatelessWidget {
  const StatusMark(this.status, {super.key, this.variant = StatusVariant.suave, this.label, this.detail, this.large = false});
  final SiscanStatus status;
  final StatusVariant variant;
  final String? label, detail;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final st = statusStyle(t, status);
    final word = label ?? st.word;
    final fs = large ? 18.0 : 14.0;
    final g = large ? 22.0 : 16.0;
    final text = SiscanType.cuerpoFuerte.copyWith(fontSize: fs, height: 1.2);
    final detailStyle = SiscanType.tabla.copyWith(fontSize: fs - 1);
    if (variant == StatusVariant.linea) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        StatusGlyph(status, color: st.tone, ink: t.papel, size: g),
        const SizedBox(width: 6),
        Text(word, style: text.copyWith(color: st.tone)),
      ]);
    }
    final solid = variant == StatusVariant.solido;
    final fg = solid ? t.papel : st.tone;
    return Semantics(
      label: word + (detail != null ? ', $detail' : ''),
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.fromLTRB(5, large ? 7 : 4, large ? 18 : 12, large ? 7 : 4),
        decoration: BoxDecoration(
          color: solid ? st.tone : st.soft,
          borderRadius: BorderRadius.circular(SiscanRadius.grano),
          border: solid
              ? Border(bottom: BorderSide(color: Color.lerp(st.tone, t.tierra, .45)!, width: 3))
              : Border.all(color: Color.lerp(st.soft, st.tone, .3)!, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: g + 6, height: g + 6, alignment: Alignment.center,
            decoration: BoxDecoration(color: solid ? Color.lerp(st.tone, t.papel, .25) : t.papel, shape: BoxShape.circle),
            child: StatusGlyph(status, color: solid ? t.papel : st.tone, ink: solid ? st.tone : t.papel, size: g * .8),
          ),
          const SizedBox(width: 7),
          Text(word, style: text.copyWith(color: fg)),
          if (detail != null) ...[
            Container(width: 1, height: fs, margin: const EdgeInsets.symmetric(horizontal: 8), color: fg.withValues(alpha: .4)),
            Text(detail!, style: detailStyle.copyWith(color: fg)),
          ],
        ]),
      ),
    );
  }
}

/// Utilidad de los glifos y gráficos: punto en un círculo.
Offset onCircle(Offset c, double r, double a) => Offset(c.dx + r * cos(a), c.dy + r * sin(a));
