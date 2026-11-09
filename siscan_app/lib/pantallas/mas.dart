import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/comun.dart';
import '../app/contexto.dart';
import '../app/preferencias.dart';
import '../core/formato.dart' show leerCifra, separadores;
import '../core/theme/siscan_theme.dart';
import '../core/theme/siscan_tokens.dart';
import '../core/ui/base.dart';
import '../core/ui/datos.dart';
import '../core/ui/dominio.dart';
import '../core/ui/marco.dart';
import '../data/estado.dart';
import '../l10n/app_localizations.dart';

/// Más (AndroidMas): perfil, calibración, mapa, historial, ubicación, reloj, notificaciones, huella, tema y sesión.
class PantallaMas extends StatelessWidget {
  const PantallaMas({super.key, required this.onIngresar});
  final VoidCallback onIngresar;
  void _ir(BuildContext context, Widget p) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => p));
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context), pref = Preferencias.of(context);
    return ListenableBuilder(listenable: Listenable.merge([s.auth, s.tema, s.idioma, pref]), builder: (context, _) => ConEstado(builder: (context, b) {
      final ses = s.auth.session, t = AppLocalizations.of(context);
      final temaTxt = switch (s.tema.preferencia) { PreferenciaTema.claro => t.temaClaro, PreferenciaTema.oscuro => t.temaOscuro, PreferenciaTema.hora => t.temaHora, PreferenciaTema.sistema => t.temaComoElTelefono };
      return CuerpoPantalla(
        barra: BarraApp(oscura: true, grande: true, logo: true, titulo: ses?.displayName ?? t.masVistaPublica,
            subtitulo: ses == null ? t.masSinCuenta : ses.canControl ? t.masSesionGestor(ses.user) : t.masSesionSinPermiso(ses.user)),
        hijos: [
          Tarjeta(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: [
            ElementoLista(icono: 'calibracion', titulo: t.masCalibracion, sub: t.masCalibracionSub, onTap: () => s.cabecera == null ? onIngresar() : _ir(context, const PantallaCalibracion())),
            ElementoLista(icono: 'mapa', titulo: t.masMapa, sub: t.masMapaSub(b?.secadores.length ?? 0), onTap: () => _ir(context, const PantallaMapa())),
            ElementoLista(icono: 'historial', titulo: t.masHistorial, sub: t.masHistorialSub, onTap: () => _ir(context, const PantallaHistorial())),
            ElementoLista(icono: 'ubicar', titulo: t.masUbicacion, sub: '${b?.sitio ?? '—'} · ${b?.secador?['locationLocked'] == true ? t.masUbicacionFijada : t.masUbicacionPorIp}',
                onTap: () => s.cabecera == null ? onIngresar() : _ir(context, const PantallaUbicacion())),
            ElementoLista(icono: 'reloj2', titulo: t.masReloj, sub: t.masRelojSub, ultimo: true, onTap: () => _ir(context, const PantallaReloj())),
          ])),
          Tarjeta(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: [
            ElementoLista(icono: 'alertas', titulo: t.masNotificaciones, sub: t.masNotificacionesSub,
                derecha: Interruptor(valor: pref.notificaciones, etiqueta: t.masNotificaciones, onChanged: (v) => pref.cambiarNotificaciones(context, v))),
            ElementoLista(icono: 'huella', titulo: t.masHuella, sub: ses == null ? t.masHuellaSinCuenta : t.masHuellaSub,
                derecha: Interruptor(valor: pref.huella, etiqueta: t.masHuella, onChanged: ses == null ? null : (v) => pref.cambiarHuella(context, v))),
            ElementoLista(icono: 'sol', titulo: t.masTema, sub: temaTxt, onTap: () => _elegirTema(context)),
            // Idioma (anexo de idiomas, I1): el actual en su propio nombre; con «Como el teléfono», además el que resulta.
            ElementoLista(icono: 'idiomas', titulo: t.idioma,
                sub: s.idioma.preferencia == PreferenciaIdioma.sistema
                    ? '${t.idiomaComoElTelefono} · ${PreferenciaIdioma.deCodigo(Localizations.localeOf(context).languageCode).nombre}'
                    : s.idioma.preferencia.nombre,
                onTap: () => _elegirIdioma(context)),
            ElementoLista(icono: 'info', titulo: t.masAcerca, sub: t.masAcercaSub, onTap: () => _ir(context, const PantallaLicencias())),
            ElementoLista(icono: 'candado', titulo: t.masPrivacidad, sub: t.masPrivacidadSub, onTap: () => _ir(context, const PantallaPrivacidad())),
            ses == null ? ElementoLista(icono: 'usuario', titulo: t.masIngresar, sub: t.masIngresarSub, ultimo: true, onTap: onIngresar)
                : ElementoLista(icono: 'salir', titulo: t.masCerrarSesion, peligro: true, ultimo: true, onTap: () async { await s.auth.signOut(); if (context.mounted) await pref.cambiarHuella(context, false); }),
          ])),
        ],
      );
    }));
  }

  /// I1: los idiomas en su propio nombre, con un saludo de muestra; sin banderas. Elegir aplica al instante y cierra.
  Future<void> _elegirIdioma(BuildContext context) async {
    final s = Siscan.of(context);
    final telefono = await s.idioma.delTelefono();
    if (!context.mounted) return;
    final m = await showModalBottomSheet<PreferenciaIdioma>(context: context, backgroundColor: context.c.superficie,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(SiscanRadius.xl))),
        builder: (d) {
          final t = AppLocalizations.of(d);
          return SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(22, 18, 22, 12), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Semantics(header: true, child: Text(t.idioma, style: TextStyle(fontFamily: SiscanType.display, fontSize: 22, fontWeight: FontWeight.w700, color: d.c.tinta))),
            const SizedBox(height: 4),
            ListaOpcionUnica<PreferenciaIdioma>(valor: s.idioma.preferencia, onChanged: (v) => Navigator.pop(d, v), opciones: [
              for (final p in const [PreferenciaIdioma.es, PreferenciaIdioma.en, PreferenciaIdioma.pt]) (p, null, p.nombre, p.saludo),
              (PreferenciaIdioma.sistema, null, t.idiomaComoElTelefono, t.idiomaAhora(telefono.nombre)),
            ]),
            const SizedBox(height: 12),
          ])));
        });
    if (m != null) await s.idioma.cambiar(m);
  }

  Future<void> _elegirTema(BuildContext context) async {
    final s = Siscan.of(context);
    final m = await showModalBottomSheet<PreferenciaTema>(context: context, backgroundColor: context.c.superficie,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(SiscanRadius.xl))),
        builder: (d) { final t = AppLocalizations.of(d); return SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(22, 18, 22, 12), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Semantics(header: true, child: Text(t.masTema, style: TextStyle(fontFamily: SiscanType.display, fontSize: 22, fontWeight: FontWeight.w700, color: d.c.tinta))),
          const SizedBox(height: 4),
          // C3: cuatro opciones no caben en el segmentado de 390 px; van como lista de opción única.
          ListaOpcionUnica<PreferenciaTema>(valor: s.tema.preferencia, onChanged: (v) => Navigator.pop(d, v), opciones: [
            (PreferenciaTema.claro, 'sol', t.temaClaro, t.temaClaroSub),
            (PreferenciaTema.oscuro, 'luna', t.temaOscuro, t.temaOscuroSub),
            (PreferenciaTema.hora, 'reloj', t.temaHora, t.temaHoraSub),
            (PreferenciaTema.sistema, 'config', t.temaComoElTelefono, t.temaSistemaSub),
          ]),
          const SizedBox(height: 12),
        ]))); });
    if (m != null) s.tema.cambiar(m);
  }
}

