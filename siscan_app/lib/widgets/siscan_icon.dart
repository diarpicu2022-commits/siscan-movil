import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Familia propia de 27 iconos de SISCAN (rejilla 24, trazo 1.75, un punto de medición relleno).
/// Hereda el color del texto como `currentColor` en la web. Tamaños: 16 rótulos, 20 navegación, 22–24 tarjetas, 28 móvil.
enum SiscanGlyph {
  aire, alerta, balanza, calibracion, candado, cerrar, check, correo, energia, finca, flecha, historial, humedad,
  lote, mano, mapa, muestra, ojo, ojoCerrado, prediccion, resistencia, sinConexion, sincronizar, solar, temperatura,
  usuario, ventilador;

  String get asset {
    final file = switch (this) { ojoCerrado => 'ojo-cerrado', sinConexion => 'sin-conexion', _ => name };
    return 'assets/icons/$file.svg';
  }
}

class SiscanIcon extends StatelessWidget {
  const SiscanIcon(this.glyph, {super.key, this.size = 24, this.color, this.semanticLabel});
  final SiscanGlyph glyph;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? DefaultTextStyle.of(context).style.color!;
    return SvgPicture.asset(glyph.asset, width: size, height: size,
        colorFilter: ColorFilter.mode(c, BlendMode.srcIn), semanticsLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null);
  }
}
