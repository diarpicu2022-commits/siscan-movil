import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../data/api.dart';
import '../data/estado.dart';

/// Notificaciones de SISCAN (05-pantallas, «fuera de la app»): alertas nuevas, hora de pesar la muestra, lote listo y la
/// actividad del lote en la pantalla de bloqueo. Una tarea en segundo plano lee el servidor cada 15 min (solo lectura).
abstract final class Notificaciones {
  static final _p = FlutterLocalNotificationsPlugin();
  static const _tarea = 'siscan-revisar';
  /// Toque en una notificación o en su acción → ruta que abre la app (siscan://equipo, siscan://pesaje…).
  static final toque = ValueNotifier<String?>(null);

  static const _alertas = AndroidNotificationChannel('alertas', 'Alertas del secador', description: 'Temperatura, humedad y equipo fuera de rango.', importance: Importance.high);
  static const _recordatorios = AndroidNotificationChannel('recordatorios', 'Pesaje y lote listo', description: 'Hora de pesar la muestra y predicción de la tesis.', importance: Importance.defaultImportance);
  static const _actividad = AndroidNotificationChannel('actividad', 'Lote en curso', description: 'Avance del lote en la pantalla de bloqueo.', importance: Importance.low);

  static Future<void> iniciar() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await _p.initialize(settings: const InitializationSettings(android: AndroidInitializationSettings('ic_stat_siscan')),
        onDidReceiveNotificationResponse: (r) => toque.value = r.actionId?.startsWith('ir:') == true ? r.actionId!.substring(3) : r.payload);
    final a = _p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    for (final c in [_alertas, _recordatorios, _actividad]) { await a?.createNotificationChannel(c); }
    final inicio = await _p.getNotificationAppLaunchDetails();
    if (inicio?.didNotificationLaunchApp == true) toque.value = inicio!.notificationResponse?.payload;
    await Workmanager().initialize(revisarEnSegundoPlano);
  }

  static Future<bool> pedirPermiso() async =>
      await _p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission() ?? false;

  static Future<void> programar() async {
    await Workmanager().registerPeriodicTask(_tarea, _tarea, frequency: const Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.connected), existingWorkPolicy: ExistingPeriodicWorkPolicy.keep);
    await revisar();
  }

  static Future<void> cancelar() async {
    await Workmanager().cancelByUniqueName(_tarea);
    await _p.cancelAll();
  }

  static AndroidNotificationDetails _det(AndroidNotificationChannel c, {List<AndroidNotificationAction>? acciones, bool fija = false, int? avance, String? sub}) => AndroidNotificationDetails(
        c.id, c.name, channelDescription: c.description, importance: c.importance, priority: c.importance == Importance.high ? Priority.high : Priority.defaultPriority,
        color: const Color(0xFF183024), actions: acciones, ongoing: fija, onlyAlertOnce: fija, showProgress: avance != null, maxProgress: 100, progress: avance ?? 0,
        subText: sub, visibility: NotificationVisibility.public, category: fija ? AndroidNotificationCategory.progress : null);

  /// Lee el servidor y avisa lo nuevo. Recuerda lo ya avisado para no repetir.
  static Future<void> revisar() async {
    final api = SiscanApi();
    final p = await SharedPreferences.getInstance();
    final vistos = (p.getStringList('siscan_vistos') ?? const []).toSet();
    final reporte = await api.reporte();
    for (final a in ((reporte['alertsDetail'] as List?) ?? const []).cast<J>()) {
      final clave = 'a:${a['id'] ?? a['title']}:${a['timestamp'] ?? ''}';
      if (vistos.contains(clave)) continue;
      vistos.add(clave);
      final critica = a['level'] == 'CRITICAL';
      await _p.show(id: clave.hashCode & 0x7fffffff, title: (a['title'] ?? a['message'] ?? 'Alerta') as String, body: (a['description'] ?? a['message'] ?? '') as String,
          notificationDetails: NotificationDetails(android: _det(_alertas, sub: critica ? 'Alerta crítica' : 'Advertencia',
              acciones: const [AndroidNotificationAction('ir:equipo', 'Ver equipo', showsUserInterface: true)])), payload: 'equipo');
    }
    final lotes = await api.lotes();
    final activo = lotes.where((b) => b['status'] == 'RUNNING').firstOrNull;
    if (activo == null) {
      await _p.cancel(id: 1);
    } else {
      final id = activo['id'] as int;
      // Hora de pesar: una vez al día si el último pesaje tiene más de 24 h.
      final ult = fecha(activo['lastSampleAt']);
      final hoy = DateTime.now().toIso8601String().substring(0, 10);
      if ((ult == null || DateTime.now().difference(ult).inHours >= 24) && !vistos.contains('p:$id:$hoy')) {
        vistos.add('p:$id:$hoy');
        await _p.show(id: 2, title: 'Hora de pesar la muestra', body: '${activo['name']} · ${ult == null ? 'aún sin pesajes' : 'último pesaje hace ${DateTime.now().difference(ult).inHours} h'}.',
            notificationDetails: NotificationDetails(android: _det(_recordatorios, acciones: const [AndroidNotificationAction('ir:pesaje', 'Registrar pesaje', showsUserInterface: true)])), payload: 'pesaje');
      }
      String linea = 'Secando';
      try {
        final pr = await api.prediccion(id);
        if (pr['estado'] == 'EN_CURSO') linea = 'Secando · listo en ~${duracion(pr['horasRestantes'] as num?)}';
        if (pr['estado'] == 'OBJETIVO_ALCANZADO' && !vistos.contains('l:$id')) {
          vistos.add('l:$id');
          await _p.show(id: 3, title: '${activo['name']} está en el objetivo', body: 'La muestra está en ${pr['humedadActual']} %: retíralo (predicción de la tesis).',
              notificationDetails: NotificationDetails(android: _det(_recordatorios)), payload: 'lotes');
        }
      } catch (_) {/* sin predicción: la actividad sigue con el dato medido */}
      // Actividad del lote en la pantalla de bloqueo: humedad y avance.
      double? d(Object? v) => (v as num?)?.toDouble();
      final ini = d(activo['firstMoisturePct']) ?? d(activo['gravimetInitialMoisturePct']), act = d(activo['lastMoisturePct']), obj = d(activo['targetMoisturePct']) ?? 11;
      final avance = ini == null || act == null || ini <= obj ? 0 : ((ini - act) / (ini - obj) * 100).clamp(0, 100).round();
      await _p.show(id: 1, title: '${activo['name']} · ${act == null ? '—' : '${act.toStringAsFixed(1).replaceAll('.', ',')} %'}', body: linea,
          notificationDetails: NotificationDetails(android: _det(_actividad, fija: true, avance: avance)), payload: 'inicio');
    }
    await p.setStringList('siscan_vistos', vistos.toList().reversed.take(200).toList());
  }
}

@pragma('vm:entry-point')
void revisarEnSegundoPlano() {
  Workmanager().executeTask((tarea, _) async {
    try {
      final p = await SharedPreferences.getInstance();
      if (p.getBool('siscan_notif') != true) return true;
      await Notificaciones._p.initialize(settings: const InitializationSettings(android: AndroidInitializationSettings('ic_stat_siscan')));
      await Notificaciones.revisar();
    } catch (_) {/* sin red: se reintenta en el siguiente ciclo */}
    return true;
  });
}