/// Calibración (AndroidMas › Calibración): Gravimet (Cenicafé, puntos medidos) y corrección de sensores.
class PantallaCalibracion extends StatefulWidget {
  const PantallaCalibracion({super.key});
  @override
  State<PantallaCalibracion> createState() => _PantallaCalibracionState();
}

class _PantallaCalibracionState extends State<PantallaCalibracion> {
  String _vista = 'g';
  bool _cenicafe = false;
  final _medidor = TextEditingController(), _peso = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context), c = context.c, t = AppLocalizations.of(context);
    return Scaffold(body: ConEstado(builder: (context, b) {
      final barra = BarraApp(titulo: t.masCalibracion, atras: true);
      final l = b?.activo ?? b?.lote;
      return CuerpoPantalla(barra: barra, hijos: [
        Segmentado<String>(bloque: true, etiqueta: t.calQueCalibrar, valor: _vista, onChanged: (v) => setState(() => _vista = v), opciones: [('g', 'Gravimet', 'balanza'), ('s', t.calSensores, 'calibracion')]),
        if (_vista == 'g') l == null ? EstadoVacio(titulo: t.calSinLotes, texto: t.calSinLotesTexto) : Pedido<J>(
          clave: '${l['id']}-${l['sampleCount']}-${b!.cargadoEn.millisecondsSinceEpoch ~/ 60000}',
          cargar: () => s.api.calibracion(l['id'] as int),
          builder: (context, cal, e, cargando) {
            final puntos = ((cal?['points'] as List?) ?? const []).cast<J>();
            if (_peso.text.isEmpty && l['lastSampleWeightGrams'] != null) _peso.text = cifra(l['lastSampleWeightGrams'] as num);
            return Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TituloTarjeta(icono: 'balanza', titulo: t.calForma('${l['name']}'), derecha: Ficha(cal?['source'] == 'MEASURED' ? t.calConPuntos : 'Cenicafé', icono: 'check')),
              Casilla(valor: _cenicafe, onChanged: (v) => setState(() => _cenicafe = v), texto: t.calReferencia),
              if (!_cenicafe) ...[
                const SizedBox(height: 8),
                Campo(etiqueta: t.calLecturaMedidor, controller: _medidor, sufijo: '%', teclado: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 12),
                Campo(etiqueta: t.calPesoMuestra, controller: _peso, sufijo: 'g', pista: t.calPesoPista, teclado: const TextInputType.numberWithOptions(decimal: true)),
              ],
              const SizedBox(height: 16),
              Boton(t.calCalibrar, variante: VarianteBoton.primary, bloque: true, onPressed: () async {
                final id = l['id'] as int;
                if (_cenicafe) {
                  await s.hacer(context, (h) => s.api.referenciaCenicafe(id, false, h), t.calReferenciaAplicada);
                  return;
                }
                final hm = double.tryParse(_medidor.text.replaceAll(',', '.')), g = leerCifra(_peso.text);
                if (hm == null || hm < 0 || hm >= 100 || g == null || g <= 0) { aviso(context, t.calErrorDatos, error: true); return; }
                await s.hacer(context, (h) => s.api.puntoMedido(id, g, hm, h), t.calPuntoAgregado, detalle: t.calLoteRecalculado);
              }),
              if (puntos.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(t.calPuntosMedidos, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.tinta)),
                for (final q in puntos) Padding(padding: const EdgeInsets.only(top: 8), child: Text(t.calPunto(corta(fecha(q['timestamp'])), cifra(q['sampleWeightGrams'] as num), cifra(q['referenceMoisturePct'] as num)),
                    style: TextStyle(fontSize: 13, color: c.tintaSuave))),
              ],
            ]));
          },
        )
        else Pedido<J>(
          clave: 'sensores-${b?.cargadoEn.millisecondsSinceEpoch}',
          cargar: s.api.calibracionSensores,
          builder: (context, d, e, cargando) {
            final filas = ((d?['calibrations'] as List?) ?? const []).cast<J>().where((x) => x['lastRaw'] != null || x['calibrated'] == true).toList();
            return Tarjeta(child: Column(children: [
              TituloTarjeta(icono: 'calibracion', titulo: t.calSensores),
              if (d == null) Cargando(texto: t.calCargandoSensores),
              for (final (i, x) in filas.indexed) () {
                final m = magnitud(x['key'] as String);
                return InkWell(onTap: () => _ajustar(x), child: FilaSensor(nombre: m.nombre, meta: t.calGanancia(cifra(x['gain'] as num, 3), cifra(x['offset'] as num, 2)),
                    valor: x['lastCalibrated'] != null ? '${cifra(x['lastCalibrated'] as num, m.dec)} ${x['unit']}' : '—', icono: m.icono, color: tono(c, m.tono),
                    estado: x['calibrated'] == true ? Estado.running : Estado.paused, estadoTexto: x['calibrated'] == true ? t.calCalibrado : t.calSinCalibrar, ultima: i == filas.length - 1, pildoraAbajo: true));
              }(),
              Pie(t.calPie),
            ]));
          },
        ),
      ]);
    }));
  }

  Future<void> _ajustar(J x) async {
    final s = Siscan.of(context), real = TextEditingController(), t = AppLocalizations.of(context);
    final m = magnitud(x['key'] as String);
    final v = await showDialog<double>(context: context, builder: (d) => AlertDialog(
      title: Text(t.calCorregir(m.nombre)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.calLecturaActual(cifra(x['lastRaw'] as num?, 2), '${x['unit']}')), const SizedBox(height: 12),
        Campo(etiqueta: t.calValorReal('${x['unit']}'), controller: real, teclado: const TextInputType.numberWithOptions(decimal: true, signed: true)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(d), child: Text(t.cancelar)), TextButton(onPressed: () => Navigator.pop(d, double.tryParse(real.text.replaceAll(',', '.'))), child: Text(t.calAplicar))],
    ));
    if (v == null || x['lastRaw'] == null || !mounted) return;
    final gain = (x['gain'] as num?)?.toDouble() ?? 1;
    await s.hacer(context, (h) => s.api.corregirSensor(x['key'] as String, gain, v - (x['lastRaw'] as num).toDouble() * gain, false, h), t.calCalibradoSensor(m.nombre));
  }
}

