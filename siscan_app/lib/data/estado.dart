import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/siscan_theme.dart';
import 'api.dart';

/// Reglas del sistema (01-secado): sin dato 2 min = advertencia; 10 min = sin conexión.
const avisoMin = 2, fueraMin = 10;

/// Las horas del servidor vienen en hora de Colombia (UTC−5) sin zona.
DateTime? fecha(Object? s) => s == null ? null : DateTime.parse('${(s as String).replaceFirst(' ', 'T')}-05:00');
const _meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
String hm(DateTime d) { final c = co(d); return '${c.hour.toString().padLeft(2, '0')}:${c.minute.toString().padLeft(2, '0')}'; }
String dia(DateTime? d) { if (d == null) return '—'; final c = co(d); return '${c.day} ${_meses[c.month - 1]}'; }
/// «Hoy · 07:40», «Ayer · 18:06», «2 oct · 07:40».
String corta(DateTime? d) {
  if (d == null) return '—';
  final hoy = co(DateTime.now()), ayer = hoy.subtract(const Duration(days: 1));
  bool mismo(DateTime a, DateTime b) { final x = co(a); return x.year == b.year && x.month == b.month && x.day == b.day; }
  if (mismo(d, hoy)) return 'Hoy · ${hm(d)}';
  if (mismo(d, ayer)) return 'Ayer · ${hm(d)}';
  return '${dia(d)} · ${hm(d)}';
}
double minutosDesde(DateTime? d) => d == null ? double.infinity : DateTime.now().difference(d).inSeconds / 60;
String hace(DateTime? d) {
  final m = minutosDesde(d);
  if (m.isInfinite) return 'Sin dato';
  if (m < 1) return 'Hace instantes';
  if (m < 60) return 'Hace ${m.round()} min';
  if (m < 24 * 60) return 'Hace ${(m / 60).round()} h';
  return corta(d);
}
String duracion(num? horas) {
  if (horas == null) return '—';
  var d = horas ~/ 24, h = (horas - d * 24).round();
  if (h == 24) { d++; h = 0; }
  return d > 0 ? '$d d $h h' : '$h h';
}

/// Magnitudes: nombre, tono, ícono y decimales fijos (el técnico aprende a leer el color).
class Magnitud {
  const Magnitud(this.nombre, this.tono, this.icono, this.meta, this.dec, this.unidad);
  final String nombre, tono, icono, meta, unidad;
  final int dec;
}

const magnitudes = {
  'TEMPERATURE_TOPE': Magnitud('Temperatura interior', 'tope', 'termometroTope', 'Tope de la cámara', 1, '°C'),
  'HUMIDITY_TOPE': Magnitud('Humedad relativa interior', 'humedad', 'gotas', 'Cámara', 1, '%'),
  'TEMPERATURE_EXTERIOR': Magnitud('Temperatura exterior', 'exterior', 'nubeSol', 'Ambiente', 1, '°C'),
  'HUMIDITY_EXTERIOR': Magnitud('Humedad relativa exterior', 'exterior', 'nube', 'Ambiente', 1, '%'),
  'HUMIDITY_CAFE_GRANO': Magnitud('Humedad del grano (sensor)', 'grano', 'grano', 'Capacitivo', 1, '%'),
  'CURRENT': Magnitud('Corriente', 'corriente', 'rayo', 'Línea AC', 2, 'A'),
  'POWER_CONTROLLER_W': Magnitud('Potencia del controlador', 'potencia', 'sensor', 'ESP32 y sensores', 0, 'W'),
  'POWER_ACTUADORES_W': Magnitud('Potencia de actuadores', 'potencia', 'potencia', 'Ventiladores y resistencias', 0, 'W'),
  'POWER_TOTAL_W': Magnitud('Potencia total', 'potencia', 'potencia', 'Controlador y actuadores', 0, 'W'),
};
Magnitud magnitud(String tipo) => magnitudes[tipo] ?? Magnitud(tipo, 'humedad', 'sensor', '', 1, '');

typedef J = Map<String, dynamic>;

/// Todo lo que comparten las pantallas, en una sola carga (lecturas públicas).
class Base {
  Base(this.crudo, {required this.cargadoEn, this.guardado = false});
  final J crudo;
  final DateTime cargadoEn;
  /// Sin red: es la última copia buena guardada en el teléfono.
  final bool guardado;

