import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'provenance.dart';
import 'status_mark.dart';

/// Fases automáticas del lecho de humedad.
enum DryingPhase { humedo, secando, cerca, alcanzado }

DryingPhase phaseOf(double current, double target) {
  if (current <= target) return DryingPhase.alcanzado;
  if (current - target <= 2) return DryingPhase.cerca;
  if (current >= 30) return DryingPhase.humedo;
  return DryingPhase.secando;
}

/// Medidor de humedad del café como **lecho de secado**: el agua por retirar (`dato-agua`) se encoge hacia el objetivo
/// sobre un lecho de granos; lo retirado queda punteado; el objetivo es una bandera `cafeto`. Nunca un anillo.
/// Al entrar, la cifra baja desde la humedad inicial hasta la actual en 1.6 s (salta al valor si las animaciones
/// están desactivadas). Tamaño «campo» (móvil): lectura de 76 px, sin leyenda.
class MoistureMeter extends StatelessWidget {
  const MoistureMeter({super.key, required this.current, this.initial = 52, this.target = 11, this.label = 'Humedad del café',
      this.kind = Provenance.medido, this.source});
  final double current, initial, target;
  final String label;
  final Provenance kind;
  final String? source;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final reduce = MediaQuery.of(context).disableAnimations;
    final phase = phaseOf(current, target);
    final (word, status) = switch (phase) {
      DryingPhase.humedo => ('Húmedo', SiscanStatus.info),
      DryingPhase.secando => ('Secando', SiscanStatus.info),
      DryingPhase.cerca => ('Cerca del objetivo', SiscanStatus.advertencia),
      DryingPhase.alcanzado => ('Objetivo alcanzado', SiscanStatus.normal),
    };
    final phaseColor = phase == DryingPhase.alcanzado ? t.cafeto : (phase == DryingPhase.cerca ? t.panela : t.bruma);
    final done = ((initial - current) / (initial - target)).clamp(0.0, 1.0);
    return Semantics(
      label: '$label: ${current.toStringAsFixed(1)} por ciento, objetivo ${target.toStringAsFixed(0)} por ciento, $word',
      value: '${current.toStringAsFixed(1)} %',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: reduce ? current : initial, end: current),
        duration: reduce ? Duration.zero : const Duration(milliseconds: 1600),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rotulo(label), style: SiscanType.etiqueta.copyWith(color: t.tierraSuave)),
          const SizedBox(height: SiscanSpace.s1),
          // La cifra dominante nunca se parte. Si al lado no caben estado, objetivo y procedencia (≈ 150 px),
          // pasan a una fila debajo; en pantallas anchas van a la derecha, como en la referencia.
          LayoutBuilder(builder: (context, box) {
            final number = Text.rich(TextSpan(children: [
              TextSpan(text: v.toStringAsFixed(1), style: SiscanType.lecturaCampo.copyWith(color: t.tierra)),
              TextSpan(text: ' %', style: SiscanType.lecturaS.copyWith(color: t.tierraSuave)),
            ]), key: const Key('moisture-value'), softWrap: false, maxLines: 1);
            final phaseLine = Row(mainAxisSize: MainAxisSize.min, children: [
              StatusGlyph(status, color: phaseColor, ink: t.papel, size: 14),
              const SizedBox(width: 6),
              Text(word, style: SiscanType.cita.copyWith(color: phaseColor, fontWeight: FontWeight.w600)),
            ]);
            final goal = Text.rich(TextSpan(style: SiscanType.nota.copyWith(color: t.tierraSuave), children: [
              const TextSpan(text: 'Objetivo '),
              TextSpan(text: '${target.toStringAsFixed(0)} %', style: SiscanType.tabla.copyWith(color: t.cafeto, fontWeight: FontWeight.w600)),
            ]));
            if (box.maxWidth >= 420) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                number,
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  phaseLine, const SizedBox(height: SiscanSpace.s1), goal, const SizedBox(height: SiscanSpace.s2), ProvenanceChip(kind),
                ]),
              ]);
            }
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              number,
              const SizedBox(height: SiscanSpace.s2),
              Wrap(spacing: SiscanSpace.s3, runSpacing: SiscanSpace.s2, crossAxisAlignment: WrapCrossAlignment.center,
                  children: [phaseLine, goal, ProvenanceChip(kind)]),
            ]);
          }),
          const SizedBox(height: SiscanSpace.s3),
          SizedBox(
            height: 92,
            width: double.infinity,
            child: CustomPaint(painter: _BedPainter(t: t, value: v, target: target, scaleMax: initial <= 55 ? 50 : (initial / 10).ceil() * 10.0, reached: phase == DryingPhase.alcanzado)),
          ),
          const SizedBox(height: SiscanSpace.s1),
          Text('${(done * 100).round()} % del secado completado · desde ${initial.toStringAsFixed(0)} %${source != null ? ' · $source' : ''}',
              style: SiscanType.tabla.copyWith(fontSize: 13, color: t.tierraSuave)),
        ]),
      ),
    );
  }
}

