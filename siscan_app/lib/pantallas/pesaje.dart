import 'dart:async';

import 'package:flutter/material.dart';

import '../app/comun.dart';
import '../app/contexto.dart';
import '../core/theme/siscan_theme.dart';
import '../core/theme/siscan_tokens.dart';
import '../core/ui/base.dart';
import '../core/ui/dominio.dart';
import '../core/ui/marco.dart';
import '../data/estado.dart';
import 'lotes.dart';

/// Pesaje (AndroidPesaje): cifra grande con − y +, humedad resultante, rango de retiro y la lista de pesajes.
class PantallaPesaje extends StatelessWidget {
  const PantallaPesaje({super.key, required this.onIngresar});
  final VoidCallback onIngresar;
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context);
    return ConEstado(builder: (context, b) {
      const barra = BarraApp(titulo: 'Pesaje');
      if (b == null) return const CuerpoPantalla(barra: barra, hijos: [Cargando()]);
      final l = b.activo;
      if (l == null) {
        return CuerpoPantalla(barra: barra, hijos: [EstadoVacio(titulo: 'Sin lote activo', texto: 'Inicia un lote para empezar a pesar la muestra cada mañana.', accion: 'Nuevo lote',
            onAccion: () => s.cabecera == null ? onIngresar() : Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaNuevoLote())))]);
      }
      return Pedido<(J, List<J>)>(
        clave: '${l['id']}-${l['sampleCount']}-${l['lastSampleAt']}',
        cargar: () async => (await s.api.calibracion(l['id'] as int), await s.api.curva(l['id'] as int)),
        builder: (context, d, e, cargando) => d == null
            ? CuerpoPantalla(barra: barra, hijos: [e != null ? ErrorCarga(detalle: '$e', onReintentar: s.estado.cargar) : const Cargando(texto: 'Cargando los pesajes…')])
            : _Pesaje(lote: l, cal: d.$1, curva: d.$2, onIngresar: onIngresar),
      );
    });
  }
}

class _Pesaje extends StatefulWidget {
  const _Pesaje({required this.lote, required this.cal, required this.curva, required this.onIngresar});
  final J lote, cal;
  final List<J> curva;
  final VoidCallback onIngresar;
  @override
  State<_Pesaje> createState() => _PesajeState();
}

class _PesajeState extends State<_Pesaje> {
  late double _g = _ultimo?['sampleWeightGrams'] != null ? (_ultimo!['sampleWeightGrams'] as num).toDouble() : (widget.lote['gravimetInitialWeightGrams'] as num?)?.toDouble() ?? 200;
  Timer? _rep;
  bool _o = false;
  List<J> get _lista => widget.curva.where((x) => x['sampleWeightGrams'] != null).toList();
  J? get _ultimo => _lista.lastOrNull;
  double get _seca => (widget.cal['dryMatterGrams'] as num?)?.toDouble() ??
      ((widget.lote['gravimetInitialWeightGrams'] as num? ?? 200) * (1 - ((widget.lote['gravimetInitialMoisturePct'] as num?) ?? 53) / 100)).toDouble();
  void _paso(double d) => setState(() => _g = ((_g + d) * 10).round() / 10);
  void _repetir(double d) { _rep?.cancel(); _rep = Timer.periodic(const Duration(milliseconds: 90), (_) => _paso(d)); }
  @override
  void dispose() { _rep?.cancel(); super.dispose(); }

