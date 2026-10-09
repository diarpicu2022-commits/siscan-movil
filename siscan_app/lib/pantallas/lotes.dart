import 'package:flutter/material.dart';

import '../app/comun.dart';
import '../app/contexto.dart';
import '../core/theme/siscan_theme.dart';
import '../core/theme/siscan_tokens.dart';
import '../core/ui/base.dart';
import '../core/ui/datos.dart';
import '../core/ui/dominio.dart';
import '../core/ui/marco.dart';
import '../data/estado.dart';

/// Lotes: historial con filtro por sitio; toca uno para su curva, predicción y proceso. FAB «Nuevo lote».
class PantallaLotes extends StatefulWidget {
  const PantallaLotes({super.key, required this.onIngresar});
  final VoidCallback onIngresar;
  @override
  State<PantallaLotes> createState() => _PantallaLotesState();
}

class _PantallaLotesState extends State<PantallaLotes> {
  String _filtro = 't';
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context);
    return Stack(children: [
      ConEstado(builder: (context, b) {
        final barra = BarraApp(titulo: 'Lotes', acciones: [AccionBarra('actualizar', 'Actualizar', s.estado.cargar)]);
        if (b == null) return CuerpoPantalla(barra: barra, hijos: const [Cargando()]);
        final lotes = b.lotes.where((l) => _filtro == 't' || (_filtro == 's' ? l['dryingSite'] != 'OPEN_AIR' : l['dryingSite'] == 'OPEN_AIR')).toList();
        return CuerpoPantalla(barra: barra, abajo: 96, onRefrescar: s.estado.cargar, hijos: [
          Segmentado<String>(bloque: true, etiqueta: 'Filtro', valor: _filtro, onChanged: (v) => setState(() => _filtro = v),
              opciones: const [('t', 'Todos', null), ('s', 'Secador', 'secador'), ('a', 'Aire libre', 'sol')]),
          if (lotes.isEmpty) EstadoVacio(titulo: 'No hay lotes registrados', texto: _filtro == 't' ? 'Cuando ingreses café al secador, su registro aparecerá aquí.' : 'No hay lotes con este filtro.')
          else Tarjeta(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: [
            for (final (i, l) in lotes.indexed) ElementoLista(
              icono: 'grano', titulo: l['name'] as String, ultimo: i == lotes.length - 1,
              sub: '${sitioLote(l)} · ${corta(fecha(l['startedAt']))}\n${duracion(l['status'] == 'RUNNING' ? minutosDesde(fecha(l['startedAt'])) / 60 : l['durationHours'] as num?).replaceAll(' ', '\u00a0')}'
                  '${l['lastMoisturePct'] != null ? ' · ${cifra(l['lastMoisturePct'] as num)}\u00a0%' : ''}',
              derecha: Pildora(estado: l['status'] == 'RUNNING' ? Estado.running : Estado.paused, chica: true, vivo: l['status'] == 'RUNNING', texto: l['status'] == 'RUNNING' ? 'Secando' : 'Terminado'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PantallaLote(id: l['id'] as int))),
            ),
          ])),
        ]);
      }),
      Positioned(right: 18, bottom: 18, child: Fab(icono: 'mas', etiqueta: 'Nuevo lote', texto: 'Nuevo lote',
          onTap: () => s.cabecera == null ? widget.onIngresar() : Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaNuevoLote())))),
    ]);
  }
}