class _BedPainter extends CustomPainter {
  _BedPainter({required this.t, required this.value, required this.target, required this.scaleMax, required this.reached});
  final SiscanTokens t;
  final double value, target, scaleMax;
  final bool reached;

  @override
  void paint(Canvas c, Size s) {
    const top = 22.0, h = 52.0;
    final bed = RRect.fromRectAndRadius(Rect.fromLTWH(0, top, s.width, h), const Radius.circular(h / 2));
    double x(double pct) => (pct / scaleMax).clamp(0, 1) * s.width;

    // Lecho (lo retirado): arena con granos punteados y contorno discontinuo.
    c.drawRRect(bed, Paint()..color = t.arena);
    c.save();
    c.clipRRect(bed);
    final grain = Paint()..color = t.linea;
    for (double gy = top + 7; gy < top + h; gy += 9) {
      final shift = ((gy - top) / 9).floor().isOdd ? 6.0 : 0.0;
      for (double gx = 5 + shift; gx < s.width; gx += 12) {
        c.drawOval(Rect.fromCenter(center: Offset(gx, gy), width: 6, height: 4.2), grain);
      }
    }
    // Agua por retirar: se encoge hacia el objetivo, con borde ondulado (secado vivo).
    final water = t.datoAgua;
    final wx = x(value);
    final wave = Path()..moveTo(0, top);
    wave.lineTo(max(0, wx - 3), top);
    for (double yy = top; yy <= top + h; yy += 4) {
      wave.lineTo(wx + 2.5 * sin(yy / 5), yy);
    }
    wave..lineTo(0, top + h)..close();
    c.drawPath(wave, Paint()..color = reached ? t.cafeto : water);
    // Trama fina del agua (no es un degradado).
    final sheen = Paint()..color = t.papel.withValues(alpha: .10)..strokeWidth = 1;
    for (double xx = -h; xx < wx; xx += 7) {
      c.drawLine(Offset(xx, top + h), Offset(xx + h * .5, top), sheen);
    }
    c.restore();
    // Contorno discontinuo de lo retirado.
    final dashed = Paint()..color = t.lineaFuerte..style = PaintingStyle.stroke..strokeWidth = 1.5;
    for (final m in (Path()..addRRect(bed.deflate(.75))).computeMetrics()) {
      for (double d = 0; d < m.length; d += 9) {
        final seg = m.extractPath(d, d + 5);
        final b = seg.getBounds();
        if (b.center.dx > wx) c.drawPath(seg, dashed);
      }
    }
    // Bandera del objetivo.
    final tx = x(target);
    final flag = Paint()..color = t.cafeto..strokeWidth = 2;
    c.drawLine(Offset(tx, top - 6), Offset(tx, top + h + 4), flag);
    final tp = TextPainter(
      text: TextSpan(text: 'Objetivo ${target.toStringAsFixed(0)} %', style: SiscanType.nota.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: t.cafeto)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset((tx - 4).clamp(0, s.width - tp.width), 0));
    // Escala.
    final tick = Paint()..color = t.lineaFuerte..strokeWidth = 1;
    for (double v = 0; v <= scaleMax; v += 5) {
      final px = x(v);
      c.drawLine(Offset(px, top + h + 3), Offset(px, top + h + 7), tick);
      final lp = TextPainter(text: TextSpan(text: v.toStringAsFixed(0), style: SiscanType.tabla.copyWith(fontSize: 11, color: t.tierraSuave)), textDirection: TextDirection.ltr)..layout();
      lp.paint(c, Offset((px - lp.width / 2).clamp(0, s.width - lp.width), top + h + 8));
    }
  }

  @override
  bool shouldRepaint(_BedPainter o) => o.value != value || o.t != t;
}