/// Mapa (AndroidMas › Mapa): mapa esquemático, leyenda y la foto del secador.
class PantallaMapa extends StatelessWidget {
  const PantallaMapa({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: ConEstado(builder: (context, b) {
        final t = AppLocalizations.of(context);
        final barra = BarraApp(titulo: t.mapaTitulo, atras: true);
        if (b == null) return CuerpoPantalla(barra: barra, hijos: [Cargando()]);
        final (pines, cuenta) = pinesDe(b);
        final g = b.secador, c = context.c;
        return CuerpoPantalla(barra: barra, hijos: [
          MapaSecadores(pines: pines, alto: 240),
          LeyendaEstados(cuenta: cuenta),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: c.superficie, border: Border.all(color: c.linea), borderRadius: BorderRadius.circular(SiscanRadius.lg), boxShadow: context.sombraTarjeta),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(height: 170, child: Stack(fit: StackFit.expand, children: [
                g?['photoUrl'] != null ? Image.network(g!['photoUrl'] as String, fit: BoxFit.cover, semanticLabel: t.mapaFotoDe(b.nombreSecador), errorBuilder: (_, _, _) => const Paisaje(encuadre: 'foto', variante: 'day'))
                    : const Paisaje(encuadre: 'foto', variante: 'day'),
                Positioned(left: 12, top: 12, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(color: context.oscuro ? const Color(0x8C0E1A14) : Colors.white.withValues(alpha: .7), borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Icono('camara', size: 14, color: context.oscuro ? c.sobreBosque : c.bosque), const SizedBox(width: 7),
                    Text(g?['photoUrl'] != null ? t.mapaFoto : t.mapaSinFoto, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.oscuro ? c.sobreBosque : c.bosque))]))),
              ])),
              Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${b.nombreSecador} · ${b.sitio}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.tinta)),
                Text(g?['latitude'] != null ? '${cifra(g!['latitude'] as num, 4)} · ${cifra(g['longitude'] as num, 4)}' : t.mapaSinCoordenadas, style: TextStyle(fontSize: 12.5, color: c.tintaSuave)),
              ])),
            ]),
          ),
        ]);
      }));
}

