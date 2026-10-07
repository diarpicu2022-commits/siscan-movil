import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/overview_controller.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/batch_tag.dart';
import '../widgets/format.dart';
import '../widgets/moisture_meter.dart';
import '../widgets/prediction_panel.dart';
import '../widgets/provenance.dart';
import '../widgets/sensor_reading.dart';
import '../widgets/siscan_icon.dart';
import '../widgets/status_mark.dart';

/// Inicio móvil (referencia `InicioMovil`, orden de plataformas.md): lote activo → humedad → temperatura → tiempo →
/// predicción → equipo → alertas. Con los datos reales del secador; si no hay lote activo lo dice y muestra el último.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key, required this.controller, this.onSeeAlerts});
  final OverviewController controller;
  final VoidCallback? onSeeAlerts;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final d = controller.data;
          if (d == null && controller.error != null) return _ErrorSheet(message: controller.error!, onRetry: controller.load);
          if (d == null) return const _LoadingSheets();
          return _Content(d: d, onSeeAlerts: onSeeAlerts, onRefresh: controller.load, refreshing: controller.loading);
        },
      );
}

BoxDecoration sheetDecoration(SiscanTokens t, {double topRadius = SiscanRadius.hoja}) => BoxDecoration(
      color: t.papel,
      borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius), bottom: const Radius.circular(SiscanRadius.hoja)),
      boxShadow: const [BoxShadow(color: Color(0x0F2B1E15), offset: Offset(0, 1)), BoxShadow(color: Color(0x662B1E15), offset: Offset(0, 12), blurRadius: 28, spreadRadius: -16)],
    );

class _Content extends StatelessWidget {
  const _Content({required this.d, required this.onRefresh, required this.refreshing, this.onSeeAlerts});
  final Overview d;
  final VoidCallback onRefresh;
  final bool refreshing;
  final VoidCallback? onSeeAlerts;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final batch = d.activeBatch;
    final temp = d.readings['TEMPERATURE_TOPE'] ?? d.readings['TEMPERATURE_EXTERIOR'];
    final hum = d.readings['HUMIDITY_TOPE'] ?? d.readings['HUMIDITY_EXTERIOR'];
    final pairs = <Widget>[];

