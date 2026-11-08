/// Formato de números, fechas y horas según el idioma (anexo de idiomas 2026-10-15, I5): español de Colombia, inglés y
/// portugués de Brasil. Las funciones de formato (`cifra`, `corta`, `hm`…) no tienen `BuildContext`; leen el idioma que
/// fija la app al resolver su `Locale` (MaterialApp.builder) y el ajuste de 12/24 h del teléfono.
library;

import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Datos de fechas de `intl` para los tres idiomas (vienen en el paquete: no usa red). Se llama al arrancar.
Future<void> prepararFormato() => Future.wait([for (final l in ['es_419', 'en', 'pt_BR']) initializeDateFormatting(l)]);

/// Código de idioma activo para el formato: `es`, `en` o `pt`.
String idiomaFormato = 'es';

/// La hora sigue el ajuste del teléfono (D6-A). Las pruebas lo fijan con `alwaysUse24HourFormatTestValue`.
bool get usar24h => WidgetsBinding.instance.platformDispatcher.alwaysUse24HourFormat;

/// Separadores: coma decimal y punto de miles en español y portugués; punto decimal y coma de miles en inglés.
(String decimal, String miles) get separadores => idiomaFormato == 'en' ? ('.', ',') : (',', '.');

/// Etiqueta de `intl` para fechas y horas. `intl` no trae es_CO: se usa es_419 (Latinoamérica, 12 h «h:mm a» como en
/// Colombia); `es` es el de España (24 h). pt_BR es 24 h, como en Brasil.
String get localeIntl => switch (idiomaFormato) { 'en' => 'en', 'pt' => 'pt_BR', _ => 'es_419' };

const _mesesEs = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// «19 ago» (es), «Aug 19» (en), «19 de ago.» (pt). El español conserva los meses propios del sistema (sep, no sept).
String diaMes(DateTime paredColombia) =>
    idiomaFormato == 'es' ? '${paredColombia.day} ${_mesesEs[paredColombia.month - 1]}' : DateFormat.MMMd(localeIntl).format(paredColombia);

/// Hora de pared: 24 h («14:53») o 12 h según el idioma («2:53 p. m.», «2:53 PM»).
String horaMinuto(DateTime paredColombia) {
  if (usar24h) return '${paredColombia.hour.toString().padLeft(2, '0')}:${paredColombia.minute.toString().padLeft(2, '0')}';
  return DateFormat.jm(localeIntl).format(paredColombia);
}

/// Lee una cifra escrita por la persona con los separadores del idioma («1.250,5» en es/pt, «1,250.5» en en) y acepta el
/// signo menos tipográfico (−). Devuelve null si no es un número.
double? leerCifra(String texto) {
  final (decimal, miles) = separadores;
  return double.tryParse(texto.trim().replaceAll(miles, '').replaceAll(decimal, '.').replaceAll('−', '-'));
}
