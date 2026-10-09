// GENERADO por tools/generar_tokens_flutter.py desde tokens.json del sistema de diseño SISCAN v2. No editar a mano.
import 'package:flutter/material.dart';

/// Colores del sistema (temas claro y oscuro). El reloj usa siempre el oscuro.
@immutable
class SiscanColors extends ThemeExtension<SiscanColors> {
  const SiscanColors({
    required this.fondo,
    required this.superficie,
    required this.superficieHoja,
    required this.superficieFuerte,
    required this.linea,
    required this.lineaFuerte,
    required this.tinta,
    required this.tintaSuave,
    required this.deshabilitado,
    required this.bosque,
    required this.bosqueHondo,
    required this.sobreBosque,
    required this.sobreBosqueSuave,
    required this.salvia,
    required this.salviaClara,
    required this.marca,
    required this.hoja,
    required this.sobreHoja,
    required this.esmeralda,
    required this.brote,
    required this.broteVivo,
    required this.lima,
    required this.cafe,
    required this.cafeSuave,
    required this.pergamino,
    required this.datoTemperatura,
    required this.datoHumedad,
    required this.datoExterior,
    required this.datoGrano,
    required this.datoSolar,
    required this.datoSolarRelleno,
    required this.datoElectrica,
    required this.objetivo,
    required this.prediccion,
    required this.operando,
    required this.operandoSuave,
    required this.pausa,
    required this.pausaSuave,
    required this.alerta,
    required this.alertaSuave,
    required this.fuera,
    required this.fueraSuave,
    required this.info,
  });
  /// Fondo de la página, detrás de las tarjetas.
  final Color fondo;
  /// Tarjetas, paneles, tablas y hojas del móvil.
  final Color superficie;
  /// Tarjetas con tinte verde: lote activo, estados en operación, resúmenes.
  final Color superficieHoja;
  /// Campos en reposo, pistas de barras y anillos, filas seleccionadas.
  final Color superficieFuerte;
  /// Bordes de tarjeta y divisores.
  final Color linea;
  /// Borde de controles (campo, interruptor apagado); 3:1 sobre fondo y superficie.
  final Color lineaFuerte;
  /// Texto principal y lecturas, sobre fondo, superficie, superficie-hoja y superficie-fuerte.
  final Color tinta;
  /// Texto secundario, unidades, metadatos; sobre las mismas superficies.
  final Color tintaSuave;
  /// Texto y controles deshabilitados (no informativo).
  final Color deshabilitado;
  /// Barra lateral, encabezados oscuros y fondo del reloj. Texto encima: sobre-bosque.
  final Color bosque;
  /// Parte baja del degradado de la barra lateral y de los encabezados móviles.
  final Color bosqueHondo;
  /// Texto e íconos sobre bosque y salvia.
  final Color sobreBosque;
  /// Texto secundario sobre bosque (ítems de menú inactivos).
  final Color sobreBosqueSuave;
  /// El verde salvia del ítem activo del menú y de la barra Android; texto sobre-bosque encima.
  final Color salvia;
  /// Segundo tono del degradado del ítem activo. Solo relleno.
  final Color salviaClara;
  /// El verde del wordmark SISCAN: títulos de marca y enlaces. Como texto, sobre fondo, superficie y superficie-hoja.
  final Color marca;
  /// Primario de acción: botón principal, interruptor encendido, FAB. Como texto, sobre fondo y superficie.
  final Color hoja;
  /// Texto sobre relleno hoja.
  final Color sobreHoja;
  /// El verde vivo de las curvas y puntos del panel aprobado: humedad de cámara, línea de progreso. Como texto, sobre fondo y superficie.
  final Color esmeralda;
  /// Fondo de chips y etiquetas verdes; detrás de texto marca u hoja.
  final Color brote;
  /// El verde claro de las barras de energía y los puntos «En vivo». Solo relleno, nunca texto.
  final Color broteVivo;
  /// Las hojas lima del logo: extremo del degradado de progreso y destellos. Solo relleno.
  final Color lima;
  /// El grano del logo: humedad del grano, lotes, pesajes. Como texto, sobre fondo, superficie y cafe-suave.
  final Color cafe;
  /// Fondo teñido detrás de texto cafe.
  final Color cafeSuave;
  /// Color del café pergamino seco: escala de humedad en objetivo. Solo relleno.
  final Color pergamino;
  /// Temperaturas (interior, tope, exterior). Como texto, sobre fondo y superficie.
  final Color datoTemperatura;
  /// Humedad relativa interior.
  final Color datoHumedad;
  /// Clima y humedad exterior; energía de la red eléctrica.
  final Color datoExterior;
  /// Humedad del grano.
  final Color datoGrano;
  /// Energía solar y radiación, como texto, sobre fondo y superficie.
  final Color datoSolar;
  /// Barras de energía solar, como en el panel aprobado.
  final Color datoSolarRelleno;
  /// Barras de energía de la red eléctrica.
  final Color datoElectrica;
  /// Banda y línea discontinua del objetivo de humedad (10 – 12 %). Solo líneas y rellenos.
  final Color objetivo;
  /// Tramo predicho por la IA en la curva (línea punteada) y su chip. Como texto, sobre fondo y superficie.
  final Color prediccion;
  /// En operación, dentro de rango, encendido. Siempre con punto y palabra.
  final Color operando;
  /// Fondo de la píldora En operación.
  final Color operandoSuave;
  /// En pausa, advertencia. Siempre con ícono y palabra.
  final Color pausa;
  /// Fondo de la píldora En pausa y de advertencias.
  final Color pausaSuave;
  /// Crítico: temperatura alta, sensor caído. Siempre con ícono y palabra.
  final Color alerta;
  /// Fondo de la píldora Alerta.
  final Color alertaSuave;
  /// Sin conexión: el secador no reporta. Gris, nunca rojo.
  final Color fuera;
  /// Fondo de la píldora Sin conexión.
  final Color fueraSuave;
  /// Información contextual y enlaces de ayuda.
  final Color info;
  static const claro = SiscanColors(
    fondo: Color(0xFFF5F8F3),
    superficie: Color(0xFFFFFFFF),
    superficieHoja: Color(0xFFF1F8EC),
    superficieFuerte: Color(0xFFE6EEE1),
    linea: Color(0xFFDDE6D7),
    lineaFuerte: Color(0xFF7B8C7D),
    tinta: Color(0xFF1A2B21),
    tintaSuave: Color(0xFF53685A),
    deshabilitado: Color(0xFFA3B0A5),
    bosque: Color(0xFF183024),
    bosqueHondo: Color(0xFF10261B),
    sobreBosque: Color(0xFFF4F2EA),
    sobreBosqueSuave: Color(0xFFAEC1B7),
    salvia: Color(0xFF5A7550),
    salviaClara: Color(0xFF7C9670),
    marca: Color(0xFF0B4A24),
    hoja: Color(0xFF1E6134),
    sobreHoja: Color(0xFFFFFFFF),
    esmeralda: Color(0xFF117040),
    brote: Color(0xFFDDE9CB),
    broteVivo: Color(0xFF8BB75B),
    lima: Color(0xFF9CBF2A),
    cafe: Color(0xFF5E2F14),
    cafeSuave: Color(0xFFF5EADF),
    pergamino: Color(0xFFCFA96D),
    datoTemperatura: Color(0xFFB84D26),
    datoHumedad: Color(0xFF117040),
    datoExterior: Color(0xFF2C66A3),
    datoGrano: Color(0xFF5E2F14),
    datoSolar: Color(0xFF4B7420),
    datoSolarRelleno: Color(0xFF8BB75B),
    datoElectrica: Color(0xFF2C66A3),
    objetivo: Color(0xFFC39324),
    prediccion: Color(0xFF6A5BB0),
    operando: Color(0xFF1B6E3E),
    operandoSuave: Color(0xFFDCF0E2),
    pausa: Color(0xFF9A5B00),
    pausaSuave: Color(0xFFFBECD2),
    alerta: Color(0xFFB23A2F),
    alertaSuave: Color(0xFFFADFDA),
    fuera: Color(0xFF5D6762),
    fueraSuave: Color(0xFFECEEEC),
    info: Color(0xFF2C66A3),
  );
  static const oscuro = SiscanColors(
    fondo: Color(0xFF0F1D16),
    superficie: Color(0xFF172A20),
    superficieHoja: Color(0xFF1C3426),
    superficieFuerte: Color(0xFF24402F),
    linea: Color(0xFF2C4636),
    lineaFuerte: Color(0xFF71897A),
    tinta: Color(0xFFEEF3EA),
    tintaSuave: Color(0xFFA9BDAE),
    deshabilitado: Color(0xFF4C6052),
    bosque: Color(0xFF0B1711),
    bosqueHondo: Color(0xFF07110C),
    sobreBosque: Color(0xFFEEF3EA),
    sobreBosqueSuave: Color(0xFF93A99A),
    salvia: Color(0xFF4F6E47),
    salviaClara: Color(0xFF6A8A5F),
    marca: Color(0xFF8FD19E),
    hoja: Color(0xFF6CC387),
    sobreHoja: Color(0xFF0F1D16),
    esmeralda: Color(0xFF5FD08F),
    brote: Color(0xFF264A2C),
    broteVivo: Color(0xFFA6D07A),
    lima: Color(0xFFB7D65A),
    cafe: Color(0xFFD2A07A),
    cafeSuave: Color(0xFF3A271C),
    pergamino: Color(0xFFD8B47C),
    datoTemperatura: Color(0xFFF08A5D),
    datoHumedad: Color(0xFF5FD08F),
    datoExterior: Color(0xFF8AB4EF),
    datoGrano: Color(0xFFD2A07A),
    datoSolar: Color(0xFFB7D65A),
    datoSolarRelleno: Color(0xFFA6D07A),
    datoElectrica: Color(0xFF8AB4EF),
    objetivo: Color(0xFFE3BF5A),
    prediccion: Color(0xFFB3A8F0),
    operando: Color(0xFF5FD08F),
    operandoSuave: Color(0xFF173B27),
    pausa: Color(0xFFF1B450),
    pausaSuave: Color(0xFF3E2C0F),
    alerta: Color(0xFFFF8E80),
    alertaSuave: Color(0xFF45201C),
    fuera: Color(0xFF9AA5A0),
    fueraSuave: Color(0xFF26302B),
    info: Color(0xFF8AB4EF),
  );
  @override
  SiscanColors copyWith() => this;
  @override
  SiscanColors lerp(ThemeExtension<SiscanColors>? other, double t) {
    if (other is! SiscanColors) return this;
    return SiscanColors(
      fondo: Color.lerp(fondo, other.fondo, t)!,
      superficie: Color.lerp(superficie, other.superficie, t)!,
      superficieHoja: Color.lerp(superficieHoja, other.superficieHoja, t)!,
      superficieFuerte: Color.lerp(superficieFuerte, other.superficieFuerte, t)!,
      linea: Color.lerp(linea, other.linea, t)!,
      lineaFuerte: Color.lerp(lineaFuerte, other.lineaFuerte, t)!,
      tinta: Color.lerp(tinta, other.tinta, t)!,
      tintaSuave: Color.lerp(tintaSuave, other.tintaSuave, t)!,
      deshabilitado: Color.lerp(deshabilitado, other.deshabilitado, t)!,
      bosque: Color.lerp(bosque, other.bosque, t)!,
      bosqueHondo: Color.lerp(bosqueHondo, other.bosqueHondo, t)!,
      sobreBosque: Color.lerp(sobreBosque, other.sobreBosque, t)!,
      sobreBosqueSuave: Color.lerp(sobreBosqueSuave, other.sobreBosqueSuave, t)!,
      salvia: Color.lerp(salvia, other.salvia, t)!,
      salviaClara: Color.lerp(salviaClara, other.salviaClara, t)!,
      marca: Color.lerp(marca, other.marca, t)!,
      hoja: Color.lerp(hoja, other.hoja, t)!,
      sobreHoja: Color.lerp(sobreHoja, other.sobreHoja, t)!,
      esmeralda: Color.lerp(esmeralda, other.esmeralda, t)!,
      brote: Color.lerp(brote, other.brote, t)!,
      broteVivo: Color.lerp(broteVivo, other.broteVivo, t)!,
      lima: Color.lerp(lima, other.lima, t)!,
      cafe: Color.lerp(cafe, other.cafe, t)!,
      cafeSuave: Color.lerp(cafeSuave, other.cafeSuave, t)!,
      pergamino: Color.lerp(pergamino, other.pergamino, t)!,
      datoTemperatura: Color.lerp(datoTemperatura, other.datoTemperatura, t)!,
      datoHumedad: Color.lerp(datoHumedad, other.datoHumedad, t)!,
      datoExterior: Color.lerp(datoExterior, other.datoExterior, t)!,
      datoGrano: Color.lerp(datoGrano, other.datoGrano, t)!,
      datoSolar: Color.lerp(datoSolar, other.datoSolar, t)!,
      datoSolarRelleno: Color.lerp(datoSolarRelleno, other.datoSolarRelleno, t)!,
      datoElectrica: Color.lerp(datoElectrica, other.datoElectrica, t)!,
      objetivo: Color.lerp(objetivo, other.objetivo, t)!,
      prediccion: Color.lerp(prediccion, other.prediccion, t)!,
      operando: Color.lerp(operando, other.operando, t)!,
      operandoSuave: Color.lerp(operandoSuave, other.operandoSuave, t)!,
      pausa: Color.lerp(pausa, other.pausa, t)!,
      pausaSuave: Color.lerp(pausaSuave, other.pausaSuave, t)!,
      alerta: Color.lerp(alerta, other.alerta, t)!,
      alertaSuave: Color.lerp(alertaSuave, other.alertaSuave, t)!,
      fuera: Color.lerp(fuera, other.fuera, t)!,
      fueraSuave: Color.lerp(fueraSuave, other.fueraSuave, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// Estilos de texto del sistema. Outfit (display) para saludos y cifras protagonistas; Plus Jakarta Sans (ui) para todo lo demás.
class SiscanType {
  SiscanType._();
  static const display = 'Outfit';
  static const ui = 'PlusJakartaSans';
  static const _tab = [FontFeature.tabularFigures()];
  /// La lectura protagonista: humedad del grano en el anillo, tiempo de secado del lote.
  static const lecturaXl = TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 40.0, height: 1.1000, fontWeight: FontWeight.w700, letterSpacing: -0.800, fontFeatures: _tab);
  /// Valor de cada tarjeta de métrica. Cifras tabulares; la unidad va en lectura-unidad.
  static const lectura = TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 30.0, height: 1.1333, fontWeight: FontWeight.w700, letterSpacing: -0.600, fontFeatures: _tab);
  /// Unidad junto al valor (°C, %, kWh, h).
  static const lecturaUnidad = TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 16.0, height: 1.2500, fontWeight: FontWeight.w600, letterSpacing: 0.000, fontFeatures: _tab);
  /// Valores dentro de tarjetas secundarias y tablas destacadas.
  static const lecturaSm = TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 18.0, height: 1.3333, fontWeight: FontWeight.w700, letterSpacing: 0.000, fontFeatures: _tab);
  /// Saludo y título de página.
  static const saludo = TextStyle(fontFamily: 'Outfit', fontSize: 28.0, height: 1.2143, fontWeight: FontWeight.w700, letterSpacing: -0.280);
  /// Título de tarjeta, con ícono a la izquierda.
  static const tituloTarjeta = TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 15.0, height: 1.3333, fontWeight: FontWeight.w700, letterSpacing: 0.000);
  /// Texto corrido y descripciones.
  static const cuerpo = TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 15.0, height: 1.4667, fontWeight: FontWeight.w500, letterSpacing: 0.000);
  /// Metadatos, variaciones (−0,8 °C), ejes de gráficas.
  static const apoyo = TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13.0, height: 1.3846, fontWeight: FontWeight.w500, letterSpacing: 0.000);
  /// Píldoras y rótulos cortos.
  static const etiqueta = TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12.0, height: 1.3333, fontWeight: FontWeight.w700, letterSpacing: 0.480);
  /// Solo cuando no se puede usar el logo (texto alternativo de respaldo). El logo real es una imagen.
  static const marcaTitulo = TextStyle(fontFamily: 'Outfit', fontSize: 44.0, height: 1.0909, fontWeight: FontWeight.w800, letterSpacing: 0.880);
  /// Lema bajo el nombre, espaciado amplio como en el logo.
  static const marcaLema = TextStyle(fontFamily: 'Outfit', fontSize: 16.0, height: 1.2500, fontWeight: FontWeight.w400, letterSpacing: 1.920);
}