  late final List<J> lotes = (crudo['lotes'] as List).cast<J>().toList()..sort((a, b) => (b['startedAt'] as String).compareTo(a['startedAt'] as String));
  late final J? activo = lotes.where((b) => b['status'] == 'RUNNING').firstOrNull;
  late final J? lote = activo ?? lotes.firstOrNull;
  late final J reporte = (crudo['reporte'] as Map).cast<String, dynamic>();
  late final List<J> actuadores = (crudo['actuadores'] as List).cast<J>();
  late final J? clima = (crudo['clima'] as Map?)?.cast<String, dynamic>();
  late final List<J> secadores = ((crudo['secadores'] as List?) ?? const []).cast<J>();
  late final J? secador = secadores.where((g) => '${g['id']}' == '1').firstOrNull;
  late final J catalogo = ((crudo['catalogo'] as Map?) ?? const {}).cast<String, dynamic>();
  late final List<J> ordenes = ((crudo['ordenes'] as List?) ?? const []).cast<J>();
  late final J? control = (crudo['control'] as Map?)?.cast<String, dynamic>();
  late final J? diagnostico = (crudo['diagnostico'] as Map?)?.cast<String, dynamic>();
  late final List<J> alertas = ((reporte['alertsDetail'] as List?) ?? const []).cast<J>();

  /// Serie por tipo de sensor, en orden de tiempo.
  late final Map<String, List<(DateTime, double)>> series = () {
    final m = <String, List<(DateTime, double)>>{};
    for (final r in (crudo['lecturas'] as List).cast<J>().reversed) {
      (m[r['sensorType'] as String] ??= []).add((fecha(r['timestamp'])!, (r['value'] as num).toDouble()));
    }
    return m;
  }();
  late final DateTime? ultimaT = series.values.expand((s) => s).map((x) => x.$1).fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
  (DateTime, double)? ultima(String tipo) => series[tipo]?.lastOrNull;

  /// Estado del secador (01-secado): operando, pausa, alerta o sin conexión.
  (Estado, String) get estado {
    if (guardado || minutosDesde(ultimaT) > fueraMin) return (Estado.offline, ultimaT != null ? 'Sin conexión · último dato ${corta(ultimaT)}' : 'Sin conexión · aún no reporta');
    if (alertas.any((a) => a['level'] == 'CRITICAL')) return (Estado.alert, 'Alerta');
    if (activo != null) return (Estado.running, 'En operación');
    return (Estado.paused, 'En pausa · sin lote activo');
  }

  String get nombreSecador => (secador?['name'] as String? ?? 'Secador').replaceFirst(RegExp(r'^SISCAN\s*[—-]\s*'), '');
  String get sitio => secador?['locationLabel'] as String? ?? 'Nariño';
}

/// Carga común cada 30 s; si falla, queda la última copia buena con su hora (nunca se presenta como actual).
class EstadoSecador extends ChangeNotifier {
  EstadoSecador(this.api, {this.cada = const Duration(seconds: 30)});
  final SiscanApi api;
  final Duration? cada;
  Base? base;
  String? error;
  bool cargando = false;
  Timer? _t;

  void iniciar() {
    _leerCopia();
    cargar();
    if (cada != null) _t = Timer.periodic(cada!, (_) => cargar());
  }

  @override
  void dispose() { _t?.cancel(); super.dispose(); }

  Future<void> cargar() async {
    cargando = true;
    notifyListeners();
    try {
      final r = await Future.wait<dynamic>([
        api.lotes(), api.reporte(), api.lecturas(), api.actuadores(),
        api.clima().catchError((_) => <String, dynamic>{}), api.secadores().catchError((_) => <Map<String, dynamic>>[]),
        api.protocolos().catchError((_) => <String, dynamic>{}), api.ordenes().catchError((_) => <Map<String, dynamic>>[]),
        api.control().then<J?>((x) => x).catchError((_) => null), api.diagnostico().then<J?>((x) => x).catchError((_) => null),
      ]);
      final crudo = {'lotes': r[0], 'reporte': r[1], 'lecturas': r[2], 'actuadores': r[3], 'clima': (r[4] as Map).isEmpty ? null : r[4],
          'secadores': r[5], 'catalogo': r[6], 'ordenes': r[7], 'control': r[8], 'diagnostico': r[9]};
      base = Base(crudo, cargadoEn: DateTime.now());
      error = null;
      _guardar(crudo);
    } catch (e) {
      error = e is ApiError ? e.mensaje : 'No pudimos conectarnos con el secador.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> _guardar(J crudo) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('siscan_base', jsonEncode({'en': DateTime.now().toIso8601String(), 'crudo': crudo}));
    } catch (_) {/* sin copia: no impide seguir */}
  }

  Future<void> _leerCopia() async {
    try {
      final p = await SharedPreferences.getInstance();
      final s = p.getString('siscan_base');
      if (s == null || base != null) return;
      final j = jsonDecode(s) as J;
      base = Base((j['crudo'] as Map).cast<String, dynamic>(), cargadoEn: DateTime.parse(j['en'] as String), guardado: true);
      notifyListeners();
    } catch (_) {/* copia dañada: se ignora */}
  }

  /// Borra la copia del teléfono (derecho de supresión, desde Privacidad).
  static Future<void> borrarCopia() async => (await SharedPreferences.getInstance()).remove('siscan_base');
}
