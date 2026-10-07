import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Último estado bueno del secador guardado en el teléfono, para el campo sin señal («Modo offline»).
/// Solo datos del secador (nada personal). Al leerlo, todo se marca como desactualizado: sin red nada es «Medido».
abstract class OverviewCache {
  Future<void> save(Overview o);
  Future<Overview?> read();
}

class PrefsOverviewCache implements OverviewCache {
  const PrefsOverviewCache();
  static const _key = 'siscan_overview_v1';
  @override
  Future<void> save(Overview o) async => (await SharedPreferences.getInstance()).setString(_key, jsonEncode(encodeOverview(o)));
  @override
  Future<Overview?> read() async {
    final s = (await SharedPreferences.getInstance()).getString(_key);
    return s == null ? null : decodeOverview(jsonDecode(s) as Map<String, dynamic>);
  }
}

class MemoryOverviewCache implements OverviewCache {
  Map<String, dynamic>? saved;
  @override
  Future<void> save(Overview o) async => saved = jsonDecode(jsonEncode(encodeOverview(o))) as Map<String, dynamic>;
  @override
  Future<Overview?> read() async => saved == null ? null : decodeOverview(saved!);
}

String _t(DateTime d) => d.toUtc().toIso8601String();
DateTime _p(Object? s) => DateTime.parse(s as String).toLocal();

Map<String, dynamic> encodeOverview(Overview o) => {
      'dryer': {'id': o.dryer.id, 'code': o.dryer.code, 'name': o.dryer.name, 'place': o.dryer.place, 'drying': o.dryer.drying, 'batch': o.dryer.activeBatchName},
      'readings': [for (final r in o.readings.values) {'type': r.type, 'value': r.value, 'at': _t(r.at)}],
      'actuators': [for (final a in o.actuators) {'id': a.id, 'name': a.name, 'kind': a.kind.name, 'on': a.on, 'w': a.powerW}],
      'alerts': [for (final a in o.alerts) {'level': a.level.name, 'message': a.message, 'at': _t(a.at)}],
      'alertCount': o.alertCount,
      'active': o.activeBatch == null ? null : _batch(o.activeBatch!),
      'last': o.lastBatch == null ? null : _batch(o.lastBatch!),
      'fetchedAt': _t(o.fetchedAt),
    };

Map<String, dynamic> _batch(Batch b) => {
      'id': b.id, 'name': b.name, 'protocol': b.protocolLabel, 'site': b.siteLabel, 'status': b.status, 'startedAt': _t(b.startedAt),
      'endedAt': b.endedAt == null ? null : _t(b.endedAt!), 'initial': b.initialMoisture, 'current': b.currentMoisture,
      'target': b.targetMoisture, 'lastSampleAt': b.lastSampleAt == null ? null : _t(b.lastSampleAt!), 'hoursToTarget': b.hoursToTarget,
    };

Batch _batchFrom(Map<String, dynamic> j) => Batch(
      id: j['id'] as int, name: j['name'] as String, protocolLabel: j['protocol'] as String, siteLabel: j['site'] as String,
      status: j['status'] as String, startedAt: _p(j['startedAt']), endedAt: j['endedAt'] == null ? null : _p(j['endedAt']),
      initialMoisture: (j['initial'] as num).toDouble(), currentMoisture: (j['current'] as num?)?.toDouble(), targetMoisture: (j['target'] as num).toDouble(),
      lastSampleAt: j['lastSampleAt'] == null ? null : _p(j['lastSampleAt']), hoursToTarget: (j['hoursToTarget'] as num?)?.toDouble(),
    );

/// Reconstruye el último estado guardado como **offline**: se muestra con la hora de hoy y todo desactualizado.
Overview decodeOverview(Map<String, dynamic> j) {
  final d = j['dryer'] as Map<String, dynamic>;
  return Overview(
    dryer: Dryer(id: d['id'] as int, code: d['code'] as String, name: d['name'] as String, place: d['place'] as String, drying: d['drying'] as bool, activeBatchName: d['batch'] as String?),
    readings: {
      for (final r in (j['readings'] as List).cast<Map<String, dynamic>>())
        r['type'] as String: Reading(type: r['type'] as String, value: (r['value'] as num).toDouble(), at: _p(r['at'])),
    },
    actuators: [
      for (final a in (j['actuators'] as List).cast<Map<String, dynamic>>())
        Actuator(id: a['id'] as int, name: a['name'] as String, kind: ActuatorKind.values.byName(a['kind'] as String), on: a['on'] as bool, powerW: (a['w'] as num).toDouble()),
    ],
    alerts: [
      for (final a in (j['alerts'] as List).cast<Map<String, dynamic>>())
        Alert(level: AlertLevel.values.byName(a['level'] as String), message: a['message'] as String, at: _p(a['at'])),
    ],
    alertCount: j['alertCount'] as int,
    activeBatch: j['active'] == null ? null : _batchFrom(j['active'] as Map<String, dynamic>),
    lastBatch: j['last'] == null ? null : _batchFrom(j['last'] as Map<String, dynamic>),
    fetchedAt: DateTime.now(),
    savedAt: _p(j['fetchedAt']),
    offline: true,
  );
}
