import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

/// Fuente de datos del Inicio. La real lee el backend del CISNA; la de ejemplo sirve para pruebas y revisión.
abstract class SiscanRepository {
  Future<Overview> overview();

  /// Enciende o apaga un actuador (exige sesión de «Gestor del Secador»). Lanza [ApiException] con el motivo.
  Future<void> setActuator(int id, bool on, {required String auth});
}

class ApiException implements Exception {
  ApiException(this.message, {this.unauthorized = false});
  final String message;
  /// La sesión ya no vale (contraseña de aplicación revocada o permiso retirado).
  final bool unauthorized;
  @override
  String toString() => message;
}

/// Backend real: WordPress REST `secador/v1` en cisna.narino.gov.co (lectura pública).
class HttpSiscanRepository implements SiscanRepository {
  HttpSiscanRepository({http.Client? client, this.base = 'https://cisna.narino.gov.co/wp-json/secador/v1', this.dryerId = 1})
      : _client = client ?? http.Client();
  final http.Client _client;
  final String base;
  final int dryerId;

  Future<dynamic> _get(String path) async {
    final http.Response r;
    try {
      r = await _client.get(Uri.parse('$base/$path')).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiException('No pudimos conectarnos con el secador. Verifica la conexión e intenta nuevamente.');
    }
    if (r.statusCode != 200) throw ApiException('No pudimos cargar los datos del secador. Intenta nuevamente.');
    return jsonDecode(utf8.decode(r.bodyBytes));
  }

  @override
  Future<void> setActuator(int id, bool on, {required String auth}) async {
    final http.Response r;
    try {
      r = await _client.put(Uri.parse('$base/api/actuators/$id'),
          headers: {'Authorization': auth, 'Content-Type': 'application/json'},
          body: jsonEncode({'status': on ? 'ON' : 'OFF', 'secadorId': dryerId})).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiException('No fue posible ${on ? 'encender' : 'apagar'} el equipo. Verifica la conexión del dispositivo.');
    }
    if (r.statusCode == 401 || r.statusCode == 403) throw ApiException('Tu sesión venció o ya no tiene permiso. Ingresa de nuevo.', unauthorized: true);
    if (r.statusCode != 200) throw ApiException('No fue posible ${on ? 'encender' : 'apagar'} el equipo. Intenta nuevamente.');
  }

  @override
  Future<Overview> overview() async {
    final results = await Future.wait([
      _get('secadores'),
      _get('readings?secadorId=$dryerId&limit=120'),
      _get('api/actuators'),
      _get('api/device/status/$dryerId'),
      _get('drying-batches'),
    ]);
    final dryers = (results[0] as List).cast<Map<String, dynamic>>().map(Dryer.fromJson).toList();
    final dryer = dryers.firstWhere((d) => d.id == dryerId, orElse: () => dryers.first);
    final latest = <String, Reading>{};
    for (final j in ((results[1] as Map)['readings'] as List).cast<Map<String, dynamic>>()) {
      final r = Reading.fromJson(j);
      latest.putIfAbsent(r.type, () => r);
    }
    final actuators = (results[2] as List).cast<Map<String, dynamic>>().map(Actuator.fromJson).toList();
    final status = results[3] as Map<String, dynamic>;
    final alerts = ((status['alerts'] as List?) ?? []).cast<Map<String, dynamic>>().map(Alert.fromJson).toList();
    final batchesJson = (results[4] as List).cast<Map<String, dynamic>>().where((b) => b['secadorId'] == dryerId).toList();
    Batch? active, last;
    if (batchesJson.isNotEmpty) {
      final sorted = [...batchesJson]..sort((a, b) => (b['startedAt'] as String).compareTo(a['startedAt'] as String));
      final firstActive = sorted.where((b) => b['endedAt'] == null && b['status'] != 'COMPLETED').firstOrNull;
      if (firstActive != null) {
        final summary = await _get('drying-batches/${firstActive['id']}/summary') as Map<String, dynamic>;
        active = Batch.fromJson(firstActive, summary: summary);
      }
      final lastClosed = sorted.where((b) => b['status'] == 'COMPLETED').firstOrNull;
      if (lastClosed != null) last = Batch.fromJson(lastClosed);
    }
    return Overview(dryer: dryer, readings: latest, actuators: actuators, alerts: alerts,
        alertCount: (status['alertCount'] as num?)?.toInt() ?? alerts.length, activeBatch: active, lastBatch: last, fetchedAt: DateTime.now());
  }
}

