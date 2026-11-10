/// Marco Android del sistema SISCAN v2: AppBar (clara o bosque grande), barra inferior (Inicio · Lotes · Pesaje ·
/// Equipo · Más) con la píldora salvia del ítem activo, FAB y logo.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/siscan_theme.dart';
import '../theme/siscan_tokens.dart';
import 'base.dart';

/// Logo del sistema (PNG oficial). Nunca se redibuja ni se escribe «SISCAN» con una fuente.
class Logo extends StatelessWidget {
  const Logo({super.key, this.variante = 'logo', this.claro = false, this.alto = 30});
  final String variante;
  final bool claro;
  final double alto;
  @override
  Widget build(BuildContext context) => Image.asset('assets/sistema/marca/siscan-$variante${claro ? '-claro' : ''}.png', height: alto,
      semanticLabel: 'SISCAN · Secado Inteligente de Café', filterQuality: FilterQuality.medium);
}

class AccionBarra {
  const AccionBarra(this.icono, this.etiqueta, this.onTap, {this.cuenta = 0});
  final String icono, etiqueta;
  final VoidCallback onTap;
  final int cuenta;
}

/// sc-appbar: título en Outfit 22; la variante oscura (Inicio y Más) va en bosque con esquinas de 30 y el logo claro.
class BarraApp extends StatelessWidget {
  const BarraApp({super.key, this.titulo, this.subtitulo, this.oscura = false, this.grande = false, this.logo = false, this.atras = false, this.acciones = const [], this.hijo});
  final String? titulo, subtitulo;
  final bool oscura, grande, logo, atras;
  final List<AccionBarra> acciones;
  final Widget? hijo;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final arriba = MediaQuery.of(context).padding.top;
    final fila = Row(children: [
      if (atras) BotonIcono(icono: 'atras', etiqueta: 'Volver', oscuro: oscura, onPressed: () => Navigator.of(context).maybePop()),
      if (logo) Padding(padding: const EdgeInsets.only(left: 6), child: Logo(claro: oscura, alto: 30))
      else Expanded(child: Padding(padding: const EdgeInsets.only(left: 6), child: Semantics(container: true, header: true, child: Text(titulo ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontFamily: SiscanType.display, fontSize: 22, fontWeight: FontWeight.w700, color: oscura ? c.sobreBosque : c.tinta))))),
      if (logo) const Spacer(),
      for (final a in acciones) BotonIcono(icono: a.icono, etiqueta: a.etiqueta, cuenta: a.cuenta, oscuro: oscura, onPressed: a.onTap),
    ]);
    final cuerpo = Padding(
      padding: EdgeInsets.fromLTRB(14, arriba + 8, 14, oscura ? 22 : 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 48, child: fila),
        if (grande && logo) Padding(padding: const EdgeInsets.fromLTRB(6, 10, 6, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Semantics(container: true, header: true, child: Text(titulo ?? '', style: TextStyle(fontFamily: SiscanType.display, fontSize: 26, height: 32 / 26, fontWeight: FontWeight.w700, color: c.sobreBosque))),
          if (subtitulo != null) Padding(padding: const EdgeInsets.only(top: 3), child: Text(subtitulo!, style: TextStyle(fontSize: 14, color: c.sobreBosqueSuave))),
        ])),
        ?hijo,
      ]),
    );
    if (!oscura) return AnnotatedRegion<SystemUiOverlayStyle>(value: context.oscuro ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark, child: cuerpo);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF1C3628), c.bosqueHondo]),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30))),
        child: cuerpo,
      ),
    );
  }
}

enum Pestana { inicio, lotes, pesaje, equipo, mas }

