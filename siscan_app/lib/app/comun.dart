import 'package:flutter/material.dart';

import '../core/theme/siscan_theme.dart';
import '../core/ui/base.dart';
import '../core/ui/dominio.dart';
import '../data/estado.dart';

/// Pide datos de una ruta y los vuelve a pedir cuando cambia la clave (lote, pesajes, recarga).
class Pedido<T> extends StatefulWidget {
  const Pedido({super.key, required this.clave, required this.cargar, required this.builder});
  final Object clave;
  final Future<T> Function() cargar;
  final Widget Function(BuildContext, T?, Object?, bool cargando) builder;
  @override
  State<Pedido<T>> createState() => _PedidoState<T>();
}

class _PedidoState<T> extends State<Pedido<T>> {
  T? _d;
  Object? _e;
  bool _c = true;
  @override
  void initState() { super.initState(); _ir(); }
  @override
  void didUpdateWidget(Pedido<T> o) { super.didUpdateWidget(o); if (o.clave != widget.clave) _ir(); }
  Future<void> _ir() async {
    setState(() => _c = true);
    try {
      final d = await widget.cargar();
      if (mounted) setState(() { _d = d; _e = null; _c = false; });
    } catch (e) {
      if (mounted) setState(() { _e = e; _c = false; });
    }
  }
  @override
  Widget build(BuildContext context) => widget.builder(context, _d, _e, _c);
}

/// Avance hacia el objetivo (0–100) desde la humedad inicial del lote.
double avanceLote(J b) {
  double? d(Object? v) => (v as num?)?.toDouble();
  final ini = d(b['firstMoisturePct']) ?? d(b['gravimetInitialMoisturePct']);
  final obj = d(b['targetMoisturePct']) ?? 11, act = d(b['lastMoisturePct']);
  if (ini == null || act == null || ini <= obj) return 0;
  return ((ini - act) / (ini - obj) * 100).clamp(0, 100).toDouble();
}

String variedad(J b) {
  final p = (b['name'] as String? ?? '').split('·');
  return p.length > 1 ? p.last.trim() : 'Variedad sin registrar';
}

String protocoloCorto(J b) => (b['protocolLabel'] as String? ?? b['protocol'] as String? ?? '').replaceFirst(RegExp(r'^[A-Z]\s*[—-]\s*'), '');
String sitioLote(J b) => b['dryingSite'] == 'OPEN_AIR' ? 'Aire libre' : 'Secador';

/// Texto de la predicción de la tesis para encabezados («Listo en ~5 h 40», «Terminó en el objetivo»…).
/// Línea de la predicción en Inicio. Un lote en curso que ya llegó se anuncia para retirar; uno cerrado, como terminado.
String textoPrediccion(J? p, {bool enCurso = false}) {
  if (p == null) return 'Calculando la predicción…';
  return switch (p['estado']) {
    'EN_CURSO' => 'Listo en ~${duracion(p['horasRestantes'] as num?)}',
    'OBJETIVO_ALCANZADO' => enCurso ? 'Listo: retíralo' : 'Terminó en el objetivo',
    'SOBRESECADO' => 'Pasó el punto: sobre-secado',
    'NO_ALCANZABLE' => 'Con este aire no llega al objetivo',
    _ => 'Pocos pesajes para predecir',
  };
}

/// Alertas del servidor como ítems del sistema.
List<ItemAlerta> itemsAlerta(Base b) => b.alertas.map((a) => ItemAlerta(
      severidad: a['level'] == 'CRITICAL' ? 'critical' : a['level'] == 'INFO' ? 'info' : 'warning',
      titulo: (a['title'] ?? a['message'] ?? 'Alerta') as String,
      meta: (a['description'] ?? a['message'] ?? '') as String,
      hora: a['timestamp'] != null ? hace(fecha(a['timestamp'])) : '',
    )).toList();

