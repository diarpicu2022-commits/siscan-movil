import 'dart:async';

import 'package:flutter/foundation.dart';

import '../widgets/connection_status.dart';
import 'models.dart';
import 'overview_cache.dart';
import 'repository.dart';

/// Estado compartido del Inicio y la barra superior: carga, actualiza cada 30 s y conserva el último dato bueno
/// si una actualización falla (el dato viejo se muestra como tal, nunca como actual).
class OverviewController extends ChangeNotifier {
  OverviewController(this.repo, {this.every = const Duration(seconds: 30), OverviewCache? cache}) : cache = cache ?? MemoryOverviewCache();
  final SiscanRepository repo;
  final OverviewCache cache;
  final Duration? every;

  Overview? data;
  String? error;
  bool loading = false;
  Timer? _timer;

  SyncStatus get sync => loading && data != null
      ? SyncStatus.sincronizando
      : error != null
          ? (data == null ? SyncStatus.error : SyncStatus.offline)
          : (data != null && !data!.dryerReporting ? SyncStatus.sinReportes : SyncStatus.conectado);

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      data = await repo.overview();
      error = null;
      await cache.save(data!);
    } catch (e) {
      error = e is ApiException ? e.message : 'No pudimos cargar los datos del secador. Intenta nuevamente.';
      // Sin red: lo último que se vio, marcado como desactualizado (nunca como actual).
      data = await cache.read() ?? data;
    }
    loading = false;
    notifyListeners();
  }

  void start() {
    load();
    if (every != null) _timer ??= Timer.periodic(every!, (_) => load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