/// sc-anav: cinco destinos; el activo en píldora con degradado salvia clara → salvia y texto blanco.
class BarraInferior extends StatelessWidget {
  const BarraInferior({super.key, required this.activa, required this.onCambio, this.alertas = 0});
  final Pestana activa;
  final ValueChanged<Pestana> onCambio;
  final int alertas;
  static const _tabs = [(Pestana.inicio, 'Inicio', 'inicio'), (Pestana.lotes, 'Lotes', 'lotes'), (Pestana.pesaje, 'Pesaje', 'balanza'), (Pestana.equipo, 'Equipo', 'ventilador'), (Pestana.mas, 'Más', 'menu')];
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(color: c.superficie, border: Border(top: BorderSide(color: c.linea))),
      padding: EdgeInsets.fromLTRB(4, 10, 4, 6 + MediaQuery.of(context).padding.bottom),
      child: Row(children: [for (final t in _tabs) Expanded(child: Semantics(container: true, 
        selected: t.$1 == activa, button: true, label: t.$2 + (t.$1 == Pestana.inicio && alertas > 0 ? ', $alertas alertas' : ''),
        child: InkWell(
          onTap: () => onCambio(t.$1),
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(constraints: const BoxConstraints(minHeight: SiscanSize.toque), child: ExcludeSemantics(child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedContainer(
              duration: SiscanMotion.rapida, width: 58, height: 32,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(999),
                  gradient: t.$1 == activa ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.salviaClara, c.salvia]) : null),
              child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
                Icono(t.$3, size: 22, color: t.$1 == activa ? Colors.white : c.tintaSuave),
                if (t.$1 == Pestana.inicio && alertas > 0) Positioned(top: -3, right: 6, child: Cuenta(alertas)),
              ]),
            ),
            const SizedBox(height: 3),
            Text(t.$2, style: TextStyle(fontSize: 11.5, fontWeight: t.$1 == activa ? FontWeight.w800 : FontWeight.w600, color: t.$1 == activa ? c.tinta : c.tintaSuave)),
          ]))),
        ),
      ))]),
    );
  }
}

/// sc-fab: 56 de alto, radio 18, degradado esmeralda → hoja y sombra activa.
class Fab extends StatelessWidget {
  const Fab({super.key, required this.icono, required this.etiqueta, this.texto, required this.onTap});
  final String icono, etiqueta;
  final String? texto;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(container: true, 
      button: true, label: etiqueta,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap, borderRadius: BorderRadius.circular(18),
          child: Ink(
            height: 56, padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), boxShadow: context.sombraActivo,
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.esmeralda, c.hoja])),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              // Enmienda al contrato (Diego, 2026-10-09): .sc-fab fija #ffffff, que en oscuro da 2,02:1 sobre esmeralda→hoja.
              // El texto toma sobre-hoja, como el botón primario: blanco en claro (igual que el sistema), bosque en oscuro.
              Icono('mas', size: 22, color: c.sobreHoja),
              if (texto != null) ...[const SizedBox(width: 8), Text(texto!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.sobreHoja))],
            ]),
          ),
        ),
      ),
    );
  }
}

/// Cuerpo de pantalla (sc-abody): contenido con margen de 14 y separación de 14 entre bloques.
class CuerpoPantalla extends StatelessWidget {
  const CuerpoPantalla({super.key, this.barra, required this.hijos, this.onRefrescar, this.abajo = 20});
  final Widget? barra;
  final List<Widget> hijos;
  final Future<void> Function()? onRefrescar;
  final double abajo;
  @override
  Widget build(BuildContext context) {
    final lista = ListView(
      padding: EdgeInsets.only(bottom: abajo),
      children: [
        ?barra,
        for (final h in hijos) Padding(padding: const EdgeInsets.fromLTRB(14, 14, 14, 0), child: h),
      ],
    );
    final cuerpo = onRefrescar == null ? lista : RefreshIndicator(onRefresh: onRefrescar!, color: context.c.hoja, child: lista);
    // Franja bajo la barra de estado: al desplazar, el contenido no pasa por detrás de la hora.
    final oscura = barra is BarraApp && (barra as BarraApp).oscura;
    final c = context.c;
    return Stack(children: [
      cuerpo,
      Positioned(top: 0, left: 0, right: 0, height: MediaQuery.of(context).padding.top, child: ColoredBox(color: oscura ? const Color(0xFF1C3628) : c.fondo)),
    ]);
  }
}
