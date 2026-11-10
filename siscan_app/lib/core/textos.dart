import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart' show BuildContext, Locale;
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'formato.dart';

/// Textos para las funciones que no tienen contexto (formatos, textos derivados de los datos). Usa el idioma ya resuelto
/// por la app (`idiomaFormato`). Dentro de un widget se usa `AppLocalizations.of(context)`, que además lo reconstruye
/// cuando cambia el idioma; estas funciones solo las llaman widgets que ya dependen del idioma.
AppLocalizations get tr => lookupAppLocalizations(Locale(idiomaFormato));

/// Textos dentro de un widget: `context.tx.clave`. Depende del idioma, así que el widget se reconstruye al cambiarlo.
extension TextosContexto on BuildContext {
  AppLocalizations get tx => AppLocalizations.of(this);
}

/// Textos para lo que corre fuera de la app (notificaciones en segundo plano): el idioma elegido en SISCAN
/// (`siscan_idioma`) o, con «Como el teléfono», el del sistema. También deja `idiomaFormato` en ese idioma.
Future<AppLocalizations> textosFueraDeLaApp() async {
  var c = 'sistema';
  try { c = (await SharedPreferences.getInstance()).getString('siscan_idioma') ?? 'sistema'; } catch (_) {/* sin preferencias: el del sistema */}
  if (c == 'sistema') c = PlatformDispatcher.instance.locale.languageCode;
  idiomaFormato = c == 'en' || c == 'pt' ? c : 'es';
  return lookupAppLocalizations(Locale(idiomaFormato));
}