/// Historial del equipo: órdenes y energía solar/red (24 h o 7 días).
class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({super.key});
  @override
  State<PantallaHistorial> createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> {
  int _horas = 24;
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context), t = AppLocalizations.of(context);
    final origen = {'WEB': t.histOrigenPanel, 'APP': t.histOrigenApp, 'WATCH': t.histOrigenReloj, 'ESP32': t.histOrigenEsp32, 'AUTO': t.histOrigenProtocolo, 'PROTOCOL': t.histOrigenProtocolo};
    return Scaffold(body: CuerpoPantalla(barra: BarraApp(titulo: t.masHistorial, atras: true), hijos: [
      Segmentado<int>(bloque: true, etiqueta: t.histPeriodo, valor: _horas, onChanged: (v) => setState(() => _horas = v), opciones: [(24, t.hist24h, null), (168, t.hist7d, null)]),
      Pedido<J>(
        clave: _horas, cargar: () => s.api.energia(horas: _horas),
        builder: (context, e, err, cargando) => e == null
            ? (err != null ? ErrorCarga(detalle: '$err', onReintentar: () => setState(() {})) : Cargando(texto: t.histCalculando))
            : TarjetaEnergia(titulo: _horas == 24 ? t.histEnergia24h : t.histEnergia7d, solar: (e['solarKwh'] as num?)?.toDouble(), red: (e['redKwh'] as num?)?.toDouble(),
                costo: (e['costoRedCOP'] as num?)?.toDouble(), tarifa: (e['tarifaCOPkWh'] as num?)?.toDouble(),
                barras: [for (final x in (e['barras'] as List).cast<J>()) (x['label'] as String, (x['solar'] as num? ?? 0).toDouble(), (x['grid'] as num? ?? 0).toDouble())],
                derecha: Ficha(e['redKwh'] == null ? t.histRedSinLecturas : t.histEstimado, tono: 'neutral'), nota: t.histNota('${e['fuenteSolar']}', '${e['fuenteRed']}')),
      ),
      Pedido<List<J>>(
        clave: 'ordenes', cargar: () => s.api.ordenes(limite: 100),
        builder: (context, o, err, cargando) => Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TituloTarjeta(icono: 'historial', titulo: t.histOrdenes),
          if (o == null) Cargando(texto: t.histCargandoOrdenes)
          else RegistroOrdenes(items: [for (final x in o) (dia(fecha(x['timestamp'])), '${x['name']} · ${x['status'] == 'ON' ? t.histEncender : t.histApagar}', '${origen[x['source']] ?? x['source'] ?? t.histOrigenSinRegistro} · ${hm(fecha(x['timestamp'])!)}')]),
        ])),
      ),
    ]));
  }
}

