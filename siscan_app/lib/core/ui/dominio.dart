/// Componentes de dominio del sistema SISCAN v2: Landscape, ActuatorRow, HoldButton, SensorRow, AlertList,
/// HealthCard, DryerMap, DryerPhoto, ListItem, EmptyState y CommandLog.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/siscan_theme.dart';
import '../theme/siscan_tokens.dart';
import 'base.dart';

/// Paisaje del secador en el cafetal (03-ilustración), exportado tal cual del componente Landscape del sistema.
/// La variante sigue la hora real; el aire fluye si hay ventiladores encendidos y la cámara brilla con calor.
class Paisaje extends StatelessWidget {
  const Paisaje({super.key, this.encuadre = 'completo', this.aire = true, this.calor = false, this.alineacion = Alignment.center, this.variante});
  final String encuadre;
  final bool aire, calor;
  final Alignment alineacion;
  final String? variante;
  static String momento([DateTime? t]) {
    final h = co(t ?? DateTime.now()).hour; // hora de Colombia, como el resto de la app
    return h >= 6 && h < 17 ? 'day' : h >= 17 && h < 19 ? 'dusk' : 'night';
  }
  @override
  Widget build(BuildContext context) {
    final v = variante ?? momento();
    final nombre = encuadre == 'completo' ? '$v${aire ? '-aire' : ''}${calor ? '-calor' : ''}-completo' : '$v-aire-$encuadre';
    return ExcludeSemantics(child: SvgPicture.asset('assets/sistema/paisaje/$nombre.svg', fit: BoxFit.cover, alignment: alineacion));
  }
}

/// ActuatorRow: ícono, nombre, potencia, estado en palabra y el interruptor. Pendiente → «Encendiendo…».
class FilaActuador extends StatelessWidget {
  const FilaActuador({super.key, required this.nombre, required this.calefactor, required this.encendido, required this.vatios, this.desde,
      this.pendiente = false, this.auto = false, this.soloLectura = false, this.bloqueado, this.onChanged, this.mostrarMeta = true});
  final String nombre;
  /// `soloLectura`: sin sesión el interruptor no responde, pero el texto sigue diciendo lo que es el equipo.
  final bool calefactor, encendido, pendiente, auto, soloLectura, mostrarMeta;
  final double vatios;
  final String? desde, bloqueado;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final st = bloqueado != null ? 'blocked' : pendiente ? 'pending' : encendido ? 'on' : 'off';
    final etiqueta = {'on': 'Encendido', 'off': 'Apagado', 'blocked': 'Bloqueado', 'pending': encendido ? 'Apagando…' : 'Encendiendo…'}[st]!;
    final colEstado = {'on': c.operando, 'blocked': c.alerta, 'pending': c.pausa}[st] ?? c.tintaSuave;
    final meta = bloqueado != null ? 'Bloqueado por seguridad · $bloqueado' : auto ? 'Controlado por el protocolo' : 'Nominal ${cifra(vatios, 0)} W${desde != null ? ' · $desde' : ''}';
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: st == 'blocked' ? c.alertaSuave : encendido ? c.superficieHoja : c.fondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: encendido && st != 'blocked' ? c.hoja.withValues(alpha: .18) : Colors.transparent),
      ),
      child: Row(children: [
        Container(width: 40, height: 40, alignment: Alignment.center,
            decoration: BoxDecoration(color: st == 'blocked' ? c.alerta : encendido ? c.hoja : c.superficieFuerte, borderRadius: BorderRadius.circular(12)),
            child: IconoEquipo(calefactor: calefactor, encendido: encendido, color: encendido || st == 'blocked' ? Colors.white : c.tintaSuave)),
        const SizedBox(width: SiscanSpace.s3),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(nombre, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.tinta)),
          if (mostrarMeta) Text(meta, style: TextStyle(fontSize: 12, color: c.tintaSuave)),
        ])),
        if (st == 'pending') ...[SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: colEstado)), const SizedBox(width: 5)]
        else if (st == 'blocked') ...[Icono('candado', size: 13, color: colEstado), const SizedBox(width: 5)],
        Text(etiqueta, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colEstado)),
        Interruptor(valor: encendido, etiqueta: nombre, onChanged: auto || soloLectura || bloqueado != null || pendiente ? null : onChanged),
      ]),
    );
  }
}

