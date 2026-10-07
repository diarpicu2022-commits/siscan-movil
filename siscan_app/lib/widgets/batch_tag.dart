import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Etiqueta de costal: el registro físico del lote (esquinas cortadas, ojal y costura en `arcilla`).
/// Tamaño «s» (móvil): código en rótulo, variedad en cita y el estado en palabra.
class BatchTag extends StatelessWidget {
  const BatchTag({super.key, required this.code, required this.variety, required this.statusWord, this.statusColor});
  final String code, variety, statusWord;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final sc = statusColor ?? t.cafeto;
    return Semantics(
      label: '$code, $variety, $statusWord',
      excludeSemantics: true,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 18, height: 72, child: CustomPaint(painter: _SeamPainter(t))),
        const SizedBox(width: SiscanSpace.s2),
        Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rotulo(code), style: SiscanType.etiqueta.copyWith(color: t.arcilla, fontSize: 13, letterSpacing: 2.4)),
          Text(variety, style: SiscanType.cita.copyWith(color: t.tierra, fontWeight: FontWeight.w600)),
          const SizedBox(height: SiscanSpace.s2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(border: Border.all(color: sc, width: 1.5), borderRadius: BorderRadius.circular(SiscanRadius.etiqueta)),
            child: Text(rotulo(statusWord), style: SiscanType.etiqueta.copyWith(color: sc, letterSpacing: 1.2)),
          ),
        ])),
      ]),
    );
  }
}

/// Borde del costal: costura discontinua en arcilla, esquinas cortadas y el ojal.
class _SeamPainter extends CustomPainter {
  _SeamPainter(this.t);
  final SiscanTokens t;
  @override
  void paint(Canvas c, Size s) {
    final seam = Paint()..color = t.arcilla.withValues(alpha: .7)..strokeWidth = 3..strokeCap = StrokeCap.butt;
    for (double y = 6; y < s.height - 6; y += 8) {
      c.drawLine(Offset(4, y), Offset(4, y + 4.5), seam);
    }
    final cut = Paint()..color = t.arcilla.withValues(alpha: .7);
    c.drawPath(Path()..moveTo(0, 0)..lineTo(6, 0)..lineTo(6, 4)..close(), cut);
    c.drawPath(Path()..moveTo(0, s.height)..lineTo(6, s.height)..lineTo(6, s.height - 4)..close(), cut);
    c.drawCircle(Offset(14, s.height * .42), 3.6, Paint()..color = t.arcilla..style = PaintingStyle.stroke..strokeWidth = 1.6);
  }
  @override
  bool shouldRepaint(_SeamPainter o) => o.t != t;
}
