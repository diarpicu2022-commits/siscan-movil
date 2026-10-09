import 'package:flutter/material.dart';

import '../app/comun.dart';
import '../app/contexto.dart';
import '../core/theme/siscan_theme.dart';
import '../core/ui/base.dart';
import '../core/ui/datos.dart';
import '../core/ui/dominio.dart';
import '../core/ui/marco.dart';
import '../data/estado.dart';
import 'alertas.dart';

/// Inicio (AndroidInicio): encabezado bosque con el anillo de humedad del grano, lecturas, equipo y alertas.
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key, required this.irA});
  final void Function(Pestana) irA;
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context);
    return ConEstado(builder: (context, b) {
      final nombre = s.auth.session?.displayName.split(' ').first;
      final alertas = b?.alertas.length ?? 0;
      final barra = BarraApp(
        oscura: true, grande: true, logo: true,
        titulo: nombre != null ? '¡Hola, $nombre!' : '¡Hola!',
        subtitulo: b == null ? 'Leyendo el secador…' : '${b.nombreSecador} · ${b.lote == null ? 'sin lotes' : '${b.lote!['name']} ${b.activo != null ? 'secando' : 'terminado'}'}',
        acciones: [AccionBarra('alertas', 'Alertas', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaAlertas())), cuenta: alertas)],
        hijo: b?.lote == null ? null : _Heroe(b: b!),
      );
      if (b == null) {
        return CuerpoPantalla(barra: barra, hijos: [s.estado.error != null ? ErrorCarga(detalle: s.estado.error, onReintentar: s.estado.cargar, automatico: true) : const Cargando()]);
      }
      Widget tile(String tipo, String rotulo) {
        final m = magnitud(tipo), u = b.ultima(tipo), serie = b.series[tipo];
        final fresca = u != null && !b.guardado && minutosDesde(u.$1) <= fueraMin;
        return LecturaTile(rotulo: rotulo, magnitud: m.tono, icono: m.icono, valor: u?.$2, unidad: m.unidad, decimales: m.dec, vivo: fresca,
            datos: serie != null && serie.length > 1 ? serie.skip(serie.length > 24 ? serie.length - 24 : 0).map((x) => x.$2).toList() : null,
            sub: u == null ? 'Sin lecturas' : fresca ? null : 'Último dato ${corta(u.$1)}');
      }
      final ultimoOn = b.actuadores.any((a) => a['status'] == 'ON');
      return CuerpoPantalla(barra: barra, onRefrescar: s.estado.cargar, hijos: [
        if (b.estado.$1 == Estado.offline) AvisoSinConexion(base: b, onReintentar: s.estado.cargar),
        if (b.lote == null) const EstadoVacio(titulo: 'No hay lotes registrados', texto: 'Cuando ingreses café al secador, su registro aparecerá aquí.'),
        Column(children: [
          for (final (i, par) in const [(('TEMPERATURE_TOPE', 'Temp. interior'), ('HUMIDITY_TOPE', 'Humedad relativa')), (('TEMPERATURE_EXTERIOR', 'Exterior'), ('POWER_TOTAL_W', 'Potencia total'))].indexed)
            Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 10), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: tile(par.$1.$1, par.$1.$2)), const SizedBox(width: 10), Expanded(child: tile(par.$2.$1, par.$2.$2)),
            ]))),
        ]),
        Tarjeta(child: Column(children: [
          TituloTarjeta(icono: 'ventilador', titulo: 'Equipo', derecha: Pildora(estado: ultimoOn ? Estado.running : Estado.paused, chica: true, texto: ultimoOn ? 'En funcionamiento' : 'Detenidos')),
          for (final (i, a) in b.actuadores.indexed) Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 8), child: FilaActuador(
            nombre: a['name'] as String, calefactor: a['type'] == 'HEATER', encendido: a['status'] == 'ON', vatios: double.tryParse('${a['powerW']}') ?? 0, mostrarMeta: false,
            auto: b.control?['pedido'] == 'AUTO', soloLectura: s.cabecera == null,
            // La resistencia nunca se enciende con un toque: se va a Equipo, donde hay que mantener presionado.
            onChanged: (v) => a['type'] == 'HEATER' && v ? irA(Pestana.equipo)
                : s.hacer(context, (h) => s.api.actuador(int.parse('${a['id']}'), v, h), '${a['name']} · ${v ? 'Encendiendo…' : 'Apagando…'}', detalle: 'Se cumple cuando el ESP32 reporte.'),
          )),
          if (s.cabecera == null) const Pie('Vista de solo lectura: para mandar órdenes ingresa con tu cuenta.', icono: 'candado'),
        ])),
        ListaAlertas(items: itemsAlerta(b).take(2).toList(), onVerTodas: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaAlertas()))),
      ]);
    });
  }
}

/// a-hero: anillo de 132 en lima sobre el bosque y, al lado, estado, objetivo, predicción de la tesis y su confianza.
class _Heroe extends StatelessWidget {
  const _Heroe({required this.b});
  final Base b;
  @override
  Widget build(BuildContext context) {
    final c = context.c, lote = b.lote!, s = Siscan.of(context);
    final hum = (lote['lastMoisturePct'] as num?)?.toDouble();
    final activo = lote['status'] == 'RUNNING';
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .07), borderRadius: BorderRadius.circular(24)),
      child: Row(children: [
        Anillo(valor: avanceLote(lote), texto: hum == null ? '—' : '${cifra(hum)} %', rotulo: 'Humedad del grano', size: 132,
            pista: Colors.white.withValues(alpha: .14), colorTexto: Colors.white, colorRotulo: c.sobreBosqueSuave),
        const SizedBox(width: 16),
        Expanded(child: Pedido<J>(
          clave: '${lote['id']}-${lote['sampleCount']}',
          cargar: () => s.api.prediccion(lote['id'] as int),
          builder: (context, p, e, cargando) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Pildora(estado: activo ? Estado.running : Estado.paused, vivo: activo, texto: activo ? 'Secando' : 'Terminado'),
            const SizedBox(height: 6),
            Text('Objetivo 10 – 12 %', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 6),
            Text(e != null ? 'Predicción no disponible' : textoPrediccion(p, enCurso: activo), style: TextStyle(fontSize: 13, color: c.sobreBosqueSuave)),
            if (p?['confianza'] != null && p?['estado'] == 'EN_CURSO') ...[
              const SizedBox(height: 6),
              Row(children: [const Icono('ia', size: 14, color: Color(0xFFB3A8F0)), const SizedBox(width: 5),
                Text('Confianza ${(p!['confianza'] as num) >= 75 ? 'alta' : (p['confianza'] as num) >= 50 ? 'media' : 'baja'}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFB3A8F0)))]),
            ],
          ]),
        )),
      ]),
    );
  }
}