/// Detalle de lote: fichas, curva de humedad, predicción de IA (tesis + red neuronal + Groq) y proceso vertical.
class PantallaLote extends StatelessWidget {
  const PantallaLote({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context);
    return Scaffold(body: ConEstado(builder: (context, base) => Pedido<(J, List<J>)>(
      clave: '$id-${(base?.cargadoEn.millisecondsSinceEpoch ?? 0) ~/ 60000}',
      cargar: () async {
        final r = await s.api.lote(id);
        return ((r['batch'] as Map).cast<String, dynamic>(), await s.api.curva(id));
      },
      builder: (context, d, e, cargando) {
        if (d == null) {
          return CuerpoPantalla(barra: const BarraApp(titulo: 'Lote', atras: true), hijos: [e != null ? ErrorCarga(detalle: '$e', onReintentar: s.estado.cargar) : const Cargando(texto: 'Cargando el lote…')]);
        }
        final (l, curva) = d;
        final pts = curva.where((x) => x['calculatedMoisturePct'] != null).toList();
        final vistos = <String>{};
        final etiquetas = [for (final (i, x) in pts.indexed) () { final dd = dia(fecha(x['timestamp'])); final r = i == 0 ? 'I' : (vistos.contains(dd) ? '' : dd); vistos.add(dd); return r; }()];
        return CuerpoPantalla(barra: BarraApp(titulo: l['name'] as String, atras: true), hijos: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            Ficha(sitioLote(l), icono: l['dryingSite'] == 'OPEN_AIR' ? 'sol' : 'secador'),
            Ficha(protocoloCorto(l), tono: 'neutral'),
            if (l['lastMoisturePct'] != null) Ficha('${cifra(l['lastMoisturePct'] as num)} %', tono: 'cafe', icono: 'grano'),
          ]),
          Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const TituloTarjeta(icono: 'grafica', titulo: 'Curva de humedad'),
            CurvaHumedad(datos: pts.map((x) => ((x['calculatedMoisturePct'] as num) * 10).round() / 10).toList(), etiquetas: etiquetas),
          ])),
          ...BloquePrediccion.de(context, l),
          Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const TituloTarjeta(icono: 'monitoreo', titulo: 'Proceso'),
            Fases(fases: fasesLote(l, curva)),
          ])),
        ]);
      },
    )));
  }
}

/// Fases del lote: solo se fecha lo que los datos permiten; lo demás «Sin registro».
List<(String, EstadoFase, String)> fasesLote(J b, List<J> curva) {
  final pts = curva.where((x) => x['calculatedMoisturePct'] != null).toList();
  DateTime? primera(bool Function(double) cond) { final x = pts.where((p) => cond((p['calculatedMoisturePct'] as num).toDouble())).firstOrNull; return x == null ? null : fecha(x['timestamp']); }
  final cerrado = b['status'] != 'RUNNING', obj = (b['targetMoisturePct'] as num?)?.toDouble() ?? 11;
  final t = [fecha(b['startedAt']), null, pts.isEmpty ? null : fecha(pts.first['timestamp']), primera((v) => v <= 30), primera((v) => v <= obj + 2), cerrado ? fecha(b['endedAt']) : null];
  const nombres = ['Inicio', 'Calentamiento', 'Secado activo', 'Reducción de humedad', 'Ajustes', 'Finalización'];
  var ultima = -1;
  for (var i = 0; i < t.length; i++) { if (t[i] != null) ultima = i; }
  final actual = cerrado ? 6 : ultima.clamp(0, 4);
  return [for (var i = 0; i < 6; i++) () {
    final st = i < actual ? EstadoFase.hecha : i == actual ? EstadoFase.ahora : EstadoFase.pendiente;
    final txt = t[i] != null ? (st == EstadoFase.ahora ? 'En curso · desde ${corta(t[i])}' : corta(t[i])) : st == EstadoFase.hecha ? 'Sin registro' : st == EstadoFase.ahora ? 'En curso' : 'Pendiente';
    return (nombres[i], st, txt);
  }()];
}

