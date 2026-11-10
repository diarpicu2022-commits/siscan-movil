import 'package:flutter/material.dart';

import '../app/comun.dart';
import '../app/contexto.dart';
import '../core/theme/siscan_theme.dart';
import '../core/textos.dart';
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
      final barra = BarraApp(titulo: context.tx.alertas, atras: true, acciones: [AccionBarra('actualizar', context.tx.actualizar, s.estado.cargar)]);
      if (b == null) return CuerpoPantalla(barra: barra, hijos: const [Cargando()]);
      final previas = (b.reporte['alertsUnreadTotal'] as num?)?.toInt() ?? 0;
      return CuerpoPantalla(barra: barra, onRefrescar: s.estado.cargar, hijos: [
        ListaAlertas(titulo: context.tx.alertasActivas, items: itemsAlerta(b)),
        Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TituloTarjeta(icono: 'historial', titulo: context.tx.avisosAnteriores, derecha: Ficha(context.tx.sinRevisar(previas), tono: previas > 0 ? 'warn' : 'neutral')),
          Text(previas > 0 ? context.tx.avisosHay(previas) : context.tx.avisosNinguno, style: TextStyle(fontSize: 14, color: context.c.tintaSuave)),
          if (previas > 0 && s.cabecera != null) ...[
            const SizedBox(height: 12),
            Boton(context.tx.marcarTodo, icono: 'check', onPressed: () async {
              final ok = await showDialog<bool>(context: context, builder: (d) => AlertDialog(title: Text(context.tx.marcarTitulo),
                  content: Text(context.tx.marcarPregunta(previas)),
                  actions: [TextButton(onPressed: () => Navigator.pop(d, false), child: Text(context.tx.cancelar)), TextButton(onPressed: () => Navigator.pop(d, true), child: Text(context.tx.marcar))]));
              if (ok == true && context.mounted) await s.hacer(context, s.api.marcarAlertasLeidas, context.tx.avisosMarcados);
            }),
          ],
        ])),
        Salud(filas: filasSalud(b)),
      ]);
    }));
  }
}