    Widget pair(String label, Widget value, Provenance kind) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rotulo(label), style: SiscanType.etiqueta.copyWith(color: t.tierraSuave)),
          const SizedBox(height: SiscanSpace.s1),
          value,
          const SizedBox(height: SiscanSpace.s1),
          ProvenanceChip(kind, label: kind == Provenance.desactualizado ? 'Última lectura' : null),
        ]);

    if (temp != null) {
      final stale = d.isStale(temp);
      pairs.add(pair('Temperatura', Text.rich(TextSpan(children: [
        TextSpan(text: temp.value.toStringAsFixed(1), style: SiscanType.lectura.copyWith(fontSize: 30, height: 34 / 30, color: stale ? t.tierraSuave : t.tierra)),
        TextSpan(text: ' °C', style: SiscanType.tabla.copyWith(fontSize: 16, color: t.tierraSuave)),
      ])), stale ? Provenance.desactualizado : Provenance.medido));
    }
    if (batch != null) {
      // Sin red el tiempo se calcula con la hora del teléfono y el lote pudo haber terminado: es una estimación.
      pairs.add(pair('Tiempo', DurationText(d.fetchedAt.difference(batch.startedAt), color: t.tierra), d.offline ? Provenance.estimado : Provenance.medido));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // 1 · Lote activo (o el último, si no hay) con la humedad dominante.
      Container(
        key: const Key('batch-sheet'),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        decoration: sheetDecoration(t, topRadius: 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (batch != null) ...[
            BatchTag(code: batch.name, variety: batch.protocolLabel, statusWord: 'Secando', statusColor: t.cafeto),
            const SizedBox(height: SiscanSpace.s4),
            MoistureMeter(current: batch.currentMoisture ?? batch.initialMoisture, initial: batch.initialMoisture, target: batch.targetMoisture,
                kind: Provenance.estimado, source: batch.lastSampleAt == null ? 'gravimetría' : 'gravimetría · ${ago(batch.lastSampleAt!, d.fetchedAt).toLowerCase()}'),
          ] else ...[
            Text('Sin lote activo', style: SiscanType.seccion.copyWith(color: t.tierra)),
            const SizedBox(height: SiscanSpace.s1),
            Text('${d.dryer.name} · ${d.dryer.place}', style: SiscanType.cita.copyWith(color: t.tierraSuave, fontSize: 16)),
            if (d.lastBatch != null) ...[
              const SizedBox(height: SiscanSpace.s4),
              Divider(color: t.linea, height: 1),
              const SizedBox(height: SiscanSpace.s4),
              BatchTag(code: 'Último lote · ${d.lastBatch!.name}', variety: d.lastBatch!.protocolLabel, statusWord: 'Completado', statusColor: t.tierraSuave),
              const SizedBox(height: SiscanSpace.s4),
              MoistureMeter(current: d.lastBatch!.currentMoisture ?? d.lastBatch!.targetMoisture, initial: d.lastBatch!.initialMoisture,
                  target: d.lastBatch!.targetMoisture, label: 'Humedad final', kind: Provenance.estimado, source: 'gravimetría'),
            ],
          ],
          if (pairs.isNotEmpty) ...[
            const SizedBox(height: SiscanSpace.s3),
            Container(height: 1.5, color: t.linea),
            const SizedBox(height: SiscanSpace.s3),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final p in pairs) Expanded(child: p)]),
          ],
          const SizedBox(height: SiscanSpace.s3),
          Row(children: [
            Expanded(child: Text(temp == null ? 'Sin lecturas del secador' : 'Última lectura del secador: ${ago(temp.at, d.fetchedAt).toLowerCase()}',
                style: SiscanType.nota.copyWith(color: t.tierraSuave))),
            TextButton.icon(
              onPressed: refreshing ? null : onRefresh,
              style: TextButton.styleFrom(foregroundColor: t.arcilla, minimumSize: const Size(48, 48)),
              icon: SiscanIcon(SiscanGlyph.sincronizar, size: 18, color: refreshing ? t.tierraSuave : t.arcilla),
              label: Text(refreshing ? 'Actualizando…' : 'Actualizar', style: SiscanType.cuerpoFuerte.copyWith(fontSize: 14)),
            ),
          ]),
        ]),
      ),
      if (d.offline) ...[
        const SizedBox(height: SiscanSpace.s4),
        OfflineNotice(savedAt: d.savedAt),
      ],
      const SizedBox(height: SiscanSpace.s4),
      // Humedad relativa del recinto (¿está funcionando el equipo?).
      if (hum != null) ...[
        SensorReading(name: hum.label, glyph: SiscanGlyph.humedad, value: hum.value, unit: hum.unit,
            status: d.offline ? SiscanStatus.sinConexion : (d.isStale(hum) ? SiscanStatus.desactualizado : SiscanStatus.normal), updated: ago(hum.at, d.fetchedAt), live: !d.isStale(hum)),
        const SizedBox(height: SiscanSpace.s4),
      ],
      // 5 · Predicción.
      PredictionPanel(
        prediction: d.offline ? null : d.prediction,
        unavailableReason: d.offline
            ? 'Sin conexión no mostramos la predicción: puede haber cambiado.'
            : batch == null
            ? 'La predicción aparece cuando hay un lote secando.'
            : 'El modelo aún no ha estimado este lote. Se calcula con las muestras de gravimetría.',
      ),
      const SizedBox(height: SiscanSpace.s4),
      // 6 · Equipo.
      _EquipmentSheet(actuators: d.actuators, offline: d.offline),
      const SizedBox(height: SiscanSpace.s4),
      // 7 · Alertas.
      _AlertsSheet(alerts: d.alerts, count: d.alertCount, now: d.fetchedAt, onSeeAll: onSeeAlerts),
    ]);
  }
}

class _EquipmentSheet extends StatelessWidget {
  const _EquipmentSheet({required this.actuators, this.offline = false});
  final List<Actuator> actuators;
  final bool offline;
  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    return Container(
      padding: const EdgeInsets.all(SiscanSpace.s5),
      decoration: sheetDecoration(t),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Equipo', style: SiscanType.seccion.copyWith(color: t.tierra, fontSize: 20)),
        if (offline) Text('Último estado conocido, sin conexión.', style: SiscanType.nota.copyWith(color: t.tierraSuave)),
        const SizedBox(height: SiscanSpace.s3),
        if (actuators.isEmpty) Text('El secador no ha registrado actuadores.', style: SiscanType.cuerpo.copyWith(color: t.tierraSuave)),
        for (final a in actuators)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              SiscanIcon(a.kind == ActuatorKind.heater ? SiscanGlyph.resistencia : (a.kind == ActuatorKind.fan ? SiscanGlyph.ventilador : SiscanGlyph.energia), size: 22, color: t.tierra),
              const SizedBox(width: SiscanSpace.s3),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.name, style: SiscanType.cuerpoFuerte.copyWith(color: t.tierra)),
                Text('${a.powerW.toStringAsFixed(0)} W nominales', style: SiscanType.tabla.copyWith(fontSize: 12, color: t.tierraSuave)),
              ])),
              StatusMark(a.on ? SiscanStatus.normal : SiscanStatus.apagado, label: a.on ? 'Encendido' : 'Apagado'),
            ]),
          ),
      ]),
    );
  }
}