  Future<void> _escribir() async {
    final ctl = TextEditingController(text: cifra(_g));
    final v = await showDialog<double>(context: context, builder: (d) => AlertDialog(
      title: const Text('Peso de la muestra'),
      content: Campo(controller: ctl, sufijo: 'g', teclado: const TextInputType.numberWithOptions(decimal: true), grande: true),
      actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(d, double.tryParse(ctl.text.replaceAll('.', '').replaceAll(',', '.'))), child: const Text('Listo'))],
    ));
    if (v != null && v > 0) setState(() => _g = v);
  }

  Future<void> _corregir(J x) async {
    final s = Siscan.of(context);
    if (s.cabecera == null) { widget.onIngresar(); return; }
    final ctl = TextEditingController(text: cifra(x['sampleWeightGrams'] as num));
    final r = await showModalBottomSheet<String>(context: context, backgroundColor: context.c.superficie, isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(SiscanRadius.xl))),
        builder: (d) => Padding(
          padding: EdgeInsets.fromLTRB(22, 14, 22, 22 + MediaQuery.of(d).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: context.c.lineaFuerte.withValues(alpha: .5), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Text('Corregir pesaje · ${corta(fecha(x['timestamp']))}', style: TextStyle(fontFamily: SiscanType.display, fontSize: 20, fontWeight: FontWeight.w700, color: context.c.tinta)),
            const SizedBox(height: 14),
            Campo(etiqueta: 'Peso corregido', controller: ctl, sufijo: 'g', teclado: const TextInputType.numberWithOptions(decimal: true), grande: true),
            const SizedBox(height: 14),
            Boton('Guardar', variante: VarianteBoton.primary, grande: true, bloque: true, onPressed: () => Navigator.pop(d, 'guardar')),
            const SizedBox(height: 8),
            Boton('Eliminar pesaje', icono: 'borrar', variante: VarianteBoton.danger, bloque: true, onPressed: () => Navigator.pop(d, 'eliminar')),
          ]),
        ));
    if (!mounted || r == null) return;
    final lote = widget.lote['id'] as int, id = x['id'] as int;
    if (r == 'guardar') {
      final g = double.tryParse(ctl.text.replaceAll('.', '').replaceAll(',', '.'));
      if (g == null || g <= 0) { aviso(context, 'Escribe el peso corregido en gramos.', error: true); return; }
      await s.hacer(context, (h) => s.api.corregirPesaje(lote, id, g, h), 'Pesaje corregido');
    } else {
      await s.hacer(context, (h) => s.api.eliminarPesaje(lote, id, h), 'Pesaje eliminado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c, s = Siscan.of(context);
    final hum = (1 - _seca / _g) * 100;
    final (ver, col) = hum > 12 ? ('Todavía le falta secar', c.pausa) : hum >= 10 ? ('Está en el rango comercial: retíralo', c.operando) : ('Ya pasó el punto: está sobre-secado', c.alerta);
    Widget redondo(String ic, String et, double d) => Semantics(container: true, button: true, label: et, child: GestureDetector(
          onTap: () => _paso(d), onLongPressStart: (_) => _repetir(d * 10), onLongPressEnd: (_) => _rep?.cancel(),
          child: Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: c.superficie, boxShadow: context.sombraTarjeta),
              child: Icono(ic, size: 22, color: c.cafe))));
    return CuerpoPantalla(barra: const BarraApp(titulo: 'Pesaje'), onRefrescar: s.estado.cargar, hijos: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        decoration: BoxDecoration(color: c.cafeSuave, borderRadius: BorderRadius.circular(26)),
        child: Column(children: [
          Text('Peso de la muestra · ${widget.lote['name']}', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.tintaSuave)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            redondo('menos', 'Restar 0,1 g', -.1),
            const SizedBox(width: 16),
            Flexible(child: Semantics(container: true, button: true, label: 'Peso ${cifra(_g)} gramos. Toca para escribirlo.', child: GestureDetector(onTap: _escribir, child: FittedBox(child: Text.rich(TextSpan(children: [
              TextSpan(text: cifra(_g), style: TextStyle(fontFamily: SiscanType.display, fontSize: 52, height: 56 / 52, fontWeight: FontWeight.w700, color: c.cafe, fontFeatures: const [FontFeature.tabularFigures()])),
              TextSpan(text: ' g', style: TextStyle(fontSize: 22, color: c.tintaSuave)),
            ])))))),
            const SizedBox(width: 16),
            redondo('mas', 'Sumar 0,1 g', .1),
          ]),
          const SizedBox(height: 8),
          Text('= ${cifra(hum)} % · $ver', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: col)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icono('balanza', size: 18, color: c.tintaSuave), const SizedBox(width: 6),
            Text.rich(TextSpan(text: 'Retira entre ', style: TextStyle(fontSize: 13, color: c.tintaSuave),
                children: [TextSpan(text: '${cifra(_seca / .90)} y ${cifra(_seca / .88)} g', style: TextStyle(fontWeight: FontWeight.w700, color: c.cafe))])),
          ]),
        ]),
      ),
      Boton('Registrar pesaje', icono: 'check', variante: VarianteBoton.primary, grande: true, bloque: true, ocupado: _o,
          onPressed: s.cabecera == null ? widget.onIngresar : () async {
            setState(() => _o = true);
            await s.hacer(context, (h) => s.api.pesaje(widget.lote['id'] as int, _g, h), 'Pesaje registrado', detalle: '${cifra(_g)} g · ${cifra(hum)} % de humedad');
            if (mounted) setState(() => _o = false);
          }),
      if (s.cabecera == null) Text('Para registrar pesajes, ingresa con tu cuenta.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.tintaSuave)),
      Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TituloTarjeta(icono: 'historial', titulo: 'Pesajes de ${widget.lote['name']}'),
        if (_lista.isEmpty) Text('Todavía no hay pesajes de este lote.', style: TextStyle(fontSize: 14, color: c.tintaSuave)),
        for (final (i, x) in _lista.reversed.indexed) InkWell(
          onTap: () => _corregir(x),
          child: Container(
            constraints: const BoxConstraints(minHeight: SiscanSize.toque), padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(border: i == _lista.length - 1 ? null : Border(bottom: BorderSide(color: c.linea))),
            child: Row(children: [
              Expanded(child: Text(corta(fecha(x['timestamp'])), style: TextStyle(fontSize: 13.5, color: c.tinta))),
              Text('${cifra(x['sampleWeightGrams'] as num)} g', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.tinta)),
              SizedBox(width: 72, child: Text('${cifra(x['calculatedMoisturePct'] as num?)} %', textAlign: TextAlign.right, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: c.cafe))),
            ]),
          ),
        ),
        Pie('Humedad por conservación de materia seca (Cenicafé)${widget.cal['source'] == 'MEASURED' ? ', ajustada con puntos medidos' : ''}: ${cifra(_seca)} g de materia seca. Toca un pesaje para corregirlo.'),
      ])),
    ]);
  }
}