/// Ubicación del secador (LocationCard): coordenadas, sitio, bloqueo y «Usar mi ubicación actual».
class PantallaUbicacion extends StatefulWidget {
  const PantallaUbicacion({super.key});
  @override
  State<PantallaUbicacion> createState() => _PantallaUbicacionState();
}

class _PantallaUbicacionState extends State<PantallaUbicacion> {
  final _lat = TextEditingController(), _lon = TextEditingController(), _sitio = TextEditingController();
  bool _bloq = true, _listo = false, _gps = false;
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context), t = AppLocalizations.of(context);
    final g = s.estado.base?.secador;
    if (!_listo && g != null) {
      // I5: la coordenada con el separador decimal del idioma (sin separador de miles: nunca pasa de 180).
      _lat.text = g['latitude'] != null ? (g['latitude'] as num).toStringAsFixed(5).replaceAll('.', separadores.$1) : '';
      _lon.text = g['longitude'] != null ? (g['longitude'] as num).toStringAsFixed(5).replaceAll('.', separadores.$1) : '';
      _sitio.text = g['locationLabel'] as String? ?? '';
      _bloq = g['locationLocked'] == true;
      _listo = true;
    }
    return Scaffold(body: CuerpoPantalla(barra: BarraApp(titulo: t.masUbicacion, atras: true), hijos: [
      Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TituloTarjeta(icono: 'ubicar', titulo: t.ubicTarjeta, derecha: Ficha(_bloq ? t.ubicFijada : t.ubicPorIp, tono: 'neutral', icono: _bloq ? 'candado' : 'wifi')),
        Row(children: [Expanded(child: Campo(etiqueta: t.ubicLatitud, controller: _lat, teclado: const TextInputType.numberWithOptions(decimal: true, signed: true))), const SizedBox(width: 12),
          Expanded(child: Campo(etiqueta: t.ubicLongitud, controller: _lon, teclado: const TextInputType.numberWithOptions(decimal: true, signed: true)))]),
        const SizedBox(height: 14),
        Campo(etiqueta: t.ubicSitio, controller: _sitio),
        const SizedBox(height: 8),
        Casilla(valor: _bloq, onChanged: (v) => setState(() => _bloq = v), texto: t.ubicBloquear),
        const SizedBox(height: 12),
        Boton(t.ubicUsarMia, icono: 'ubicar', ocupado: _gps, onPressed: () async {
          setState(() => _gps = true);
          try {
            var p = await Geolocator.checkPermission();
            if (p == LocationPermission.denied && context.mounted) {
              // Divulgación destacada antes del permiso de Android (política de datos v0.2 · Ubicación).
              final ok = await showDialog<bool>(context: context, builder: (d) => AlertDialog(
                title: Text(t.masUbicacion),
                content: Text(t.ubicDivulgacion),
                actions: [TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.ubicAhoraNo)), TextButton(onPressed: () => Navigator.pop(d, true), child: Text(t.ubicContinuar))],
              ));
              if (ok != true) { if (mounted) setState(() => _gps = false); return; }
              p = await Geolocator.requestPermission();
            }
            if (p == LocationPermission.denied || p == LocationPermission.deniedForever) throw Exception();
            final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)));
            _lat.text = pos.latitude.toStringAsFixed(5).replaceAll('.', separadores.$1);
            _lon.text = pos.longitude.toStringAsFixed(5).replaceAll('.', separadores.$1);
            if (context.mounted) aviso(context, t.ubicTomada, detalle: t.ubicRevisaGuarda);
          } catch (_) {
            if (context.mounted) aviso(context, t.ubicError, error: true);
          }
          if (mounted) setState(() => _gps = false);
        }),
        const SizedBox(height: 8),
        Boton(t.ubicGuardar, variante: VarianteBoton.primary, onPressed: () async {
          final la = double.tryParse(_lat.text.replaceAll(',', '.').replaceAll('−', '-')), lo = double.tryParse(_lon.text.replaceAll(',', '.').replaceAll('−', '-'));
          if (la == null || lo == null || la.abs() > 90 || lo.abs() > 180) { aviso(context, t.ubicRevisaCoordenadas, error: true); return; }
          await s.hacer(context, (h) => s.api.ubicacion(la, lo, _bloq, _sitio.text.trim(), h), t.ubicGuardada, detalle: t.ubicGuardadaDetalle);
        }),
        Pie(t.ubicPie),
      ])),
    ]));
  }
}

