import 'package:flutter/material.dart';

import '../theme/typography.dart';

/// Duraciones como «18 h 20 min» (reduce las unidades: «45 min», «3 d 4 h»).
String formatDuration(Duration d) {
  final days = d.inDays, h = d.inHours % 24, m = d.inMinutes % 60;
  if (days > 0) return '$days d $h h';
  if (d.inHours > 0) return m == 0 ? '${d.inHours} h' : '${d.inHours} h $m min';
  return '${d.inMinutes} min';
}

/// «Hace 5 s», «Hace 14 min», «Hace 2 h», «el 19 ago».
String ago(DateTime at, DateTime now) {
  final d = now.difference(at);
  if (d.inSeconds < 60) return 'Hace ${d.inSeconds.clamp(0, 59)} s';
  if (d.inMinutes < 60) return 'Hace ${d.inMinutes} min';
  if (d.inHours < 24) return 'Hace ${d.inHours} h';
  const m = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
  return 'El ${at.day} ${m[at.month - 1]}';
}

/// Duración con las cifras grandes y las unidades pequeñas, en mono.
class DurationText extends StatelessWidget {
  const DurationText(this.d, {super.key, required this.color, this.big = false});
  final Duration d;
  final Color color;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final num = (big ? SiscanType.lectura.copyWith(fontSize: 44, height: 1.1) : SiscanType.lectura.copyWith(fontSize: 30, height: 34 / 30)).copyWith(color: color);
    final unit = SiscanType.tabla.copyWith(fontSize: big ? 22 : 16, color: color.withValues(alpha: .8));
    final spans = <InlineSpan>[];
    for (final part in formatDuration(d).split(' ')) {
      final bits = part.split(' ');
      spans
        ..add(TextSpan(text: bits[0], style: num))
        ..add(TextSpan(text: ' ${bits.length > 1 ? bits[1] : ''} ', style: unit));
    }
    return Text.rich(TextSpan(children: spans), semanticsLabel: formatDuration(d).replaceAll(' ', ' '));
  }
}