/// Predicción de IA en dos fuentes (decisión de Diego): el modelo de la tesis (PredictionCard), la red neuronal de la
/// tesis (estado de los sensores) y la segunda opinión de Groq a pedido.
class BloquePrediccion {
  static List<Widget> de(BuildContext context, J l, {bool compacta = false}) {
    final s = Siscan.of(context);
    return [
      Pedido<J>(
        clave: '${l['id']}-${l['sampleCount']}-${l['lastSampleAt']}',
        cargar: () => s.api.prediccion(l['id'] as int),
        builder: (context, p, e, cargando) {
          if (p != null && p['estado'] == 'EN_CURSO') {
            final c = context.c;
            return TarjetaPrediccion(
              compacta: compacta, valor: duracion(p['horasRestantes'] as num?), confianza: (p['confianza'] as num?)?.toInt(),
              rango: Text.rich(TextSpan(children: [const TextSpan(text: 'Entre '), TextSpan(text: duracion(p['horasMin'] as num?), style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta)),
                const TextSpan(text: ' y '), TextSpan(text: duracion(p['horasMax'] as num?), style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta)),
                const TextSpan(text: ' · listo cerca de las '), TextSpan(text: corta(fecha(p['fechaEstimada'])), style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta))])),
              entradas: [('${p['pesajes']} pesajes', 'balanza'), ('Lewis · Page · Henderson-Pabis', 'grafica'), ('${p['ajustes']} ajustes bootstrap', 'ia')],
              pie: p['fiable'] == true ? null : 'Solo ${p['pesajes']} pesajes: por debajo de ${p['minimoFiable']} la tesis lo considera orientativo.',
            );
          }
          final (v, t) = p == null ? ('—', cargando ? 'Ajustando los modelos de la tesis…' : 'No fue posible calcular la predicción.') : switch (p['estado']) {
            'OBJETIVO_ALCANZADO' => ('Listo', 'La muestra está en ${cifra(p['humedadActual'] as num)} %: dentro de la ventana comercial. Retíralo.'),
            'SOBRESECADO' => ('Pasado', 'La muestra está en ${cifra(p['humedadActual'] as num)} %, por debajo del 10 %: está sobre-secado.'),
            'NO_ALCANZABLE' => ('No llega', p['nota'] as String? ?? ''),
            _ => ('—', p['nota'] as String? ?? 'Pocos pesajes para predecir.'),
          };
          final pm = (p?['porModelo'] as Map?)?.cast<String, dynamic>();
          return TarjetaPrediccion(valor: v, rango: Text(t), compacta: compacta,
              pie: pm == null ? null : 'Punto de retiro por modelo: ${pm.entries.map((e) => '${e.key.replaceAll('HendersonPabis', 'Henderson-Pabis')} ${e.value != null ? '${(e.value as num).round()} h' : 'no llega'}').join(' · ')} desde el primer pesaje.');
        },
      ),
      const RedNeuronal(),
      OpinionIA(lote: l['id'] as int),
    ];
  }
}

/// Red neuronal de la tesis (MLP 32×16, F1 0,90): estado de cada sensor según 2 h de su señal.
class RedNeuronal extends StatelessWidget {
  const RedNeuronal({super.key});
  @override
  Widget build(BuildContext context) => ConEstado(builder: (context, b) {
        final g = b?.diagnostico;
        if (g == null) return const SizedBox.shrink();
        final sens = ((g['sensores'] as List?) ?? const []).cast<J>();
        final fallas = sens.where((x) => x['clase'] != null && x['clase'] != 'ok').length;
        return Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TituloTarjeta(icono: 'ia', titulo: 'Red neuronal · sensores', derecha: Pildora(estado: fallas > 0 ? Estado.alert : Estado.running, chica: true, texto: fallas > 0 ? '$fallas con falla' : 'Sin fallas')),
          for (final (i, x) in sens.indexed) () {
            final m = magnitud(x['sensorType'] as String), e = estadoRed(x['clase'] as String? ?? '');
            return FilaSensor(nombre: m.nombre, meta: x['clase'] != null ? '2 h hasta ${corta(fecha(x['hasta']))}' : (x['nota'] as String? ?? ''),
                valor: x['probabilidad'] != null ? '${((x['probabilidad'] as num) * 100).round()} %' : '—', icono: m.icono, color: tono(context.c, m.tono),
                estado: e.$1, estadoTexto: e.$2, ultima: i == sens.length - 1);
          }(),
          Pie('MLP (32, 16) de la tesis, F1 ${cifra(g['f1MacroPrueba'] as num, 2)} en prueba. Clasifica la forma de la señal: normal, pegado, deriva, salto de escalón, ruido, picos o saturado.'),
        ]));
      });
}

