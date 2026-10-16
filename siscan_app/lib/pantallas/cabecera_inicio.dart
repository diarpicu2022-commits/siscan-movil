/// Cabecera de Inicio (contrato C1 del anexo 2026-10-12): el secador en su cafetal, a sangre y con la luz de esta hora,
/// sostiene en su borde inferior la tarjeta de vidrio del lote. Saludo y campana van en la banda de cielo con la tinta
/// de la escena (no del tema): tinta oscura sobre `day`/`dusk`, sobre-bosque sobre `night`.
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/comun.dart';
import '../app/contexto.dart';
import '../core/momento.dart';
import '../core/theme/siscan_theme.dart';
import '../core/theme/siscan_tokens.dart';
import '../core/ui/base.dart';
import '../core/ui/dominio.dart';
import '../core/ui/marco.dart';
import '../data/estado.dart';

/// Medidas de la cabecera, en un solo lugar para que la prueba mida lo mismo que se dibuja.
abstract final class MedidasCabecera {
  /// Margen lateral del contenido de la página (sc-abody, el mismo de [CuerpoPantalla]).
  static const margen = 14.0;
  /// Cuánto pisa la tarjeta la escena. El secador ocupa x ≈ 600–1150 e y ≈ 400–600 del lienzo 1200 × 600 y sus
  /// bandejas terminan en y ≈ 545 (el 91 % del alto): 32 px (space-8) dejan la tarjeta sobre el pasto y las patas, sin
  /// tapar las bandejas, en 360, 390 y 412 px.
  static const solape = SiscanSpace.s8;
  /// Alto total de la escena, barra de estado incluida. Con `xMaxYMax` y recorte, la escala es alto/600 y se ve el
  /// lienzo desde x = 1200 − 600·ancho/alto; con alto = 0,9375 × ancho se ve desde x = 560, así el secador entra
  /// entero con 40 u de pasto a su izquierda.
  static double escena(double ancho) => ancho * .9375;
}

/// La escena, el saludo, la campana y la tarjeta del lote. `momento` solo se fija en pruebas; en la app sigue la
/// fuente única [RelojDelDia] (la misma del tema «Según la hora»). Sin `base` (cargando o error) se ven la escena y el
/// saludo, sin tarjeta; sin lote, tampoco hay tarjeta (el estado vacío va debajo, en el cuerpo de Inicio).
class CabeceraInicio extends StatelessWidget {
  const CabeceraInicio({super.key, required this.base, required this.saludo, required this.subtitulo, required this.alertas, required this.onAlertas, this.momento});
  final Base? base;
  final String saludo, subtitulo;
  final int alertas;
  final VoidCallback onAlertas;
  final Momento? momento;

  @override
  Widget build(BuildContext context) {
    if (momento != null) return _dibujar(context, momento!);
    final reloj = Siscan.of(context).tema.reloj;
    return ListenableBuilder(listenable: reloj, builder: (context, _) => _dibujar(context, reloj.momento));
  }

  Widget _dibujar(BuildContext context, Momento m) {
    final b = base;
    final arriba = MediaQuery.paddingOf(context).top;
    final noche = m == Momento.noche;
    // `aire`: hay ventilador encendido con lote activo; `calor`: hay resistencia encendida. Con el dato viejo (el secador
    // no reporta o es la copia guardada del teléfono) no se sabe si el equipo sigue así: la escena queda sin aire ni calor.
    final viejo = b == null || b.estado.$1 == Estado.offline;
    final on = (viejo ? const <J>[] : b.actuadores).where((a) => a['status'] == 'ON');
    final aire = b?.activo != null && on.any((a) => a['type'] != 'HEATER');
    final calor = on.any((a) => a['type'] == 'HEATER');
    return LayoutBuilder(builder: (context, caja) {
      final ancho = caja.maxWidth;
      final alto = MedidasCabecera.escena(ancho);
      // La banda de cielo toma los tokens del tema que corresponde a la luz de la escena: así el texto, la campana y el
      // contador se leen sobre el cielo aunque la persona haya fijado el tema contrario.
      final cielo = Theme(
        data: siscanTheme(noche ? Brightness.dark : Brightness.light),
        child: Builder(builder: (context) {
          final c = context.c;
          return Padding(
            padding: EdgeInsets.fromLTRB(MedidasCabecera.margen, arriba + SiscanSpace.s2, MedidasCabecera.margen, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: SiscanSize.toque, child: Row(children: [
                Padding(padding: const EdgeInsets.only(left: 6), child: Logo(claro: noche, alto: 30)),
                const Spacer(),
                // Sobre la escena la campana va en tinta (enmienda del 2026-10-15): en tinta-suave daba 3,08:1 al atardecer.
                BotonIcono(icono: 'alertas', etiqueta: 'Alertas', cuenta: alertas, oscuro: noche, colorIcono: c.tinta, onPressed: onAlertas),
              ])),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, SiscanSpace.s2, 6, 0),
                // Cada texto en su propio nodo: el lector de pantalla lee logo, campana, saludo, subtítulo y tarjeta en ese
                // orden (sin esto, el subtítulo se fundía con la tarjeta en un nodo que se leía antes que el saludo).
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Semantics(container: true, header: true, child: Text(saludo, style: SiscanType.saludo.copyWith(color: c.tinta))),
                  Semantics(container: true, child: Text(subtitulo, maxLines: 2, overflow: TextOverflow.ellipsis, style: SiscanType.apoyo.copyWith(fontWeight: FontWeight.w600, color: c.tinta))),
                ]),
              ),
            ]),
          );
        }),
      );
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: noche ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Stack(clipBehavior: Clip.none, children: [
          // A sangre: sin margen lateral y detrás de la barra de estado. Anclada abajo a la derecha, sobre el secador.
          Positioned(left: 0, top: 0, right: 0, height: alto,
              child: Paisaje(variante: m.variante, aire: aire, calor: calor, alineacion: Alignment.bottomRight)),
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(height: alto - MedidasCabecera.solape, child: Align(alignment: Alignment.topLeft, child: cielo)),
            // Sin tarjeta (cargando, error, sin lote), nada pisa la escena: lo de abajo empieza donde ella termina.
            if (b?.lote == null) const SizedBox(height: MedidasCabecera.solape),
            if (b?.lote != null) Padding(
              padding: const EdgeInsets.symmetric(horizontal: MedidasCabecera.margen),
              child: Semantics(container: true, child: TarjetaLoteVidrio(b: b!)),
            ),
          ]),
        ]),
      );
    });
  }
}

