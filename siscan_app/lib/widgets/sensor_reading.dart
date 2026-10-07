import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'provenance.dart';
import 'siscan_icon.dart';
import 'status_mark.dart';

/// Lectura de un sensor como instrumento: regla, cifra grande, estado, procedencia y frescura.
/// Desactualizado o sin conexión: la cifra pasa a tierra-suave sobre rayado y la procedencia cambia —
/// nunca se presentan datos viejos como actuales.
class SensorReading extends StatelessWidget {
  const SensorReading({super.key, required this.name, required this.glyph, required this.value, required this.unit,
      this.decimals = 1, this.status = SiscanStatus.normal, this.range, this.updated, this.source, this.live = false});
  final String name, unit;
  final SiscanGlyph glyph;
  final double? value;
  final int decimals;
  final SiscanStatus status;
  final String? range, updated, source;
  final bool live;

  bool get _stale => status == SiscanStatus.desactualizado || status == SiscanStatus.sinConexion || value == null;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final kind = value == null ? Provenance.noDisponible : (_stale ? Provenance.desactualizado : Provenance.medido);
    final tint = switch (status) { SiscanStatus.advertencia => t.panelaSuave, SiscanStatus.critico || SiscanStatus.error => t.oxidoSuave, _ => t.arena };
    final valueText = value == null ? '—' : value!.toStringAsFixed(decimals);
    return Semantics(
      container: true,
      label: '$name: ${value == null ? 'sin dato' : '$valueText $unit'}, ${statusStyle(t, status).word}${updated != null ? ', $updated' : ''}',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(color: t.papel, borderRadius: BorderRadius.circular(SiscanRadius.hoja),
            boxShadow: const [BoxShadow(color: Color(0x0F2B1E15), offset: Offset(0, 1)), BoxShadow(color: Color(0x662B1E15), offset: Offset(0, 12), blurRadius: 28, spreadRadius: -16)]),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 8, width: double.infinity, child: CustomPaint(painter: _RulerPainter(t.lineaFuerte))),
          Padding(
            padding: const EdgeInsets.fromLTRB(SiscanSpace.s4, SiscanSpace.s2, SiscanSpace.s4, SiscanSpace.s4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 40, height: 40, alignment: Alignment.center,
                  decoration: BoxDecoration(color: tint, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomRight: Radius.circular(12), bottomLeft: Radius.circular(4))),
                  child: SiscanIcon(glyph, size: 22, color: t.tierra),
                ),
                const SizedBox(width: SiscanSpace.s3),
                Expanded(child: Text(name, style: SiscanType.cuerpoFuerte.copyWith(color: t.tierra))),
                if (live && !_stale) Container(width: 9, height: 9, decoration: BoxDecoration(color: t.cafeto, shape: BoxShape.circle)),
              ]),
              const SizedBox(height: SiscanSpace.s3),
              Container(
                width: double.infinity,
                decoration: _stale ? BoxDecoration(borderRadius: BorderRadius.circular(SiscanRadius.etiqueta)) : null,
                child: CustomPaint(
                  painter: _stale ? _HatchPainter(t.arena) : null,
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: valueText, style: SiscanType.lectura.copyWith(color: _stale ? t.tierraSuave : t.tierra)),
                    TextSpan(text: ' $unit', style: SiscanType.tabla.copyWith(fontSize: 16, color: t.tierraSuave)),
                  ])),
                ),
              ),
              if (range != null && !_stale) ...[
                const SizedBox(height: SiscanSpace.s1),
                Text('Rango esperado $range', style: SiscanType.tabla.copyWith(fontSize: 13, color: t.tierraSuave)),
              ],
              Divider(height: SiscanSpace.s5, color: t.linea),
              Wrap(spacing: SiscanSpace.s2, runSpacing: SiscanSpace.s2, crossAxisAlignment: WrapCrossAlignment.center, children: [
                StatusMark(status),
                ProvenanceChip(kind, label: kind == Provenance.desactualizado ? 'Última lectura' : null, source: source),
                if (updated != null) Text(updated!, style: SiscanType.nota.copyWith(color: t.tierraSuave)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Regla superior de instrumento (marcas cortas, una larga cada cinco).
class _RulerPainter extends CustomPainter {
  _RulerPainter(this.color);
  final Color color;
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = color.withValues(alpha: .55)..strokeWidth = 1;
    var i = 0;
    for (double x = 14; x < s.width - 8; x += 7, i++) {
      c.drawLine(Offset(x, 0), Offset(x, i % 5 == 0 ? 7 : 4), p);
    }
  }
  @override
  bool shouldRepaint(_RulerPainter o) => o.color != color;
}

class _HatchPainter extends CustomPainter {
  _HatchPainter(this.color);
  final Color color;
  @override
  void paint(Canvas c, Size s) {
    c.save();
    c.clipRRect(RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(SiscanRadius.etiqueta)));
    final p = Paint()..color = color..strokeWidth = 4;
    for (double x = -s.height; x < s.width; x += 12) {
      c.drawLine(Offset(x, s.height), Offset(x + s.height, 0), p);
    }
    c.restore();
  }
  @override
  bool shouldRepaint(_HatchPainter o) => o.color != color;
}
