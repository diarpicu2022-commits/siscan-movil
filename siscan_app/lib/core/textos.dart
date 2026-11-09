import 'package:flutter/widgets.dart' show BuildContext, Locale;

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