/// Reloj inteligente: qué hace SISCAN en Wear OS y cómo se instala.
class PantallaReloj extends StatelessWidget {
  const PantallaReloj({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(body: CuerpoPantalla(barra: BarraApp(titulo: t.masReloj, atras: true), hijos: [
        Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TituloTarjeta(icono: 'reloj2', titulo: t.relojTarjeta),
          Text(t.relojTexto, style: TextStyle(fontSize: 14, height: 22 / 14, color: context.c.tinta)),
          Pie(t.relojPie),
        ])),
      ]));
  }
}

/// Tus datos y privacidad (borrador técnico; docs/legal/politica-datos-app-siscan.md): política, exportar y borrar.
/// Acerca de y licencias (E9, 2026-10-15): el aviso de Lucide (íconos del sistema y «luna») se muestra completo, tal
/// como exige su licencia ISC, y está también en el registro de licencias de Flutter (main.dart), con el resto del
/// software de terceros.
class PantallaLicencias extends StatelessWidget {
  const PantallaLicencias({super.key});
  static const archivo = 'assets/sistema/iconos/LICENCIA-lucide.txt';
  @override
  Widget build(BuildContext context) {
    final c = context.c, t = AppLocalizations.of(context);
    return Scaffold(body: CuerpoPantalla(barra: BarraApp(titulo: t.masAcerca, atras: true), hijos: [
      Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TituloTarjeta(icono: 'info', titulo: t.licIconos),
        Text(t.licIconosTexto,
            style: TextStyle(fontSize: 14, height: 22 / 14, color: c.tinta)),
        const SizedBox(height: 12),
        FutureBuilder<String>(
          future: rootBundle.loadString(archivo),
          builder: (context, a) => a.hasData
              ? SelectableText(a.data!, style: TextStyle(fontSize: 12.5, height: 19 / 12.5, color: c.tintaSuave))
              : Text(a.hasError ? t.licErrorAviso : t.cargando, style: TextStyle(fontSize: 12.5, color: c.tintaSuave)),
        ),
      ])),
      Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TituloTarjeta(icono: 'config', titulo: t.licTerceros),
        Text(t.licTercerosTexto, style: TextStyle(fontSize: 14, height: 22 / 14, color: c.tinta)),
        const SizedBox(height: 12),
        Boton(t.licVerTodas, icono: 'chevron', onPressed: () => showLicensePage(context: context, applicationName: 'SISCAN')),
      ])),
    ]));
  }
}

