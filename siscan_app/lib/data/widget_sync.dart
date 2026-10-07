import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import 'auth.dart';
import 'models.dart';
import 'repository.dart';

/// Widgets del sistema (plataformas.md → «Widgets del sistema»): la app comparte el último estado con los widgets
/// nativos de Android mediante `home_widget`. Un widget no es tiempo real: siempre dice cuándo se actualizó.
abstract final class WidgetSync {
  /// Solo la app real lo activa (main); en pruebas no hay widgets nativos que respondan.
  static bool enabled = false;

  static const providers = ['MoistureWidgetProvider', 'BatchWidgetProvider', 'EquipmentWidgetProvider'];

  static String _n(double v) => v.toStringAsFixed(1);
  static String _hm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// Escribe los datos que leen los widgets y les pide redibujarse.
  static Future<void> publish(Overview o) async {
    if (!enabled || kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    // Sin lote activo se muestra el último lote, como en el Inicio de la app (nunca un «—» si hay un dato real).
    final active = o.activeBatch;
    final b = active ?? o.lastBatch;
    final temp = o.readings['TEMPERATURE_TOPE'] ?? o.readings['TEMPERATURE_EXTERIOR'];
    final fan = o.actuators.where((a) => a.kind == ActuatorKind.fan).firstOrNull;
    final alert = o.alerts.isEmpty ? null : (o.alerts.toList()..sort((a, c) => a.level.index.compareTo(c.level.index))).first;
    final reached = b != null && b.currentMoisture != null && b.currentMoisture! <= b.targetMoisture;
    final values = <String, Object?>{
      'batch': b == null ? 'Sin lote activo' : (active == null ? 'Último: ${b.name}' : b.name),
      'variety': b?.protocolLabel ?? o.dryer.name,
      'moisture': b?.currentMoisture == null ? '—' : _n(b!.currentMoisture!),
      'target': b == null ? '' : 'Objetivo ${b.targetMoisture.toStringAsFixed(0)} %',
      'progress': b == null || b.currentMoisture == null ? 0 : (((b.initialMoisture - b.currentMoisture!) / (b.initialMoisture - b.targetMoisture)).clamp(0, 1) * 100).round(),
      'phase': b == null ? 'Sin lote' : (active == null ? 'Lote terminado' : (reached ? 'Objetivo alcanzado' : 'Secando')),
      'temperature': temp == null ? '—' : _n(temp.value),
      'tempStale': temp == null || o.isStale(temp),
      'remaining': o.prediction == null ? '—' : '${o.prediction!.remaining.inHours} h ${o.prediction!.remaining.inMinutes % 60}',
      'confidence': o.prediction?.confidence ?? 0,
      'alert': alert?.message ?? 'Sin alertas pendientes',
      'alertLevel': alert?.level.name ?? 'none',
      'fanId': fan?.id ?? -1,
      'fanOn': fan?.on ?? false,
      'updated': o.offline ? 'Sin conexión · guardado ${_hm(o.savedAt ?? o.fetchedAt)}' : 'Actualizado ${_hm(o.fetchedAt)}',
    };
    for (final e in values.entries) {
      await HomeWidget.saveWidgetData(e.key, e.value);
    }
    for (final p in providers) {
      await HomeWidget.updateWidget(androidName: p);
    }
  }
}

/// Toque en «Ventilador» del widget (corre en segundo plano, sin abrir la app). Solo el ventilador: la resistencia
/// nunca se enciende desde un widget (abre la app, que exige mantener presionado).
@pragma('vm:entry-point')
Future<void> widgetCallback(Uri? uri) async {
  if (uri == null || uri.host != 'fan') return;
  WidgetSync.enabled = true; // corre en su propio proceso de fondo
  final id = int.tryParse(uri.queryParameters['id'] ?? '');
  final on = uri.queryParameters['on'] == '1';
  if (id == null) return;
  final saved = await const SecureCredentialStore().read();
  if (saved == null) {
    await HomeWidget.saveWidgetData('updated', 'Ingresa en la app para usar el ventilador');
    await HomeWidget.updateWidget(androidName: 'EquipmentWidgetProvider');
    return;
  }
  final auth = AuthController(store: const SecureCredentialStore());
  if (await auth.signIn(saved.$1, saved.$2) != null || auth.session == null) return;
  final repo = HttpSiscanRepository();
  try {
    await repo.setActuator(id, on, auth: auth.session!.header);
    await WidgetSync.publish(await repo.overview());
  } catch (_) {
    await HomeWidget.saveWidgetData('updated', 'No fue posible cambiar el ventilador');
    await HomeWidget.updateWidget(androidName: 'EquipmentWidgetProvider');
  }
}