/// Segunda opinión de IA generativa (Groq, el servicio gratuito de AgroPulse), a pedido por el límite del plan gratuito.
class OpinionIA extends StatefulWidget {
  const OpinionIA({super.key, required this.lote});
  final int lote;
  @override
  State<OpinionIA> createState() => _OpinionIAState();
}

class _OpinionIAState extends State<OpinionIA> {
  J? _r;
  bool _o = false;
  Future<void> _pedir() async {
    setState(() => _o = true);
    try { _r = await Siscan.of(context).api.opinionIA(widget.lote); } catch (e) { _r = {'disponible': false, 'motivo': 'No fue posible consultar la IA. ($e)'}; }
    if (mounted) setState(() => _o = false);
  }
  @override
  Widget build(BuildContext context) {
    final c = context.c, ok = _r?['disponible'] == true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: c.linea), borderRadius: BorderRadius.circular(SiscanRadius.lg), boxShadow: context.sombraTarjeta,
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0, .6], colors: [mezcla(c.prediccion, .07, c.superficie), c.superficie])),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TituloTarjeta(icono: 'ia', titulo: 'Segunda opinión de IA', derecha: Ficha(ok ? 'Groq · ${_r!['modelo']}' : 'Groq', tono: 'pred')),
        if (ok) ...[
          Text(_r!['texto'] as String, style: TextStyle(fontSize: 14, height: 22 / 14, color: c.tinta)),
          Pie('Texto generado por IA con los datos del lote, la predicción de la tesis, la red neuronal y el clima · ${corta(fecha(_r!['generadoEn']))}. No reemplaza la medición.'),
        ] else Text(_r?['motivo'] as String? ?? 'Un modelo de lenguaje lee los datos del lote y la predicción de la tesis, y da su estimación con una recomendación.',
            style: TextStyle(fontSize: 13, color: c.tintaSuave)),
        const SizedBox(height: 12),
        Boton(ok ? 'Volver a consultar' : 'Consultar a la IA', icono: 'ia', variante: VarianteBoton.soft, ocupado: _o, onPressed: _pedir),
      ]),
    );
  }
}

/// Nuevo lote (AndroidInicio › Nuevo lote): nombre, sitio, variedad, protocolo, muestra, humedad y peso de retiro en vivo.
class PantallaNuevoLote extends StatefulWidget {
  const PantallaNuevoLote({super.key});
  @override
  State<PantallaNuevoLote> createState() => _PantallaNuevoLoteState();
}

