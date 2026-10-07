import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/siscan_icon.dart';

/// Paso 1 · Fundamentos: tokens, tipografía e iconos tal como los usará la app (para revisión de Diego).
class FoundationsScreen extends StatelessWidget {
  const FoundationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    Widget swatch(String name, Color c, Color on) => Container(
          width: 112, height: 64, padding: const EdgeInsets.all(SiscanSpace.s2),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(SiscanRadius.etiqueta), border: Border.all(color: t.linea)),
          alignment: Alignment.bottomLeft,
          child: Text(name, style: SiscanType.tabla.copyWith(color: on, fontSize: 12)),
        );
    Widget sheet(String label, Widget child) => Container(
          margin: const EdgeInsets.only(bottom: SiscanSpace.s5),
          padding: const EdgeInsets.all(SiscanSpace.s5),
          decoration: BoxDecoration(color: t.papel, borderRadius: BorderRadius.circular(SiscanRadius.hoja),
              boxShadow: const [BoxShadow(color: Color(0x0F2B1E15), offset: Offset(0, 1)), BoxShadow(color: Color(0x662B1E15), offset: Offset(0, 12), blurRadius: 28, spreadRadius: -16)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rotulo(label), style: SiscanType.etiqueta.copyWith(color: t.tierraSuave)),
            const SizedBox(height: SiscanSpace.s3),
            child,
          ]),
        );
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(SiscanSpace.s4), children: [
          Text('SISCAN', style: SiscanType.titulo.copyWith(color: t.monte, fontVariations: const [FontVariation('SOFT', 100), FontVariation('WONK', 1), FontVariation('wght', 700)])),
          Text('Fundamentos del sistema en la app', style: SiscanType.cita.copyWith(color: t.tierraSuave)),
          const SizedBox(height: SiscanSpace.s5),
          sheet('Superficies y texto', Wrap(spacing: SiscanSpace.s2, runSpacing: SiscanSpace.s2, children: [
            swatch('pergamino', t.pergamino, t.tierra), swatch('papel', t.papel, t.tierra), swatch('arena', t.arena, t.tierra),
            swatch('monte', t.monte, t.sobreMonte), swatch('arcilla', t.arcilla, t.sobreArcilla), swatch('tierra', t.tierra, t.pergamino),
          ])),
          sheet('Estado del proceso', Wrap(spacing: SiscanSpace.s2, runSpacing: SiscanSpace.s2, children: [
            swatch('cafeto', t.cafetoSuave, t.cafeto), swatch('panela', t.panelaSuave, t.panela), swatch('oxido', t.oxidoSuave, t.oxido),
            swatch('bruma', t.brumaSuave, t.bruma), swatch('anil', t.anilSuave, t.anil), swatch('dato-agua', t.datoAgua, t.papel),
          ])),
          sheet('Tres voces', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Café Supremo — Lote B', style: SiscanType.seccion.copyWith(color: t.tierra)),
            Text('Proceso dentro del rango esperado', style: SiscanType.cita.copyWith(color: t.tierraSuave)),
            const SizedBox(height: SiscanSpace.s3),
            Text(rotulo('Humedad del café'), style: SiscanType.etiqueta.copyWith(color: t.tierraSuave)),
            Text('14.5 %', style: SiscanType.lecturaCampo.copyWith(color: t.tierra)),
            Text('40.5 °C', style: SiscanType.lectura.copyWith(color: t.tierra)),
            Text('18 h 20 min', style: SiscanType.lectura.copyWith(color: t.anil)),
            Text('Actualizado hace 3 s', style: SiscanType.nota.copyWith(color: t.tierraSuave)),
          ])),
          sheet('Iconos', Wrap(spacing: SiscanSpace.s4, runSpacing: SiscanSpace.s4, children: [
            for (final g in SiscanGlyph.values) SiscanIcon(g, size: 28, color: t.tierra),
          ])),
        ]),
      ),
    );
  }
}
