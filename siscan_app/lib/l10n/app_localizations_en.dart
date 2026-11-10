// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navInicio => 'Home';

  @override
  String get navLotes => 'Batches';

  @override
  String get navPesaje => 'Weighing';

  @override
  String get navEquipo => 'Equipment';

  @override
  String get navMas => 'More';

  @override
  String navInicioConAlertas(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Home, $cantidad alerts',
      one: 'Home, 1 alert',
    );
    return '$_temp0';
  }

  @override
  String get idioma => 'Language';

  @override
  String get idiomaComoElTelefono => 'Same as phone';

  @override
  String idiomaAhora(String idioma) {
    return 'Now: $idioma';
  }

  @override
  String get hoy => 'Today';

  @override
  String get ayer => 'Yesterday';

  @override
  String get volver => 'Back';

  @override
  String get cancelar => 'Cancel';

  @override
  String get cargando => 'Loading…';

  @override
  String get masVistaPublica => 'Public view';

  @override
  String get masSinCuenta => 'No account · read only';

  @override
  String masSesionGestor(String usuario) {
    return 'Dryer manager · $usuario';
  }

  @override
  String masSesionSinPermiso(String usuario) {
    return 'No control permission · $usuario';
  }

  @override
  String get masCalibracion => 'Calibration';

  @override
  String get masCalibracionSub => 'Gravimet and sensors';

  @override
  String get masMapa => 'Dryer map';

  @override
  String masMapaSub(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad dryers in Nariño',
      one: '1 dryer in Nariño',
    );
    return '$_temp0';
  }

  @override
  String get masHistorial => 'Equipment history';

  @override
  String get masHistorialSub => 'Commands and energy';

  @override
  String get masUbicacion => 'Dryer location';

  @override
  String get masUbicacionFijada => 'set by hand';

  @override
  String get masUbicacionPorIp => 'from the ESP32\'s IP';

  @override
  String get masReloj => 'Smartwatch';

  @override
  String get masRelojSub =>
      'SISCAN for Wear OS · reads the dryer and, when you\'re signed in, sends commands';

  @override
  String get masNotificaciones => 'Notifications';

  @override
  String get masNotificacionesSub => 'Alerts, weighing time and batch ready';

  @override
  String get masHuella => 'Fingerprint sign-in';

  @override
  String get masHuellaSinCuenta => 'Sign in with your account first';

  @override
  String get masHuellaSub => 'Sign in quickly without typing your password';

  @override
  String get masTema => 'Theme';

  @override
  String get masAcerca => 'About and licenses';

  @override
  String get masAcercaSub => 'Lucide icons and third-party software';

  @override
  String get masPrivacidad => 'Your data and privacy';

  @override
  String get masPrivacidadSub => 'Policy, export and delete';

  @override
  String get masIngresar => 'Sign in';

  @override
  String get masIngresarSub => 'To record weighings and send commands';

  @override
  String get masCerrarSesion => 'Sign out';

  @override
  String get temaClaro => 'Light';

  @override
  String get temaClaroSub => 'Always light';

  @override
  String get temaOscuro => 'Dark';

  @override
  String get temaOscuroSub => 'Always dark';

  @override
  String get temaHora => 'By time of day';

  @override
  String get temaHoraSub =>
      'Light from 6 AM to 7 PM, dark at night (Colombia time)';

  @override
  String get temaComoElTelefono => 'Same as phone';

  @override
  String get temaSistemaSub => 'Follows the system setting';

  @override
  String get calQueCalibrar => 'What to calibrate';

  @override
  String get calSensores => 'Sensors';

  @override
  String get calSinLotes => 'No batches to calibrate';

  @override
  String get calSinLotesTexto =>
      'Gravimet is calibrated on a batch that has weighings.';

  @override
  String calForma(String lote) {
    return 'How to calibrate · $lote';
  }

  @override
  String get calConPuntos => 'With points';

  @override
  String get calReferencia => 'Cenicafé reference (53 %)';

  @override
  String get calLecturaMedidor => 'Moisture meter reading';

  @override
  String get calPesoMuestra => 'Sample weight';

  @override
  String get calPesoPista => 'Uses the weight from the last weighing.';

  @override
  String get calCalibrar => 'Calibrate and recalculate';

  @override
  String get calReferenciaAplicada => 'Cenicafé reference applied';

  @override
  String get calErrorDatos =>
      'Enter the meter reading (0–99.9 %) and the weight in grams.';

  @override
  String get calPuntoAgregado => 'Measured point added';

  @override
  String get calLoteRecalculado => 'The batch was recalculated.';

  @override
  String get calPuntosMedidos => 'Measured points';

  @override
  String calPunto(String fecha, String peso, String lectura) {
    return '$fecha · $peso g · meter $lectura %';
  }

  @override
  String get calCargandoSensores => 'Loading sensor corrections…';

  @override
  String calGanancia(String ganancia, String desplazamiento) {
    return 'Gain $ganancia · offset $desplazamiento';
  }

  @override
  String get calCalibrado => 'Calibrated';

  @override
  String get calSinCalibrar => 'Uncalibrated';

  @override
  String get calPie =>
      'Tap a sensor to correct it with one point: enter the real value measured with your instrument.';

  @override
  String calCorregir(String sensor) {
    return 'Correct $sensor';
  }

  @override
  String calLecturaActual(String valor, String unidad) {
    return 'Current sensor reading: $valor $unidad';
  }

  @override
  String calValorReal(String unidad) {
    return 'Real value ($unidad)';
  }

  @override
  String get calAplicar => 'Apply';

  @override
  String calCalibradoSensor(String sensor) {
    return 'Calibrated: $sensor';
  }

  @override
  String get mapaTitulo => 'Map';

  @override
  String mapaFotoDe(String secador) {
    return 'Photo of $secador';
  }

  @override
  String get mapaFoto => 'Dryer photo';

  @override
  String get mapaSinFoto => 'No photo yet';

  @override
  String get mapaSinCoordenadas => 'No coordinates';

  @override
  String get histPeriodo => 'Period';

  @override
  String get hist24h => 'Last 24 h';

  @override
  String get hist7d => 'Last 7 days';

  @override
  String get histCalculando => 'Calculating energy…';

  @override
  String get histEnergia24h => 'Energy · last 24 h';

  @override
  String get histEnergia7d => 'Energy · last 7 days';

  @override
  String get histRedSinLecturas => 'No grid readings';

  @override
  String get histEstimado => 'Estimated';

  @override
  String histNota(String solar, String red) {
    return 'Solar: $solar. Grid: $red.';
  }

  @override
  String get histOrdenes => 'Equipment commands';

  @override
  String get histCargandoOrdenes => 'Loading commands…';

  @override
  String get histEncender => 'Turn on';

  @override
  String get histApagar => 'Turn off';

  @override
  String get histOrigenPanel => 'From the web panel';

  @override
  String get histOrigenApp => 'From the app';

  @override
  String get histOrigenReloj => 'From the watch';

  @override
  String get histOrigenEsp32 => 'The ESP32';

  @override
  String get histOrigenProtocolo => 'Protocol';

  @override
  String get histOrigenSinRegistro => 'Unrecorded source';

  @override
  String get ubicTarjeta => 'Location';

  @override
  String get ubicFijada => 'Set by hand';

  @override
  String get ubicPorIp => 'From the ESP32\'s IP';

  @override
  String get ubicLatitud => 'Latitude';

  @override
  String get ubicLongitud => 'Longitude';

  @override
  String get ubicSitio => 'Site name (optional)';

  @override
  String get ubicBloquear =>
      'Lock the location (ignore the ESP32\'s IP geolocation)';

  @override
  String get ubicUsarMia => 'Use my current location';

  @override
  String get ubicDivulgacion =>
      'SISCAN will use this phone\'s location only once to set where the dryer is and look up its weather. It\'s sent to the CISNA server as the equipment\'s location; it isn\'t stored on the phone or used in the background.';

  @override
  String get ubicAhoraNo => 'Not now';

  @override
  String get ubicContinuar => 'Continue';

  @override
  String get ubicTomada => 'Location taken from the phone';

  @override
  String get ubicRevisaGuarda => 'Check it and save.';

  @override
  String get ubicError =>
      'Couldn\'t get your location. Check the location permission.';

  @override
  String get ubicGuardar => 'Save location and refresh weather';

  @override
  String get ubicRevisaCoordenadas => 'Check the latitude and longitude.';

  @override
  String get ubicGuardada => 'Location saved';

  @override
  String get ubicGuardadaDetalle =>
      'Weather is now checked for the right place.';

  @override
  String get ubicPie =>
      'The phone\'s location is only used when you tap “Use my current location”; it isn\'t stored on the phone.';

  @override
  String get relojTarjeta => 'SISCAN on Wear OS';

  @override
  String get relojTexto =>
      'The watch shows batch monitoring, readings, equipment, the prediction and alerts. When you\'re signed in on this phone, it can also turn actuators on or off and record weighings: the watch asks the phone, and the phone sends the command with your account (sign in with “Remember me”).';

  @override
  String get relojPie =>
      'Install SISCAN on the watch from the same app package. Without a session on the phone, the watch is read-only.';

  @override
  String get licIconos => 'Icons';

  @override
  String get licIconosTexto =>
      'SISCAN\'s icons come from Lucide (lucide.dev), with our own 1.75 stroke. These are their license notices.';

  @override
  String get licErrorAviso => 'Couldn\'t read the license notice.';

  @override
  String get licTerceros => 'Third-party software';

  @override
  String get licTercerosTexto =>
      'Flutter and the packages the app uses, each with its license.';

  @override
  String get licVerTodas => 'View all licenses';

  @override
  String get privTitulo => 'Your data';

  @override
  String get privPolitica => 'Data processing policy';

  @override
  String get privDerechos => 'Your rights in the app';

  @override
  String get privRevocar => 'Revoke the application password';

  @override
  String get privBorrar => 'Delete this phone\'s data';

  @override
  String get privBorrarTexto =>
      'You\'ll be signed out, and your credential, the saved copy of the dryer and your preferences will be deleted. The CISNA server doesn\'t change.';

  @override
  String get privBorrarConfirmar => 'Delete';

  @override
  String get privBorrados => 'This phone\'s data was deleted';

  @override
  String get prefSinPermisoNotif =>
      'Android didn\'t allow notifications. Turn them on in the phone\'s settings.';

  @override
  String get prefSinHuella => 'This phone has no fingerprint set up.';

  @override
  String get prefConfirmaHuella =>
      'Confirm your fingerprint to turn on quick sign-in';

  @override
  String get variedadSinRegistrar => 'Variety not recorded';

  @override
  String get sitioAireLibre => 'Open air';

  @override
  String get sitioSecador => 'Dryer';

  @override
  String get predCalculando => 'Calculating the prediction…';

  @override
  String predListoEn(String tiempo) {
    return 'Ready in ~$tiempo';
  }

  @override
  String get predRetiralo => 'Ready: take it out';

  @override
  String get predTermino => 'Finished on target';

  @override
  String get predSobresecado => 'Past the point: over-dried';

  @override
  String get predNoAlcanza => 'With this air it won\'t reach the target';

  @override
  String get predPocosPesajes => 'Too few weighings to predict';

  @override
  String get estadoAlerta => 'Alert';

  @override
  String get saludRedSinFallas => 'The neural network sees no faults';

  @override
  String get saludRedConFallas => 'The neural network sees faults';

  @override
  String saludSensoresNormales(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad sensors with a normal signal',
      one: '1 sensor with a normal signal',
    );
    return '$_temp0';
  }

  @override
  String get saludEspConectado => 'ESP32 connected';

  @override
  String get saludEspSinConexion => 'ESP32 offline';

  @override
  String saludUltimoReporte(String cuando) {
    return 'Last report $cuando';
  }

  @override
  String get saludNoReporta => 'Not reporting yet';

  @override
  String saludSensoresReportando(int vivos, int total) {
    return '$vivos of $total sensors reporting';
  }

  @override
  String get saludActCopias => 'Actuators with duplicates';

  @override
  String get saludActRegistrados => 'Registered actuators';

  @override
  String saludActCuenta(int cantidad) {
    return '$cantidad registered';
  }

  @override
  String saludActCopiasGpio(int cantidad) {
    return ' · $cantidad duplicates by GPIO';
  }

  @override
  String get saludUltimoEstado => ' · last known state';

  @override
  String get redNormal => 'Normal';

  @override
  String get redPegado => 'Stuck';

  @override
  String get redSaturado => 'Saturated';

  @override
  String get redDeriva => 'Drift';

  @override
  String get redSalto => 'Step jump';

  @override
  String get redRuido => 'Noise';

  @override
  String get redPicos => 'Spikes';

  @override
  String get redSinDatos => 'No data';

  @override
  String get soloLecturaTitulo => 'Read-only view';

  @override
  String inicioHola(String nombre) {
    return 'Hi, $nombre!';
  }

  @override
  String get inicioHolaSinNombre => 'Hi!';

  @override
  String get inicioNoSeLeyo => 'Couldn\'t read the dryer';

  @override
  String get inicioLeyendo => 'Reading the dryer…';

  @override
  String inicioSubSinLotes(String secador) {
    return '$secador · no batches';
  }

  @override
  String inicioSubSecando(String secador, String lote) {
    return '$secador · $lote drying';
  }

  @override
  String inicioSubTerminado(String secador, String lote) {
    return '$secador · $lote finished';
  }

  @override
  String get sinLecturas => 'No readings';

  @override
  String ultimoDato(String cuando) {
    return 'Last reading $cuando';
  }

  @override
  String get inicioSinLotes => 'No batches recorded';

  @override
  String get inicioSinLotesTexto =>
      'When you load coffee into the dryer, its record will show up here.';

  @override
  String get inicioTempInterior => 'Inside temp.';

  @override
  String get inicioHumedadRelativa => 'Relative humidity';

  @override
  String get inicioExterior => 'Outside';

  @override
  String get inicioPotenciaTotal => 'Total power';

  @override
  String get actEnFuncionamiento => 'Running';

  @override
  String get actDetenidos => 'Stopped';

  @override
  String actEncendiendo(String nombre) {
    return '$nombre · Turning on…';
  }

  @override
  String actApagando(String nombre) {
    return '$nombre · Turning off…';
  }

  @override
  String get ordenSeCumple => 'It takes effect when the ESP32 reports.';

  @override
  String get inicioSoloLectura =>
      'Read-only view: sign in with your account to send commands.';

  @override
  String get alertas => 'Alerts';

  @override
  String get loteSecando => 'Drying';

  @override
  String get loteTerminado => 'Finished';

  @override
  String get humedadGrano => 'Bean moisture';

  @override
  String humedadGranoLector(String valor) {
    return 'Bean moisture $valor';
  }

  @override
  String get sinDato => 'no data';

  @override
  String get objetivoPrefijo => 'Target 10 – 12 % · ';

  @override
  String get predNoDisponible => 'prediction unavailable';

  @override
  String predFaltan(String tiempo) {
    return '~$tiempo to go';
  }

  @override
  String ultimoPesaje(String cuando) {
    return 'Last weighing $cuando';
  }

  @override
  String get avanceObjetivo => 'Progress toward the target';

  @override
  String get confianzaAlta => 'High confidence';

  @override
  String get confianzaMedia => 'Medium confidence';

  @override
  String get confianzaBaja => 'Low confidence';

  @override
  String get magTempInterior => 'Inside temperature';

  @override
  String get magHumInterior => 'Inside relative humidity';

  @override
  String get magTempExterior => 'Outside temperature';

  @override
  String get magHumExterior => 'Outside relative humidity';

  @override
  String get magHumGrano => 'Bean moisture (sensor)';

  @override
  String get magCorriente => 'Current';

  @override
  String get magPotControlador => 'Controller power';

  @override
  String get magPotActuadores => 'Actuator power';

  @override
  String get metaTope => 'Top of the chamber';

  @override
  String get metaCamara => 'Chamber';

  @override
  String get metaAmbiente => 'Outdoors';

  @override
  String get metaCapacitivo => 'Capacitive';

  @override
  String get metaLineaAc => 'AC line';

  @override
  String get metaEspSensores => 'ESP32 and sensors';

  @override
  String get metaVentResist => 'Fans and heaters';

  @override
  String get metaCtrlAct => 'Controller and actuators';

  @override
  String sinConexionUltimoDato(String cuando) {
    return 'Offline · last reading $cuando';
  }

  @override
  String get sinConexionNoReporta => 'Offline · not reporting yet';

  @override
  String get estadoEnOperacion => 'Running';

  @override
  String get estadoEnPausa => 'Paused';

  @override
  String get estadoSinConexion => 'Offline';

  @override
  String get estadoPausaSinLote => 'Paused · no active batch';

  @override
  String get errorConexion => 'We couldn\'t connect to the dryer.';

  @override
  String get haceSinDato => 'No data';

  @override
  String get haceInstantes => 'Just now';

  @override
  String haceMin(int minutos) {
    return '$minutos min ago';
  }

  @override
  String haceH(int horas) {
    return '$horas h ago';
  }

  @override
  String get claveOcultar => 'Hide password';

  @override
  String get claveMostrar => 'Show password';

  @override
  String get curvaSinPesajes =>
      'No weighings yet: the curve appears with the first gravimetric sample.';

  @override
  String get curvaUnPesaje =>
      'Only one weighing: the curve appears with the second.';

  @override
  String curvaResumen(String desde, String hasta) {
    return 'Bean moisture dropped from $desde % to $hasta %. Target 10 – 12 %.';
  }

  @override
  String get leyendaGravimetrico => 'Bean moisture (gravimetric)';

  @override
  String get leyendaPrediccionIa => 'AI prediction';

  @override
  String get leyendaObjetivo => 'Target';

  @override
  String get objetivoRango => 'Target 10 – 12 %';

  @override
  String get energiaTitulo => 'Energy use and cost';

  @override
  String get energiaSolar => 'Solar';

  @override
  String get energiaRed => 'Grid';

  @override
  String get energiaCosto => 'Cost';

  @override
  String get energiaGraficoLector =>
      'Energy per period: solar below, grid above';

  @override
  String energiaTarifa(String tarifa) {
    return 'Rate $tarifa/kWh';
  }

  @override
  String get predModeloTesis => 'Thesis model';

  @override
  String get predTitulo => 'AI prediction';

  @override
  String get predTiempoRestante => 'Estimated time left';

  @override
  String get predConfianzaRotulo => 'Prediction confidence';

  @override
  String get predDatosConsiderados => 'Inputs considered';

  @override
  String get procesoLote => 'Batch process';

  @override
  String get zonaHumedo => 'Wet';

  @override
  String get zonaOreado => 'Pre-dried';

  @override
  String get zonaObjetivo => 'Target reached';

  @override
  String get zonaSobresecado => 'Over-dried';

  @override
  String get zonaHumedo53 => 'Wet 53 %';

  @override
  String get zonaActual => 'Current zone: ';

  @override
  String escalaLector(String valor, String zona) {
    return 'Moisture scale: $valor %, $zona zone';
  }

  @override
  String get actEncendido => 'On';

  @override
  String get actApagado => 'Off';

  @override
  String get actBloqueado => 'Locked';

  @override
  String get actEncendiendoSolo => 'Turning on…';

  @override
  String get actApagandoSolo => 'Turning off…';

  @override
  String actBloqueadoSeguridad(String motivo) {
    return 'Locked for safety · $motivo';
  }

  @override
  String get actPorProtocolo => 'Controlled by the protocol';

  @override
  String actNominal(String vatios) {
    return 'Rated $vatios W';
  }

  @override
  String get ordenEnviada => 'Command sent';

  @override
  String get mantenerHint =>
      'Press and hold. With a screen reader, double-tap and hold.';

  @override
  String get alertasRecientes => 'Recent alerts';

  @override
  String get verTodas => 'See all';

  @override
  String get sinAlertas => 'No active alerts';

  @override
  String get todoEnOrden => 'All good.';

  @override
  String get saludTitulo => 'Is the equipment working?';

  @override
  String get saludSi => 'Yes, all good';

  @override
  String get saludRevisa => 'Check the equipment';

  @override
  String mapaLector(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Schematic map of Nariño with $cantidad dryers',
      one: 'Schematic map of Nariño with 1 dryer',
    );
    return '$_temp0';
  }

  @override
  String get sinOrdenes => 'No commands recorded yet.';

  @override
  String get ingresaParaCambios => 'Sign in with your account to make changes';

  @override
  String get cargandoSecador => 'Loading the dryer status…';

  @override
  String errorServidorCodigo(String codigo) {
    return 'The server returned an error (code $codigo).';
  }

  @override
  String get errorSinRespuesta => 'The server didn\'t respond.';

  @override
  String get errorReintentaSolo => ' It retries on its own every 30 s.';

  @override
  String get errorCargaTitulo => 'These data couldn\'t be loaded';

  @override
  String get reintentar => 'Try again';

  @override
  String avisoCopiaGuardada(String cuando) {
    return 'No signal: you\'re seeing the saved copy ($cuando).';
  }

  @override
  String avisoNoReportaDesde(String cuando) {
    return 'The dryer hasn\'t reported since $cuando. You\'re seeing the last reading with its time.';
  }

  @override
  String get avisoSuInstalacion => 'it was installed';

  @override
  String get actualizar => 'Refresh';

  @override
  String get filtro => 'Filter';

  @override
  String get filtroTodos => 'All';

  @override
  String get lotesSinFiltro => 'No batches match this filter.';

  @override
  String get nuevoLote => 'New batch';

  @override
  String get loteTitulo => 'Batch';

  @override
  String get cargandoLote => 'Loading the batch…';

  @override
  String get curvaHumedad => 'Moisture curve';

  @override
  String get proceso => 'Process';

  @override
  String get faseInicio => 'Start';

  @override
  String get faseCalentamiento => 'Warm-up';

  @override
  String get faseSecadoActivo => 'Active drying';

  @override
  String get faseReduccion => 'Moisture reduction';

  @override
  String get faseAjustes => 'Adjustments';

  @override
  String get faseFinalizacion => 'Completion';

  @override
  String faseEnCursoDesde(String cuando) {
    return 'In progress · since $cuando';
  }

  @override
  String get faseSinRegistro => 'Not recorded';

  @override
  String get faseEnCurso => 'In progress';

  @override
  String get fasePendiente => 'Pending';

  @override
  String get predEntre => 'Between ';

  @override
  String get predY => ' and ';

  @override
  String get predListoCerca => ' · ready around ';

  @override
  String predPesajes(String cantidad) {
    return '$cantidad weighings';
  }

  @override
  String predAjustesBootstrap(String cantidad) {
    return '$cantidad bootstrap fits';
  }

  @override
  String predOrientativo(String cantidad, String minimo) {
    return 'Only $cantidad weighings: below $minimo the thesis treats it as a rough guide.';
  }

  @override
  String get predAjustando => 'Fitting the thesis models…';

  @override
  String get predNoCalculo => 'The prediction couldn\'t be calculated.';

  @override
  String get predListo => 'Ready';

  @override
  String predListoTexto(String valor) {
    return 'The sample is at $valor %: within the commercial window. Take it out.';
  }

  @override
  String get predPasado => 'Over';

  @override
  String predPasadoTexto(String valor) {
    return 'The sample is at $valor %, below 10 %: it\'s over-dried.';
  }

  @override
  String get predNoLlega => 'Won\'t reach';

  @override
  String get predPocosPesajesPunto => 'Too few weighings to predict.';

  @override
  String predPuntoRetiro(String lista) {
    return 'Removal point by model: $lista from the first weighing.';
  }

  @override
  String get predNoLlegaMin => 'won\'t reach';

  @override
  String get redTitulo => 'Neural network · sensors';

  @override
  String redConFalla(int cantidad) {
    return '$cantidad faulty';
  }

  @override
  String get redSinFallas => 'No faults';

  @override
  String red2hHasta(String cuando) {
    return '2 h up to $cuando';
  }

  @override
  String redPie(String f1) {
    return 'Thesis MLP (32, 16), F1 $f1 on the test set. It classifies the signal shape: normal, stuck, drift, step jump, noise, spikes or saturated.';
  }

  @override
  String iaError(String error) {
    return 'The AI couldn\'t be reached. ($error)';
  }

  @override
  String get iaTitulo => 'AI second opinion';

  @override
  String iaPie(String cuando) {
    return 'AI-generated text from the batch data, the thesis prediction, the neural network and the weather · $cuando. It doesn\'t replace measuring.';
  }

  @override
  String get iaExplica =>
      'A language model reads the batch data and the thesis prediction, and gives its estimate with a recommendation.';

  @override
  String get iaVolver => 'Ask again';

  @override
  String get iaConsultar => 'Ask the AI';

  @override
  String get nombreLote => 'Batch name';

  @override
  String get nombreLoteEjemplo => 'Batch C · Castillo';

  @override
  String get nombreLotePista =>
      'This is how it will show on the dashboard, the app and the watch.';

  @override
  String get dondeSeSeca => 'Where does it dry?';

  @override
  String get variedad => 'Variety';

  @override
  String get sinEspecificar => 'Not specified';

  @override
  String get protocolo => 'Protocol';

  @override
  String get muestra => 'Sample';

  @override
  String get humedadInicial => 'Initial moisture';

  @override
  String get humedadObjetivo => 'Target moisture';

  @override
  String get pesoRetiro => 'Calculated removal weight';

  @override
  String materiaSeca(String gramos) {
    return 'with $gramos g of dry matter';
  }

  @override
  String get iniciarLote => 'Start batch';

  @override
  String get escribeNombre => 'Write the batch name.';

  @override
  String get loteIniciado => 'Batch started';

  @override
  String get sinLoteActivo => 'No active batch';

  @override
  String get sinLoteActivoTexto =>
      'Start a batch to begin weighing the sample every morning.';

  @override
  String get cargandoPesajes => 'Loading the weighings…';

  @override
  String get pesoMuestra => 'Sample weight';

  @override
  String get hecho => 'Done';

  @override
  String corregirPesaje(String cuando) {
    return 'Correct weighing · $cuando';
  }

  @override
  String get pesoCorregido => 'Corrected weight';

  @override
  String get guardar => 'Save';

  @override
  String get eliminarPesaje => 'Delete weighing';

  @override
  String get escribePesoCorregido => 'Write the corrected weight in grams.';

  @override
  String get pesajeCorregido => 'Weighing corrected';

  @override
  String get pesajeEliminado => 'Weighing deleted';

  @override
  String get faltaSecar => 'It still needs drying';

  @override
  String get rangoComercial => 'It\'s in the commercial range: take it out';

  @override
  String get yaPaso => 'Past the point: it\'s over-dried';

  @override
  String pesoMuestraDe(String lote) {
    return 'Sample weight · $lote';
  }

  @override
  String get restarDecima => 'Subtract 0.1 g';

  @override
  String get sumarDecima => 'Add 0.1 g';

  @override
  String pesoLector(String gramos) {
    return 'Weight $gramos grams. Tap to type it.';
  }

  @override
  String get retiraEntre => 'Take it out between ';

  @override
  String rangoGramos(String desde, String hasta) {
    return '$desde and $hasta g';
  }

  @override
  String get registrarPesaje => 'Record weighing';

  @override
  String get pesajeRegistrado => 'Weighing recorded';

  @override
  String pesajeDetalle(String gramos, String humedad) {
    return '$gramos g · $humedad % moisture';
  }

  @override
  String get ingresaParaPesar =>
      'Sign in with your account to record weighings.';

  @override
  String pesajesDe(String lote) {
    return 'Weighings for $lote';
  }

  @override
  String get sinPesajesLote => 'This batch has no weighings yet.';

  @override
  String pesajePie(String ajuste, String gramos) {
    return 'Moisture by dry-matter conservation (Cenicafé)$ajuste: $gramos g of dry matter. Tap a weighing to correct it.';
  }

  @override
  String get ajustadaPuntos => ', adjusted with measured points';

  @override
  String get modoSinInfo => 'The server doesn\'t report the dryer mode yet';

  @override
  String modoConfirmado(String cuando) {
    return 'Confirmed by the ESP32 · $cuando';
  }

  @override
  String modoEsperando(String modo) {
    return 'The ESP32 is in $modo mode; waiting for it to apply the change';
  }

  @override
  String get modoAutomaticoMin => 'automatic';

  @override
  String get modoManualMin => 'manual';

  @override
  String get modoNoReportado => 'The ESP32 hasn\'t reported its mode yet';

  @override
  String get modoPedido => 'Requested · the ESP32 hasn\'t confirmed it yet';

  @override
  String get modoOperacion => 'Operating mode';

  @override
  String get modoAutoPedido => 'Automatic mode requested';

  @override
  String get modoManualPedido => 'Manual mode requested';

  @override
  String get modoSeAplica => 'It applies when the ESP32 confirms it.';

  @override
  String get modoAutomatico => 'Automatic';

  @override
  String get modoManual => 'Manual';

  @override
  String get enviando => 'Sending…';

  @override
  String get actuadores => 'Actuators';

  @override
  String copiaDe(String nombre, String gpio) {
    return 'copy of “$nombre” (GPIO $gpio)';
  }

  @override
  String get pieAuto =>
      'The protocol decides when to turn things on. Switch to Manual to send commands.';

  @override
  String get pieAdmin =>
      'Commands take effect when the ESP32 reads them. If the dryer isn\'t reporting, they apply when it reconnects.';

  @override
  String encenderNombre(String nombre) {
    return 'Turn on $nombre';
  }

  @override
  String get mantenerEncender => 'Press and hold to turn on';

  @override
  String get pieResistencia =>
      'To turn on a heater, tap its switch and then press and hold the button that appears.';

  @override
  String get soloLecturaEquipo =>
      'You can see the equipment status. Turning things on or off requires the “Dryer manager” account.';

  @override
  String get sinLecturasSecador => 'The dryer isn\'t sending readings yet.';

  @override
  String redSufijo(String clase) {
    return ' · network: $clase';
  }

  @override
  String get desactualizado => 'Out of date';

  @override
  String get alertasActivas => 'Active';

  @override
  String get avisosAnteriores => 'Earlier notices';

  @override
  String sinRevisar(int cantidad) {
    return '$cantidad unread';
  }

  @override
  String avisosHay(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other:
          'There are $cantidad unread notices from earlier days on the dashboard.',
      one: 'There is 1 unread notice from earlier days on the dashboard.',
    );
    return '$_temp0';
  }

  @override
  String get avisosNinguno => 'No earlier notices pending.';

  @override
  String get marcarTodo => 'Mark all as read';

  @override
  String get marcarTitulo => 'Mark notices as read';

  @override
  String marcarPregunta(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Mark the $cantidad earlier notices as read?',
      one: 'Mark the earlier notice as read?',
    );
    return '$_temp0';
  }

  @override
  String get marcar => 'Mark';

  @override
  String get avisosMarcados => 'Notices marked as read';

  @override
  String get huellaMotivo => 'Sign in to SISCAN with your fingerprint';

  @override
  String get credencialError =>
      'We couldn\'t use the saved credential. Sign in with your password.';

  @override
  String get holaDeNuevo => 'Welcome back';

  @override
  String get ingresaSiscan => 'Sign in to SISCAN';

  @override
  String get usaHuella => 'Use your fingerprint to get in fast.';

  @override
  String get conCuentaCisna =>
      'With your CISNA portal account and an application password.';

  @override
  String get tocaSensor => 'Touch the fingerprint sensor';

  @override
  String get usuarioCorreo => 'Username or email';

  @override
  String get claveApp => 'Application password';

  @override
  String get claveAppPista =>
      'It\'s not your usual password: you create it in your WordPress profile and can revoke it any time.';

  @override
  String get recordarme => 'Remember me';

  @override
  String get crearClave => 'Create password';

  @override
  String get usarCorreo => 'Use email and password';

  @override
  String get ingresarHuella => 'Sign in with fingerprint';

  @override
  String get verSinCuenta => 'View the dryer (read-only)';

  @override
  String get notifCanalAlertas => 'Dryer alerts';

  @override
  String get notifCanalAlertasDesc =>
      'Temperature, humidity and equipment out of range.';

  @override
  String get notifCanalRecord => 'Weighing and batch ready';

  @override
  String get notifCanalRecordDesc =>
      'Time to weigh the sample, and the thesis prediction.';

  @override
  String get notifCanalActividad => 'Batch in progress';

  @override
  String get notifCanalActividadDesc => 'Batch progress on the lock screen.';

  @override
  String get notifAlertaCritica => 'Critical alert';

  @override
  String get notifAdvertencia => 'Warning';

  @override
  String get notifVerEquipo => 'See equipment';

  @override
  String get notifHoraPesar => 'Time to weigh the sample';

  @override
  String get notifSinPesajes => 'no weighings yet';

  @override
  String notifUltimoPesajeHace(int horas) {
    return 'last weighing $horas h ago';
  }

  @override
  String notifSecandoListo(String tiempo) {
    return 'Drying · ready in ~$tiempo';
  }

  @override
  String notifEnObjetivo(String lote) {
    return '$lote is on target';
  }

  @override
  String notifEnObjetivoTexto(String valor) {
    return 'The sample is at $valor %: take it out (thesis prediction).';
  }

  @override
  String get widgetSinLotes => 'SISCAN: no batches recorded.';

  @override
  String widgetDescripcion(String lote, String humedad, String estado) {
    return 'SISCAN, $lote: bean moisture $humedad percent. $estado.';
  }

  @override
  String get widgetHumedad => 'bean moisture';

  @override
  String widgetSinConexionMin(String dia) {
    return 'offline · $dia';
  }

  @override
  String widgetSinConexion(String dia) {
    return 'Offline · $dia';
  }

  @override
  String get hrAbrev => 'RH';

  @override
  String get loteTerminadoLargo => 'Batch finished';

  @override
  String get apiSinConexion =>
      'We couldn\'t connect to the dryer. Check the connection and try again.';

  @override
  String apiCargaCodigo(String codigo) {
    return 'These data couldn\'t be loaded (code $codigo).';
  }

  @override
  String get apiNoGuardo => 'Couldn\'t save. Check the connection.';

  @override
  String get apiSesionVencio =>
      'Your session expired or no longer has permission. Sign in again.';

  @override
  String get apiModoAuto => 'The dryer is in automatic mode.';

  @override
  String apiNoGuardoCodigo(String codigo) {
    return 'Couldn\'t save (code $codigo).';
  }

  @override
  String get authFaltan => 'Write your username and your application password.';

  @override
  String get authIncorrecto =>
      'The username or the application password is incorrect.';

  @override
  String get authNoVerifica => 'We couldn\'t verify your account. Try again.';

  @override
  String get authSinPermiso =>
      'Your account doesn\'t have the “Dryer manager” permission. Ask CISNA for it.';

  @override
  String get authSinConexion =>
      'We couldn\'t connect. Check the connection and try again.';

  @override
  String get privVersion =>
      '0.3 · November 9, 2026 (draft for review by a lawyer)';

  @override
  String privVersionRotulo(String version) {
    return 'Version $version';
  }

  @override
  String get privSecQueGuardaTitulo => 'What the app stores';

  @override
  String get privSecQueGuarda =>
      'The last dryer status (readings, batch, equipment and alerts) so it can be shown without signal; this is not personal data. If you sign in as Dryer manager, your username and application password, encrypted in the phone\'s secure storage, to send commands and record weighings. Your choice of theme, language, notifications and fingerprint.';

  @override
  String get privSecHuellaTitulo => 'Fingerprint';

  @override
  String get privSecHuella =>
      'If you turn it on, the phone checks your fingerprint with its own sensor; the app never receives or stores it. It only unlocks the encrypted credential.';

  @override
  String get privSecUbicacionTitulo => 'Location';

  @override
  String get privSecUbicacion =>
      'Only when an administrator taps “Use my current location” to set the dryer\'s site. It is sent to the CISNA server as the dryer\'s location, not the person\'s. It is not stored on the phone or used in the background.';

  @override
  String get privSecNotificacionesTitulo => 'Notifications';

  @override
  String get privSecNotificaciones =>
      'If you turn them on, the app checks the CISNA server every 15 minutes to warn about alerts, weighing time and a ready batch. It only reads the dryer status.';

  @override
  String get privSecRelojTitulo => 'Smartwatch';

  @override
  String get privSecReloj =>
      'If you sign in with “Remember me”, the phone keeps your session header encrypted with an Android Keystore key so SISCAN on the watch can ask it for commands and weighings. The watch stores no passwords. It is deleted when you sign out or clear the phone\'s data.';

  @override
  String get privSecIaTitulo => 'Artificial intelligence';

  @override
  String get privSecIa =>
      'The “second opinion” is generated by Groq from the CISNA server with batch and dryer data; it receives no personal data. The thesis prediction and the neural network run on the CISNA server.';

  @override
  String get privSecNoHaceTitulo => 'What it doesn\'t do';

  @override
  String get privSecNoHace =>
      'It doesn\'t use the camera or contacts. It has no ads, analytics or tracking. It only talks to cisna.narino.gov.co over HTTPS.';

  @override
  String get privSecTiempoTitulo => 'How long';

  @override
  String get privSecTiempo =>
      'Until you sign out (which deletes the credential), use “Delete this phone\'s data” or uninstall the app.';

  @override
  String get privSecDerechosTitulo => 'Your rights';

  @override
  String get privSecDerechos =>
      'To know, update, correct and delete your data and to withdraw your authorization (Colombian Law 1581 of 2012 and Decree 1377 of 2013, compiled in Decree 1074 of 2015). The application password can also be revoked in your WordPress profile.';

  @override
  String get privSecResponsableTitulo => 'Data controller';

  @override
  String get privSecResponsable =>
      'SISCAN project (Secado Inteligente de Café), Gobernación de Nariño (CISNA). Contact: to be defined by CISNA.';
}