/// Espaciado (base de 4).
class SiscanSpace {
  SiscanSpace._();
  /// Ícono–texto en píldoras.
  static const double s1 = 4.0;
  /// Entre valor y variación; dentro de chips.
  static const double s2 = 8.0;
  /// Entre filas de una lista.
  static const double s3 = 12.0;
  /// Relleno de tarjetas y separación entre tarjetas.
  static const double s4 = 16.0;
  /// Relleno de tarjetas grandes (gráficas, lote activo).
  static const double s5 = 20.0;
  /// Margen del área de contenido y entre bloques.
  static const double s6 = 24.0;
  /// Separación entre secciones de una página.
  static const double s8 = 32.0;
}

/// Radios.
class SiscanRadius {
  SiscanRadius._();
  /// Campos, chips cuadrados, íconos con fondo.
  static const double sm = 8.0;
  /// Tarjetas de métrica, filas de alerta, ítems del menú.
  static const double md = 14.0;
  /// Tarjetas grandes, mapa, lote activo.
  static const double lg = 20.0;
  /// Marco del panel, hero ilustrado, hojas inferiores del móvil.
  static const double xl = 28.0;
  /// Píldoras de estado, interruptores, botones.
  static const double pill = 999.0;
}

/// Medidas fijas (toque mínimo, íconos, reloj).
class SiscanSize {
  SiscanSize._();
  /// Ancho de la barra lateral del portal web.
  static const double sidebar = 232.0;
  /// Objetivo táctil mínimo (botones, filas, interruptores).
  static const double toque = 44.0;
  /// Íconos de interfaz; 18px dentro de títulos de tarjeta.
  static const double icono = 20.0;
  /// Ícono dentro de un cuadro teñido (alertas, actuadores).
  static const double iconoFondo = 36.0;
  /// Diámetro de la esfera de Wear OS en la documentación (equivale a 454 px reales).
  static const double reloj = 224.0;
  /// Objetivo táctil mínimo en el reloj; los chips van a lo ancho.
  static const double toqueReloj = 48.0;
}

