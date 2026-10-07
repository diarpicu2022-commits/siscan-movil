import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'format.dart';
import 'provenance.dart';
import 'siscan_icon.dart';

/// Predicción de la IA como asistente de investigación: tiempo restante en `anil`, ventana, confianza como **regla**
/// (Baja < 60, Media 60–79, Alta ≥ 80; nunca un anillo) y procedencia «Predicción». Sin predicción, lo dice.
class PredictionPanel extends StatelessWidget {
  const PredictionPanel({super.key, required this.prediction, this.unavailableReason});
  final AIPrediction? prediction;
  final String? unavailableReason;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final p = prediction;
    return Container(
      padding: const EdgeInsets.all(SiscanSpace.s5),
      decoration: BoxDecoration(color: t.papel, borderRadius: BorderRadius.circular(SiscanRadius.hoja), border: Border.all(color: t.anilSuave, width: 2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SiscanIcon(SiscanGlyph.prediccion, size: 24, color: t.anil),
          const SizedBox(width: SiscanSpace.s2),
          Expanded(child: Text('Predicción de IA', style: SiscanType.seccion.copyWith(color: t.tierra, fontSize: 20))),
          ProvenanceChip(p == null ? Provenance.noDisponible : Provenance.prediccion),
        ]),
        const SizedBox(height: SiscanSpace.s4),
        Text(rotulo('Tiempo restante estimado'), style: SiscanType.etiqueta.copyWith(color: t.tierraSuave)),
        if (p == null) ...[
          const SizedBox(height: SiscanSpace.s2),
          Text(unavailableReason ?? 'Sin predicción disponible.', style: SiscanType.cita.copyWith(color: t.tierraSuave)),
        ] else ...[
          DurationText(p.remaining, color: t.anil, big: true),
          const SizedBox(height: SiscanSpace.s1),
          Text.rich(TextSpan(style: SiscanType.nota.copyWith(color: t.tierraSuave), children: [
            const TextSpan(text: 'Entre '),
            TextSpan(text: formatDuration(p.low), style: SiscanType.tabla.copyWith(color: t.tierra)),
            const TextSpan(text: ' y '),
            TextSpan(text: formatDuration(p.high), style: SiscanType.tabla.copyWith(color: t.tierra)),
          ])),
          const SizedBox(height: SiscanSpace.s4),
          ConfidenceRule(p.confidence),
        ],
      ]),
    );
  }
}

/// Regla de confianza: pista hundida con tres zonas, relleno `anil` rayado hasta el valor y aguja de papel.
class ConfidenceRule extends StatelessWidget {
  const ConfidenceRule(this.value, {super.key});
  final int value;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final level = value >= 80 ? 'Alta' : value >= 60 ? 'Media' : 'Baja';
    return Semantics(
      label: 'Confianza de la predicción: $value por ciento, $level',
      excludeSemantics: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(rotulo('Confianza de la predicción'), style: SiscanType.etiqueta.copyWith(color: t.tierraSuave))),
          Text('$value %', style: SiscanType.lecturaS.copyWith(color: t.anil)),
          const SizedBox(width: SiscanSpace.s2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: t.anil, borderRadius: BorderRadius.circular(SiscanRadius.grano)),
            child: Text(rotulo(level), style: SiscanType.etiqueta.copyWith(color: t.papel)),
          ),
        ]),
        const SizedBox(height: SiscanSpace.s2),
        SizedBox(height: 34, width: double.infinity, child: CustomPaint(painter: _RulePainter(t, value / 100))),
      ]),
    );
  }
}

class _RulePainter extends CustomPainter {
  _RulePainter(this.t, this.v);
  final SiscanTokens t;
  final double v;
  @override
  void paint(Canvas c, Size s) {
    const h = 14.0;
    final track = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s.width, h), const Radius.circular(h / 2));
    c.drawRRect(track, Paint()..color = t.anilSuave);
    c.drawRRect(track, Paint()..color = t.tierra.withValues(alpha: .18)..style = PaintingStyle.stroke..strokeWidth = 1);
    c.save();
    c.clipRRect(track);
    final fill = Rect.fromLTWH(0, 0, s.width * v, h);
    c.drawRect(fill, Paint()..color = t.anil);
    final stripe = Paint()..color = t.papel.withValues(alpha: .28)..strokeWidth = 3;
    for (double x = -h; x < fill.right; x += 9) {
      c.drawLine(Offset(x, h), Offset(x + h, 0), stripe);
    }
    c.restore();
    final tick = Paint()..color = t.lineaFuerte..strokeWidth = 1;
    for (final z in [.6, .8]) {
      c.drawLine(Offset(s.width * z, h + 2), Offset(s.width * z, h + 6), tick);
    }
    final nx = (s.width * v).clamp(3.0, s.width - 3);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(nx, h / 2), width: 6, height: h + 8), const Radius.circular(3)), Paint()..color = t.papel);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(nx, h / 2), width: 6, height: h + 8), const Radius.circular(3)), Paint()..color = t.anil..style = PaintingStyle.stroke..strokeWidth = 1.5);
    for (final (z, l) in [(0.0, 'Baja'), (.6, 'Media'), (.8, 'Alta')]) {
      final tp = TextPainter(text: TextSpan(text: l, style: SiscanType.tabla.copyWith(fontSize: 11, color: t.tierraSuave)), textDirection: TextDirection.ltr)..layout();
      tp.paint(c, Offset((s.width * z + (z == 0 ? 0 : 4)).clamp(0, s.width - tp.width), h + 7));
    }
  }
  @override
  bool shouldRepaint(_RulePainter o) => o.v != v || o.t != t;
}
