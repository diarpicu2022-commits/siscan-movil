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
}
