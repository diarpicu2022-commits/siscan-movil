import 'package:flutter/material.dart';

import '../app/comun.dart';
import '../app/contexto.dart';
import '../core/theme/siscan_theme.dart';
import '../core/ui/base.dart';
import '../core/ui/dominio.dart';
import '../core/ui/marco.dart';

/// Alertas (AndroidPesaje › Alertas): las activas, los avisos anteriores sin revisar y el estado del equipo.
class PantallaAlertas extends StatelessWidget {
  const PantallaAlertas({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context);
    return Scaffold(body: ConEstado(builder: (context, b) {
      final barra = BarraApp(titulo: 'Alertas', atras: true, acciones: [AccionBarra('actualizar', 'Actualizar', s.estado.cargar)]);
      if (b == null) return CuerpoPantalla(barra: barra, hijos: const [Cargando()]);
      final previas = (b.reporte['alertsUnreadTotal'] as num?)?.toInt() ?? 0;
      return CuerpoPantalla(barra: barra, onRefrescar: s.estado.cargar, hijos: [
        ListaAlertas(titulo: 'Activas', items: itemsAlerta(b)),
        Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TituloTarjeta(icono: 'historial', titulo: 'Avisos anteriores', derecha: Ficha('$previas sin revisar', tono: previas > 0 ? 'warn' : 'neutral')),
          Text(previas > 0 ? 'Hay $previas avisos de días anteriores sin revisar en el panel.' : 'No hay avisos anteriores pendientes.', style: TextStyle(fontSize: 14, color: context.c.tintaSuave)),
          if (previas > 0 && s.cabecera != null) ...[
            const SizedBox(height: 12),
            Boton('Marcar todo como leído', icono: 'check', onPressed: () async {
              final ok = await showDialog<bool>(context: context, builder: (d) => AlertDialog(title: const Text('Marcar avisos como leídos'),
                  content: Text('¿Marcar como leídos los $previas avisos anteriores?'),
                  actions: [TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancelar')), TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Marcar'))]));
              if (ok == true && context.mounted) await s.hacer(context, s.api.marcarAlertasLeidas, 'Avisos marcados como leídos');
            }),
          ],
        ])),
        Salud(filas: filasSalud(b)),
      ]);
    }));
  }
}
