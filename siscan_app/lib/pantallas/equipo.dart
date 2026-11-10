import 'package:flutter/material.dart';

import '../app/comun.dart';
import '../app/contexto.dart';
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
    final ok = await s.hacer(context, (h) => s.api.actuador(id, on, h), '${a['name']} · ${on ? 'Encendiendo…' : 'Apagando…'}', detalle: 'Se cumple cuando el ESP32 reporte.');
    if (!ok && mounted) setState(() => _pendientes.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context);
    return ConEstado(builder: (context, b) {
      final barra = BarraApp(titulo: 'Equipo', acciones: [AccionBarra('actualizar', 'Actualizar', s.estado.cargar)]);
      if (b == null) return CuerpoPantalla(barra: barra, hijos: const [Cargando()]);
      _pendientes.removeWhere((_, t) => b.ultimaT != null && b.ultimaT!.isAfter(t));
      final c = context.c, ctl = b.control ?? const {'pedido': 'MANUAL'};
      final auto = ctl['pedido'] == 'AUTO', admin = s.cabecera != null;
      final pines = <Object?, J>{};
      for (final a in b.actuadores) { pines.putIfAbsent(a['gpioPin'], () => a); }
      final estadoModo = b.control == null ? 'El servidor todavía no informa el modo del secador'
          : ctl['confirmado'] == true ? 'Confirmado por el ESP32 · ${corta(fecha(ctl['reportadoEn']))}${ctl['estrategia'] != null ? ' · ${ctl['estrategia'] == 'PID' ? 'PID' : 'On-Off'}' : ''}'
          : ctl['reportado'] != null ? 'El ESP32 está en ${ctl['reportado'] == 'AUTO' ? 'automático' : 'manual'}; esperando que aplique el cambio'
          : ctl['pedidoEn'] == null ? 'El ESP32 todavía no ha reportado su modo' : 'Pedido · el ESP32 todavía no lo confirma';
      final algunoOn = b.actuadores.any((a) => a['status'] == 'ON');
      final apagadas = b.actuadores.where((a) => a['type'] == 'HEATER' && a['status'] != 'ON').toList();
      return CuerpoPantalla(barra: barra, onRefrescar: s.estado.cargar, hijos: [
        if (b.estado.$1 == Estado.offline) AvisoSinConexion(base: b, onReintentar: s.estado.cargar),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Segmentado<bool>(bloque: true, etiqueta: 'Modo de operación', valor: auto,
              onChanged: !admin || _modoOcupado ? null : (v) async {
                if (v == auto) return;
                setState(() => _modoOcupado = true);
                await s.hacer(context, (h) => s.api.modo(v, h), v ? 'Modo automático pedido' : 'Modo manual pedido', detalle: 'Se aplica cuando el ESP32 lo confirme.');
                if (mounted) setState(() => _modoOcupado = false);
              },
              opciones: const [(true, 'Automático', 'ia'), (false, 'Manual', 'mano')]),
          Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [
            Icono(ctl['confirmado'] == true ? 'check' : 'reloj', size: 14, color: c.tintaSuave), const SizedBox(width: 6),
            Expanded(child: Text(_modoOcupado ? 'Enviando…' : estadoModo, style: TextStyle(fontSize: 13, color: c.tintaSuave))),
          ])),
        ]),
        Tarjeta(child: Column(children: [
          TituloTarjeta(icono: 'ventilador', titulo: 'Actuadores', derecha: Pildora(estado: algunoOn ? Estado.running : Estado.paused, chica: true, texto: algunoOn ? 'En funcionamiento' : 'Detenidos')),
          for (final (i, a) in b.actuadores.indexed) () {
            final id = int.parse('${a['id']}'), heater = a['type'] == 'HEATER', on = a['status'] == 'ON';
            final real = pines[a['gpioPin']];
            return Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 8), child: FilaActuador(
              nombre: a['name'] as String, calefactor: heater, encendido: on, vatios: double.tryParse('${a['powerW']}') ?? 0, pendiente: _pendientes.containsKey(id),
              desde: real != null && real['id'] != a['id'] ? 'copia de «${real['name']}» (GPIO ${a['gpioPin']})' : null,
              auto: auto, soloLectura: !admin,
              // Encender una resistencia exige mantener presionado (abajo); apagarla, no.
              onChanged: (v) => heater && v ? setState(() => _armada = a) : _orden(a, v),
            ));
          }(),
          Pie(auto ? 'El protocolo decide cuándo encender. Cambia a Manual para mandar órdenes.' : admin ? 'Las órdenes se cumplen cuando el ESP32 las lee. Si el secador no reporta, se aplican al reconectar.' : 'Vista de solo lectura: para mandar órdenes ingresa con tu cuenta.',
              icono: auto ? 'ia' : admin ? 'info' : 'candado'),
        ])),
        if (!auto && admin) ...[
          if (_armada != null && apagadas.any((a) => a['id'] == _armada!['id']))
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('${_armada!['name']} · ${cifra(double.tryParse('${_armada!['powerW']}'), 0)} W', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.tintaSuave)),
              const SizedBox(height: 6),
              Semantics(container: true, label: 'Encender ${_armada!['name']}', child: BotonMantener(key: ValueKey(_armada!['id']), texto: 'Mantén presionado para encender',
                  onCompleto: () { final a = _armada!; setState(() => _armada = null); _orden(a, true); })),
            ])
          else if (apagadas.isNotEmpty)
            Pie('Para encender una resistencia, toca su interruptor y luego mantén presionado el botón que aparece.', icono: 'candado'),
        ],
        if (!admin) SoloLectura(texto: 'Puedes ver el estado del equipo. Encender o apagar exige la cuenta de «Gestor del Secador».', onIngresar: widget.onIngresar),
        Tarjeta(child: Column(children: [
          const TituloTarjeta(icono: 'sensor', titulo: 'Sensores'),
          if (b.series.isEmpty) Text('El secador todavía no envía lecturas.', style: TextStyle(fontSize: 14, color: c.tintaSuave)),
          for (final (i, t) in magnitudes.keys.where(b.series.containsKey).indexed) () {
            final m = magnitud(t), u = b.ultima(t)!, min = minutosDesde(u.$1);
            final st = b.guardado || min > fueraMin ? Estado.offline : min > avisoMin ? Estado.paused : Estado.running;
            final dg = ((b.diagnostico?['sensores'] as List?) ?? const []).cast<J>().where((x) => x['sensorType'] == t).firstOrNull;
            // La hora del último dato ya la dice el aviso de conexión; aquí solo qué mide y qué ve la red neuronal.
            final red = dg?['clase'] != null ? ' · red: ${estadoRed(dg!['clase'] as String).$2.toLowerCase()}' : '';
            return FilaSensor(nombre: m.nombre, meta: '${m.meta}$red', valor: '${cifra(u.$2, m.dec)} ${m.unidad}',
                icono: m.icono, color: tono(c, m.tono), estado: st, estadoTexto: st == Estado.running ? 'Hace ${min.round()} min' : st == Estado.paused ? 'Desactualizado' : null,
                ultima: i == b.series.length - 1);
          }(),
        ])),
      ]);
    });
  }
}