/// HoldButton: hay que mantener presionado (el relleno avanza) para encender una resistencia.
class BotonMantener extends StatefulWidget {
  const BotonMantener({super.key, required this.texto, required this.onCompleto, this.hecho = 'Orden enviada', this.activo = true});
  final String texto, hecho;
  final VoidCallback onCompleto;
  final bool activo;
  @override
  State<BotonMantener> createState() => _BotonMantenerState();
}

class _BotonMantenerState extends State<BotonMantener> {
  double _p = 0;
  Timer? _t;
  bool _hecho = false;
  void _inicio() {
    if (!widget.activo || _hecho) return;
    _t?.cancel();
    _t = Timer.periodic(const Duration(milliseconds: 60), (t) {
      setState(() => _p = (_p + 8).clamp(0, 100));
      if (_p >= 100) { t.cancel(); setState(() => _hecho = true); widget.onCompleto(); Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() { _hecho = false; _p = 0; }); }); }
    });
  }
  void _fin() { _t?.cancel(); if (!_hecho) setState(() => _p = 0); }
  @override
  void dispose() { _t?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(container: true, 
      button: true, enabled: widget.activo, label: widget.texto, hint: 'Mantén presionado. Con lector de pantalla, toca dos veces y mantén.',
      onLongPress: widget.activo ? widget.onCompleto : null,
      child: GestureDetector(
        onTapDown: (_) => _inicio(), onTapUp: (_) => _fin(), onTapCancel: _fin,
        child: Opacity(
          opacity: widget.activo ? 1 : .55,
          child: Container(
            height: 54, clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: c.superficieHoja, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.hoja, width: 1.5)),
            child: Stack(children: [
              FractionallySizedBox(widthFactor: _p / 100, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [c.hoja, c.broteVivo])))),
              Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icono(_hecho ? 'check' : 'encendido', size: 18, color: _hecho ? Colors.white : c.hoja),
                const SizedBox(width: 8),
                Flexible(child: Text(_hecho ? widget.hecho : widget.texto, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _hecho ? Colors.white : c.hoja))),
              ])),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Cuadro teñido de 36 (sc-sq) con el ícono de una magnitud o estado.
class Cuadro extends StatelessWidget {
  const Cuadro({super.key, required this.icono, required this.color});
  final String icono;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(width: SiscanSize.iconoFondo, height: SiscanSize.iconoFondo, alignment: Alignment.center,
      decoration: BoxDecoration(color: mezcla(color, .13, context.c.superficie), borderRadius: BorderRadius.circular(11)), child: Icono(icono, size: 18, color: color));
}

/// SensorRow: magnitud, metadatos, valor y frescura (en vivo, desactualizado o sin conexión).
class FilaSensor extends StatelessWidget {
  const FilaSensor({super.key, required this.nombre, required this.meta, required this.valor, required this.icono, required this.color, required this.estado, this.estadoTexto, this.ultima = false});
  final String nombre, meta, valor, icono;
  final Color color;
  final Estado estado;
  final String? estadoTexto;
  final bool ultima;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(border: ultima ? null : Border(bottom: BorderSide(color: c.linea))),
      child: Row(children: [
        Cuadro(icono: icono, color: color),
        const SizedBox(width: SiscanSpace.s3),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(nombre, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.tinta)),
          Text(meta, style: TextStyle(fontSize: 12, color: c.tintaSuave)),
        ])),
        Text(valor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.tinta, fontFeatures: const [FontFeature.tabularFigures()])),
        const SizedBox(width: 8),
        Pildora(estado: estado, chica: true, texto: estadoTexto),
      ]),
    );
  }
}

