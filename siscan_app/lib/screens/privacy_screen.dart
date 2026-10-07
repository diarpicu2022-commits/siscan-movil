import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Política de tratamiento de datos dentro de la app (borrador técnico; docs/legal/politica-datos-app-siscan.md).
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const version = '0.1 · 7 de octubre de 2026 (borrador)';

  static const _sections = <(String, String)>[
    ('Qué guarda la app',
        'El último estado del secador (lecturas, lote, equipo y alertas) para mostrarlo sin señal; no son datos personales. '
            'Si ingresas como Gestor del Secador, tu usuario y tu contraseña de aplicación, cifrados en el almacén seguro del teléfono, '
            'solo para enviar órdenes al secador.'),
    ('Qué no hace',
        'No usa ubicación, cámara ni contactos. No tiene publicidad, analítica ni rastreo, y no comparte datos con nadie. '
            'Solo habla con cisna.narino.gov.co por HTTPS.'),
    ('Para qué', 'Mostrar el estado del secado y permitir al personal autorizado encender o apagar el equipo.'),
    ('Cuánto tiempo', 'Hasta que cierres sesión (borra la credencial), borres los datos de este teléfono o desinstales la app.'),
    ('Tus derechos',
        'Conocer, actualizar, rectificar y suprimir tus datos y revocar la autorización (Ley 1581 de 2012 y Decreto 1377 de 2013). '
            'En Ajustes: «Cerrar sesión» borra la credencial y «Borrar datos de este teléfono» borra todo lo guardado. '
            'La contraseña de aplicación también se puede revocar en WordPress.'),
    ('Responsable', 'Proyecto SISCAN — Secado Inteligente de Café, Gobernación de Nariño (CISNA).'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    return Scaffold(
      backgroundColor: t.pergamino,
      appBar: AppBar(
        backgroundColor: t.monte,
        foregroundColor: t.sobreMonte,
        title: Text('Tus datos', style: SiscanType.seccion.copyWith(color: t.sobreMonte, fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(SiscanSpace.s5),
        children: [
          Text(rotulo('Versión'), style: SiscanType.etiqueta.copyWith(color: t.tierraSuave)),
          Text(version, style: SiscanType.nota.copyWith(color: t.tierraSuave)),
          for (final (title, body) in _sections) ...[
            const SizedBox(height: SiscanSpace.s5),
            Text(title, style: SiscanType.cuerpoFuerte.copyWith(color: t.tierra)),
            const SizedBox(height: SiscanSpace.s1),
            Text(body, style: SiscanType.cuerpo.copyWith(color: t.tierra)),
          ],
        ],
      ),
    );
  }
}