class PantallaPrivacidad extends StatelessWidget {
  const PantallaPrivacidad({super.key});
  static const version = '0.2 · 8 de octubre de 2026 (borrador para revisión de un abogado)';
  static const secciones = <(String, String)>[
    ('Qué guarda la app', 'El último estado del secador (lecturas, lote, equipo y alertas) para mostrarlo sin señal; no son datos personales. '
        'Si ingresas como Gestor del Secador, tu usuario y tu contraseña de aplicación, cifrados en el almacén seguro del teléfono, para enviar órdenes y registrar pesajes. '
        'Tu elección de tema, notificaciones y huella.'),
    ('Huella', 'Si la activas, el teléfono verifica tu huella con su propio sensor; la app nunca recibe ni guarda la huella. Solo desbloquea la credencial cifrada.'),
    ('Ubicación', 'Solo cuando un administrador toca «Usar mi ubicación actual» para fijar el sitio del secador. Se envía al servidor del CISNA como ubicación del secador, no de la persona. No se guarda en el teléfono ni se usa en segundo plano.'),
    ('Notificaciones', 'Si las activas, la app consulta cada 15 minutos el servidor del CISNA para avisar alertas, hora de pesar y lote listo. Solo lee el estado del secador.'),
    ('Reloj inteligente', 'Si ingresas con «Recordarme», el teléfono guarda la cabecera de tu sesión cifrada con una llave del Android Keystore para que SISCAN en el reloj pueda pedirle órdenes y pesajes. El reloj no guarda contraseñas. Se borra al cerrar sesión o al borrar los datos del teléfono.'),
    ('Inteligencia artificial', 'La «segunda opinión» la genera Groq desde el servidor del CISNA con datos del lote y del secador; no recibe datos personales. La predicción de la tesis y la red neuronal corren en el servidor del CISNA.'),
    ('Qué no hace', 'No usa cámara ni contactos. No tiene publicidad, analítica ni rastreo. Solo habla con cisna.narino.gov.co por HTTPS.'),
    ('Cuánto tiempo', 'Hasta que cierres sesión (borra la credencial), uses «Borrar los datos de este teléfono» o desinstales la app.'),
    ('Tus derechos', 'Conocer, actualizar, rectificar y suprimir tus datos y revocar la autorización (Ley 1581 de 2012 y Decreto 1377 de 2013, compilado en el Decreto 1074 de 2015). '
        'La contraseña de aplicación también se puede revocar en tu perfil de WordPress.'),
    ('Responsable', 'Proyecto SISCAN — Secado Inteligente de Café, Gobernación de Nariño (CISNA). Contacto: pendiente de definir por el CISNA.'),
  ];
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context), c = context.c, t = AppLocalizations.of(context);
    return Scaffold(body: CuerpoPantalla(barra: BarraApp(titulo: t.privTitulo, atras: true), hijos: [
      Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TituloTarjeta(icono: 'candado', titulo: t.privPolitica),
        // El texto de la política (versión y secciones) pasa a los tres idiomas en el paso 5 del anexo de idiomas.
        Text('Versión $version', style: TextStyle(fontSize: 12.5, color: c.tintaSuave)),
        for (final (titulo, x) in secciones) ...[
          const SizedBox(height: 16),
          Text(titulo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.tinta)),
          const SizedBox(height: 4),
          Text(x, style: TextStyle(fontSize: 14, height: 22 / 14, color: c.tinta)),
        ],
      ])),
      Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TituloTarjeta(icono: 'usuario', titulo: t.privDerechos),
        if (s.auth.session != null) Boton(t.privRevocar, icono: 'candado', onPressed: () => launchUrl(Uri.parse('${s.auth.site}/wp-admin/profile.php#application-passwords-section'), mode: LaunchMode.externalApplication)),
        const SizedBox(height: 8),
        Boton(t.privBorrar, icono: 'borrar', variante: VarianteBoton.danger, onPressed: () async {
          final ok = await showDialog<bool>(context: context, builder: (d) => AlertDialog(title: Text(t.privBorrar),
              content: Text(t.privBorrarTexto),
              actions: [TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.cancelar)), TextButton(onPressed: () => Navigator.pop(d, true), child: Text(t.privBorrarConfirmar))]));
          if (ok != true || !context.mounted) return;
          await s.auth.signOut();
          await EstadoSecador.borrarCopia();
          if (context.mounted) await Preferencias.of(context).borrarTodo(context);
          if (context.mounted) await Siscan.of(context).idioma.olvidar();
          if (context.mounted) aviso(context, t.privBorrados);
        }),
      ])),
    ]));
  }
}