class _PantallaNuevoLoteState extends State<PantallaNuevoLote> {
  final _nombre = TextEditingController(), _muestra = TextEditingController(text: '200'), _ini = TextEditingController(text: '53'), _obj = TextEditingController(text: '11');
  String _sitio = 'dryer', _variedad = 'Sin especificar';
  String? _proto, _error;
  bool _o = false;
  double _n(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0;
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context), c = context.c;
    final protos = ((s.estado.base?.catalogo['protocols'] as List?) ?? const []).cast<J>();
    _proto ??= protos.firstOrNull?['key'] as String?;
    final seca = _n(_muestra) * (1 - _n(_ini) / 100), obj = _n(_obj);
    Widget select(String et, String valor, List<(String, String)> ops, ValueChanged<String> on) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(et, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.tinta)), const SizedBox(height: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: c.superficie, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.lineaFuerte, width: 1.5)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: valor, isExpanded: true, dropdownColor: c.superficie, style: TextStyle(fontSize: 15, color: c.tinta, fontFamily: SiscanType.ui),
                icon: Icono('abajo', size: 16, color: c.tintaSuave), items: [for (final o in ops) DropdownMenuItem(value: o.$1, child: Text(o.$2, overflow: TextOverflow.ellipsis))], onChanged: (v) => on(v!)))),
        ]);
    return Scaffold(body: CuerpoPantalla(barra: const BarraApp(titulo: 'Nuevo lote', atras: true), hijos: [
      Campo(etiqueta: 'Nombre del lote', controller: _nombre, placeholder: 'Lote C · Castillo', pista: 'Así aparecerá en el panel, la app y el reloj.', error: _error),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('¿Dónde se seca?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.tinta)), const SizedBox(height: 6),
        Segmentado<String>(bloque: true, etiqueta: '¿Dónde se seca?', valor: _sitio, onChanged: (v) => setState(() => _sitio = v), opciones: const [('dryer', 'Secador', 'secador'), ('open', 'Aire libre', 'sol')]),
      ]),
      select('Variedad', _variedad, [for (final v in ['Sin especificar', 'Castillo', 'Caturra', 'Colombia', 'Tabi', 'Cenicafé 1']) (v, v)], (v) => setState(() => _variedad = v)),
      if (protos.isNotEmpty) select('Protocolo', _proto!, [for (final p in protos) (p['key'] as String, p['label'] as String)], (v) => setState(() => _proto = v)),
      Row(children: [
        Expanded(child: Campo(etiqueta: 'Muestra', controller: _muestra, sufijo: 'g', teclado: const TextInputType.numberWithOptions(decimal: true), onChanged: (_) => setState(() {}))),
        const SizedBox(width: 12),
        Expanded(child: Campo(etiqueta: 'Humedad inicial', controller: _ini, sufijo: '%', teclado: const TextInputType.numberWithOptions(decimal: true), onChanged: (_) => setState(() {}))),
      ]),
      Campo(etiqueta: 'Humedad objetivo', controller: _obj, sufijo: '%', teclado: const TextInputType.numberWithOptions(decimal: true), onChanged: (_) => setState(() {})),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: c.cafeSuave, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [Icono('balanza', size: 20, color: c.cafe), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Peso de retiro calculado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.cafe)),
          Text(obj > 0 && obj < 100 && seca > 0 ? '${cifra(seca / (1 - obj / 100))} g' : '—', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.cafe, fontFeatures: const [FontFeature.tabularFigures()])),
          Text('con ${cifra(seca)} g de materia seca', style: TextStyle(fontSize: 12, color: c.cafe)),
        ]))]),
      ),
      Boton('Iniciar lote', icono: 'encendido', variante: VarianteBoton.primary, grande: true, bloque: true, ocupado: _o, onPressed: () async {
        var nombre = _nombre.text.trim();
        if (nombre.isEmpty) { setState(() => _error = 'Escribe el nombre del lote.'); return; }
        if (_variedad != 'Sin especificar' && !nombre.toLowerCase().contains(_variedad.toLowerCase())) nombre = '$nombre · $_variedad';
        setState(() { _error = null; _o = true; });
        final ok = await s.hacer(context, (h) => s.api.crearLote({'name': nombre, 'protocol': _proto, 'dryingSite': _sitio == 'open' ? 'OPEN_AIR' : 'DRYER',
            'gravimetInitialWeightGrams': _n(_muestra), 'gravimetInitialMoisturePct': _n(_ini) > 0 ? _n(_ini) : 53, 'targetMoisturePct': obj > 0 ? obj : 11}, h), 'Lote iniciado', detalle: nombre);
        if (mounted) setState(() => _o = false);
        if (ok && context.mounted) Navigator.of(context).pop();
      }),
    ]));
  }
}