/// AlertItem: severidad con cuadro teñido, título, dato y hora.
class ItemAlerta {
  const ItemAlerta({required this.severidad, required this.titulo, required this.meta, required this.hora, this.icono});
  final String severidad, titulo, meta, hora;
  final String? icono;
}

class ListaAlertas extends StatelessWidget {
  const ListaAlertas({super.key, required this.items, this.titulo = 'Alertas recientes', this.onVerTodas});
  final List<ItemAlerta> items;
  final String titulo;
  final VoidCallback? onVerTodas;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TituloTarjeta(icono: 'alertas', titulo: titulo, derecha: onVerTodas == null ? null : TextButton(onPressed: onVerTodas,
          style: TextButton.styleFrom(minimumSize: const Size(SiscanSize.toque, SiscanSize.toque)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Ver todas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.hoja)), Icono('chevron', size: 14, color: c.hoja)]))),
      if (items.isEmpty) Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: c.operandoSuave, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [Icono('checkCirculo', size: 22, color: c.operando), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sin alertas activas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.operando)),
          Text('Todo en orden.', style: TextStyle(fontSize: 13, color: c.operando)),
        ]))]),
      )
      else for (final (i, a) in items.indexed) Padding(
        padding: EdgeInsets.only(top: i == 0 ? 0 : SiscanSpace.s3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Cuadro(icono: a.icono ?? {'critical': 'termometro', 'ok': 'checkCirculo', 'info': 'info'}[a.severidad] ?? 'aviso',
              color: {'critical': c.alerta, 'ok': c.operando, 'info': c.info}[a.severidad] ?? c.pausa),
          const SizedBox(width: SiscanSpace.s3),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.tinta)),
            if (a.meta.isNotEmpty) Text(a.meta, style: TextStyle(fontSize: 12, color: c.tintaSuave)),
          ])),
          Text(a.hora, style: TextStyle(fontSize: 12, color: c.tintaSuave)),
        ]),
      ),
    ]));
  }
}

/// HealthCard: «¿Está funcionando el equipo?» con veredicto y comprobaciones.
class Salud extends StatelessWidget {
  const Salud({super.key, required this.filas});
  final List<(String, String, bool)> filas;
  @override
  Widget build(BuildContext context) {
    final c = context.c, ok = filas.every((f) => f.$3);
    return Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const TituloTarjeta(icono: 'secador', titulo: '¿Está funcionando el equipo?'),
      Row(children: [Icono(ok ? 'checkCirculo' : 'aviso', size: 22, color: ok ? c.operando : c.pausa), const SizedBox(width: 8),
        Text(ok ? 'Sí, todo en orden' : 'Revisa el equipo', style: TextStyle(fontFamily: SiscanType.display, fontSize: 20, fontWeight: FontWeight.w700, color: ok ? c.operando : c.pausa))]),
      const SizedBox(height: SiscanSpace.s3),
      for (final f in filas) Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: Icono(f.$3 ? 'check' : 'x', size: 15, color: f.$3 ? c.operando : c.alerta)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(f.$1, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: c.tinta)),
          Text(f.$2, style: TextStyle(fontSize: 12, color: c.tintaSuave)),
        ])),
      ])),
    ]));
  }
}

