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

  @override
  String get variedadSinRegistrar => 'Variedad sin registrar';

  @override
  String get sitioAireLibre => 'Aire libre';

  @override
  String get sitioSecador => 'Secador';

  @override
  String get predCalculando => 'Calculando la predicción…';

  @override
  String predListoEn(String tiempo) {
    return 'Listo en ~$tiempo';
  }

  @override
  String get predRetiralo => 'Listo: retíralo';

  @override
  String get predTermino => 'Terminó en el objetivo';

  @override
  String get predSobresecado => 'Pasó el punto: sobre-secado';

  @override
  String get predNoAlcanza => 'Con este aire no llega al objetivo';

  @override
  String get predPocosPesajes => 'Pocos pesajes para predecir';

  @override
  String get estadoAlerta => 'Alerta';

  @override
  String get saludRedSinFallas => 'La red neuronal no ve fallas';

  @override
  String get saludRedConFallas => 'La red neuronal ve fallas';

  @override
  String saludSensoresNormales(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad sensores con señal normal',
      one: '1 sensor con señal normal',
    );
    return '$_temp0';
  }

  @override
  String get saludEspConectado => 'ESP32 conectado';

  @override
  String get saludEspSinConexion => 'ESP32 sin conexión';

  @override
  String saludUltimoReporte(String cuando) {
    return 'Último reporte $cuando';
  }

  @override
  String get saludNoReporta => 'Todavía no reporta';

  @override
  String saludSensoresReportando(int vivos, int total) {
    return '$vivos de $total sensores reportando';
  }

  @override
  String get saludActCopias => 'Actuadores con copias';

  @override
  String get saludActRegistrados => 'Actuadores registrados';

  @override
  String saludActCuenta(int cantidad) {
    return '$cantidad registrados';
  }

  @override
  String saludActCopiasGpio(int cantidad) {
    return ' · $cantidad copias por GPIO';
  }

  @override
  String get saludUltimoEstado => ' · último estado conocido';

  @override
  String get redNormal => 'Normal';

  @override
  String get redPegado => 'Pegado';

  @override
  String get redSaturado => 'Saturado';

  @override
  String get redDeriva => 'Deriva';

  @override
  String get redSalto => 'Salto de escalón';

  @override
  String get redRuido => 'Ruido';

  @override
  String get redPicos => 'Picos';

  @override
  String get redSinDatos => 'Sin datos';

  @override
  String get soloLecturaTitulo => 'Vista de solo lectura';

  @override
  String inicioHola(String nombre) {
    return '¡Hola, $nombre!';
  }

  @override
  String get inicioHolaSinNombre => '¡Hola!';

  @override
  String get inicioNoSeLeyo => 'No se pudo leer el secador';

  @override
  String get inicioLeyendo => 'Leyendo el secador…';

  @override
  String inicioSubSinLotes(String secador) {
    return '$secador · sin lotes';
  }

  @override
  String inicioSubSecando(String secador, String lote) {
    return '$secador · $lote secando';
  }

  @override
  String inicioSubTerminado(String secador, String lote) {
    return '$secador · $lote terminado';
  }

  @override
  String get sinLecturas => 'Sin lecturas';

  @override
  String ultimoDato(String cuando) {
    return 'Último dato $cuando';
  }

  @override
  String get inicioSinLotes => 'No hay lotes registrados';

  @override
  String get inicioSinLotesTexto =>
      'Cuando ingreses café al secador, su registro aparecerá aquí.';

  @override
  String get inicioTempInterior => 'Temp. interior';

  @override
  String get inicioHumedadRelativa => 'Humedad relativa';

  @override
  String get inicioExterior => 'Exterior';

  @override
  String get inicioPotenciaTotal => 'Potencia total';

  @override
  String get actEnFuncionamiento => 'En funcionamiento';

  @override
  String get actDetenidos => 'Detenidos';

  @override
  String actEncendiendo(String nombre) {
    return '$nombre · Encendiendo…';
  }

  @override
  String actApagando(String nombre) {
    return '$nombre · Apagando…';
  }

  @override
  String get ordenSeCumple => 'Se cumple cuando el ESP32 reporte.';

  @override
  String get inicioSoloLectura =>
      'Vista de solo lectura: para mandar órdenes ingresa con tu cuenta.';

  @override
  String get alertas => 'Alertas';

  @override
  String get loteSecando => 'Secando';

  @override
  String get loteTerminado => 'Terminado';

  @override
  String get humedadGrano => 'Humedad del grano';

  @override
  String humedadGranoLector(String valor) {
    return 'Humedad del grano $valor';
  }

  @override
  String get sinDato => 'sin dato';

  @override
  String get objetivoPrefijo => 'Objetivo 10 – 12 % · ';

  @override
  String get predNoDisponible => 'predicción no disponible';

  @override
  String predFaltan(String tiempo) {
    return 'faltan ~$tiempo';
  }

  @override
  String ultimoPesaje(String cuando) {
    return 'Último pesaje $cuando';
  }

  @override
  String get avanceObjetivo => 'Avance hacia el objetivo';

  @override
  String get confianzaAlta => 'Confianza alta';

  @override
  String get confianzaMedia => 'Confianza media';

  @override
  String get confianzaBaja => 'Confianza baja';

  @override
  String get magTempInterior => 'Temperatura interior';

  @override
  String get magHumInterior => 'Humedad relativa interior';

  @override
  String get magTempExterior => 'Temperatura exterior';

  @override
  String get magHumExterior => 'Humedad relativa exterior';

  @override
  String get magHumGrano => 'Humedad del grano (sensor)';

  @override
  String get magCorriente => 'Corriente';

  @override
  String get magPotControlador => 'Potencia del controlador';

  @override
  String get magPotActuadores => 'Potencia de actuadores';

  @override
  String get metaTope => 'Tope de la cámara';

  @override
  String get metaCamara => 'Cámara';

  @override
  String get metaAmbiente => 'Ambiente';

  @override
  String get metaCapacitivo => 'Capacitivo';

  @override
  String get metaLineaAc => 'Línea AC';

  @override
  String get metaEspSensores => 'ESP32 y sensores';

  @override
  String get metaVentResist => 'Ventiladores y resistencias';

  @override
  String get metaCtrlAct => 'Controlador y actuadores';

  @override
  String sinConexionUltimoDato(String cuando) {
    return 'Sin conexión · último dato $cuando';
  }

  @override
  String get sinConexionNoReporta => 'Sin conexión · aún no reporta';

  @override
  String get estadoEnOperacion => 'En operación';

  @override
  String get estadoEnPausa => 'En pausa';

  @override
  String get estadoSinConexion => 'Sin conexión';

  @override
  String get estadoPausaSinLote => 'En pausa · sin lote activo';

  @override
  String get errorConexion => 'No pudimos conectarnos con el secador.';

  @override
  String get haceSinDato => 'Sin dato';

  @override
  String get haceInstantes => 'Hace instantes';

  @override
  String haceMin(int minutos) {
    return 'Hace $minutos min';
  }

  @override
  String haceH(int horas) {
    return 'Hace $horas h';
  }

  @override
  String get claveOcultar => 'Ocultar contraseña';

  @override
  String get claveMostrar => 'Mostrar contraseña';

  @override
  String get curvaSinPesajes =>
      'Sin pesajes todavía: la curva aparece con la primera muestra gravimétrica.';

  @override
  String get curvaUnPesaje =>
      'Un solo pesaje: la curva aparece con el segundo.';

  @override
  String curvaResumen(String desde, String hasta) {
    return 'La humedad del grano bajó de $desde % a $hasta %; objetivo 10 – 12 %.';
  }

  @override
  String get leyendaGravimetrico => 'Humedad del grano (gravimétrico)';

  @override
  String get leyendaPrediccionIa => 'Predicción IA';

  @override
  String get leyendaObjetivo => 'Objetivo';

  @override
  String get objetivoRango => 'Objetivo 10 – 12 %';

  @override
  String get energiaTitulo => 'Consumo energético y costo';

  @override
  String get energiaSolar => 'Solar';

  @override
  String get energiaRed => 'Red eléctrica';

  @override
  String get energiaCosto => 'Costo';

  @override
  String get energiaGraficoLector =>
      'Energía por periodo: solar abajo, red eléctrica arriba';

  @override
  String energiaTarifa(String tarifa) {
    return 'Tarifa $tarifa/kWh';
  }

  @override
  String get predModeloTesis => 'Modelo de la tesis';

  @override
  String get predTitulo => 'Predicción de IA';

  @override
  String get predTiempoRestante => 'Tiempo restante estimado';

  @override
  String get predConfianzaRotulo => 'Confianza de la predicción';

  @override
  String get predDatosConsiderados => 'Datos considerados';

  @override
  String get procesoLote => 'Proceso del lote';

  @override
  String get zonaHumedo => 'Húmedo';

  @override
  String get zonaOreado => 'Oreado';

  @override
  String get zonaObjetivo => 'Objetivo alcanzado';

  @override
  String get zonaSobresecado => 'Sobresecado';

  @override
  String get zonaHumedo53 => 'Húmedo 53 %';

  @override
  String get zonaActual => 'Zona actual: ';

  @override
  String escalaLector(String valor, String zona) {
    return 'Escala de humedad: $valor %, zona $zona';
  }

  @override
  String get actEncendido => 'Encendido';

  @override
  String get actApagado => 'Apagado';

  @override
  String get actBloqueado => 'Bloqueado';

  @override
  String get actEncendiendoSolo => 'Encendiendo…';

  @override
  String get actApagandoSolo => 'Apagando…';

  @override
  String actBloqueadoSeguridad(String motivo) {
    return 'Bloqueado por seguridad · $motivo';
  }

  @override
  String get actPorProtocolo => 'Controlado por el protocolo';

  @override
  String actNominal(String vatios) {
    return 'Nominal $vatios W';
  }

  @override
  String get ordenEnviada => 'Orden enviada';

  @override
  String get mantenerHint =>
      'Mantén presionado. Con lector de pantalla, toca dos veces y mantén.';

  @override
  String get alertasRecientes => 'Alertas recientes';

  @override
  String get verTodas => 'Ver todas';

  @override
  String get sinAlertas => 'Sin alertas activas';

  @override
  String get todoEnOrden => 'Todo en orden.';

  @override
  String get saludTitulo => '¿Está funcionando el equipo?';

  @override
  String get saludSi => 'Sí, todo en orden';

  @override
  String get saludRevisa => 'Revisa el equipo';

  @override
  String mapaLector(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Mapa esquemático de Nariño con $cantidad secadores',
      one: 'Mapa esquemático de Nariño con 1 secador',
    );
    return '$_temp0';
  }

  @override
  String get sinOrdenes => 'Sin órdenes registradas todavía.';

  @override
  String get ingresaParaCambios => 'Ingresa con tu cuenta para hacer cambios';

  @override
  String get cargandoSecador => 'Cargando el estado del secador…';

  @override
  String errorServidorCodigo(String codigo) {
    return 'El servidor respondió con un error (código $codigo).';
  }

  @override
  String get errorSinRespuesta => 'No hubo respuesta del servidor.';

  @override
  String get errorReintentaSolo => ' Se reintenta solo cada 30 s.';

  @override
  String get errorCargaTitulo => 'No fue posible cargar estos datos';

  @override
  String get reintentar => 'Reintentar';

  @override
  String avisoCopiaGuardada(String cuando) {
    return 'Sin señal: ves la copia guardada ($cuando).';
  }

  @override
  String avisoNoReportaDesde(String cuando) {
    return 'El secador no reporta desde $cuando. Ves el último dato con su hora.';
  }

  @override
  String get avisoSuInstalacion => 'su instalación';

  @override
  String get actualizar => 'Actualizar';

  @override
  String get filtro => 'Filtro';

  @override
  String get filtroTodos => 'Todos';

  @override
  String get lotesSinFiltro => 'No hay lotes con este filtro.';

  @override
  String get nuevoLote => 'Nuevo lote';

  @override
  String get loteTitulo => 'Lote';

  @override
  String get cargandoLote => 'Cargando el lote…';

  @override
  String get curvaHumedad => 'Curva de humedad';

  @override
  String get proceso => 'Proceso';

  @override
  String get faseInicio => 'Inicio';

  @override
  String get faseCalentamiento => 'Calentamiento';

  @override
  String get faseSecadoActivo => 'Secado activo';

  @override
  String get faseReduccion => 'Reducción de humedad';

  @override
  String get faseAjustes => 'Ajustes';

  @override
  String get faseFinalizacion => 'Finalización';

  @override
  String faseEnCursoDesde(String cuando) {
    return 'En curso · desde $cuando';
  }

  @override
  String get faseSinRegistro => 'Sin registro';

  @override
  String get faseEnCurso => 'En curso';

  @override
  String get fasePendiente => 'Pendiente';

  @override
  String get predEntre => 'Entre ';

  @override
  String get predY => ' y ';

  @override
  String get predListoCerca => ' · listo cerca de las ';

  @override
  String predPesajes(String cantidad) {
    return '$cantidad pesajes';
  }

  @override
  String predAjustesBootstrap(String cantidad) {
    return '$cantidad ajustes bootstrap';
  }

  @override
  String predOrientativo(String cantidad, String minimo) {
    return 'Solo $cantidad pesajes: por debajo de $minimo la tesis lo considera orientativo.';
  }

  @override
  String get predAjustando => 'Ajustando los modelos de la tesis…';

  @override
  String get predNoCalculo => 'No fue posible calcular la predicción.';

  @override
  String get predListo => 'Listo';

  @override
  String predListoTexto(String valor) {
    return 'La muestra está en $valor %: dentro de la ventana comercial. Retíralo.';
  }

  @override
  String get predPasado => 'Pasado';

  @override
  String predPasadoTexto(String valor) {
    return 'La muestra está en $valor %, por debajo del 10 %: está sobre-secado.';
  }

  @override
  String get predNoLlega => 'No llega';

  @override
  String get predPocosPesajesPunto => 'Pocos pesajes para predecir.';

  @override
  String predPuntoRetiro(String lista) {
    return 'Punto de retiro por modelo: $lista desde el primer pesaje.';
  }

  @override
  String get predNoLlegaMin => 'no llega';

  @override
  String get redTitulo => 'Red neuronal · sensores';

  @override
  String redConFalla(int cantidad) {
    return '$cantidad con falla';
  }

  @override
  String get redSinFallas => 'Sin fallas';

  @override
  String red2hHasta(String cuando) {
    return '2 h hasta $cuando';
  }

  @override
  String redPie(String f1) {
    return 'MLP (32, 16) de la tesis, F1 $f1 en prueba. Clasifica la forma de la señal: normal, pegado, deriva, salto de escalón, ruido, picos o saturado.';
  }

  @override
  String iaError(String error) {
    return 'No fue posible consultar la IA. ($error)';
  }

  @override
  String get iaTitulo => 'Segunda opinión de IA';

  @override
  String iaPie(String cuando) {
    return 'Texto generado por IA con los datos del lote, la predicción de la tesis, la red neuronal y el clima · $cuando. No reemplaza la medición.';
  }

  @override
  String get iaExplica =>
      'Un modelo de lenguaje lee los datos del lote y la predicción de la tesis, y da su estimación con una recomendación.';

  @override
  String get iaVolver => 'Volver a consultar';

  @override
  String get iaConsultar => 'Consultar a la IA';

  @override
  String get nombreLote => 'Nombre del lote';

  @override
  String get nombreLoteEjemplo => 'Lote C · Castillo';

  @override
  String get nombreLotePista => 'Así aparecerá en el panel, la app y el reloj.';

  @override
  String get dondeSeSeca => '¿Dónde se seca?';

  @override
  String get variedad => 'Variedad';

  @override
  String get sinEspecificar => 'Sin especificar';

  @override
  String get protocolo => 'Protocolo';

  @override
  String get muestra => 'Muestra';

  @override
  String get humedadInicial => 'Humedad inicial';

  @override
  String get humedadObjetivo => 'Humedad objetivo';

  @override
  String get pesoRetiro => 'Peso de retiro calculado';

  @override
  String materiaSeca(String gramos) {
    return 'con $gramos g de materia seca';
  }

  @override
  String get iniciarLote => 'Iniciar lote';

  @override
  String get escribeNombre => 'Escribe el nombre del lote.';

  @override
  String get loteIniciado => 'Lote iniciado';

  @override
  String get sinLoteActivo => 'Sin lote activo';

  @override
  String get sinLoteActivoTexto =>
      'Inicia un lote para empezar a pesar la muestra cada mañana.';

  @override
  String get cargandoPesajes => 'Cargando los pesajes…';

  @override
  String get pesoMuestra => 'Peso de la muestra';

  @override
  String get hecho => 'Listo';

  @override
  String corregirPesaje(String cuando) {
    return 'Corregir pesaje · $cuando';
  }

  @override
  String get pesoCorregido => 'Peso corregido';

  @override
  String get guardar => 'Guardar';

  @override
  String get eliminarPesaje => 'Eliminar pesaje';

  @override
  String get escribePesoCorregido => 'Escribe el peso corregido en gramos.';

  @override
  String get pesajeCorregido => 'Pesaje corregido';

  @override
  String get pesajeEliminado => 'Pesaje eliminado';

  @override
  String get faltaSecar => 'Todavía le falta secar';

  @override
  String get rangoComercial => 'Está en el rango comercial: retíralo';

  @override
  String get yaPaso => 'Ya pasó el punto: está sobre-secado';

  @override
  String pesoMuestraDe(String lote) {
    return 'Peso de la muestra · $lote';
  }

  @override
  String get restarDecima => 'Restar 0,1 g';

  @override
  String get sumarDecima => 'Sumar 0,1 g';

  @override
  String pesoLector(String gramos) {
    return 'Peso $gramos gramos. Toca para escribirlo.';
  }

  @override
  String get retiraEntre => 'Retira entre ';

  @override
  String rangoGramos(String desde, String hasta) {
    return '$desde y $hasta g';
  }

  @override
  String get registrarPesaje => 'Registrar pesaje';

  @override
  String get pesajeRegistrado => 'Pesaje registrado';

  @override
  String pesajeDetalle(String gramos, String humedad) {
    return '$gramos g · $humedad % de humedad';
  }

  @override
  String get ingresaParaPesar =>
      'Para registrar pesajes, ingresa con tu cuenta.';

  @override
  String pesajesDe(String lote) {
    return 'Pesajes de $lote';
  }

  @override
  String get sinPesajesLote => 'Todavía no hay pesajes de este lote.';

  @override
  String pesajePie(String ajuste, String gramos) {
    return 'Humedad por conservación de materia seca (Cenicafé)$ajuste: $gramos g de materia seca. Toca un pesaje para corregirlo.';
  }

  @override
  String get ajustadaPuntos => ', ajustada con puntos medidos';
}
