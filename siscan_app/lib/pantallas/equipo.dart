import 'package:flutter/material.dart';

import '../app/comun.dart';
import '../app/contexto.dart';
import '../core/textos.dart';
import '../core/theme/siscan_theme.dart';
import '../core/ui/base.dart';
import '../core/ui/dominio.dart';
import '../core/ui/marco.dart';
import '../data/estado.dart';

/// Equipo (AndroidPesaje › Equipo): modo, actuadores, «mantén presionado para encender» y sensores.
class PantallaEquipo extends StatefulWidget {
  const PantallaEquipo({super.key, required this.onIngresar});
  final VoidCallback onIngresar;
  @override
  State<PantallaEquipo> createState() => _PantallaEquipoState();
}

class _PantallaEquipoState extends State<PantallaEquipo> {
  /// Orden enviada → «Encendiendo…» hasta que el ESP32 reporte después de la orden.
  final _pendientes = <int, DateTime>{};
  bool _modoOcupado = false;
  /// Resistencia que se pidió encender: aparece un solo «Mantén presionado» para ella (HoldButton del sistema).
  J? _armada;

  Future<void> _orden(J a, bool on) async {
    final s = Siscan.of(context), id = int.parse('${a['id']}');
    setState(() => _pendientes[id] = DateTime.now());
    final ok = await s.hacer(context, (h) => s.api.actuador(id, on, h), on ? context.tx.actEncendiendo('${a['name']}') : context.tx.actApagando('${a['name']}'), detalle: context.tx.ordenSeCumple);
    if (!ok && mounted) setState(() => _pendientes.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context);
    return ConEstado(builder: (context, b) {
      final barra = BarraApp(titulo: context.tx.navEquipo, acciones: [AccionBarra('actualizar', context.tx.actualizar, s.estado.cargar)]);
      if (b == null) return CuerpoPantalla(barra: barra, hijos: const [Cargando()]);
      _pendientes.removeWhere((_, t) => b.ultimaT != null && b.ultimaT!.isAfter(t));
      final c = context.c, ctl = b.control ?? const {'pedido': 'MANUAL'};
      final auto = ctl['pedido'] == 'AUTO', admin = s.cabecera != null;
      final pines = <Object?, J>{};
      for (final a in b.actuadores) { pines.putIfAbsent(a['gpioPin'], () => a); }
      final x = context.tx;
      final estadoModo = b.control == null ? x.modoSinInfo
          : ctl['confirmado'] == true ? '${x.modoConfirmado(corta(fecha(ctl['reportadoEn'])))}${ctl['estrategia'] != null ? ' · ${ctl['estrategia'] == 'PID' ? 'PID' : 'On-Off'}' : ''}'
          : ctl['reportado'] != null ? x.modoEsperando(ctl['reportado'] == 'AUTO' ? x.modoAutomaticoMin : x.modoManualMin)
          : ctl['pedidoEn'] == null ? x.modoNoReportado : x.modoPedido;
      final algunoOn = b.actuadores.any((a) => a['status'] == 'ON');
      final apagadas = b.actuadores.where((a) => a['type'] == 'HEATER' && a['status'] != 'ON').toList();
      return CuerpoPantalla(barra: barra, onRefrescar: s.estado.cargar, hijos: [
        if (b.estado.$1 == Estado.offline) AvisoSinConexion(base: b, onReintentar: s.estado.cargar),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Segmentado<bool>(bloque: true, etiqueta: x.modoOperacion, valor: auto,
              onChanged: !admin || _modoOcupado ? null : (v) async {
                if (v == auto) return;
                setState(() => _modoOcupado = true);
                await s.hacer(context, (h) => s.api.modo(v, h), v ? context.tx.modoAutoPedido : context.tx.modoManualPedido, detalle: context.tx.modoSeAplica);
                if (mounted) setState(() => _modoOcupado = false);
              },
              opciones: [(true, x.modoAutomatico, 'ia'), (false, x.modoManual, 'mano')]),
          Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [
            Icono(ctl['confirmado'] == true ? 'check' : 'reloj', size: 14, color: c.tintaSuave), const SizedBox(width: 6),
            Expanded(child: Text(_modoOcupado ? x.enviando : estadoModo, style: TextStyle(fontSize: 13, color: c.tintaSuave))),
          ])),
        ]),
        Tarjeta(child: Column(children: [
          TituloTarjeta(icono: 'ventilador', titulo: x.actuadores, derecha: Pildora(estado: algunoOn ? Estado.running : Estado.paused, chica: true, texto: algunoOn ? x.actEnFuncionamiento : x.actDetenidos)),
          for (final (i, a) in b.actuadores.indexed) () {
            final id = int.parse('${a['id']}'), heater = a['type'] == 'HEATER', on = a['status'] == 'ON';
            final real = pines[a['gpioPin']];
            return Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 8), child: FilaActuador(
              nombre: a['name'] as String, calefactor: heater, encendido: on, vatios: double.tryParse('${a['powerW']}') ?? 0, pendiente: _pendientes.containsKey(id),
              desde: real != null && real['id'] != a['id'] ? x.copiaDe('${real['name']}', '${a['gpioPin']}') : null,
              auto: auto, soloLectura: !admin,
              // Encender una resistencia exige mantener presionado (abajo); apagarla, no.
              onChanged: (v) => heater && v ? setState(() => _armada = a) : _orden(a, v),
            ));
          }(),
          Pie(auto ? x.pieAuto : admin ? x.pieAdmin : x.inicioSoloLectura,
              icono: auto ? 'ia' : admin ? 'info' : 'candado'),
        ])),
        if (!auto && admin) ...[
          if (_armada != null && apagadas.any((a) => a['id'] == _armada!['id']))
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('${_armada!['name']} · ${cifra(double.tryParse('${_armada!['powerW']}'), 0)} W', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.tintaSuave)),
              const SizedBox(height: 6),
              Semantics(container: true, label: x.encenderNombre('${_armada!['name']}'), child: BotonMantener(key: ValueKey(_armada!['id']), texto: x.mantenerEncender,
                  onCompleto: () { final a = _armada!; setState(() => _armada = null); _orden(a, true); })),
            ])
          else if (apagadas.isNotEmpty)
            Pie(x.pieResistencia, icono: 'candado'),
        ],
        if (!admin) SoloLectura(texto: x.soloLecturaEquipo, onIngresar: widget.onIngresar),
        Tarjeta(child: Column(children: [
          TituloTarjeta(icono: 'sensor', titulo: x.calSensores),
          if (b.series.isEmpty) Text(x.sinLecturasSecador, style: TextStyle(fontSize: 14, color: c.tintaSuave)),
          for (final (i, t) in magnitudes.keys.where(b.series.containsKey).indexed) () {
            final m = magnitud(t), u = b.ultima(t)!, min = minutosDesde(u.$1);
            final st = b.guardado || min > fueraMin ? Estado.offline : min > avisoMin ? Estado.paused : Estado.running;
            final dg = ((b.diagnostico?['sensores'] as List?) ?? const []).cast<J>().where((x) => x['sensorType'] == t).firstOrNull;
            // La hora del último dato ya la dice el aviso de conexión; aquí solo qué mide y qué ve la red neuronal.
            final red = dg?['clase'] != null ? x.redSufijo(estadoRed(dg!['clase'] as String).$2.toLowerCase()) : '';
            return FilaSensor(nombre: m.nombre, meta: '${m.meta}$red', valor: '${cifra(u.$2, m.dec)} ${m.unidad}',
                icono: m.icono, color: tono(c, m.tono), estado: st, estadoTexto: st == Estado.running ? x.haceMin(min.round()) : st == Estado.paused ? x.desactualizado : null,
                ultima: i == b.series.length - 1);
          }(),
        ])),
      ]);
    });
  }
}