/// DryerMap: mapa esquemático de Nariño (relieve, curvas de nivel, río, vía y municipios) con un pin por secador.
class MapaSecadores extends StatelessWidget {
  const MapaSecadores({super.key, required this.pines, this.alto = 210});
  final List<(double, double, Estado, String?)> pines;
  final double alto;
  static const pueblos = [('Pasto', 250.0, 172.0), ('Chachagüí', 222.0, 92.0), ('La Unión', 330.0, 54.0), ('Sandoná', 120.0, 150.0), ('Ipiales', 175.0, 228.0)];
  String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  @override
  Widget build(BuildContext context) {
    final c = context.c, osc = context.oscuro;
    final pueblo = osc ? c.sobreBosque : c.bosque, borde = osc ? 'rgba(0,0,0,.55)' : 'rgba(255,255,255,.85)';
    final curvas = [60, 85, 110, 140, 170, 200, 230].map((y) => '<path d="M-10 $y C80 ${y - 30} 160 ${y + 25} 240 ${y - 12} S360 ${y - 28} 430 ${y - 6}"/>').join();
    final svg = StringBuffer('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 260" preserveAspectRatio="xMidYMid slice">'
        '<rect width="420" height="260" fill="${_hex(c.superficieHoja)}"/>'
        '<path fill="${_hex(c.brote)}" d="M0 70 C60 40 120 80 180 50 S300 30 420 60 V260 H0 Z"/>'
        '<path fill="${_hex(c.broteVivo)}" fill-opacity=".5" d="M0 130 C70 100 140 150 220 110 S340 90 420 120 V260 H0 Z"/>'
        '<path fill="${_hex(c.hoja)}" fill-opacity=".45" d="M0 195 C80 165 170 215 250 185 S360 165 420 190 V260 H0 Z"/>'
        '<g fill="none" stroke="${_hex(c.bosque)}" stroke-opacity=".14">$curvas</g>'
        '<path fill="none" stroke="${_hex(c.datoExterior)}" stroke-width="3.5" stroke-opacity=".55" stroke-linecap="round" d="M20 260 C70 220 80 190 140 168 S230 132 262 92 S330 46 370 0"/>'
        '<path fill="none" stroke="#ffffff" stroke-width="3" stroke-dasharray="8 6" stroke-opacity=".85" stroke-linecap="round" d="M175 228 C200 205 230 190 250 172 S240 120 222 92 S290 70 330 54"/>');
    for (final p in pueblos) {
      svg.write('<circle cx="${p.$2}" cy="${p.$3}" r="3" fill="${_hex(pueblo)}"/>'
          // flutter_svg no admite paint-order: el borde se dibuja primero como texto aparte y el relleno encima.
          '<text x="${p.$2 + 6}" y="${p.$3 + 4}" font-size="11" font-weight="800" font-family="PlusJakartaSans" fill="none" stroke="$borde" stroke-width="3" stroke-linejoin="round">${p.$1}</text>'
          '<text x="${p.$2 + 6}" y="${p.$3 + 4}" font-size="11" font-weight="800" font-family="PlusJakartaSans" fill="${_hex(pueblo)}">${p.$1}</text>');
    }
    for (final p in pines) {
      final (col, _) = colorEstado(c, p.$3);
      svg.write('<g transform="translate(${p.$1} ${p.$2})"><path d="M0 0 C-3 -6 -11 -12 -11 -20 A11 11 0 0 1 11 -20 C11 -12 3 -6 0 0 Z" fill="${_hex(col)}" stroke="#ffffff" stroke-width="2"/>'
          '<circle cy="-20" r="4" fill="#ffffff"/>${p.$4 != null ? '<text x="14" y="-16" font-size="11" font-weight="800" font-family="PlusJakartaSans" fill="none" stroke="${_hex(c.superficie)}" stroke-width="3" stroke-linejoin="round">${p.$4}</text>'
          '<text x="14" y="-16" font-size="11" font-weight="800" font-family="PlusJakartaSans" fill="${_hex(c.tinta)}">${p.$4}</text>' : ''}</g>');
    }
    svg.write('</svg>');
    return Semantics(container: true, 
      label: 'Mapa esquemático de Nariño con ${pines.length} ${pines.length == 1 ? 'secador' : 'secadores'}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(height: alto, width: double.infinity, child: Stack(children: [
          Positioned.fill(child: SvgPicture.string(svg.toString(), fit: BoxFit.cover)),
          Positioned(left: 12, bottom: 10, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
            decoration: BoxDecoration(color: osc ? c.sobreBosque : Colors.white.withValues(alpha: .75), borderRadius: BorderRadius.circular(999)),
            child: Text('Nariño', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c.bosque)))),
        ])),
      ),
    );
  }
}

