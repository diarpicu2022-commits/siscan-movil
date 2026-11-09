import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// Destino de la barra inferior: la pantalla principal con el secador y la humedad del grano. Máximo unos 11 caracteres (cinco destinos en 360 px).
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navInicio;

  /// Destino de la barra inferior: la lista de lotes de café (cada tanda de café que entra al secador). Máximo unos 11 caracteres.
  ///
  /// In es, this message translates to:
  /// **'Lotes'**
  String get navLotes;

  /// Destino de la barra inferior: registrar el peso de la muestra de café para saber su humedad. Máximo unos 11 caracteres.
  ///
  /// In es, this message translates to:
  /// **'Pesaje'**
  String get navPesaje;

  /// Destino de la barra inferior: los ventiladores y resistencias del secador (encender y apagar). Máximo unos 11 caracteres.
  ///
  /// In es, this message translates to:
  /// **'Equipo'**
  String get navEquipo;

  /// Destino de la barra inferior: más opciones y ajustes. Máximo unos 11 caracteres.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get navMas;

  /// Lo que dice el lector de pantalla en el destino Inicio cuando hay alertas sin leer.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, =1{Inicio, 1 alerta} other{Inicio, {cantidad} alertas}}'**
  String navInicioConAlertas(int cantidad);

  /// Fila de Más y título de la hoja donde se elige el idioma de la app.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// Opción del selector de idioma: usar el idioma que tiene configurado el teléfono.
  ///
  /// In es, this message translates to:
  /// **'Como el teléfono'**
  String get idiomaComoElTelefono;

  /// Explicación bajo «Como el teléfono»: qué idioma tiene el teléfono en este momento. {idioma} va escrito en su propio idioma (Español, English, Português).
  ///
  /// In es, this message translates to:
  /// **'Ahora: {idioma}'**
  String idiomaAhora(String idioma);

  /// Fecha corta de algo que pasó hoy, antes de la hora: «Hoy · 07:40». Con mayúscula inicial.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get hoy;

  /// Fecha corta de algo que pasó ayer, antes de la hora: «Ayer · 18:06». Con mayúscula inicial.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get ayer;

  /// Botón de la flecha arriba a la izquierda de las subpáginas: vuelve a la pantalla anterior. Lo dice el lector de pantalla y aparece al mantenerlo presionado.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get volver;

  /// Botón de los diálogos que cierra sin hacer nada.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// Texto corto mientras se lee algo del teléfono (por ejemplo, el aviso de licencia). Lleva puntos suspensivos (…).
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get cargando;

  /// Título grande de Más cuando nadie ha ingresado con su cuenta: se puede mirar el secador pero no mandar órdenes.
  ///
  /// In es, this message translates to:
  /// **'Vista pública'**
  String get masVistaPublica;

  /// Subtítulo bajo «Vista pública». El punto medio (·) separa dos ideas; se conserva.
  ///
  /// In es, this message translates to:
  /// **'Sin cuenta · solo lectura'**
  String get masSinCuenta;

  /// Subtítulo de Más con la sesión iniciada: el rol de la persona (puede controlar el secador) y su usuario de WordPress, que no se traduce.
  ///
  /// In es, this message translates to:
  /// **'Gestor del Secador · {usuario}'**
  String masSesionGestor(String usuario);

  /// Subtítulo de Más con la sesión iniciada de alguien que solo puede mirar, no encender ni apagar. {usuario} no se traduce.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso de control · {usuario}'**
  String masSesionSinPermiso(String usuario);

  /// Fila de Más y título de la pantalla donde se ajusta el Gravimet (método de humedad del grano) y los sensores.
  ///
  /// In es, this message translates to:
  /// **'Calibración'**
  String get masCalibracion;

  /// Explicación bajo «Calibración». Gravimet es un nombre propio: no se traduce.
  ///
  /// In es, this message translates to:
  /// **'Gravimet y sensores'**
  String get masCalibracionSub;

  /// Fila de Más que abre el mapa con los secadores de café del departamento.
  ///
  /// In es, this message translates to:
  /// **'Mapa de secadores'**
  String get masMapa;

  /// Explicación bajo «Mapa de secadores»: cuántos secadores hay. Nariño es un departamento de Colombia: no se traduce.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, =1{1 secador en Nariño} other{{cantidad} secadores en Nariño}}'**
  String masMapaSub(int cantidad);

  /// Fila de Más y título de la pantalla con las órdenes dadas a los ventiladores y resistencias y la energía usada. «Equipo» es el mismo de la pestaña de la barra inferior (pt: «Aparelhos»).
  ///
  /// In es, this message translates to:
  /// **'Historial del equipo'**
  String get masHistorial;

  /// Explicación bajo «Historial del equipo»: encender/apagar dados al equipo y energía solar y de la red.
  ///
  /// In es, this message translates to:
  /// **'Órdenes y energía'**
  String get masHistorialSub;

  /// Fila de Más y título de la pantalla donde se fija dónde está el secador (sirve para el clima). Va en una línea en la barra superior.
  ///
  /// In es, this message translates to:
  /// **'Ubicación del secador'**
  String get masUbicacion;

  /// Al final del subtítulo de «Ubicación del secador», tras el nombre del sitio y un «·»: la ubicación la escribió una persona. En minúscula.
  ///
  /// In es, this message translates to:
  /// **'fijada a mano'**
  String get masUbicacionFijada;

  /// Al final del subtítulo de «Ubicación del secador»: la ubicación se calculó por la dirección de internet del controlador ESP32 (nombre propio). En minúscula.
  ///
  /// In es, this message translates to:
  /// **'por IP del ESP32'**
  String get masUbicacionPorIp;

  /// Fila de Más y título de la pantalla que explica SISCAN en el reloj Wear OS.
  ///
  /// In es, this message translates to:
  /// **'Reloj inteligente'**
  String get masReloj;

  /// Explicación bajo «Reloj inteligente». SISCAN y Wear OS no se traducen.
  ///
  /// In es, this message translates to:
  /// **'SISCAN para Wear OS · lee el secador y, con tu sesión, manda órdenes'**
  String get masRelojSub;

  /// Fila de Más con un interruptor para recibir avisos del secador. También es la etiqueta del interruptor para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get masNotificaciones;

  /// Explicación bajo «Notificaciones»: qué avisos llegan. «Pesar» es pesar la muestra de café; «lote» es la tanda de café en el secador.
  ///
  /// In es, this message translates to:
  /// **'Alertas, hora de pesar y lote listo'**
  String get masNotificacionesSub;

  /// Fila de Más con un interruptor para entrar a la cuenta con la huella del teléfono. También es la etiqueta del interruptor.
  ///
  /// In es, this message translates to:
  /// **'Ingreso con huella'**
  String get masHuella;

  /// Explicación bajo «Ingreso con huella» cuando no hay sesión: el interruptor está desactivado.
  ///
  /// In es, this message translates to:
  /// **'Primero ingresa con tu cuenta'**
  String get masHuellaSinCuenta;

  /// Explicación bajo «Ingreso con huella» con la sesión iniciada.
  ///
  /// In es, this message translates to:
  /// **'Entra rápido sin escribir la contraseña'**
  String get masHuellaSub;

  /// Fila de Más y título de la hoja donde se elige claro u oscuro.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get masTema;

  /// Fila de Más y título de la pantalla con los avisos de licencia del software usado. Va en una línea en la barra superior.
  ///
  /// In es, this message translates to:
  /// **'Acerca de y licencias'**
  String get masAcerca;

  /// Explicación bajo «Acerca de y licencias». Lucide es un nombre propio.
  ///
  /// In es, this message translates to:
  /// **'Íconos Lucide y software de terceros'**
  String get masAcercaSub;

  /// Fila de Más que abre la política de datos y los derechos de la persona.
  ///
  /// In es, this message translates to:
  /// **'Tus datos y privacidad'**
  String get masPrivacidad;

  /// Explicación bajo «Tus datos y privacidad»: qué se puede hacer ahí.
  ///
  /// In es, this message translates to:
  /// **'Política, exportar y borrar'**
  String get masPrivacidadSub;

  /// Fila de Más para entrar con la cuenta cuando no hay sesión.
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get masIngresar;

  /// Explicación bajo «Ingresar»: qué se puede hacer con cuenta. «Pesaje» es pesar la muestra de café.
  ///
  /// In es, this message translates to:
  /// **'Para registrar pesajes y mandar órdenes'**
  String get masIngresarSub;

  /// Última fila de Más, en rojo, para salir de la cuenta.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get masCerrarSesion;

  /// Opción de tema (y subtítulo de la fila Tema): colores claros.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get temaClaro;

  /// Explicación bajo la opción «Claro».
  ///
  /// In es, this message translates to:
  /// **'Siempre claro'**
  String get temaClaroSub;

  /// Opción de tema: colores oscuros.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get temaOscuro;

  /// Explicación bajo la opción «Oscuro».
  ///
  /// In es, this message translates to:
  /// **'Siempre oscuro'**
  String get temaOscuroSub;

  /// Opción de tema: claro de día y oscuro de noche, automático.
  ///
  /// In es, this message translates to:
  /// **'Según la hora'**
  String get temaHora;

  /// Explicación bajo «Según la hora». Las horas se escriben como es costumbre en cada idioma; el horario es siempre el de Colombia (el secador está allí).
  ///
  /// In es, this message translates to:
  /// **'Claro de 6:00 a 19:00, oscuro de noche (hora de Colombia)'**
  String get temaHoraSub;

  /// Opción de tema: usar el claro u oscuro que tenga el teléfono. Igual que la opción de idioma «Como el teléfono».
  ///
  /// In es, this message translates to:
  /// **'Como el teléfono'**
  String get temaComoElTelefono;

  /// Explicación bajo la opción de tema «Como el teléfono».
  ///
  /// In es, this message translates to:
  /// **'Sigue el ajuste del sistema'**
  String get temaSistemaSub;

  /// Nombre del selector de dos opciones (Gravimet / Sensores) para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Qué calibrar'**
  String get calQueCalibrar;

  /// Opción del selector y título de la tarjeta de sensores (temperatura, humedad del aire…). Va en una línea dentro de un botón de media pantalla.
  ///
  /// In es, this message translates to:
  /// **'Sensores'**
  String get calSensores;

  /// Título del estado vacío de Calibración cuando no hay ningún lote de café.
  ///
  /// In es, this message translates to:
  /// **'Sin lotes para calibrar'**
  String get calSinLotes;

  /// Texto del estado vacío de Calibración. Gravimet es nombre propio.
  ///
  /// In es, this message translates to:
  /// **'La calibración del Gravimet se hace sobre un lote con pesajes.'**
  String get calSinLotesTexto;

  /// Título de la tarjeta de calibración del Gravimet. {lote} es el nombre del lote de café que puso la persona: no se traduce.
  ///
  /// In es, this message translates to:
  /// **'Forma de calibrar · {lote}'**
  String calForma(String lote);

  /// Ficha corta junto al título: la calibración usa puntos medidos por la persona (si no, dice «Cenicafé»). Va en una línea.
  ///
  /// In es, this message translates to:
  /// **'Con puntos'**
  String get calConPuntos;

  /// Casilla para usar la referencia de Cenicafé (centro de investigación del café de Colombia, nombre propio). «53 %» no se traduce.
  ///
  /// In es, this message translates to:
  /// **'Referencia Cenicafé (53 %)'**
  String get calReferencia;

  /// Campo: el porcentaje de humedad que marca el medidor de humedad del grano.
  ///
  /// In es, this message translates to:
  /// **'Lectura del medidor'**
  String get calLecturaMedidor;

  /// Campo: el peso en gramos de la muestra de café.
  ///
  /// In es, this message translates to:
  /// **'Peso de la muestra'**
  String get calPesoMuestra;

  /// Ayuda bajo «Peso de la muestra»: el campo ya trae el último peso registrado.
  ///
  /// In es, this message translates to:
  /// **'Usa el peso del último pesaje.'**
  String get calPesoPista;

  /// Botón principal de Calibración: guarda el punto y recalcula la humedad del lote.
  ///
  /// In es, this message translates to:
  /// **'Calibrar y recalcular'**
  String get calCalibrar;

  /// Aviso tras aplicar la referencia de Cenicafé.
  ///
  /// In es, this message translates to:
  /// **'Referencia Cenicafé aplicada'**
  String get calReferenciaAplicada;

  /// Aviso de error cuando falta un dato o no es válido. El número va con el separador decimal del idioma.
  ///
  /// In es, this message translates to:
  /// **'Escribe la lectura del medidor (0–99,9 %) y el peso en gramos.'**
  String get calErrorDatos;

  /// Aviso tras guardar un punto de calibración.
  ///
  /// In es, this message translates to:
  /// **'Punto medido agregado'**
  String get calPuntoAgregado;

  /// Detalle del aviso «Punto medido agregado».
  ///
  /// In es, this message translates to:
  /// **'El lote se recalculó.'**
  String get calLoteRecalculado;

  /// Subtítulo de la lista de puntos de calibración ya guardados.
  ///
  /// In es, this message translates to:
  /// **'Puntos medidos'**
  String get calPuntosMedidos;

  /// Una línea por punto guardado: fecha corta, peso de la muestra y lectura del medidor. «g» y «%» no se traducen; los números ya vienen con el formato del idioma.
  ///
  /// In es, this message translates to:
  /// **'{fecha} · {peso} g · medidor {lectura} %'**
  String calPunto(String fecha, String peso, String lectura);

  /// Mientras se descarga la calibración de los sensores.
  ///
  /// In es, this message translates to:
  /// **'Cargando la corrección de sensores…'**
  String get calCargandoSensores;

  /// Bajo el nombre de cada sensor: los dos números de su corrección lineal (técnico, para el técnico del CISNA).
  ///
  /// In es, this message translates to:
  /// **'Ganancia {ganancia} · desplazamiento {desplazamiento}'**
  String calGanancia(String ganancia, String desplazamiento);

  /// Estado de un sensor ya corregido.
  ///
  /// In es, this message translates to:
  /// **'Calibrado'**
  String get calCalibrado;

  /// Estado de un sensor que todavía no se ha corregido.
  ///
  /// In es, this message translates to:
  /// **'Sin calibrar'**
  String get calSinCalibrar;

  /// Nota al pie de la tarjeta de sensores.
  ///
  /// In es, this message translates to:
  /// **'Toca un sensor para corregirlo con un punto: escribe el valor real medido con tu instrumento.'**
  String get calPie;

  /// Título del diálogo para corregir un sensor. {sensor} es el nombre de la medida (por ejemplo, «Temperatura interna»).
  ///
  /// In es, this message translates to:
  /// **'Corregir {sensor}'**
  String calCorregir(String sensor);

  /// En el diálogo: lo que mide el sensor ahora. La unidad (°C, %…) no se traduce.
  ///
  /// In es, this message translates to:
  /// **'Lectura actual del sensor: {valor} {unidad}'**
  String calLecturaActual(String valor, String unidad);

  /// Campo del diálogo: el valor medido con un instrumento de referencia.
  ///
  /// In es, this message translates to:
  /// **'Valor real ({unidad})'**
  String calValorReal(String unidad);

  /// Botón del diálogo que guarda la corrección del sensor.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get calAplicar;

  /// Aviso tras corregir un sensor.
  ///
  /// In es, this message translates to:
  /// **'Calibrado: {sensor}'**
  String calCalibradoSensor(String sensor);

  /// Título de la pantalla del mapa de secadores.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get mapaTitulo;

  /// Descripción para el lector de pantalla de la foto del secador. {secador} es su nombre (no se traduce).
  ///
  /// In es, this message translates to:
  /// **'Foto del {secador}'**
  String mapaFotoDe(String secador);

  /// Rótulo sobre la foto del secador.
  ///
  /// In es, this message translates to:
  /// **'Foto del secador'**
  String get mapaFoto;

  /// Rótulo cuando el secador no tiene foto.
  ///
  /// In es, this message translates to:
  /// **'Sin foto todavía'**
  String get mapaSinFoto;

  /// Cuando el secador no tiene latitud y longitud.
  ///
  /// In es, this message translates to:
  /// **'Sin coordenadas'**
  String get mapaSinCoordenadas;

  /// Nombre del selector de periodo para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Periodo'**
  String get histPeriodo;

  /// Opción del selector de periodo. «h» (horas) no se traduce. Va en una línea en medio ancho de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Últimas 24 h'**
  String get hist24h;

  /// Opción del selector de periodo. Va en una línea en medio ancho de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Últimos 7 días'**
  String get hist7d;

  /// Mientras se descarga la energía del periodo.
  ///
  /// In es, this message translates to:
  /// **'Calculando la energía…'**
  String get histCalculando;

  /// Título de la tarjeta de energía para el último día.
  ///
  /// In es, this message translates to:
  /// **'Energía · últimas 24 h'**
  String get histEnergia24h;

  /// Título de la tarjeta de energía para la última semana.
  ///
  /// In es, this message translates to:
  /// **'Energía · últimos 7 días'**
  String get histEnergia7d;

  /// Ficha: no hay lecturas de la red eléctrica. Va en una línea.
  ///
  /// In es, this message translates to:
  /// **'Red sin lecturas'**
  String get histRedSinLecturas;

  /// Ficha: la energía es estimada, no medida. Va en una línea.
  ///
  /// In es, this message translates to:
  /// **'Estimado'**
  String get histEstimado;

  /// Nota bajo la energía: de dónde sale cada dato. {solar} y {red} los manda el servidor en español (no se traducen en la app).
  ///
  /// In es, this message translates to:
  /// **'Solar: {solar}. Red: {red}.'**
  String histNota(String solar, String red);

  /// Título de la lista de órdenes de encender/apagar. «Equipo» es el de la pestaña (pt: «Aparelhos»).
  ///
  /// In es, this message translates to:
  /// **'Órdenes al equipo'**
  String get histOrdenes;

  /// Mientras se descargan las órdenes.
  ///
  /// In es, this message translates to:
  /// **'Cargando las órdenes…'**
  String get histCargandoOrdenes;

  /// Orden de encender un ventilador o resistencia, tras su nombre y un «·».
  ///
  /// In es, this message translates to:
  /// **'Encender'**
  String get histEncender;

  /// Orden de apagar un ventilador o resistencia, tras su nombre y un «·».
  ///
  /// In es, this message translates to:
  /// **'Apagar'**
  String get histApagar;

  /// Quién dio la orden: el panel web.
  ///
  /// In es, this message translates to:
  /// **'Desde el panel'**
  String get histOrigenPanel;

  /// Quién dio la orden: esta app.
  ///
  /// In es, this message translates to:
  /// **'Desde la app'**
  String get histOrigenApp;

  /// Quién dio la orden: el reloj inteligente.
  ///
  /// In es, this message translates to:
  /// **'Desde el reloj'**
  String get histOrigenReloj;

  /// Quién dio la orden: el propio controlador ESP32 (nombre propio).
  ///
  /// In es, this message translates to:
  /// **'El ESP32'**
  String get histOrigenEsp32;

  /// Quién dio la orden: el protocolo automático de secado.
  ///
  /// In es, this message translates to:
  /// **'Protocolo'**
  String get histOrigenProtocolo;

  /// Cuando la orden no dice quién la dio.
  ///
  /// In es, this message translates to:
  /// **'Origen sin registrar'**
  String get histOrigenSinRegistro;

  /// Título de la tarjeta con las coordenadas del secador.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get ubicTarjeta;

  /// Ficha: la ubicación la escribió una persona. Va en una línea junto al título.
  ///
  /// In es, this message translates to:
  /// **'Fijada a mano'**
  String get ubicFijada;

  /// Ficha: la ubicación sale de la dirección de internet del controlador ESP32. Va en una línea junto al título.
  ///
  /// In es, this message translates to:
  /// **'Por IP del ESP32'**
  String get ubicPorIp;

  /// Campo de coordenada.
  ///
  /// In es, this message translates to:
  /// **'Latitud'**
  String get ubicLatitud;

  /// Campo de coordenada.
  ///
  /// In es, this message translates to:
  /// **'Longitud'**
  String get ubicLongitud;

  /// Campo: nombre de la finca o vereda.
  ///
  /// In es, this message translates to:
  /// **'Nombre del sitio (opcional)'**
  String get ubicSitio;

  /// Casilla: que la ubicación escrita no la cambie la que calcula el controlador por internet.
  ///
  /// In es, this message translates to:
  /// **'Bloquear la ubicación (ignorar la geolocalización por IP del ESP32)'**
  String get ubicBloquear;

  /// Botón que toma la ubicación del teléfono una vez. Se nombra también en el pie y en la política: usar la misma frase.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación actual'**
  String get ubicUsarMia;

  /// Aviso antes de pedir el permiso de ubicación de Android (divulgación destacada que exige Google Play). Texto legal: borrador, revisar con la política. SISCAN y CISNA no se traducen.
  ///
  /// In es, this message translates to:
  /// **'SISCAN usará la ubicación de este teléfono una sola vez para fijar dónde está el secador y consultar su clima. Se envía al servidor del CISNA como ubicación del equipo; no se guarda en el teléfono ni se usa en segundo plano.'**
  String get ubicDivulgacion;

  /// Botón del aviso de ubicación que no pide el permiso.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get ubicAhoraNo;

  /// Botón del aviso de ubicación que sigue y pide el permiso de Android.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get ubicContinuar;

  /// Aviso tras leer la ubicación del teléfono.
  ///
  /// In es, this message translates to:
  /// **'Ubicación tomada del teléfono'**
  String get ubicTomada;

  /// Detalle del aviso anterior: falta guardar.
  ///
  /// In es, this message translates to:
  /// **'Revisa y guarda.'**
  String get ubicRevisaGuarda;

  /// Aviso de error al leer la ubicación del teléfono.
  ///
  /// In es, this message translates to:
  /// **'No fue posible obtener tu ubicación. Revisa el permiso de ubicación.'**
  String get ubicError;

  /// Botón principal: guarda las coordenadas en el servidor y vuelve a consultar el clima.
  ///
  /// In es, this message translates to:
  /// **'Guardar ubicación y refrescar clima'**
  String get ubicGuardar;

  /// Aviso de error cuando las coordenadas no son válidas.
  ///
  /// In es, this message translates to:
  /// **'Revisa la latitud y la longitud.'**
  String get ubicRevisaCoordenadas;

  /// Aviso tras guardar la ubicación.
  ///
  /// In es, this message translates to:
  /// **'Ubicación guardada'**
  String get ubicGuardada;

  /// Detalle del aviso «Ubicación guardada».
  ///
  /// In es, this message translates to:
  /// **'El clima se consulta con el sitio correcto.'**
  String get ubicGuardadaDetalle;

  /// Nota al pie. Lo de entre comillas es el nombre del botón (clave ubicUsarMia): debe coincidir.
  ///
  /// In es, this message translates to:
  /// **'La ubicación del teléfono solo se usa cuando tocas «Usar mi ubicación actual»; no se guarda en el teléfono.'**
  String get ubicPie;

  /// Título de la tarjeta. SISCAN y Wear OS no se traducen.
  ///
  /// In es, this message translates to:
  /// **'SISCAN en Wear OS'**
  String get relojTarjeta;

  /// Explicación de qué hace el reloj. Lo de entre comillas es la casilla de la pantalla de ingreso: debe coincidir con su traducción. «Equipo» es el de la pestaña (pt: «aparelhos»).
  ///
  /// In es, this message translates to:
  /// **'El reloj muestra el monitoreo del lote, las lecturas, el equipo, la predicción y las alertas. Con la sesión iniciada en este teléfono, también puede encender o apagar actuadores y registrar pesajes: el reloj le pide la orden al teléfono y el teléfono la envía con tu cuenta (ingresa con «Recordarme»).'**
  String get relojTexto;

  /// Nota al pie de la pantalla del reloj.
  ///
  /// In es, this message translates to:
  /// **'Instala SISCAN en el reloj desde el mismo paquete de la app. Sin sesión en el teléfono, el reloj solo lee.'**
  String get relojPie;

  /// Título de la tarjeta con el aviso de licencia de los íconos.
  ///
  /// In es, this message translates to:
  /// **'Íconos'**
  String get licIconos;

  /// Texto antes del aviso de licencia (que va en inglés, tal como lo publica Lucide, y no se traduce). El número va con el separador decimal del idioma.
  ///
  /// In es, this message translates to:
  /// **'Los íconos de SISCAN salen de Lucide (lucide.dev), con trazo propio de 1,75. Estos son sus avisos de licencia.'**
  String get licIconosTexto;

  /// Error si el archivo de licencia no se puede abrir.
  ///
  /// In es, this message translates to:
  /// **'No se pudo leer el aviso de licencia.'**
  String get licErrorAviso;

  /// Título de la tarjeta que abre la lista de licencias de Flutter y paquetes.
  ///
  /// In es, this message translates to:
  /// **'Software de terceros'**
  String get licTerceros;

  /// Texto de la tarjeta «Software de terceros».
  ///
  /// In es, this message translates to:
  /// **'Flutter y los paquetes que usa la app, cada uno con su licencia.'**
  String get licTercerosTexto;

  /// Botón que abre la lista de licencias del sistema.
  ///
  /// In es, this message translates to:
  /// **'Ver todas las licencias'**
  String get licVerTodas;

  /// Título de la pantalla de privacidad.
  ///
  /// In es, this message translates to:
  /// **'Tus datos'**
  String get privTitulo;

  /// Título de la tarjeta con la política de datos (texto legal; su contenido se traduce aparte).
  ///
  /// In es, this message translates to:
  /// **'Política de tratamiento de datos'**
  String get privPolitica;

  /// Título de la tarjeta con los botones para ejercer derechos sobre los datos.
  ///
  /// In es, this message translates to:
  /// **'Tus derechos en la app'**
  String get privDerechos;

  /// Botón que abre el perfil de WordPress para anular la contraseña de aplicación que usa SISCAN.
  ///
  /// In es, this message translates to:
  /// **'Revocar la contraseña de aplicación'**
  String get privRevocar;

  /// Botón rojo y título del diálogo de confirmación: borra todo lo que SISCAN guarda en el teléfono.
  ///
  /// In es, this message translates to:
  /// **'Borrar los datos de este teléfono'**
  String get privBorrar;

  /// Texto del diálogo de confirmación de borrado. CISNA no se traduce.
  ///
  /// In es, this message translates to:
  /// **'Se cierra la sesión y se borran la credencial, la copia del secador y tus preferencias. El servidor del CISNA no cambia.'**
  String get privBorrarTexto;

  /// Botón del diálogo que confirma el borrado (no se puede deshacer).
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get privBorrarConfirmar;

  /// Aviso tras borrar los datos.
  ///
  /// In es, this message translates to:
  /// **'Datos de este teléfono borrados'**
  String get privBorrados;

  /// Aviso de error al activar las notificaciones sin permiso del sistema.
  ///
  /// In es, this message translates to:
  /// **'Android no dio permiso para notificaciones. Actívalo en los ajustes del teléfono.'**
  String get prefSinPermisoNotif;

  /// Aviso de error al activar el ingreso con huella en un teléfono sin huella.
  ///
  /// In es, this message translates to:
  /// **'Este teléfono no tiene huella configurada.'**
  String get prefSinHuella;

  /// Motivo que muestra la ventana de huella del sistema al activar el ingreso con huella.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu huella para activar el ingreso rápido'**
  String get prefConfirmaHuella;

  /// Lote sin variedad en su nombre.
  ///
  /// In es, this message translates to:
  /// **'Variedad sin registrar'**
  String get variedadSinRegistrar;

  /// Lugar de secado: al aire libre (protocolo A).
  ///
  /// In es, this message translates to:
  /// **'Aire libre'**
  String get sitioAireLibre;

  /// Lugar de secado: dentro del secador solar.
  ///
  /// In es, this message translates to:
  /// **'Secador'**
  String get sitioSecador;

  /// Mientras llega la predicción de la tesis.
  ///
  /// In es, this message translates to:
  /// **'Calculando la predicción…'**
  String get predCalculando;

  /// Tiempo que falta para el objetivo; tiempo ya formateado («5 h», «1 d 3 h»).
  ///
  /// In es, this message translates to:
  /// **'Listo en ~{tiempo}'**
  String predListoEn(String tiempo);

  /// Lote en curso que ya llegó al objetivo.
  ///
  /// In es, this message translates to:
  /// **'Listo: retíralo'**
  String get predRetiralo;

  /// Lote cerrado que terminó entre 10 y 12 %.
  ///
  /// In es, this message translates to:
  /// **'Terminó en el objetivo'**
  String get predTermino;

  /// El grano quedó por debajo del 10 %.
  ///
  /// In es, this message translates to:
  /// **'Pasó el punto: sobre-secado'**
  String get predSobresecado;

  /// La predicción dice que con las condiciones actuales no llega al 10–12 %.
  ///
  /// In es, this message translates to:
  /// **'Con este aire no llega al objetivo'**
  String get predNoAlcanza;

  /// La red necesita más pesajes.
  ///
  /// In es, this message translates to:
  /// **'Pocos pesajes para predecir'**
  String get predPocosPesajes;

  /// Estado del secador o título de una alerta sin título.
  ///
  /// In es, this message translates to:
  /// **'Alerta'**
  String get estadoAlerta;

  /// Salud del equipo: veredicto de la red neuronal de la tesis.
  ///
  /// In es, this message translates to:
  /// **'La red neuronal no ve fallas'**
  String get saludRedSinFallas;

  /// Salud del equipo: la red encontró sensores con falla.
  ///
  /// In es, this message translates to:
  /// **'La red neuronal ve fallas'**
  String get saludRedConFallas;

  /// Detalle cuando la red no ve fallas.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, =1{1 sensor con señal normal} other{{cantidad} sensores con señal normal}}'**
  String saludSensoresNormales(int cantidad);

  /// El controlador reportó hace menos de 10 min.
  ///
  /// In es, this message translates to:
  /// **'ESP32 conectado'**
  String get saludEspConectado;

  /// El controlador no reporta hace 10 min o más.
  ///
  /// In es, this message translates to:
  /// **'ESP32 sin conexión'**
  String get saludEspSinConexion;

  /// Cuándo reportó el ESP32; cuando ya viene en minúscula («hace 5 min»).
  ///
  /// In es, this message translates to:
  /// **'Último reporte {cuando}'**
  String saludUltimoReporte(String cuando);

  /// El ESP32 nunca ha reportado.
  ///
  /// In es, this message translates to:
  /// **'Todavía no reporta'**
  String get saludNoReporta;

  /// Sensores con dato reciente sobre el total.
  ///
  /// In es, this message translates to:
  /// **'{vivos} de {total} sensores reportando'**
  String saludSensoresReportando(int vivos, int total);

  /// Hay actuadores repetidos en el mismo pin GPIO.
  ///
  /// In es, this message translates to:
  /// **'Actuadores con copias'**
  String get saludActCopias;

  /// Título de la fila de actuadores.
  ///
  /// In es, this message translates to:
  /// **'Actuadores registrados'**
  String get saludActRegistrados;

  /// Cantidad de actuadores registrados.
  ///
  /// In es, this message translates to:
  /// **'{cantidad} registrados'**
  String saludActCuenta(int cantidad);

  /// Se agrega después de la cantidad; empieza con espacio y punto medio.
  ///
  /// In es, this message translates to:
  /// **' · {cantidad} copias por GPIO'**
  String saludActCopiasGpio(int cantidad);

  /// Se agrega cuando el ESP32 no reporta; empieza con espacio y punto medio.
  ///
  /// In es, this message translates to:
  /// **' · último estado conocido'**
  String get saludUltimoEstado;

  /// Clase de la red neuronal: señal normal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get redNormal;

  /// Clase de la red neuronal: el sensor repite el mismo valor.
  ///
  /// In es, this message translates to:
  /// **'Pegado'**
  String get redPegado;

  /// Clase de la red neuronal: el sensor está en su tope.
  ///
  /// In es, this message translates to:
  /// **'Saturado'**
  String get redSaturado;

  /// Clase de la red neuronal: el sensor se desvía poco a poco.
  ///
  /// In es, this message translates to:
  /// **'Deriva'**
  String get redDeriva;

  /// Clase de la red neuronal: cambio brusco de nivel.
  ///
  /// In es, this message translates to:
  /// **'Salto de escalón'**
  String get redSalto;

  /// Clase de la red neuronal: señal ruidosa.
  ///
  /// In es, this message translates to:
  /// **'Ruido'**
  String get redRuido;

  /// Clase de la red neuronal: picos aislados.
  ///
  /// In es, this message translates to:
  /// **'Picos'**
  String get redPicos;

  /// Clase de la red neuronal: no hay datos.
  ///
  /// In es, this message translates to:
  /// **'Sin datos'**
  String get redSinDatos;

  /// Título del bloque para quien no inició sesión.
  ///
  /// In es, this message translates to:
  /// **'Vista de solo lectura'**
  String get soloLecturaTitulo;

  /// Saludo de Inicio con el primer nombre.
  ///
  /// In es, this message translates to:
  /// **'¡Hola, {nombre}!'**
  String inicioHola(String nombre);

  /// Saludo de Inicio sin sesión.
  ///
  /// In es, this message translates to:
  /// **'¡Hola!'**
  String get inicioHolaSinNombre;

  /// Subtítulo de Inicio cuando falló la carga.
  ///
  /// In es, this message translates to:
  /// **'No se pudo leer el secador'**
  String get inicioNoSeLeyo;

  /// Subtítulo de Inicio mientras carga.
  ///
  /// In es, this message translates to:
  /// **'Leyendo el secador…'**
  String get inicioLeyendo;

  /// Subtítulo de Inicio sin lotes.
  ///
  /// In es, this message translates to:
  /// **'{secador} · sin lotes'**
  String inicioSubSinLotes(String secador);

  /// Subtítulo de Inicio con el lote en curso.
  ///
  /// In es, this message translates to:
  /// **'{secador} · {lote} secando'**
  String inicioSubSecando(String secador, String lote);

  /// Subtítulo de Inicio con el último lote cerrado.
  ///
  /// In es, this message translates to:
  /// **'{secador} · {lote} terminado'**
  String inicioSubTerminado(String secador, String lote);

  /// Lectura sin ningún dato.
  ///
  /// In es, this message translates to:
  /// **'Sin lecturas'**
  String get sinLecturas;

  /// De cuándo es el último dato; cuando es «Hoy · 07:40».
  ///
  /// In es, this message translates to:
  /// **'Último dato {cuando}'**
  String ultimoDato(String cuando);

  /// Estado vacío de Inicio.
  ///
  /// In es, this message translates to:
  /// **'No hay lotes registrados'**
  String get inicioSinLotes;

  /// Texto del estado vacío de Inicio.
  ///
  /// In es, this message translates to:
  /// **'Cuando ingreses café al secador, su registro aparecerá aquí.'**
  String get inicioSinLotesTexto;

  /// Mosaico corto de Inicio.
  ///
  /// In es, this message translates to:
  /// **'Temp. interior'**
  String get inicioTempInterior;

  /// Mosaico de Inicio.
  ///
  /// In es, this message translates to:
  /// **'Humedad relativa'**
  String get inicioHumedadRelativa;

  /// Mosaico de Inicio: temperatura exterior.
  ///
  /// In es, this message translates to:
  /// **'Exterior'**
  String get inicioExterior;

  /// Mosaico de Inicio.
  ///
  /// In es, this message translates to:
  /// **'Potencia total'**
  String get inicioPotenciaTotal;

  /// Píldora: algún actuador encendido.
  ///
  /// In es, this message translates to:
  /// **'En funcionamiento'**
  String get actEnFuncionamiento;

  /// Píldora: todos los actuadores apagados.
  ///
  /// In es, this message translates to:
  /// **'Detenidos'**
  String get actDetenidos;

  /// Aviso mientras se manda la orden de encender.
  ///
  /// In es, this message translates to:
  /// **'{nombre} · Encendiendo…'**
  String actEncendiendo(String nombre);

  /// Aviso mientras se manda la orden de apagar.
  ///
  /// In es, this message translates to:
  /// **'{nombre} · Apagando…'**
  String actApagando(String nombre);

  /// Detalle del aviso de una orden.
  ///
  /// In es, this message translates to:
  /// **'Se cumple cuando el ESP32 reporte.'**
  String get ordenSeCumple;

  /// Pie de la tarjeta Equipo sin sesión.
  ///
  /// In es, this message translates to:
  /// **'Vista de solo lectura: para mandar órdenes ingresa con tu cuenta.'**
  String get inicioSoloLectura;

  /// Botón de la campana.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get alertas;

  /// Píldora de lote en curso.
  ///
  /// In es, this message translates to:
  /// **'Secando'**
  String get loteSecando;

  /// Píldora de lote cerrado.
  ///
  /// In es, this message translates to:
  /// **'Terminado'**
  String get loteTerminado;

  /// Rótulo de la cifra principal.
  ///
  /// In es, this message translates to:
  /// **'Humedad del grano'**
  String get humedadGrano;

  /// Para el lector de pantalla; valor es «10,6 %» o «sin dato».
  ///
  /// In es, this message translates to:
  /// **'Humedad del grano {valor}'**
  String humedadGranoLector(String valor);

  /// Valor que falta, en minúscula, dentro de una frase.
  ///
  /// In es, this message translates to:
  /// **'sin dato'**
  String get sinDato;

  /// Inicio de la línea de predicción; termina en punto medio y espacio.
  ///
  /// In es, this message translates to:
  /// **'Objetivo 10 – 12 % · '**
  String get objetivoPrefijo;

  /// Sigue a «Objetivo 10 – 12 % · ».
  ///
  /// In es, this message translates to:
  /// **'predicción no disponible'**
  String get predNoDisponible;

  /// Sigue a «Objetivo 10 – 12 % · »; tiempo ya formateado.
  ///
  /// In es, this message translates to:
  /// **'faltan ~{tiempo}'**
  String predFaltan(String tiempo);

  /// De cuándo es la cifra; cuando es «Hoy · 07:40».
  ///
  /// In es, this message translates to:
  /// **'Último pesaje {cuando}'**
  String ultimoPesaje(String cuando);

  /// Etiqueta de la barra de avance.
  ///
  /// In es, this message translates to:
  /// **'Avance hacia el objetivo'**
  String get avanceObjetivo;

  /// Confianza de la predicción ≥ 75 %.
  ///
  /// In es, this message translates to:
  /// **'Confianza alta'**
  String get confianzaAlta;

  /// Confianza de la predicción entre 50 y 75 %.
  ///
  /// In es, this message translates to:
  /// **'Confianza media'**
  String get confianzaMedia;

  /// Confianza de la predicción < 50 %.
  ///
  /// In es, this message translates to:
  /// **'Confianza baja'**
  String get confianzaBaja;

  /// Magnitud: temperatura en el tope de la cámara.
  ///
  /// In es, this message translates to:
  /// **'Temperatura interior'**
  String get magTempInterior;

  /// Magnitud: humedad del aire en la cámara.
  ///
  /// In es, this message translates to:
  /// **'Humedad relativa interior'**
  String get magHumInterior;

  /// Magnitud.
  ///
  /// In es, this message translates to:
  /// **'Temperatura exterior'**
  String get magTempExterior;

  /// Magnitud.
  ///
  /// In es, this message translates to:
  /// **'Humedad relativa exterior'**
  String get magHumExterior;

  /// Magnitud: sonda capacitiva del grano.
  ///
  /// In es, this message translates to:
  /// **'Humedad del grano (sensor)'**
  String get magHumGrano;

  /// Magnitud eléctrica.
  ///
  /// In es, this message translates to:
  /// **'Corriente'**
  String get magCorriente;

  /// Magnitud eléctrica.
  ///
  /// In es, this message translates to:
  /// **'Potencia del controlador'**
  String get magPotControlador;

  /// Magnitud eléctrica.
  ///
  /// In es, this message translates to:
  /// **'Potencia de actuadores'**
  String get magPotActuadores;

  /// Dónde mide el sensor.
  ///
  /// In es, this message translates to:
  /// **'Tope de la cámara'**
  String get metaTope;

  /// Dónde mide el sensor.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get metaCamara;

  /// Dónde mide el sensor: fuera del secador.
  ///
  /// In es, this message translates to:
  /// **'Ambiente'**
  String get metaAmbiente;

  /// Tipo de sensor.
  ///
  /// In es, this message translates to:
  /// **'Capacitivo'**
  String get metaCapacitivo;

  /// Dónde mide el sensor de corriente.
  ///
  /// In es, this message translates to:
  /// **'Línea AC'**
  String get metaLineaAc;

  /// Qué consume esa potencia.
  ///
  /// In es, this message translates to:
  /// **'ESP32 y sensores'**
  String get metaEspSensores;

  /// Qué consume esa potencia.
  ///
  /// In es, this message translates to:
  /// **'Ventiladores y resistencias'**
  String get metaVentResist;

  /// Qué suma la potencia total.
  ///
  /// In es, this message translates to:
  /// **'Controlador y actuadores'**
  String get metaCtrlAct;

  /// Estado del secador; cuando es «Hoy · 07:40».
  ///
  /// In es, this message translates to:
  /// **'Sin conexión · último dato {cuando}'**
  String sinConexionUltimoDato(String cuando);

  /// Estado del secador que nunca reportó.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión · aún no reporta'**
  String get sinConexionNoReporta;

  /// Estado del secador.
  ///
  /// In es, this message translates to:
  /// **'En operación'**
  String get estadoEnOperacion;

  /// Estado del secador.
  ///
  /// In es, this message translates to:
  /// **'En pausa'**
  String get estadoEnPausa;

  /// Estado del secador.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get estadoSinConexion;

  /// Estado del secador sin lote en curso.
  ///
  /// In es, this message translates to:
  /// **'En pausa · sin lote activo'**
  String get estadoPausaSinLote;

  /// Error de carga sin mensaje del servidor.
  ///
  /// In es, this message translates to:
  /// **'No pudimos conectarnos con el secador.'**
  String get errorConexion;

  /// Frescura de un dato que no existe.
  ///
  /// In es, this message translates to:
  /// **'Sin dato'**
  String get haceSinDato;

  /// Dato de hace menos de un minuto.
  ///
  /// In es, this message translates to:
  /// **'Hace instantes'**
  String get haceInstantes;

  /// Antigüedad en minutos.
  ///
  /// In es, this message translates to:
  /// **'Hace {minutos} min'**
  String haceMin(int minutos);

  /// Antigüedad en horas.
  ///
  /// In es, this message translates to:
  /// **'Hace {horas} h'**
  String haceH(int horas);

  /// Botón del ojo del campo de contraseña.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get claveOcultar;

  /// Botón del ojo del campo de contraseña.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get claveMostrar;

  /// Curva de secado vacía.
  ///
  /// In es, this message translates to:
  /// **'Sin pesajes todavía: la curva aparece con la primera muestra gravimétrica.'**
  String get curvaSinPesajes;

  /// Curva de secado con un punto.
  ///
  /// In es, this message translates to:
  /// **'Un solo pesaje: la curva aparece con el segundo.'**
  String get curvaUnPesaje;

  /// Resumen de la curva para el lector de pantalla; cifras ya formateadas.
  ///
  /// In es, this message translates to:
  /// **'La humedad del grano bajó de {desde} % a {hasta} %; objetivo 10 – 12 %.'**
  String curvaResumen(String desde, String hasta);

  /// Leyenda de la curva.
  ///
  /// In es, this message translates to:
  /// **'Humedad del grano (gravimétrico)'**
  String get leyendaGravimetrico;

  /// Leyenda de la curva.
  ///
  /// In es, this message translates to:
  /// **'Predicción IA'**
  String get leyendaPrediccionIa;

  /// Leyenda de la curva.
  ///
  /// In es, this message translates to:
  /// **'Objetivo'**
  String get leyendaObjetivo;

  /// Rótulo de la banda objetivo dentro del gráfico.
  ///
  /// In es, this message translates to:
  /// **'Objetivo 10 – 12 %'**
  String get objetivoRango;

  /// Título de la tarjeta de energía.
  ///
  /// In es, this message translates to:
  /// **'Consumo energético y costo'**
  String get energiaTitulo;

  /// Energía solar.
  ///
  /// In es, this message translates to:
  /// **'Solar'**
  String get energiaSolar;

  /// Energía de la red.
  ///
  /// In es, this message translates to:
  /// **'Red eléctrica'**
  String get energiaRed;

  /// Costo de la energía.
  ///
  /// In es, this message translates to:
  /// **'Costo'**
  String get energiaCosto;

  /// Descripción del gráfico de barras para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Energía por periodo: solar abajo, red eléctrica arriba'**
  String get energiaGraficoLector;

  /// Tarifa con la moneda ya formateada.
  ///
  /// In es, this message translates to:
  /// **'Tarifa {tarifa}/kWh'**
  String energiaTarifa(String tarifa);

  /// Ficha de la tarjeta de predicción.
  ///
  /// In es, this message translates to:
  /// **'Modelo de la tesis'**
  String get predModeloTesis;

  /// Título de la tarjeta de predicción.
  ///
  /// In es, this message translates to:
  /// **'Predicción de IA'**
  String get predTitulo;

  /// Rótulo de la cifra de la predicción.
  ///
  /// In es, this message translates to:
  /// **'Tiempo restante estimado'**
  String get predTiempoRestante;

  /// Rótulo de la barra de confianza.
  ///
  /// In es, this message translates to:
  /// **'Confianza de la predicción'**
  String get predConfianzaRotulo;

  /// Entradas que usó el modelo.
  ///
  /// In es, this message translates to:
  /// **'Datos considerados'**
  String get predDatosConsiderados;

  /// Lector de pantalla de la línea de etapas.
  ///
  /// In es, this message translates to:
  /// **'Proceso del lote'**
  String get procesoLote;

  /// Zona de la escala de humedad (> 30 %).
  ///
  /// In es, this message translates to:
  /// **'Húmedo'**
  String get zonaHumedo;

  /// Zona de la escala de humedad (20–30 %).
  ///
  /// In es, this message translates to:
  /// **'Oreado'**
  String get zonaOreado;

  /// Zona de la escala de humedad (10–12 %).
  ///
  /// In es, this message translates to:
  /// **'Objetivo alcanzado'**
  String get zonaObjetivo;

  /// Zona de la escala de humedad (< 10 %).
  ///
  /// In es, this message translates to:
  /// **'Sobresecado'**
  String get zonaSobresecado;

  /// Extremo izquierdo de la escala.
  ///
  /// In es, this message translates to:
  /// **'Húmedo 53 %'**
  String get zonaHumedo53;

  /// Antes del nombre de la zona; termina en espacio.
  ///
  /// In es, this message translates to:
  /// **'Zona actual: '**
  String get zonaActual;

  /// Lector de pantalla de la escala.
  ///
  /// In es, this message translates to:
  /// **'Escala de humedad: {valor} %, zona {zona}'**
  String escalaLector(String valor, String zona);

  /// Estado de un actuador.
  ///
  /// In es, this message translates to:
  /// **'Encendido'**
  String get actEncendido;

  /// Estado de un actuador.
  ///
  /// In es, this message translates to:
  /// **'Apagado'**
  String get actApagado;

  /// Estado de un actuador bloqueado por seguridad.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado'**
  String get actBloqueado;

  /// Estado mientras llega la orden.
  ///
  /// In es, this message translates to:
  /// **'Encendiendo…'**
  String get actEncendiendoSolo;

  /// Estado mientras llega la orden.
  ///
  /// In es, this message translates to:
  /// **'Apagando…'**
  String get actApagandoSolo;

  /// Motivo del bloqueo.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado por seguridad · {motivo}'**
  String actBloqueadoSeguridad(String motivo);

  /// El protocolo automático manda el actuador.
  ///
  /// In es, this message translates to:
  /// **'Controlado por el protocolo'**
  String get actPorProtocolo;

  /// Potencia nominal ya formateada.
  ///
  /// In es, this message translates to:
  /// **'Nominal {vatios} W'**
  String actNominal(String vatios);

  /// Botón de mantener presionado al completar.
  ///
  /// In es, this message translates to:
  /// **'Orden enviada'**
  String get ordenEnviada;

  /// Pista del lector de pantalla del botón de mantener.
  ///
  /// In es, this message translates to:
  /// **'Mantén presionado. Con lector de pantalla, toca dos veces y mantén.'**
  String get mantenerHint;

  /// Título de la tarjeta de alertas.
  ///
  /// In es, this message translates to:
  /// **'Alertas recientes'**
  String get alertasRecientes;

  /// Enlace a todas las alertas.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get verTodas;

  /// Tarjeta de alertas vacía.
  ///
  /// In es, this message translates to:
  /// **'Sin alertas activas'**
  String get sinAlertas;

  /// Tarjeta de alertas vacía.
  ///
  /// In es, this message translates to:
  /// **'Todo en orden.'**
  String get todoEnOrden;

  /// Título de la tarjeta de salud.
  ///
  /// In es, this message translates to:
  /// **'¿Está funcionando el equipo?'**
  String get saludTitulo;

  /// Veredicto de la tarjeta de salud.
  ///
  /// In es, this message translates to:
  /// **'Sí, todo en orden'**
  String get saludSi;

  /// Veredicto de la tarjeta de salud.
  ///
  /// In es, this message translates to:
  /// **'Revisa el equipo'**
  String get saludRevisa;

  /// Lector de pantalla del mapa.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, =1{Mapa esquemático de Nariño con 1 secador} other{Mapa esquemático de Nariño con {cantidad} secadores}}'**
  String mapaLector(int cantidad);

  /// Registro de órdenes vacío.
  ///
  /// In es, this message translates to:
  /// **'Sin órdenes registradas todavía.'**
  String get sinOrdenes;

  /// Aviso al intentar una acción sin sesión.
  ///
  /// In es, this message translates to:
  /// **'Ingresa con tu cuenta para hacer cambios'**
  String get ingresaParaCambios;

  /// Carga de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Cargando el estado del secador…'**
  String get cargandoSecador;

  /// Qué pasó, con el código HTTP.
  ///
  /// In es, this message translates to:
  /// **'El servidor respondió con un error (código {codigo}).'**
  String errorServidorCodigo(String codigo);

  /// Qué pasó cuando no hubo respuesta.
  ///
  /// In es, this message translates to:
  /// **'No hubo respuesta del servidor.'**
  String get errorSinRespuesta;

  /// Se agrega al final; empieza con espacio.
  ///
  /// In es, this message translates to:
  /// **' Se reintenta solo cada 30 s.'**
  String get errorReintentaSolo;

  /// Título de la tarjeta de error.
  ///
  /// In es, this message translates to:
  /// **'No fue posible cargar estos datos'**
  String get errorCargaTitulo;

  /// Botón para volver a pedir los datos.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get reintentar;

  /// Aviso de copia guardada; cuando en minúscula («hoy · 07:40»).
  ///
  /// In es, this message translates to:
  /// **'Sin señal: ves la copia guardada ({cuando}).'**
  String avisoCopiaGuardada(String cuando);

  /// Aviso de sin conexión; cuando es «19 ago · 14:53» o «su instalación».
  ///
  /// In es, this message translates to:
  /// **'El secador no reporta desde {cuando}. Ves el último dato con su hora.'**
  String avisoNoReportaDesde(String cuando);

  /// Sigue a «no reporta desde» cuando nunca reportó.
  ///
  /// In es, this message translates to:
  /// **'su instalación'**
  String get avisoSuInstalacion;

  /// Acción de la barra: volver a cargar.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get actualizar;

  /// Etiqueta del selector de filtro (lector de pantalla).
  ///
  /// In es, this message translates to:
  /// **'Filtro'**
  String get filtro;

  /// Filtro de lotes: todos.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get filtroTodos;

  /// Lista de lotes vacía por el filtro.
  ///
  /// In es, this message translates to:
  /// **'No hay lotes con este filtro.'**
  String get lotesSinFiltro;

  /// Botón y título para crear un lote.
  ///
  /// In es, this message translates to:
  /// **'Nuevo lote'**
  String get nuevoLote;

  /// Título de la ficha de un lote mientras carga.
  ///
  /// In es, this message translates to:
  /// **'Lote'**
  String get loteTitulo;

  /// Carga de la ficha del lote.
  ///
  /// In es, this message translates to:
  /// **'Cargando el lote…'**
  String get cargandoLote;

  /// Título de la tarjeta de la curva.
  ///
  /// In es, this message translates to:
  /// **'Curva de humedad'**
  String get curvaHumedad;

  /// Título de la tarjeta de etapas.
  ///
  /// In es, this message translates to:
  /// **'Proceso'**
  String get proceso;

  /// Etapa del lote.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get faseInicio;

  /// Etapa del lote.
  ///
  /// In es, this message translates to:
  /// **'Calentamiento'**
  String get faseCalentamiento;

  /// Etapa del lote.
  ///
  /// In es, this message translates to:
  /// **'Secado activo'**
  String get faseSecadoActivo;

  /// Etapa del lote.
  ///
  /// In es, this message translates to:
  /// **'Reducción de humedad'**
  String get faseReduccion;

  /// Etapa del lote.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get faseAjustes;

  /// Etapa del lote.
  ///
  /// In es, this message translates to:
  /// **'Finalización'**
  String get faseFinalizacion;

  /// Etapa actual con su inicio.
  ///
  /// In es, this message translates to:
  /// **'En curso · desde {cuando}'**
  String faseEnCursoDesde(String cuando);

  /// Etapa pasada sin fecha.
  ///
  /// In es, this message translates to:
  /// **'Sin registro'**
  String get faseSinRegistro;

  /// Etapa actual sin fecha.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get faseEnCurso;

  /// Etapa que falta.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get fasePendiente;

  /// Rango de la predicción: «Entre 5 h y 8 h». Termina en espacio.
  ///
  /// In es, this message translates to:
  /// **'Entre '**
  String get predEntre;

  /// Une los dos extremos del rango, con espacios.
  ///
  /// In es, this message translates to:
  /// **' y '**
  String get predY;

  /// Antes de la fecha estimada; empieza y termina en espacio.
  ///
  /// In es, this message translates to:
  /// **' · listo cerca de las '**
  String get predListoCerca;

  /// Entrada del modelo: cantidad de pesajes.
  ///
  /// In es, this message translates to:
  /// **'{cantidad} pesajes'**
  String predPesajes(String cantidad);

  /// Entrada del modelo.
  ///
  /// In es, this message translates to:
  /// **'{cantidad} ajustes bootstrap'**
  String predAjustesBootstrap(String cantidad);

  /// Pie cuando la predicción no es fiable.
  ///
  /// In es, this message translates to:
  /// **'Solo {cantidad} pesajes: por debajo de {minimo} la tesis lo considera orientativo.'**
  String predOrientativo(String cantidad, String minimo);

  /// Mientras calcula la predicción.
  ///
  /// In es, this message translates to:
  /// **'Ajustando los modelos de la tesis…'**
  String get predAjustando;

  /// Error de la predicción.
  ///
  /// In es, this message translates to:
  /// **'No fue posible calcular la predicción.'**
  String get predNoCalculo;

  /// Cifra de la predicción: el lote llegó.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get predListo;

  /// Explicación del lote listo; valor ya formateado.
  ///
  /// In es, this message translates to:
  /// **'La muestra está en {valor} %: dentro de la ventana comercial. Retíralo.'**
  String predListoTexto(String valor);

  /// Cifra de la predicción: se pasó del objetivo.
  ///
  /// In es, this message translates to:
  /// **'Pasado'**
  String get predPasado;

  /// Explicación del sobresecado.
  ///
  /// In es, this message translates to:
  /// **'La muestra está en {valor} %, por debajo del 10 %: está sobre-secado.'**
  String predPasadoTexto(String valor);

  /// Cifra de la predicción: no llega al objetivo.
  ///
  /// In es, this message translates to:
  /// **'No llega'**
  String get predNoLlega;

  /// Explicación cuando faltan pesajes.
  ///
  /// In es, this message translates to:
  /// **'Pocos pesajes para predecir.'**
  String get predPocosPesajesPunto;

  /// Lista «Lewis 40 h · Page 38 h».
  ///
  /// In es, this message translates to:
  /// **'Punto de retiro por modelo: {lista} desde el primer pesaje.'**
  String predPuntoRetiro(String lista);

  /// Dentro de la lista por modelo, en minúscula.
  ///
  /// In es, this message translates to:
  /// **'no llega'**
  String get predNoLlegaMin;

  /// Título de la tarjeta de la red neuronal.
  ///
  /// In es, this message translates to:
  /// **'Red neuronal · sensores'**
  String get redTitulo;

  /// Píldora con la cantidad de sensores con falla.
  ///
  /// In es, this message translates to:
  /// **'{cantidad} con falla'**
  String redConFalla(int cantidad);

  /// Píldora sin fallas.
  ///
  /// In es, this message translates to:
  /// **'Sin fallas'**
  String get redSinFallas;

  /// Ventana de señal analizada.
  ///
  /// In es, this message translates to:
  /// **'2 h hasta {cuando}'**
  String red2hHasta(String cuando);

  /// Pie de la red neuronal.
  ///
  /// In es, this message translates to:
  /// **'MLP (32, 16) de la tesis, F1 {f1} en prueba. Clasifica la forma de la señal: normal, pegado, deriva, salto de escalón, ruido, picos o saturado.'**
  String redPie(String f1);

  /// Error de la segunda opinión.
  ///
  /// In es, this message translates to:
  /// **'No fue posible consultar la IA. ({error})'**
  String iaError(String error);

  /// Título de la tarjeta de Groq.
  ///
  /// In es, this message translates to:
  /// **'Segunda opinión de IA'**
  String get iaTitulo;

  /// Pie de la segunda opinión.
  ///
  /// In es, this message translates to:
  /// **'Texto generado por IA con los datos del lote, la predicción de la tesis, la red neuronal y el clima · {cuando}. No reemplaza la medición.'**
  String iaPie(String cuando);

  /// Qué hace la segunda opinión, antes de pedirla.
  ///
  /// In es, this message translates to:
  /// **'Un modelo de lenguaje lee los datos del lote y la predicción de la tesis, y da su estimación con una recomendación.'**
  String get iaExplica;

  /// Botón de la segunda opinión.
  ///
  /// In es, this message translates to:
  /// **'Volver a consultar'**
  String get iaVolver;

  /// Botón de la segunda opinión.
  ///
  /// In es, this message translates to:
  /// **'Consultar a la IA'**
  String get iaConsultar;

  /// Campo del formulario.
  ///
  /// In es, this message translates to:
  /// **'Nombre del lote'**
  String get nombreLote;

  /// Ejemplo del campo; Castillo es una variedad (no se traduce).
  ///
  /// In es, this message translates to:
  /// **'Lote C · Castillo'**
  String get nombreLoteEjemplo;

  /// Pista del campo.
  ///
  /// In es, this message translates to:
  /// **'Así aparecerá en el panel, la app y el reloj.'**
  String get nombreLotePista;

  /// Pregunta del formulario.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde se seca?'**
  String get dondeSeSeca;

  /// Campo del formulario.
  ///
  /// In es, this message translates to:
  /// **'Variedad'**
  String get variedad;

  /// Variedad sin elegir.
  ///
  /// In es, this message translates to:
  /// **'Sin especificar'**
  String get sinEspecificar;

  /// Campo del formulario.
  ///
  /// In es, this message translates to:
  /// **'Protocolo'**
  String get protocolo;

  /// Peso de la muestra del Gravimet.
  ///
  /// In es, this message translates to:
  /// **'Muestra'**
  String get muestra;

  /// Campo del formulario.
  ///
  /// In es, this message translates to:
  /// **'Humedad inicial'**
  String get humedadInicial;

  /// Campo del formulario.
  ///
  /// In es, this message translates to:
  /// **'Humedad objetivo'**
  String get humedadObjetivo;

  /// Resultado del formulario.
  ///
  /// In es, this message translates to:
  /// **'Peso de retiro calculado'**
  String get pesoRetiro;

  /// Bajo el peso de retiro.
  ///
  /// In es, this message translates to:
  /// **'con {gramos} g de materia seca'**
  String materiaSeca(String gramos);

  /// Botón del formulario.
  ///
  /// In es, this message translates to:
  /// **'Iniciar lote'**
  String get iniciarLote;

  /// Error del formulario.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre del lote.'**
  String get escribeNombre;

  /// Aviso al crear el lote.
  ///
  /// In es, this message translates to:
  /// **'Lote iniciado'**
  String get loteIniciado;

  /// Pesaje vacío.
  ///
  /// In es, this message translates to:
  /// **'Sin lote activo'**
  String get sinLoteActivo;

  /// Pesaje vacío.
  ///
  /// In es, this message translates to:
  /// **'Inicia un lote para empezar a pesar la muestra cada mañana.'**
  String get sinLoteActivoTexto;

  /// Carga de Pesaje.
  ///
  /// In es, this message translates to:
  /// **'Cargando los pesajes…'**
  String get cargandoPesajes;

  /// Título del diálogo para escribir el peso.
  ///
  /// In es, this message translates to:
  /// **'Peso de la muestra'**
  String get pesoMuestra;

  /// Botón que cierra un diálogo aceptando.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get hecho;

  /// Título de la hoja de corrección.
  ///
  /// In es, this message translates to:
  /// **'Corregir pesaje · {cuando}'**
  String corregirPesaje(String cuando);

  /// Campo de la hoja de corrección.
  ///
  /// In es, this message translates to:
  /// **'Peso corregido'**
  String get pesoCorregido;

  /// Botón guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// Botón de la hoja de corrección.
  ///
  /// In es, this message translates to:
  /// **'Eliminar pesaje'**
  String get eliminarPesaje;

  /// Error de la corrección.
  ///
  /// In es, this message translates to:
  /// **'Escribe el peso corregido en gramos.'**
  String get escribePesoCorregido;

  /// Aviso.
  ///
  /// In es, this message translates to:
  /// **'Pesaje corregido'**
  String get pesajeCorregido;

  /// Aviso.
  ///
  /// In es, this message translates to:
  /// **'Pesaje eliminado'**
  String get pesajeEliminado;

  /// Veredicto del pesaje (> 12 %).
  ///
  /// In es, this message translates to:
  /// **'Todavía le falta secar'**
  String get faltaSecar;

  /// Veredicto del pesaje (10–12 %).
  ///
  /// In es, this message translates to:
  /// **'Está en el rango comercial: retíralo'**
  String get rangoComercial;

  /// Veredicto del pesaje (< 10 %).
  ///
  /// In es, this message translates to:
  /// **'Ya pasó el punto: está sobre-secado'**
  String get yaPaso;

  /// Encima de la cifra del peso.
  ///
  /// In es, this message translates to:
  /// **'Peso de la muestra · {lote}'**
  String pesoMuestraDe(String lote);

  /// Botón redondo (lector de pantalla); la cifra con el separador del idioma.
  ///
  /// In es, this message translates to:
  /// **'Restar 0,1 g'**
  String get restarDecima;

  /// Botón redondo (lector de pantalla); la cifra con el separador del idioma.
  ///
  /// In es, this message translates to:
  /// **'Sumar 0,1 g'**
  String get sumarDecima;

  /// Lector de pantalla de la cifra del peso.
  ///
  /// In es, this message translates to:
  /// **'Peso {gramos} gramos. Toca para escribirlo.'**
  String pesoLector(String gramos);

  /// Antes del rango en gramos; termina en espacio.
  ///
  /// In es, this message translates to:
  /// **'Retira entre '**
  String get retiraEntre;

  /// Rango de retiro en gramos.
  ///
  /// In es, this message translates to:
  /// **'{desde} y {hasta} g'**
  String rangoGramos(String desde, String hasta);

  /// Botón principal de Pesaje.
  ///
  /// In es, this message translates to:
  /// **'Registrar pesaje'**
  String get registrarPesaje;

  /// Aviso.
  ///
  /// In es, this message translates to:
  /// **'Pesaje registrado'**
  String get pesajeRegistrado;

  /// Detalle del aviso.
  ///
  /// In es, this message translates to:
  /// **'{gramos} g · {humedad} % de humedad'**
  String pesajeDetalle(String gramos, String humedad);

  /// Pesaje sin sesión.
  ///
  /// In es, this message translates to:
  /// **'Para registrar pesajes, ingresa con tu cuenta.'**
  String get ingresaParaPesar;

  /// Título del historial.
  ///
  /// In es, this message translates to:
  /// **'Pesajes de {lote}'**
  String pesajesDe(String lote);

  /// Historial vacío.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay pesajes de este lote.'**
  String get sinPesajesLote;

  /// Pie del historial; ajuste es vacío o «, ajustada con puntos medidos».
  ///
  /// In es, this message translates to:
  /// **'Humedad por conservación de materia seca (Cenicafé){ajuste}: {gramos} g de materia seca. Toca un pesaje para corregirlo.'**
  String pesajePie(String ajuste, String gramos);

  /// Se agrega dentro del pie; empieza con coma.
  ///
  /// In es, this message translates to:
  /// **', ajustada con puntos medidos'**
  String get ajustadaPuntos;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