/// Datos de ejemplo verosímiles del sistema (Café Supremo — Lote B secando), para revisión y pruebas.
class DemoSiscanRepository implements SiscanRepository {
  DemoSiscanRepository({this.withActiveBatch = true, this.delay = Duration.zero, this.fail = false, this.failCommands = false, this.expiredSession = false});
  bool withActiveBatch, fail, failCommands, expiredSession;
  final Duration delay;
  final commands = <(int, bool)>[];

  @override
  Future<void> setActuator(int id, bool on, {required String auth}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (expiredSession) throw ApiException('Tu sesión venció o ya no tiene permiso. Ingresa de nuevo.', unauthorized: true);
    if (failCommands) throw ApiException('No fue posible ${on ? 'encender' : 'apagar'} el equipo. Verifica la conexión del dispositivo.');
    commands.add((id, on));
  }

  @override
  Future<Overview> overview() async {
    await Future<void>.delayed(delay);
    if (fail) throw ApiException('No pudimos conectarnos con el secador. Verifica la conexión e intenta nuevamente.');
    final now = DateTime.now();
    Reading r(String t, double v, Duration ago) => Reading(type: t, value: v, at: now.subtract(ago));
    return Overview(
      dryer: const Dryer(id: 1, code: 'SC-001', name: 'SISCAN — Secador 01', place: 'Vereda La Cruz - Chachagüí', drying: true, activeBatchName: 'Lote B'),
      readings: {
        'TEMPERATURE_TOPE': r('TEMPERATURE_TOPE', 40.5, const Duration(seconds: 5)),
        'HUMIDITY_TOPE': r('HUMIDITY_TOPE', 63.2, const Duration(seconds: 5)),
        'TEMPERATURE_EXTERIOR': r('TEMPERATURE_EXTERIOR', 17.8, const Duration(minutes: 14, seconds: 30)),
        'POWER_TOTAL_W': r('POWER_TOTAL_W', 210, const Duration(seconds: 8)),
      },
      actuators: const [
        Actuator(id: 1, name: 'Ventiladores', kind: ActuatorKind.fan, on: true, powerW: 210),
        Actuator(id: 3, name: 'Calefactor 1', kind: ActuatorKind.heater, on: false, powerW: 1500),
        Actuator(id: 5, name: 'Calefactor 2', kind: ActuatorKind.heater, on: false, powerW: 1500),
      ],
      alerts: [
        Alert(level: AlertLevel.warning, message: 'Humedad relativa interior por encima del rango (63.2 %)', at: now.subtract(const Duration(minutes: 3))),
        Alert(level: AlertLevel.info, message: 'Lluvia probable en las próximas 6 h', at: now.subtract(const Duration(hours: 1))),
      ],
      alertCount: 2,
      activeBatch: withActiveBatch
          ? Batch(id: 9, name: 'Lote B', protocolLabel: 'C — Continuo templado', siteLabel: 'Secador', status: 'ACTIVE',
              startedAt: now.subtract(const Duration(hours: 18, minutes: 20)), initialMoisture: 52, currentMoisture: 14.5, targetMoisture: 11,
              lastSampleAt: now.subtract(const Duration(minutes: 40)))
          : null,
      lastBatch: Batch(id: 3, name: 'Lote juco', protocolLabel: 'A — Tradicional (secado al sol)', siteLabel: 'Al aire libre', status: 'COMPLETED',
          startedAt: DateTime(2026, 8, 11, 11, 56), endedAt: DateTime(2026, 8, 17, 16, 19), initialMoisture: 44.4, currentMoisture: 10.6, targetMoisture: 11),
      prediction: withActiveBatch
          ? AIPrediction(remaining: const Duration(hours: 4, minutes: 15), low: const Duration(hours: 3, minutes: 50), high: const Duration(hours: 4, minutes: 40), confidence: 87, createdAt: now)
          : null,
      fetchedAt: now,
    );
  }
}
