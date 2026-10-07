import 'package:flutter/material.dart';

import '../app_shell.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/moisture_meter.dart';

/// Contenido provisional del paso 3 (esqueleto): cada destino dice qué tendrá y en qué paso llega.
/// Inicio muestra la hoja del lote con el componente clave para ver cómo sube sobre la banda.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.tab});
  final AppTab tab;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final (title, text) = switch (tab) {
      AppTab.inicio => ('¿Cómo está el secado?', 'Paso 4: lote activo, humedad, temperatura, tiempo, predicción, equipo y alertas con los datos del secador.'),
      AppTab.controles => ('¿Está funcionando el equipo?', 'Paso 5: ventiladores, resistencias y luces; modo automático o manual.'),
      AppTab.prediccion => ('¿Cuánto falta?', 'Paso 5: tiempo restante estimado por la IA, su rango y su confianza.'),
      AppTab.alertas => ('¿Hay algo que deba revisar?', 'Paso 5: avisos del secador, del más grave al más leve.'),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: t.papel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28), bottom: Radius.circular(SiscanRadius.hoja)),
        boxShadow: const [BoxShadow(color: Color(0x0F2B1E15), offset: Offset(0, 1)), BoxShadow(color: Color(0x662B1E15), offset: Offset(0, 12), blurRadius: 28, spreadRadius: -16)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: SiscanType.seccion.copyWith(color: t.tierra)),
        const SizedBox(height: SiscanSpace.s2),
        Text(text, style: SiscanType.cuerpo.copyWith(color: t.tierraSuave)),
        if (tab == AppTab.inicio) ...[
          const SizedBox(height: SiscanSpace.s5),
          const MoistureMeter(current: 14.5, initial: 52, target: 11),
        ],
      ]),
    );
  }
}
