import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/overview_controller.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/format.dart';
import '../widgets/prediction_panel.dart';
import '../widgets/siscan_icon.dart';
import '../widgets/status_mark.dart';
import 'inicio_screen.dart' show sheetDecoration;

/// Predicción: ¿cuánto falta? La IA habla como asistente de investigación y dice con qué datos estimó.
class PrediccionScreen extends StatelessWidget {
  const PrediccionScreen({super.key, required this.overview});
  final OverviewController overview;
  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    return ListenableBuilder(listenable: overview, builder: (context, _) {
      final d = overview.data;
      final batch = d?.activeBatch;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: sheetDecoration(t, topRadius: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('¿Cuánto falta?', style: SiscanType.seccion.copyWith(color: t.tierra)),
            const SizedBox(height: SiscanSpace.s2),
            Text(batch == null ? 'No hay un lote secando ahora.' : '${batch.name} · ${batch.protocolLabel}', style: SiscanType.cita.copyWith(color: t.tierraSuave)),
          ]),
        ),
        const SizedBox(height: SiscanSpace.s4),
        PredictionPanel(
          prediction: d?.prediction,
          unavailableReason: batch == null ? 'La predicción aparece cuando hay un lote secando.' : 'El modelo aún no ha estimado este lote. Se calcula con las muestras de gravimetría.',
        ),
        const SizedBox(height: SiscanSpace.s4),
        Container(
          padding: const EdgeInsets.all(SiscanSpace.s5),
          decoration: sheetDecoration(t),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rotulo('Datos considerados'), style: SiscanType.etiqueta.copyWith(color: t.tierraSuave)),
            const SizedBox(height: SiscanSpace.s2),
            for (final v in const ['Muestras de gravimetría del lote', 'Temperatura y humedad del recinto', 'Clima de la zona (pronóstico de 6 h)'])
              Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: t.anil, shape: BoxShape.circle)),
                const SizedBox(width: SiscanSpace.s2),
                Expanded(child: Text(v, style: SiscanType.cuerpo.copyWith(fontSize: 15, color: t.tierra))),
              ])),
            const SizedBox(height: SiscanSpace.s3),
            Text('Es una estimación con su margen de error, no una garantía. Confirma el punto de retiro con la balanza.',
                style: SiscanType.cita.copyWith(fontSize: 16, color: t.tierraSuave)),
          ]),
        ),
      ]);
    });
  }
}

/// Alertas (referencia `AlertItem`): del más grave al más leve. El backend publica las más recientes y el total.
class AlertasScreen extends StatelessWidget {
  const AlertasScreen({super.key, required this.overview});
  final OverviewController overview;
  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    return ListenableBuilder(listenable: overview, builder: (context, _) {
      final d = overview.data;
      final alerts = [...?d?.alerts]..sort((a, b) => a.level.index.compareTo(b.level.index));
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: sheetDecoration(t, topRadius: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('¿Hay algo que deba revisar?', style: SiscanType.seccion.copyWith(color: t.tierra)),
            const SizedBox(height: SiscanSpace.s2),
            if (d == null)
              Text('Cargando las alertas…', style: SiscanType.cuerpo.copyWith(color: t.tierraSuave))
            else if (alerts.isEmpty)
              const StatusMark(SiscanStatus.normal, variant: StatusVariant.linea, label: 'Sin alertas pendientes')
            else
              Text(d.alertCount > alerts.length
                  ? 'Mostramos las ${alerts.length} más recientes de ${d.alertCount}. El historial completo está en el panel web.'
                  : '${alerts.length} ${alerts.length == 1 ? 'alerta' : 'alertas'}.', style: SiscanType.cuerpo.copyWith(color: t.tierraSuave)),
          ]),
        ),
        for (final a in alerts) ...[const SizedBox(height: SiscanSpace.s3), AlertItem(alert: a, now: d!.fetchedAt)],
      ]);
    });
  }
}

class AlertItem extends StatelessWidget {
  const AlertItem({super.key, required this.alert, required this.now});
  final Alert alert;
  final DateTime now;
  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final crit = alert.level == AlertLevel.critical;
    final (status, word, glyph) = switch (alert.level) {
      AlertLevel.critical => (SiscanStatus.critico, 'Crítica', SiscanGlyph.alerta),
      AlertLevel.warning => (SiscanStatus.advertencia, 'Advertencia', SiscanGlyph.alerta),
      AlertLevel.info => (SiscanStatus.info, 'Informativa', SiscanGlyph.sincronizar),
    };
    final st = statusStyle(t, status);
    return Container(
      padding: const EdgeInsets.all(SiscanSpace.s4),
      decoration: BoxDecoration(
        color: crit ? t.oxidoSuave : t.papel,
        borderRadius: BorderRadius.circular(SiscanRadius.hoja),
        border: Border.all(color: crit ? t.oxido : t.linea, width: crit ? 2 : 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40, alignment: Alignment.center,
          decoration: BoxDecoration(color: crit ? t.oxido : st.soft, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomRight: Radius.circular(12), bottomLeft: Radius.circular(4))),
          child: SiscanIcon(glyph, size: 22, color: crit ? t.sobreOxido : st.tone),
        ),
        const SizedBox(width: SiscanSpace.s3),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [StatusMark(status, label: word), const Spacer(), Text(ago(alert.at, now), style: SiscanType.tabla.copyWith(fontSize: 12, color: t.tierraSuave))]),
          const SizedBox(height: SiscanSpace.s2),
          Text(alert.message, style: SiscanType.cuerpo.copyWith(fontSize: 15, height: 1.35, color: t.tierra)),
        ])),
      ]),
    );
  }
}
