import 'dart:convert';

import 'package:http/http.dart' as http;

/// Cliente del servidor de SISCAN (WordPress REST `secador/v1` en cisna.narino.gov.co): las mismas rutas que el panel
/// web. Lectura pública; las escrituras llevan la cabecera de la contraseña de aplicación de quien inició sesión.
class SiscanApi {
  SiscanApi({http.Client? client, this.base = const String.fromEnvironment('SISCAN_API', defaultValue: 'https://cisna.narino.gov.co/wp-json/secador/v1'), this.secador = 1}) : _c = client ?? http.Client();
  final http.Client _c;
  final String base;
  final int secador;

  Future<dynamic> get(String ruta) async {
    final http.Response r;
    try {
      r = await _c.get(Uri.parse('$base$ruta'), headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 20));
    } catch (_) {
      throw ApiError('No pudimos conectarnos con el secador. Verifica la conexión e intenta nuevamente.');
    }
    if (r.statusCode != 200) throw ApiError('No fue posible cargar estos datos (código ${r.statusCode}).', estado: r.statusCode);
    return jsonDecode(utf8.decode(r.bodyBytes));
  }

  Future<dynamic> enviar(String metodo, String ruta, {Object? cuerpo, required String auth}) async {
    final req = http.Request(metodo, Uri.parse('$base$ruta'))
      ..headers.addAll({'Authorization': auth, 'Content-Type': 'application/json', 'Accept': 'application/json'})
      ..body = jsonEncode(cuerpo ?? {});
    final http.Response r;
    try {
      r = await http.Response.fromStream(await _c.send(req).timeout(const Duration(seconds: 25)));
    } catch (_) {
      throw ApiError('No fue posible guardar. Verifica la conexión.');
    }
    final d = r.bodyBytes.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    if (r.statusCode == 401 || r.statusCode == 403) throw ApiError('Tu sesión venció o ya no tiene permiso. Ingresa de nuevo.', estado: r.statusCode);
    if (r.statusCode == 409) throw ApiError((d is Map ? d['message'] as String? : null) ?? 'El secador está en modo automático.', estado: 409);
    if (r.statusCode < 200 || r.statusCode >= 300) throw ApiError((d is Map ? d['message'] as String? : null) ?? 'No fue posible guardar (código ${r.statusCode}).', estado: r.statusCode);
    return d;
  }

  /* Lecturas */
  Future<List<Map<String, dynamic>>> lotes() async => (await get('/drying-batches?secadorId=$secador') as List).cast<Map<String, dynamic>>();
  Future<Map<String, dynamic>> lote(int id) async => (await get('/drying-batches/$id/summary') as Map).cast<String, dynamic>();
  Future<List<Map<String, dynamic>>> curva(int id) async => (await get('/drying-batches/$id/curve') as List).cast<Map<String, dynamic>>();
  Future<Map<String, dynamic>> calibracion(int id) async => (await get('/drying-batches/$id/calibration') as Map).cast<String, dynamic>();
  Future<Map<String, dynamic>> prediccion(int id) async => (await get('/drying-batches/$id/prediction') as Map).cast<String, dynamic>();
  Future<Map<String, dynamic>> opinionIA(int id) async => (await get('/drying-batches/$id/ai-opinion') as Map).cast<String, dynamic>();
  Future<Map<String, dynamic>> reporte() async => (await get('/secadores/$secador/report') as Map).cast<String, dynamic>();
  Future<List<Map<String, dynamic>>> lecturas({int limite = 600}) async => ((await get('/readings?secadorId=$secador&limit=$limite') as Map)['readings'] as List).cast<Map<String, dynamic>>();
  Future<List<Map<String, dynamic>>> actuadores() async => (await get('/api/actuators?secadorId=$secador') as List).cast<Map<String, dynamic>>();
  Future<Map<String, dynamic>> clima() async => (await get('/weather/$secador') as Map).cast<String, dynamic>();
  Future<List<Map<String, dynamic>>> secadores() async => (await get('/secadores') as List).cast<Map<String, dynamic>>();
  Future<Map<String, dynamic>> protocolos() async => (await get('/protocols') as Map).cast<String, dynamic>();
  Future<List<Map<String, dynamic>>> ordenes({int limite = 50}) async => ((await get('/actuator-log?secadorId=$secador&limit=$limite') as Map)['events'] as List).cast<Map<String, dynamic>>();
  Future<Map<String, dynamic>> control() async => (await get('/secadores/$secador/control') as Map).cast<String, dynamic>();
  Future<Map<String, dynamic>> diagnostico() async => (await get('/secadores/$secador/sensor-diagnosis') as Map).cast<String, dynamic>();
  Future<Map<String, dynamic>> energia({int horas = 24}) async => (await get('/energy-hourly/$secador?hours=$horas') as Map).cast<String, dynamic>();
  Future<Map<String, dynamic>> energiaActuadores({int horas = 24}) async => (await get('/actuator-energy/$secador?hours=$horas') as Map).cast<String, dynamic>();
  Future<Map<String, dynamic>> calibracionSensores() async => (await get('/sensor-calibration?secadorId=$secador') as Map).cast<String, dynamic>();
  Future<Map<String, dynamic>> comparar() async => (await get('/drying-batches/compare?secadorId=$secador') as Map).cast<String, dynamic>();

  /* Escrituras (administración o «Gestor del Secador») */
  Future<void> actuador(int id, bool on, String auth) => enviar('PUT', '/api/actuators/$id', cuerpo: {'status': on ? 'ON' : 'OFF', 'secadorId': secador}, auth: auth);
  Future<void> modo(bool auto, String auth) => enviar('PUT', '/secadores/$secador/control', cuerpo: {'mode': auto ? 'AUTO' : 'MANUAL'}, auth: auth);
  Future<void> pesaje(int lote, double gramos, String auth) => enviar('POST', '/drying-batches/$lote/samples', cuerpo: {'sampleWeightGrams': gramos}, auth: auth);
  Future<void> corregirPesaje(int lote, int id, double gramos, String auth) => enviar('PUT', '/drying-batches/$lote/samples/$id', cuerpo: {'sampleWeightGrams': gramos}, auth: auth);
  Future<void> eliminarPesaje(int lote, int id, String auth) => enviar('DELETE', '/drying-batches/$lote/samples/$id', auth: auth);
  Future<void> crearLote(Map<String, dynamic> datos, String auth) => enviar('POST', '/drying-batches', cuerpo: {...datos, 'secadorId': secador}, auth: auth);
  Future<void> finalizarLote(int id, double? pesoFinalKg, String auth) => enviar('PUT', '/drying-batches/$id/close', cuerpo: {'status': 'COMPLETED', 'finalWeightKg': pesoFinalKg}, auth: auth);
  Future<void> puntoMedido(int lote, double gramos, double medidor, String auth) =>
      enviar('POST', '/drying-batches/$lote/calibration', cuerpo: {'sampleWeightGrams': gramos, 'referenceMoisturePct': medidor}, auth: auth);
  Future<void> referenciaCenicafe(int lote, bool borrarPuntos, String auth) => enviar('PUT', '/drying-batches/$lote/calibration/cenicafe', cuerpo: {'clearPoints': borrarPuntos}, auth: auth);
  Future<void> corregirSensor(String tipo, double ganancia, double desplazamiento, bool historico, String auth) => enviar('PUT', '/sensor-calibration',
      cuerpo: {'secadorId': secador, 'sensorType': tipo, 'gain': ganancia, 'offset': desplazamiento, 'applyToHistory': historico}, auth: auth);
  Future<void> ubicacion(double lat, double lon, bool bloqueada, String? sitio, String auth) => enviar('PUT', '/secadores/$secador',
      cuerpo: {'latitude': lat, 'longitude': lon, 'locationLocked': bloqueada, if (sitio != null && sitio.isNotEmpty) 'locationLabel': sitio}, auth: auth);
  Future<void> marcarAlertasLeidas(String auth) => enviar('PUT', '/secadores/$secador/alerts/read', auth: auth);
}

class ApiError implements Exception {
  ApiError(this.mensaje, {this.estado});
  final String mensaje;
  final int? estado;
  bool get sinPermiso => estado == 401 || estado == 403;
  @override
  String toString() => mensaje;
}