/// Duraciones y curvas. Las de «SIEMPRE» se mantienen mientras el estado exista; con movimiento reducido, quietas.
class SiscanMotion {
  SiscanMotion._();
  /// Interruptores, hover, chips.
  static const rapida = Duration(milliseconds: 160);
  /// Cambio de lectura, entrada de alerta, toast.
  static const media = Duration(milliseconds: 320);
  /// Dibujo de curvas y llenado de anillos al cargar.
  static const lenta = Duration(milliseconds: 900);
  /// SIEMPRE: una vuelta del ícono de ventilador encendido.
  static const ventilador = Duration(milliseconds: 1400);
  /// SIEMPRE: flujo de aire en la ilustración del secador cuando los ventiladores operan.
  static const aire = Duration(milliseconds: 2600);
  /// SIEMPRE: latido del punto «En vivo» y del último punto de cada serie.
  static const latido = Duration(milliseconds: 2000);
  /// Por defecto.
  static const suave = Cubic(0.4, 0, 0.2, 1);
  /// Lo que llega: alertas, toasts, curvas que se dibujan.
  static const entrada = Cubic(0.16, 1, 0.3, 1);
}

/// Sombras por tema.
class SiscanShadow {
  SiscanShadow._();
  static const tarjetaClaro = [BoxShadow(offset: Offset(0.0, 1.0), blurRadius: 2.0, spreadRadius: 0.0, color: Color.fromRGBO(24, 48, 36, 0.05)), BoxShadow(offset: Offset(0.0, 6.0), blurRadius: 18.0, spreadRadius: 0.0, color: Color.fromRGBO(24, 48, 36, 0.05))];
  static const tarjetaOscuro = [BoxShadow(offset: Offset(0.0, 1.0), blurRadius: 0.0, spreadRadius: 0.0, color: Color.fromRGBO(0, 0, 0, 0.35))];
  static List<BoxShadow> tarjeta(Brightness b) => b == Brightness.dark ? tarjetaOscuro : tarjetaClaro;
  static const flotanteClaro = [BoxShadow(offset: Offset(0.0, 18.0), blurRadius: 44.0, spreadRadius: 0.0, color: Color.fromRGBO(16, 38, 27, 0.16))];
  static const flotanteOscuro = [BoxShadow(offset: Offset(0.0, 18.0), blurRadius: 44.0, spreadRadius: 0.0, color: Color.fromRGBO(0, 0, 0, 0.55))];
  static List<BoxShadow> flotante(Brightness b) => b == Brightness.dark ? flotanteOscuro : flotanteClaro;
  static const activoClaro = [BoxShadow(offset: Offset(0.0, 6.0), blurRadius: 16.0, spreadRadius: 0.0, color: Color.fromRGBO(24, 48, 36, 0.28))];
  static const activoOscuro = [BoxShadow(offset: Offset(0.0, 6.0), blurRadius: 16.0, spreadRadius: 0.0, color: Color.fromRGBO(0, 0, 0, 0.5))];
  static List<BoxShadow> activo(Brightness b) => b == Brightness.dark ? activoOscuro : activoClaro;
}