/// La tarjeta de vidrio del lote (sc-bhero-card): superficie al 86 %, borde blanco al 60 % (8 % en oscuro), radio
/// lg, desenfoque 14 detrás. Desde E8 (2026-10-15, enmienda a C1 aprobada por Diego) lleva la composición de
/// ActiveBatchHero de la web: lote y estado, la cifra grande (.sc-bhero-v .sc-read: Outfit 52/56, 750, −0,03 em; «%» a
/// 22/700 en tinta-suave), «Objetivo 10 – 12 % · faltan ~X» y la barra de avance (sc-progress) en lugar del anillo.
class TarjetaLoteVidrio extends StatelessWidget {
  const TarjetaLoteVidrio({super.key, required this.b});
  final Base b;
  @override
  Widget build(BuildContext context) {
    final c = context.c, lote = b.lote!, s = Siscan.of(context);
    final hum = (lote['lastMoisturePct'] as num?)?.toDouble();
    final activo = lote['status'] == 'RUNNING';
    final radio = BorderRadius.circular(SiscanRadius.lg);
    final apoyo = SiscanType.apoyo.copyWith(color: c.tintaSuave);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radio, boxShadow: context.sombraTarjeta),
      child: ClipRRect(
        borderRadius: radio,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(SiscanSpace.s5),
            decoration: BoxDecoration(
              color: c.superficie.withValues(alpha: .86),
              borderRadius: radio,
              border: Border.all(color: Colors.white.withValues(alpha: context.oscuro ? .08 : .60)),
            ),
            child: Pedido<J>(
              clave: '${lote['id']}-${lote['sampleCount']}',
              cargar: () => s.api.prediccion(lote['id'] as int),
              builder: (context, p, e, cargando) {
                final enCurso = p?['estado'] == 'EN_CURSO';
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Wrap(spacing: SiscanSpace.s2, runSpacing: 6, children: [
                    Ficha('${lote['name']}', icono: 'lotes'),
                    Pildora(estado: activo ? Estado.running : Estado.paused, vivo: activo, texto: activo ? 'Secando' : 'Terminado'),
                  ]),
                  const SizedBox(height: SiscanSpace.s3),
                  // Un solo nodo para el lector: «Humedad del grano 10,6 %».
                  Semantics(
                    container: true, label: 'Humedad del grano ${hum == null ? 'sin dato' : '${cifra(hum)} %'}',
                    child: ExcludeSemantics(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Humedad del grano', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.tintaSuave)),
                      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                        Text(hum == null ? '—' : cifra(hum), style: TextStyle(fontFamily: SiscanType.display, fontSize: 52, height: 56 / 52,
                            fontWeight: FontWeight.w700, letterSpacing: -1.56, color: c.tinta, fontFeatures: const [FontFeature.tabularFigures()])),
                        const SizedBox(width: SiscanSpace.s1),
                        Text('%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: c.tintaSuave)),
                      ]),
                    ])),
                  ),
                  Text.rich(TextSpan(style: apoyo, children: [
                    const TextSpan(text: 'Objetivo 10 – 12 % · '),
                    if (e != null) const TextSpan(text: 'predicción no disponible')
                    else if (enCurso) TextSpan(text: 'faltan ~${duracion(p!['horasRestantes'] as num?)}', style: TextStyle(fontWeight: FontWeight.w700, color: c.hoja))
                    else TextSpan(text: textoPrediccion(p, enCurso: activo)),
                  ])),
                  // Paso 6: de cuándo es la cifra (sc-bhero-meta). La humedad sale del último pesaje, no del ESP32.
                  if (lote['lastSampleAt'] != null) Padding(padding: const EdgeInsets.only(top: SiscanSpace.s1), child: Row(children: [
                    Icono('balanza', size: 14, color: c.tintaSuave), const SizedBox(width: 5),
                    Expanded(child: Text('Último pesaje ${corta(fecha(lote['lastSampleAt']))}',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.tintaSuave))),
                  ])),
                  const SizedBox(height: SiscanSpace.s3),
                  Progreso(valor: avanceLote(lote), etiqueta: 'Avance hacia el objetivo'),
                  if (enCurso && p!['confianza'] != null) ...[
                    const SizedBox(height: SiscanSpace.s3),
                    Row(children: [Icono('ia', size: 14, color: c.prediccion), const SizedBox(width: 5),
                      Text('Confianza ${(p['confianza'] as num) >= 75 ? 'alta' : (p['confianza'] as num) >= 50 ? 'media' : 'baja'}',
                          style: SiscanType.apoyo.copyWith(fontWeight: FontWeight.w700, color: c.prediccion))]),
                  ],
                ]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