/// StatusLegend: conteo de secadores por estado.
class LeyendaEstados extends StatelessWidget {
  const LeyendaEstados({super.key, required this.cuenta});
  final Map<Estado, int> cuenta;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    const nombres = {Estado.running: 'En operación', Estado.paused: 'En pausa', Estado.alert: 'Alerta', Estado.offline: 'Sin conexión'};
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.fondo, borderRadius: BorderRadius.circular(14)),
      child: Wrap(spacing: 14, runSpacing: 8, children: [for (final e in Estado.values) Row(mainAxisSize: MainAxisSize.min, children: [
        PuntoVivo(color: colorEstado(c, e).$1, vivo: false, hueco: e == Estado.offline), const SizedBox(width: 8),
        Text(nombres[e]!, style: TextStyle(fontSize: 13, color: c.tinta)), const SizedBox(width: 6),
        Text('${cuenta[e] ?? 0}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.tinta)),
      ])]),
    );
  }
}

/// ListItem: cuadro con ícono, título, subtítulo y chevron (o un control a la derecha).
class ElementoLista extends StatelessWidget {
  const ElementoLista({super.key, required this.icono, required this.titulo, this.sub, this.derecha, this.onTap, this.peligro = false, this.ultimo = false});
  final String icono, titulo;
  final String? sub;
  final Widget? derecha;
  final VoidCallback? onTap;
  final bool peligro, ultimo;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(container: true, 
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(border: ultimo ? null : Border(bottom: BorderSide(color: c.linea))),
          child: Row(children: [
            Cuadro(icono: icono, color: peligro ? c.alerta : c.hoja),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: peligro ? c.alerta : c.tinta)),
              if (sub != null) Text(sub!, style: TextStyle(fontSize: 12.5, color: c.tintaSuave)),
            ])),
            derecha ?? Icono('chevron', size: 18, color: c.tintaSuave),
          ]),
        ),
      ),
    );
  }
}

/// EmptyState: paisaje, título en Outfit, texto y acción.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({super.key, required this.titulo, required this.texto, this.accion, this.onAccion, this.icono = 'mas'});
  final String titulo, texto, icono;
  final String? accion;
  final VoidCallback? onAccion;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Tarjeta(child: Column(children: [
      ClipRRect(borderRadius: BorderRadius.circular(16), child: const SizedBox(height: 150, width: double.infinity, child: Paisaje(encuadre: 'vacio', variante: 'day'))),
      const SizedBox(height: 16),
      Text(titulo, textAlign: TextAlign.center, style: TextStyle(fontFamily: SiscanType.display, fontSize: 20, fontWeight: FontWeight.w700, color: c.tinta)),
      const SizedBox(height: 6),
      Text(texto, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: c.tintaSuave)),
      if (accion != null) ...[const SizedBox(height: 14), Boton(accion!, variante: VarianteBoton.primary, icono: icono, onPressed: onAccion)],
    ]));
  }
}

/// CommandLog: órdenes al equipo con hora, acción y origen (sin afirmar confirmaciones que el servidor no da).
class RegistroOrdenes extends StatelessWidget {
  const RegistroOrdenes({super.key, required this.items});
  final List<(String, String, String)> items;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (items.isEmpty) return Text('Sin órdenes registradas todavía.', style: TextStyle(fontSize: 14, color: c.tintaSuave));
    return Column(children: [for (final (i, o) in items.indexed) IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(width: 56, child: Text(o.$1, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.tintaSuave, fontFeatures: const [FontFeature.tabularFigures()]))),
      const SizedBox(width: 10),
      SizedBox(width: 14, child: Stack(alignment: Alignment.topCenter, children: [
        if (i < items.length - 1) Positioned(top: 16, bottom: 0, child: Container(width: 2, color: c.linea)),
        Container(margin: const EdgeInsets.only(top: 3), width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: c.operando, boxShadow: [BoxShadow(color: c.operandoSuave, spreadRadius: 3)])),
      ])),
      const SizedBox(width: 10),
      Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(o.$2, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: c.tinta)),
        Text(o.$3, style: TextStyle(fontSize: 12, color: c.tintaSuave)),
      ]))),
    ]))]);
  }
}
