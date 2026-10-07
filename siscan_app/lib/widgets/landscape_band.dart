import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';

/// Paisaje «loma» sobre `monte` para la barra superior móvil: capas planas de gouache (lomas y una hilera de
/// cafetos), sin contornos ni degradados. Las pinturas nunca llevan texto ni comunican estado.
/// Vivo pero quieto con movimiento reducido: la hilera se mece despacio.
class LandscapeBand extends StatefulWidget {
  const LandscapeBand({super.key, this.height = 84});
  final double height;
  @override
  State<LandscapeBand> createState() => _LandscapeBandState();
}

class _LandscapeBandState extends State<LandscapeBand> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 9));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: RepaintBoundary(child: CustomPaint(painter: _LomaPainter(context.sc, _c))),
        ),
      );
}

class _LomaPainter extends CustomPainter {
  _LomaPainter(this.t, this.anim) : super(repaint: anim);
  final SiscanTokens t;
  final Animation<double> anim;

  Path _hill(Size s, double base, double amp, double freq, double phase) {
    final p = Path()..moveTo(0, s.height);
    for (double x = 0; x <= s.width; x += 6) {
      // Borde vivo: dos ondas superpuestas, como el desplazamiento de ruido del gouache.
      final y = base + amp * sin(x / s.width * pi * freq + phase) + amp * .25 * sin(x / 13 + phase * 3);
      p.lineTo(x, y);
    }
    return p..lineTo(s.width, s.height)..close();
  }

  @override
  void paint(Canvas c, Size s) {
    final sway = sin(anim.value * 2 * pi) * .06;
    c.drawPath(_hill(s, s.height * .30, 6, 2.2, .4), Paint()..color = Color.lerp(t.monte, t.pinturaCafetal, .45)!);
    c.drawPath(_hill(s, s.height * .52, 7, 1.6, 2.1), Paint()..color = t.pinturaCafetal);
    // Hilera de cafetos (copas planas) sobre la loma media.
    final bush = Paint()..color = Color.lerp(t.pinturaCafetal, t.monte, .35)!;
    for (double x = 10; x < s.width; x += 22) {
      final y = s.height * .52 + 7 * sin(x / s.width * pi * 1.6 + 2.1) - 2;
      c.drawOval(Rect.fromCenter(center: Offset(x + 3 * sway * 10, y), width: 18, height: 10), bush);
    }
    c.drawPath(_hill(s, s.height * .74, 5, 1.2, 4.0), Paint()..color = t.pinturaHoja);
  }

  @override
  bool shouldRepaint(_LomaPainter o) => o.t != t;
}
