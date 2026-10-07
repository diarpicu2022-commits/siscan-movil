import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'siscan_icon.dart';

/// `sinReportes`: hay conexión con el servidor, pero el secador no envía lecturas recientes (más de 15 min).
enum SyncStatus { conectado, sincronizando, offline, error, sinReportes }

/// Píldora de conexión con el secador. En la barra superior móvil va sobre `monte` (onDark).
/// En «offline» las lecturas deben pasar a «Última lectura».
class ConnectionStatus extends StatelessWidget {
  const ConnectionStatus(this.status, {super.key, this.onDark = false});
  final SyncStatus status;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final (word, glyph, tone) = switch (status) {
      SyncStatus.conectado => ('Conectado', SiscanGlyph.check, onDark ? t.sobreMonte : t.cafeto),
      SyncStatus.sincronizando => ('Sincronizando', SiscanGlyph.sincronizar, onDark ? t.sobreMonte : t.bruma),
      SyncStatus.offline => ('Modo offline', SiscanGlyph.sinConexion, onDark ? t.panelaSuave : t.panela),
      SyncStatus.error => ('Sin conexión', SiscanGlyph.alerta, onDark ? t.oxidoSuave : t.oxido),
      SyncStatus.sinReportes => ('Secador sin reportar', SiscanGlyph.historial, onDark ? t.panelaSuave : t.panela),
    };
    return Semantics(
      label: word, liveRegion: true, excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: onDark ? t.sobreMonte.withValues(alpha: .08) : t.papel,
          borderRadius: BorderRadius.circular(SiscanRadius.grano),
          border: Border.all(color: onDark ? t.sobreMonteSuave.withValues(alpha: .45) : t.lineaFuerte),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (status == SyncStatus.conectado)
            Container(width: 8, height: 8, decoration: BoxDecoration(color: onDark ? t.fococolor : t.cafeto, shape: BoxShape.circle))
          else
            SiscanIcon(glyph, size: 16, color: tone),
          const SizedBox(width: 6),
          Flexible(child: Text(word, maxLines: 1, overflow: TextOverflow.ellipsis, style: SiscanType.cuerpoFuerte.copyWith(fontSize: 13, height: 1.2, color: tone))),
        ]),
      ),
    );
  }
}

extension on SiscanTokens {
  /// Punto «en vivo» sobre monte: el foco cálido del sistema, legible sobre el verde.
  Color get fococolor => focoSobreMonte;
}