class _AlertsSheet extends StatelessWidget {
  const _AlertsSheet({required this.alerts, required this.count, required this.now, this.onSeeAll});
  final List<Alert> alerts;
  final int count;
  final DateTime now;
  final VoidCallback? onSeeAll;
  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    return Container(
      padding: const EdgeInsets.all(SiscanSpace.s5),
      decoration: sheetDecoration(t),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('¿Hay algo que deba revisar?', style: SiscanType.seccion.copyWith(color: t.tierra, fontSize: 20)),
        const SizedBox(height: SiscanSpace.s3),
        if (alerts.isEmpty)
          const StatusMark(SiscanStatus.normal, variant: StatusVariant.linea, label: 'Sin alertas pendientes')
        else
          for (final a in alerts.take(3))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                StatusMark(switch (a.level) { AlertLevel.critical => SiscanStatus.critico, AlertLevel.warning => SiscanStatus.advertencia, _ => SiscanStatus.info },
                    label: switch (a.level) { AlertLevel.critical => 'Crítica', AlertLevel.warning => 'Atención', _ => 'Aviso' }),
                const SizedBox(width: SiscanSpace.s3),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.message, style: SiscanType.cuerpo.copyWith(fontSize: 15, height: 1.35, color: t.tierra)),
                  Text(ago(a.at, now), style: SiscanType.nota.copyWith(color: t.tierraSuave)),
                ])),
              ]),
            ),
        if (count > 0 && onSeeAll != null)
          Align(alignment: Alignment.centerRight, child: TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(foregroundColor: t.arcilla, minimumSize: const Size(48, 48)),
            child: Text('Ver las $count alertas', style: SiscanType.cuerpoFuerte.copyWith(fontSize: 14)),
          )),
      ]),
    );
  }
}

/// Cargando: hojas en reposo con bloques de arena (sin girar ruedas).
class _LoadingSheets extends StatelessWidget {
  const _LoadingSheets();
  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    Widget bar(double w, double h) => Container(width: w, height: h, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: t.arena, borderRadius: BorderRadius.circular(SiscanRadius.etiqueta)));
    return Semantics(
      label: 'Cargando los datos del secador',
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        decoration: sheetDecoration(t, topRadius: 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [bar(120, 14), bar(200, 20), bar(170, 64), bar(double.infinity, 52), bar(240, 14)]),
      ),
    );
  }
}

class _ErrorSheet extends StatelessWidget {
  const _ErrorSheet({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: sheetDecoration(t, topRadius: 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StatusMark(SiscanStatus.sinConexion, label: 'Sin datos del secador'),
        const SizedBox(height: SiscanSpace.s3),
        Text(message, style: SiscanType.cuerpo.copyWith(color: t.tierra)),
        const SizedBox(height: SiscanSpace.s4),
        FilledButton(
          onPressed: onRetry,
          style: FilledButton.styleFrom(backgroundColor: t.arcilla, foregroundColor: t.sobreArcilla, minimumSize: const Size(48, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SiscanRadius.control))),
          child: Text('Intentar nuevamente', style: SiscanType.cuerpoFuerte),
        ),
      ]),
    );
  }
}

/// Aviso de «Modo offline» (referencia: Toast de atención en `InicioMovil`).
class OfflineNotice extends StatelessWidget {
  const OfflineNotice({super.key, this.savedAt});
  final DateTime? savedAt;
  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(SiscanSpace.s4),
        decoration: BoxDecoration(color: t.papel, borderRadius: BorderRadius.circular(SiscanRadius.control), border: Border.all(color: t.panela, width: 1.5)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const StatusMark(SiscanStatus.advertencia, label: 'Atención'),
          const SizedBox(width: SiscanSpace.s3),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Modo offline', style: SiscanType.cuerpoFuerte.copyWith(color: t.tierra)),
            Text(savedAt == null
                ? 'Los datos se sincronizarán cuando vuelva la conexión.'
                : 'Mostramos lo guardado ${ago(savedAt!, DateTime.now()).toLowerCase()}. Se sincroniza al volver la conexión.',
                style: SiscanType.nota.copyWith(color: t.tierra)),
          ])),
        ]),
      ),
    );
  }
}
