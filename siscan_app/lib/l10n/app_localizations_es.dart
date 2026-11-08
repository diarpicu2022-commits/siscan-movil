// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navInicio => 'Inicio';

  @override
  String get navLotes => 'Lotes';

  @override
  String get navPesaje => 'Pesaje';

  @override
  String get navEquipo => 'Equipo';

  @override
  String get navMas => 'Más';

  @override
  String navInicioConAlertas(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Inicio, $cantidad alertas',
      one: 'Inicio, 1 alerta',
    );
    return '$_temp0';
  }

  @override
  String get idioma => 'Idioma';

  @override
  String get idiomaComoElTelefono => 'Como el teléfono';

  @override
  String idiomaAhora(String idioma) {
    return 'Ahora: $idioma';
  }

  @override
  String get hoy => 'Hoy';

  @override
  String get ayer => 'Ayer';

  @override
  String get volver => 'Volver';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get cargando => 'Cargando…';

  @override
  String get masVistaPublica => 'Vista pública';

  @override
  String get masSinCuenta => 'Sin cuenta · solo lectura';

  @override
  String masSesionGestor(String usuario) {
    return 'Gestor del Secador · $usuario';
  }

  @override
  String masSesionSinPermiso(String usuario) {
    return 'Sin permiso de control · $usuario';
  }

  @override
  String get masCalibracion => 'Calibración';

  @override
  String get masCalibracionSub => 'Gravimet y sensores';

  @override
  String get masMapa => 'Mapa de secadores';

  @override
  String masMapaSub(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad secadores en Nariño',
      one: '1 secador en Nariño',
    );
    return '$_temp0';
  }

  @override
  String get masHistorial => 'Historial del equipo';

  @override
  String get masHistorialSub => 'Órdenes y energía';

  @override
  String get masUbicacion => 'Ubicación del secador';

  @override
  String get masUbicacionFijada => 'fijada a mano';

  @override
  String get masUbicacionPorIp => 'por IP del ESP32';

  @override
  String get masReloj => 'Reloj inteligente';

  @override
  String get masRelojSub =>
      'SISCAN para Wear OS · lee el secador y, con tu sesión, manda órdenes';

  @override
  String get masNotificaciones => 'Notificaciones';

  @override
  String get masNotificacionesSub => 'Alertas, hora de pesar y lote listo';

  @override
  String get masHuella => 'Ingreso con huella';

  @override
  String get masHuellaSinCuenta => 'Primero ingresa con tu cuenta';

  @override
  String get masHuellaSub => 'Entra rápido sin escribir la contraseña';

  @override
  String get masTema => 'Tema';

  @override
  String get masAcerca => 'Acerca de y licencias';

  @override
  String get masAcercaSub => 'Íconos Lucide y software de terceros';

  @override
  String get masPrivacidad => 'Tus datos y privacidad';

  @override
  String get masPrivacidadSub => 'Política, exportar y borrar';

  @override
  String get masIngresar => 'Ingresar';

  @override
  String get masIngresarSub => 'Para registrar pesajes y mandar órdenes';

  @override
  String get masCerrarSesion => 'Cerrar sesión';

  @override
  String get temaClaro => 'Claro';

  @override
  String get temaClaroSub => 'Siempre claro';

  @override
  String get temaOscuro => 'Oscuro';

  @override
  String get temaOscuroSub => 'Siempre oscuro';

  @override
  String get temaHora => 'Según la hora';

  @override
  String get temaHoraSub =>
      'Claro de 6:00 a 19:00, oscuro de noche (hora de Colombia)';

  @override
  String get temaComoElTelefono => 'Como el teléfono';

  @override
  String get temaSistemaSub => 'Sigue el ajuste del sistema';

  @override
  String get calQueCalibrar => 'Qué calibrar';

  @override
  String get calSensores => 'Sensores';

  @override
  String get calSinLotes => 'Sin lotes para calibrar';

  @override
  String get calSinLotesTexto =>
      'La calibración del Gravimet se hace sobre un lote con pesajes.';

  @override
  String calForma(String lote) {
    return 'Forma de calibrar · $lote';
  }

  @override
  String get calConPuntos => 'Con puntos';

  @override
  String get calReferencia => 'Referencia Cenicafé (53 %)';

  @override
  String get calLecturaMedidor => 'Lectura del medidor';

  @override
  String get calPesoMuestra => 'Peso de la muestra';

  @override
  String get calPesoPista => 'Usa el peso del último pesaje.';

  @override
  String get calCalibrar => 'Calibrar y recalcular';

  @override
  String get calReferenciaAplicada => 'Referencia Cenicafé aplicada';

  @override
  String get calErrorDatos =>
      'Escribe la lectura del medidor (0–99,9 %) y el peso en gramos.';

  @override
  String get calPuntoAgregado => 'Punto medido agregado';

  @override
  String get calLoteRecalculado => 'El lote se recalculó.';

  @override
  String get calPuntosMedidos => 'Puntos medidos';

  @override
  String calPunto(String fecha, String peso, String lectura) {
    return '$fecha · $peso g · medidor $lectura %';
  }

  @override
  String get calCargandoSensores => 'Cargando la corrección de sensores…';

  @override
  String calGanancia(String ganancia, String desplazamiento) {
    return 'Ganancia $ganancia · desplazamiento $desplazamiento';
  }

  @override
  String get calCalibrado => 'Calibrado';

  @override
  String get calSinCalibrar => 'Sin calibrar';

  @override
  String get calPie =>
      'Toca un sensor para corregirlo con un punto: escribe el valor real medido con tu instrumento.';

  @override
  String calCorregir(String sensor) {
    return 'Corregir $sensor';
  }

  @override
  String calLecturaActual(String valor, String unidad) {
    return 'Lectura actual del sensor: $valor $unidad';
  }

  @override
  String calValorReal(String unidad) {
    return 'Valor real ($unidad)';
  }

  @override
  String get calAplicar => 'Aplicar';

  @override
  String calCalibradoSensor(String sensor) {
    return 'Calibrado: $sensor';
  }

  @override
  String get mapaTitulo => 'Mapa';

  @override
  String mapaFotoDe(String secador) {
    return 'Foto del $secador';
  }

  @override
  String get mapaFoto => 'Foto del secador';

  @override
  String get mapaSinFoto => 'Sin foto todavía';

  @override
  String get mapaSinCoordenadas => 'Sin coordenadas';

  @override
  String get histPeriodo => 'Periodo';

  @override
  String get hist24h => 'Últimas 24 h';

  @override
  String get hist7d => 'Últimos 7 días';

  @override
  String get histCalculando => 'Calculando la energía…';

  @override
  String get histEnergia24h => 'Energía · últimas 24 h';

  @override
  String get histEnergia7d => 'Energía · últimos 7 días';

  @override
  String get histRedSinLecturas => 'Red sin lecturas';

  @override
  String get histEstimado => 'Estimado';

  @override
  String histNota(String solar, String red) {
    return 'Solar: $solar. Red: $red.';
  }

  @override
  String get histOrdenes => 'Órdenes al equipo';

  @override
  String get histCargandoOrdenes => 'Cargando las órdenes…';

  @override
  String get histEncender => 'Encender';

  @override
  String get histApagar => 'Apagar';

  @override
  String get histOrigenPanel => 'Desde el panel';

  @override
  String get histOrigenApp => 'Desde la app';

  @override
  String get histOrigenReloj => 'Desde el reloj';

  @override
  String get histOrigenEsp32 => 'El ESP32';

  @override
  String get histOrigenProtocolo => 'Protocolo';

  @override
  String get histOrigenSinRegistro => 'Origen sin registrar';

  @override
  String get ubicTarjeta => 'Ubicación';

  @override
  String get ubicFijada => 'Fijada a mano';

  @override
  String get ubicPorIp => 'Por IP del ESP32';

  @override
  String get ubicLatitud => 'Latitud';

  @override
  String get ubicLongitud => 'Longitud';

  @override
  String get ubicSitio => 'Nombre del sitio (opcional)';

  @override
  String get ubicBloquear =>
      'Bloquear la ubicación (ignorar la geolocalización por IP del ESP32)';

  @override
  String get ubicUsarMia => 'Usar mi ubicación actual';

  @override
  String get ubicDivulgacion =>
      'SISCAN usará la ubicación de este teléfono una sola vez para fijar dónde está el secador y consultar su clima. Se envía al servidor del CISNA como ubicación del equipo; no se guarda en el teléfono ni se usa en segundo plano.';

  @override
  String get ubicAhoraNo => 'Ahora no';

  @override
  String get ubicContinuar => 'Continuar';

  @override
  String get ubicTomada => 'Ubicación tomada del teléfono';

  @override
  String get ubicRevisaGuarda => 'Revisa y guarda.';

  @override
  String get ubicError =>
      'No fue posible obtener tu ubicación. Revisa el permiso de ubicación.';

  @override
  String get ubicGuardar => 'Guardar ubicación y refrescar clima';

  @override
  String get ubicRevisaCoordenadas => 'Revisa la latitud y la longitud.';

  @override
  String get ubicGuardada => 'Ubicación guardada';

  @override
  String get ubicGuardadaDetalle =>
      'El clima se consulta con el sitio correcto.';

  @override
  String get ubicPie =>
      'La ubicación del teléfono solo se usa cuando tocas «Usar mi ubicación actual»; no se guarda en el teléfono.';

  @override
  String get relojTarjeta => 'SISCAN en Wear OS';

  @override
  String get relojTexto =>
      'El reloj muestra el monitoreo del lote, las lecturas, el equipo, la predicción y las alertas. Con la sesión iniciada en este teléfono, también puede encender o apagar actuadores y registrar pesajes: el reloj le pide la orden al teléfono y el teléfono la envía con tu cuenta (ingresa con «Recordarme»).';

  @override
  String get relojPie =>
      'Instala SISCAN en el reloj desde el mismo paquete de la app. Sin sesión en el teléfono, el reloj solo lee.';

  @override
  String get licIconos => 'Íconos';

  @override
  String get licIconosTexto =>
      'Los íconos de SISCAN salen de Lucide (lucide.dev), con trazo propio de 1,75. Estos son sus avisos de licencia.';

  @override
  String get licErrorAviso => 'No se pudo leer el aviso de licencia.';

  @override
  String get licTerceros => 'Software de terceros';

  @override
  String get licTercerosTexto =>
      'Flutter y los paquetes que usa la app, cada uno con su licencia.';

  @override
  String get licVerTodas => 'Ver todas las licencias';

  @override
  String get privTitulo => 'Tus datos';

  @override
  String get privPolitica => 'Política de tratamiento de datos';

  @override
  String get privDerechos => 'Tus derechos en la app';

  @override
  String get privRevocar => 'Revocar la contraseña de aplicación';

  @override
  String get privBorrar => 'Borrar los datos de este teléfono';

  @override
  String get privBorrarTexto =>
      'Se cierra la sesión y se borran la credencial, la copia del secador y tus preferencias. El servidor del CISNA no cambia.';

  @override
  String get privBorrarConfirmar => 'Borrar';

  @override
  String get privBorrados => 'Datos de este teléfono borrados';

  @override
  String get prefSinPermisoNotif =>
      'Android no dio permiso para notificaciones. Actívalo en los ajustes del teléfono.';

  @override
  String get prefSinHuella => 'Este teléfono no tiene huella configurada.';

  @override
  String get prefConfirmaHuella =>
      'Confirma tu huella para activar el ingreso rápido';
}