/// «¿Está funcionando el equipo?» con datos reales (y el veredicto de la red neuronal de la tesis).
List<(String, String, bool)> filasSalud(Base b) {
  final fresco = !b.guardado && minutosDesde(b.ultimaT) <= fueraMin;
  final tipos = b.series.keys.toList();
  final vivos = tipos.where((t) => minutosDesde(b.ultima(t)?.$1) <= fueraMin).length;
  final pines = <Object?>{for (final a in b.actuadores) a['gpioPin']};
  final copias = b.actuadores.length - pines.length;
  final red = ((b.diagnostico?['sensores'] as List?) ?? const []).cast<J>();
  final fallas = red.where((s) => s['clase'] != null && s['clase'] != 'ok').toList();
  return [
    if (red.isNotEmpty) (fallas.isEmpty ? 'La red neuronal no ve fallas' : 'La red neuronal ve fallas',
        fallas.isEmpty ? '${red.length} sensores con señal normal' : fallas.map((s) => '${magnitud(s['sensorType'] as String).nombre}: ${estadoRed(s['clase'] as String).$2.toLowerCase()}').join(', '), fallas.isEmpty),
    (fresco ? 'ESP32 conectado' : 'ESP32 sin conexión', b.ultimaT != null ? 'Último reporte ${hace(b.ultimaT).toLowerCase()}' : 'Todavía no reporta', fresco),
    ('$vivos de ${tipos.length} sensores reportando', tipos.take(4).map((t) => magnitud(t).nombre).join(', '), tipos.isNotEmpty && vivos == tipos.length),
    (copias > 0 ? 'Actuadores con copias' : 'Actuadores registrados', '${b.actuadores.length} registrados${copias > 0 ? ' · $copias copias por GPIO' : ''}${fresco ? '' : ' · último estado conocido'}', copias == 0 && fresco),
  ];
}

/// Clases de la red neuronal de la tesis → estado y palabra.
(Estado, String) estadoRed(String clase) => switch (clase) {
      'ok' => (Estado.running, 'Normal'),
      'pegado' => (Estado.alert, 'Pegado'),
      'saturado' => (Estado.alert, 'Saturado'),
      'deriva' => (Estado.paused, 'Deriva'),
      'offset' => (Estado.paused, 'Salto de escalón'),
      'ruido' => (Estado.paused, 'Ruido'),
      'pico' => (Estado.paused, 'Picos'),
      _ => (Estado.offline, 'Sin datos'),
    };

/// Pines del mapa esquemático: cada secador sobre su municipio (por el nombre del sitio o el más cercano).
(List<(double, double, Estado, String?)>, Map<Estado, int>) pinesDe(Base b) {
  const coords = {'Pasto': (1.2136, -77.2811), 'Chachagüí': (1.36, -77.2833), 'La Unión': (1.6036, -77.1311), 'Sandoná': (1.2853, -77.4719), 'Ipiales': (0.8303, -77.6444)};
  final cuenta = {for (final e in Estado.values) e: 0};
  final usados = <String, int>{};
  final pines = b.secadores.map((g) {
    final st = '${g['id']}' == '1' ? b.estado.$1 : (g['drying'] == true ? Estado.running : Estado.paused);
    cuenta[st] = cuenta[st]! + 1;
    final lbl = (g['locationLabel'] as String? ?? '').toLowerCase();
    var p = MapaSecadores.pueblos.where((x) => lbl.contains(x.$1.toLowerCase())).firstOrNull;
    if (p == null && g['latitude'] != null) {
      final la = (g['latitude'] as num).toDouble(), lo = (g['longitude'] as num).toDouble();
      p = (MapaSecadores.pueblos.toList()..sort((a, c) {
        double d(String n) { final q = coords[n]!; return (q.$1 - la) * (q.$1 - la) + (q.$2 - lo) * (q.$2 - lo); }
        return d(a.$1).compareTo(d(c.$1));
      })).first;
    }
    p ??= MapaSecadores.pueblos.first;
    final n = usados[p.$1] = (usados[p.$1] ?? 0) + 1;
    return (p.$2 + (n - 1) * 16, p.$3 - 2, st, (g['name'] as String? ?? '').replaceFirst(RegExp(r'^SISCAN\s*[—-]\s*'), '') as String?);
  }).toList();
  return (pines, cuenta);
}

/// Bloque de solo lectura para quien no inició sesión.
class SoloLectura extends StatelessWidget {
  const SoloLectura({super.key, required this.texto, required this.onIngresar});
  final String texto;
  final VoidCallback onIngresar;
  @override
  Widget build(BuildContext context) => Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const TituloTarjeta(icono: 'candado', titulo: 'Vista de solo lectura'),
        Text(texto, style: TextStyle(fontSize: 14, color: context.c.tintaSuave)),
        const SizedBox(height: 12),
        Boton('Ingresar', icono: 'usuario', variante: VarianteBoton.primary, onPressed: onIngresar),
      ]));
}
