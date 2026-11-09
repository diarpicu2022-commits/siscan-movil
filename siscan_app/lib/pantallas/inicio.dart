import 'package:flutter/material.dart';

import '../app/comun.dart';
import '../app/contexto.dart';
import '../core/theme/siscan_theme.dart';
import '../core/ui/base.dart';
import '../core/ui/datos.dart';
import '../core/ui/dominio.dart';
import '../core/ui/marco.dart';
import '../data/estado.dart';
import '../l10n/app_localizations.dart';
import 'alertas.dart';
import 'cabecera_inicio.dart';

/// Inicio (AndroidInicio): la escena del secador con la tarjeta de vidrio del lote (CabeceraInicio, contrato C1 del
/// anexo 2026-10-12), y debajo lecturas, equipo y alertas.
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key, required this.irA});
  final void Function(Pestana) irA;
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context), t = AppLocalizations.of(context);
    return ConEstado(builder: (context, b) {
      final nombre = s.auth.session?.displayName.split(' ').first;
      final alertas = b?.alertas.length ?? 0;
      final barra = CabeceraInicio(
        base: b,
        saludo: nombre != null ? t.inicioHola(nombre) : t.inicioHolaSinNombre,
        // Paso 6: sin datos y con error, el subtítulo no puede decir que está leyendo.
        subtitulo: b == null ? (s.estado.error != null ? t.inicioNoSeLeyo : t.inicioLeyendo)
            : b.lote == null ? t.inicioSubSinLotes(b.nombreSecador)
            : b.activo != null ? t.inicioSubSecando(b.nombreSecador, '${b.lote!['name']}') : t.inicioSubTerminado(b.nombreSecador, '${b.lote!['name']}'),
        alertas: alertas,
        onAlertas: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaAlertas())),
      );
      // La franja bajo la hora aparece solo cuando la escena ya salió por arriba.
      final franja = MedidasCabecera.escena(MediaQuery.sizeOf(context).width) - MediaQuery.paddingOf(context).top;
      if (b == null) {
        return CuerpoPantalla(barra: barra, franjaDesde: franja, hijos: [s.estado.error != null ? ErrorCarga(detalle: s.estado.error, onReintentar: s.estado.cargar, automatico: true) : const Cargando()]);
      }
      Widget tile(String tipo, String rotulo) {
        final m = magnitud(tipo), u = b.ultima(tipo), serie = b.series[tipo];
        final fresca = u != null && !b.guardado && minutosDesde(u.$1) <= fueraMin;
        return LecturaTile(rotulo: rotulo, magnitud: m.tono, icono: m.icono, valor: u?.$2, unidad: m.unidad, decimales: m.dec, vivo: fresca,
            datos: serie != null && serie.length > 1 ? serie.skip(serie.length > 24 ? serie.length - 24 : 0).map((x) => x.$2).toList() : null,
            sub: u == null ? t.sinLecturas : fresca ? null : t.ultimoDato(corta(u.$1)));
      }
      final ultimoOn = b.actuadores.any((a) => a['status'] == 'ON');
      return CuerpoPantalla(barra: barra, franjaDesde: franja, onRefrescar: s.estado.cargar, hijos: [
        if (b.estado.$1 == Estado.offline) AvisoSinConexion(base: b, onReintentar: s.estado.cargar),
        if (b.lote == null) EstadoVacio(titulo: t.inicioSinLotes, texto: t.inicioSinLotesTexto, ilustracion: false),
        Column(children: [
          for (final (i, par) in [(('TEMPERATURE_TOPE', t.inicioTempInterior), ('HUMIDITY_TOPE', t.inicioHumedadRelativa)), (('TEMPERATURE_EXTERIOR', t.inicioExterior), ('POWER_TOTAL_W', t.inicioPotenciaTotal))].indexed)
            Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 10), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: tile(par.$1.$1, par.$1.$2)), const SizedBox(width: 10), Expanded(child: tile(par.$2.$1, par.$2.$2)),
            ]))),
        ]),
        Tarjeta(child: Column(children: [
          TituloTarjeta(icono: 'ventilador', titulo: t.navEquipo, derecha: Pildora(estado: ultimoOn ? Estado.running : Estado.paused, chica: true, texto: ultimoOn ? t.actEnFuncionamiento : t.actDetenidos)),
          for (final (i, a) in b.actuadores.indexed) Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 8), child: FilaActuador(
            nombre: a['name'] as String, calefactor: a['type'] == 'HEATER', encendido: a['status'] == 'ON', vatios: double.tryParse('${a['powerW']}') ?? 0, mostrarMeta: false,
            auto: b.control?['pedido'] == 'AUTO', soloLectura: s.cabecera == null,
            // La resistencia nunca se enciende con un toque: se va a Equipo, donde hay que mantener presionado.
            onChanged: (v) => a['type'] == 'HEATER' && v ? irA(Pestana.equipo)
                : s.hacer(context, (h) => s.api.actuador(int.parse('${a['id']}'), v, h), v ? t.actEncendiendo('${a['name']}') : t.actApagando('${a['name']}'), detalle: t.ordenSeCumple),
          )),
          if (s.cabecera == null) Pie(t.inicioSoloLectura, icono: 'candado'),
        ])),
        ListaAlertas(items: itemsAlerta(b).take(2).toList(), onVerTodas: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaAlertas()))),
      ]);
    });
  }
}
