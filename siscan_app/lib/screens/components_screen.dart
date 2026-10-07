import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/moisture_meter.dart';
import '../widgets/provenance.dart';
import '../widgets/sensor_reading.dart';
import '../widgets/siscan_icon.dart';
import '../widgets/status_mark.dart';

/// Paso 2 · componente clave en sus estados (para revisión de Diego): lecho de humedad, lectura de sensor,
/// procedencia y sellos de estado. Datos de ejemplo verosímiles del sistema.
class ComponentsScreen extends StatelessWidget {
  const ComponentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    Widget sheet(Widget child) => Container(
          margin: const EdgeInsets.only(bottom: SiscanSpace.s5),
          padding: const EdgeInsets.all(SiscanSpace.s5),
          decoration: BoxDecoration(color: t.papel, borderRadius: BorderRadius.circular(SiscanRadius.hoja),
              boxShadow: const [BoxShadow(color: Color(0x0F2B1E15), offset: Offset(0, 1)), BoxShadow(color: Color(0x662B1E15), offset: Offset(0, 12), blurRadius: 28, spreadRadius: -16)]),
          child: child,
        );
    Widget label(String s) => Padding(
          padding: const EdgeInsets.only(bottom: SiscanSpace.s3),
          child: Text(rotulo(s), style: SiscanType.etiqueta.copyWith(color: t.tierraSuave)),
        );
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(SiscanSpace.s4), children: [
          sheet(const MoistureMeter(current: 14.5, initial: 52, target: 11, source: 'sonda de grano')),
          sheet(const MoistureMeter(current: 10.8, initial: 52, target: 11, label: 'Humedad final · Lote A', kind: Provenance.estimado, source: 'gravimetría')),
          const SensorReading(name: 'Temperatura interior', glyph: SiscanGlyph.temperatura, value: 40.5, unit: '°C', range: '38 – 42 °C', updated: 'Hace 5 s', live: true),
          const SizedBox(height: SiscanSpace.s4),
          const SensorReading(name: 'Humedad relativa', glyph: SiscanGlyph.humedad, value: 63.2, unit: '%', range: '40 – 60 %', status: SiscanStatus.advertencia, updated: 'Hace 5 s', live: true),
          const SizedBox(height: SiscanSpace.s4),
          const SensorReading(name: 'Temperatura exterior', glyph: SiscanGlyph.solar, value: 17.8, unit: '°C', status: SiscanStatus.desactualizado, updated: 'Hace 14 min'),
          const SizedBox(height: SiscanSpace.s4),
          const SensorReading(name: 'Flujo de aire', glyph: SiscanGlyph.aire, value: null, unit: 'm/s', status: SiscanStatus.sinConexion, updated: 'Sin datos desde 09:42'),
          const SizedBox(height: SiscanSpace.s5),
          sheet(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            label('Procedencia · junto a cada cifra'),
            Wrap(spacing: SiscanSpace.s2, runSpacing: SiscanSpace.s2, children: [for (final k in Provenance.values) ProvenanceChip(k)]),
            const SizedBox(height: SiscanSpace.s3),
            const ProvenanceChip(Provenance.prediccion, source: 'modelo v2 · 87 %'),
            const SizedBox(height: SiscanSpace.s5),
            label('Sellos de estado'),
            const Wrap(spacing: SiscanSpace.s2, runSpacing: SiscanSpace.s2, children: [
              StatusMark(SiscanStatus.normal), StatusMark(SiscanStatus.advertencia), StatusMark(SiscanStatus.critico),
              StatusMark(SiscanStatus.sinConexion), StatusMark(SiscanStatus.desactualizado), StatusMark(SiscanStatus.info),
              StatusMark(SiscanStatus.normal, variant: StatusVariant.solido, label: 'Secando'),
              StatusMark(SiscanStatus.critico, variant: StatusVariant.solido, label: 'Atención requerida', detail: '10:42'),
              StatusMark(SiscanStatus.normal, variant: StatusVariant.solido, label: 'Objetivo alcanzado', large: true),
              StatusMark(SiscanStatus.normal, variant: StatusVariant.linea, label: 'Proceso dentro del rango esperado'),
            ]),
          ])),
        ]),
      ),
    );
  }
}
