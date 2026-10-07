/// Modelo de datos de SISCAN (plataformas.md), alimentado por el backend real de WordPress del CISNA.
library;

/// Tipos de variable del secador con su etiqueta y unidad (las mismas del plugin `secador-cafe-api`).
const sensorLabels = <String, (String, String)>{
  'TEMPERATURE_EXTERIOR': ('Temperatura exterior', '°C'),
  'HUMIDITY_EXTERIOR': ('Humedad relativa exterior', '%'),
  'TEMPERATURE_TOPE': ('Temperatura interior', '°C'),
  'HUMIDITY_TOPE': ('Humedad relativa interior', '%'),
  'HUMIDITY_CAFE_GRANO': ('Humedad del grano (sensor)', '%'),
  'CURRENT': ('Corriente', 'A'),
  'POWER_CONTROLLER_W': ('Potencia controlador', 'W'),
  'POWER_ACTUADORES_W': ('Potencia actuadores', 'W'),
  'POWER_TOTAL_W': ('Potencia total', 'W'),
};

/// La hora del servidor es la de Colombia (UTC−5) sin zona: se interpreta así para medir frescura.
DateTime parseServerTime(String s) => DateTime.parse('${s.replaceFirst(' ', 'T')}-05:00');

class Reading {
  const Reading({required this.type, required this.value, required this.at});
  final String type;
  final double value;
  final DateTime at;
  String get label => sensorLabels[type]?.$1 ?? type;
  String get unit => sensorLabels[type]?.$2 ?? '';

  factory Reading.fromJson(Map<String, dynamic> j) =>
      Reading(type: j['sensorType'] as String, value: (j['value'] as num).toDouble(), at: parseServerTime(j['timestamp'] as String));
}

/// Una lectura vieja nunca se presenta como actual: más de 15 min → desactualizada.
const staleAfter = Duration(minutes: 15);

class Dryer {
  const Dryer({required this.id, required this.code, required this.name, required this.place, required this.drying, this.activeBatchName});
  final int id;
  final String code, name, place;
  final bool drying;
  final String? activeBatchName;

  factory Dryer.fromJson(Map<String, dynamic> j) => Dryer(
        id: j['id'] as int, code: j['code'] as String, name: j['name'] as String,
        place: (j['locationLabel'] as String?) ?? '', drying: j['drying'] == true, activeBatchName: j['activeBatchName'] as String?);
}

class Batch {
  const Batch({required this.id, required this.name, required this.protocolLabel, required this.siteLabel, required this.status,
      required this.startedAt, this.endedAt, required this.initialMoisture, this.currentMoisture, required this.targetMoisture,
      this.lastSampleAt, this.hoursToTarget});
  final int id;
  final String name, protocolLabel, siteLabel, status;
  final DateTime startedAt;
  final DateTime? endedAt, lastSampleAt;
  final double initialMoisture, targetMoisture;
  final double? currentMoisture;
  /// Horas que el modelo de la tesis estimó para llegar al objetivo (resumen del lote), si existe.
  final double? hoursToTarget;

  bool get active => status != 'COMPLETED' && status != 'CANCELLED' && endedAt == null;

  factory Batch.fromJson(Map<String, dynamic> j, {Map<String, dynamic>? summary}) {
    double? d(Object? v) => v == null ? null : (v as num).toDouble();
    final initial = d(j['firstMoisturePct']) ?? d(j['gravimetInitialMoisturePct']) ?? 52;
    return Batch(
      id: j['id'] as int, name: j['name'] as String, protocolLabel: (j['protocolLabel'] as String?) ?? '',
      siteLabel: (j['dryingSiteLabel'] as String?) ?? '', status: j['status'] as String,
      startedAt: parseServerTime(j['startedAt'] as String),
      endedAt: j['endedAt'] == null ? null : parseServerTime(j['endedAt'] as String),
      initialMoisture: initial, currentMoisture: d(j['lastMoisturePct']), targetMoisture: d(j['targetMoisturePct']) ?? 11,
      lastSampleAt: j['lastSampleAt'] == null ? null : parseServerTime(j['lastSampleAt'] as String),
      hoursToTarget: d((summary?['moisture'] as Map<String, dynamic>?)?['hoursToTarget']),
    );
  }
}

enum ActuatorKind { fan, heater, light, other }

class Actuator {
  const Actuator({required this.id, required this.name, required this.kind, required this.on, required this.powerW});
  final int id;
  final String name;
  final ActuatorKind kind;
  final bool on;
  final double powerW;

  factory Actuator.fromJson(Map<String, dynamic> j) => Actuator(
        id: int.parse('${j['id']}'), name: j['name'] as String,
        kind: switch (j['type']) { 'FAN' => ActuatorKind.fan, 'HEATER' => ActuatorKind.heater, 'LIGHT' => ActuatorKind.light, _ => ActuatorKind.other },
        on: j['status'] == 'ON', powerW: double.tryParse('${j['powerW']}') ?? 0);
}

enum AlertLevel { critical, warning, info }

class Alert {
  const Alert({required this.level, required this.message, required this.at});
  final AlertLevel level;
  final String message;
  final DateTime at;
  factory Alert.fromJson(Map<String, dynamic> j) => Alert(
        level: switch (j['level']) { 'CRITICAL' => AlertLevel.critical, 'WARNING' => AlertLevel.warning, _ => AlertLevel.info },
        message: j['message'] as String, at: parseServerTime(j['at'] as String));
}

/// Predicción de la IA (tiempo restante). El backend aún no la publica: llega como `null` y la app lo dice.
class AIPrediction {
  const AIPrediction({required this.remaining, required this.low, required this.high, required this.confidence, required this.createdAt});
  final Duration remaining, low, high;
  final int confidence;
  final DateTime createdAt;
}

/// Todo lo que necesita el Inicio, en el orden de las preguntas del sistema.
class Overview {
  const Overview({required this.dryer, required this.readings, required this.actuators, required this.alerts, required this.alertCount,
      this.activeBatch, this.lastBatch, this.prediction, required this.fetchedAt, this.offline = false, this.savedAt});
  final Dryer dryer;
  final Map<String, Reading> readings; // la más reciente de cada tipo
  final List<Actuator> actuators;
  final List<Alert> alerts;
  final int alertCount;
  final Batch? activeBatch, lastBatch;
  final AIPrediction? prediction;
  final DateTime fetchedAt;
  /// Estado guardado en el teléfono mostrado sin red: todo es «Última lectura» y la predicción no se muestra.
  final bool offline;
  /// Cuándo se guardó el estado mostrado sin red.
  final DateTime? savedAt;

  bool isStale(Reading r) => offline || fetchedAt.difference(r.at) > staleAfter;

  /// El secador está reportando si alguna lectura es reciente.
  bool get dryerReporting => readings.values.any((r) => !isStale(r));
}
