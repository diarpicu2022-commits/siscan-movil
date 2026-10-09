import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/comun.dart';
import '../app/contexto.dart';
import '../app/preferencias.dart';
import '../core/theme/siscan_theme.dart';
import '../core/theme/siscan_tokens.dart';
import '../core/ui/base.dart';
import '../core/ui/datos.dart';
import '../core/ui/dominio.dart';
import '../core/ui/marco.dart';
import '../data/estado.dart';

/// Más (AndroidMas): perfil, calibración, mapa, historial, ubicación, reloj, notificaciones, huella, tema y sesión.
class PantallaMas extends StatelessWidget {
  const PantallaMas({super.key, required this.onIngresar});
  final VoidCallback onIngresar;
  void _ir(BuildContext context, Widget p) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => p));
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context), pref = Preferencias.of(context);
    return ListenableBuilder(listenable: Listenable.merge([s.auth, s.tema, pref]), builder: (context, _) => ConEstado(builder: (context, b) {
      final ses = s.auth.session;
      final temaTxt = switch (s.tema.modo) { ThemeMode.light => 'Claro', ThemeMode.dark => 'Oscuro', _ => 'Como el teléfono' };
      return CuerpoPantalla(
        barra: BarraApp(oscura: true, grande: true, logo: true, titulo: ses?.displayName ?? 'Vista pública',
            subtitulo: ses == null ? 'Sin cuenta · solo lectura' : '${ses.canControl ? 'Gestor del Secador' : 'Sin permiso de control'} · ${ses.user}'),
        hijos: [
          Tarjeta(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: [
            ElementoLista(icono: 'calibracion', titulo: 'Calibración', sub: 'Gravimet y sensores', onTap: () => s.cabecera == null ? onIngresar() : _ir(context, const PantallaCalibracion())),
            ElementoLista(icono: 'mapa', titulo: 'Mapa de secadores', sub: '${b?.secadores.length ?? 0} ${b?.secadores.length == 1 ? 'secador' : 'secadores'} en Nariño', onTap: () => _ir(context, const PantallaMapa())),
            ElementoLista(icono: 'historial', titulo: 'Historial del equipo', sub: 'Órdenes y energía', onTap: () => _ir(context, const PantallaHistorial())),
            ElementoLista(icono: 'ubicar', titulo: 'Ubicación del secador', sub: '${b?.sitio ?? '—'} · ${b?.secador?['locationLocked'] == true ? 'fijada a mano' : 'por IP del ESP32'}',
                onTap: () => s.cabecera == null ? onIngresar() : _ir(context, const PantallaUbicacion())),
            ElementoLista(icono: 'reloj2', titulo: 'Reloj inteligente', sub: 'SISCAN para Wear OS · lee el secador y, con tu sesión, manda órdenes', ultimo: true, onTap: () => _ir(context, const PantallaReloj())),
          ])),
          Tarjeta(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: [
            ElementoLista(icono: 'alertas', titulo: 'Notificaciones', sub: 'Alertas, hora de pesar y lote listo',
                derecha: Interruptor(valor: pref.notificaciones, etiqueta: 'Notificaciones', onChanged: (v) => pref.cambiarNotificaciones(context, v))),
            ElementoLista(icono: 'huella', titulo: 'Ingreso con huella', sub: ses == null ? 'Primero ingresa con tu cuenta' : 'Entra rápido sin escribir la contraseña',
                derecha: Interruptor(valor: pref.huella, etiqueta: 'Ingreso con huella', onChanged: ses == null ? null : (v) => pref.cambiarHuella(context, v))),
            ElementoLista(icono: 'sol', titulo: 'Tema', sub: temaTxt, onTap: () => _elegirTema(context)),
            ElementoLista(icono: 'candado', titulo: 'Tus datos y privacidad', sub: 'Política, exportar y borrar', onTap: () => _ir(context, const PantallaPrivacidad())),
            ses == null ? ElementoLista(icono: 'usuario', titulo: 'Ingresar', sub: 'Para registrar pesajes y mandar órdenes', ultimo: true, onTap: onIngresar)
                : ElementoLista(icono: 'salir', titulo: 'Cerrar sesión', peligro: true, ultimo: true, onTap: () async { await s.auth.signOut(); if (context.mounted) await pref.cambiarHuella(context, false); }),
          ])),
        ],
      );
    }));
  }

  Future<void> _elegirTema(BuildContext context) async {
    final s = Siscan.of(context);
    final m = await showModalBottomSheet<ThemeMode>(context: context, backgroundColor: context.c.superficie,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(SiscanRadius.xl))),
        builder: (d) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(22, 18, 22, 12), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Tema', style: TextStyle(fontFamily: SiscanType.display, fontSize: 22, fontWeight: FontWeight.w700, color: d.c.tinta)),
          const SizedBox(height: 12),
          Segmentado<ThemeMode>(bloque: true, etiqueta: 'Tema', valor: s.tema.modo, onChanged: (v) => Navigator.pop(d, v),
              opciones: const [(ThemeMode.light, 'Claro', 'sol'), (ThemeMode.dark, 'Oscuro', 'nube'), (ThemeMode.system, 'Teléfono', null)]),
          const SizedBox(height: 12),
        ]))));
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
    final s = Siscan.of(context), c = context.c;
    return Scaffold(body: ConEstado(builder: (context, b) {
      final barra = const BarraApp(titulo: 'Calibración', atras: true);
      final l = b?.activo ?? b?.lote;
      return CuerpoPantalla(barra: barra, hijos: [
        Segmentado<String>(bloque: true, etiqueta: 'Qué calibrar', valor: _vista, onChanged: (v) => setState(() => _vista = v), opciones: const [('g', 'Gravimet', 'balanza'), ('s', 'Sensores', 'calibracion')]),
        if (_vista == 'g') l == null ? const EstadoVacio(titulo: 'Sin lotes para calibrar', texto: 'La calibración del Gravimet se hace sobre un lote con pesajes.') : Pedido<J>(
          clave: '${l['id']}-${l['sampleCount']}-${b!.cargadoEn.millisecondsSinceEpoch ~/ 60000}',
          cargar: () => s.api.calibracion(l['id'] as int),
          builder: (context, cal, e, cargando) {
            final puntos = ((cal?['points'] as List?) ?? const []).cast<J>();
            if (_peso.text.isEmpty && l['lastSampleWeightGrams'] != null) _peso.text = cifra(l['lastSampleWeightGrams'] as num);
            return Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TituloTarjeta(icono: 'balanza', titulo: 'Forma de calibrar · ${l['name']}', derecha: Ficha(cal?['source'] == 'MEASURED' ? 'Con puntos' : 'Cenicafé', icono: 'check')),
              Casilla(valor: _cenicafe, onChanged: (v) => setState(() => _cenicafe = v), texto: 'Referencia Cenicafé (53 %)'),
              if (!_cenicafe) ...[
                const SizedBox(height: 8),
                Campo(etiqueta: 'Lectura del medidor', controller: _medidor, sufijo: '%', teclado: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 12),
                Campo(etiqueta: 'Peso de la muestra', controller: _peso, sufijo: 'g', pista: 'Usa el peso del último pesaje.', teclado: const TextInputType.numberWithOptions(decimal: true)),
              ],
              const SizedBox(height: 16),
              Boton('Calibrar y recalcular', variante: VarianteBoton.primary, bloque: true, onPressed: () async {
                final id = l['id'] as int;
                if (_cenicafe) {
                  await s.hacer(context, (h) => s.api.referenciaCenicafe(id, false, h), 'Referencia Cenicafé aplicada');
                  return;
                }
                final hm = double.tryParse(_medidor.text.replaceAll(',', '.')), g = double.tryParse(_peso.text.replaceAll('.', '').replaceAll(',', '.'));
                if (hm == null || hm < 0 || hm >= 100 || g == null || g <= 0) { aviso(context, 'Escribe la lectura del medidor (0–99,9 %) y el peso en gramos.', error: true); return; }
                await s.hacer(context, (h) => s.api.puntoMedido(id, g, hm, h), 'Punto medido agregado', detalle: 'El lote se recalculó.');
              }),
              if (puntos.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Puntos medidos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.tinta)),
                for (final q in puntos) Padding(padding: const EdgeInsets.only(top: 8), child: Text('${corta(fecha(q['timestamp']))} · ${cifra(q['sampleWeightGrams'] as num)} g · medidor ${cifra(q['referenceMoisturePct'] as num)} %',
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
              const TituloTarjeta(icono: 'calibracion', titulo: 'Sensores'),
              if (d == null) const Cargando(texto: 'Cargando la corrección de sensores…'),
              for (final (i, x) in filas.indexed) () {
                final m = magnitud(x['key'] as String);
                return InkWell(onTap: () => _ajustar(x), child: FilaSensor(nombre: m.nombre, meta: 'Ganancia ${cifra(x['gain'] as num, 3)} · desplazamiento ${cifra(x['offset'] as num, 2)}',
                    valor: x['lastCalibrated'] != null ? '${cifra(x['lastCalibrated'] as num, m.dec)} ${x['unit']}' : '—', icono: m.icono, color: tono(c, m.tono),
                    estado: x['calibrated'] == true ? Estado.running : Estado.paused, estadoTexto: x['calibrated'] == true ? 'Calibrado' : 'Sin calibrar', ultima: i == filas.length - 1));
              }(),
              const Pie('Toca un sensor para corregirlo con un punto: escribe el valor real medido con tu instrumento.'),
            ]));
          },
        ),
      ]);
    }));
  }

  Future<void> _ajustar(J x) async {
    final s = Siscan.of(context), real = TextEditingController();
    final m = magnitud(x['key'] as String);
    final v = await showDialog<double>(context: context, builder: (d) => AlertDialog(
      title: Text('Corregir ${m.nombre}'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Lectura actual del sensor: ${cifra(x['lastRaw'] as num?, 2)} ${x['unit']}'), const SizedBox(height: 12),
        Campo(etiqueta: 'Valor real (${x['unit']})', controller: real, teclado: const TextInputType.numberWithOptions(decimal: true, signed: true)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancelar')), TextButton(onPressed: () => Navigator.pop(d, double.tryParse(real.text.replaceAll(',', '.'))), child: const Text('Aplicar'))],
    ));
    if (v == null || x['lastRaw'] == null || !mounted) return;
    final gain = (x['gain'] as num?)?.toDouble() ?? 1;
    await s.hacer(context, (h) => s.api.corregirSensor(x['key'] as String, gain, v - (x['lastRaw'] as num).toDouble() * gain, false, h), 'Calibrado: ${m.nombre}');
  }
}

/// Mapa (AndroidMas › Mapa): mapa esquemático, leyenda y la foto del secador.
class PantallaMapa extends StatelessWidget {
  const PantallaMapa({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: ConEstado(builder: (context, b) {
        final barra = const BarraApp(titulo: 'Mapa', atras: true);
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
                g?['photoUrl'] != null ? Image.network(g!['photoUrl'] as String, fit: BoxFit.cover, semanticLabel: 'Foto del ${b.nombreSecador}', errorBuilder: (_, _, _) => const Paisaje(encuadre: 'foto', variante: 'day'))
                    : const Paisaje(encuadre: 'foto', variante: 'day'),
                Positioned(left: 12, top: 12, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(color: context.oscuro ? const Color(0x8C0E1A14) : Colors.white.withValues(alpha: .7), borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Icono('camara', size: 14, color: context.oscuro ? c.sobreBosque : c.bosque), const SizedBox(width: 7),
                    Text(g?['photoUrl'] != null ? 'Foto del secador' : 'Sin foto todavía', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.oscuro ? c.sobreBosque : c.bosque))]))),
              ])),
              Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${b.nombreSecador} · ${b.sitio}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.tinta)),
                Text(g?['latitude'] != null ? '${cifra(g!['latitude'] as num, 4)} · ${cifra(g['longitude'] as num, 4)}' : 'Sin coordenadas', style: TextStyle(fontSize: 12.5, color: c.tintaSuave)),
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
  static const _origen = {'WEB': 'Desde el panel', 'APP': 'Desde la app', 'WATCH': 'Desde el reloj', 'ESP32': 'El ESP32', 'AUTO': 'Protocolo', 'PROTOCOL': 'Protocolo'};
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context);
    return Scaffold(body: CuerpoPantalla(barra: const BarraApp(titulo: 'Historial del equipo', atras: true), hijos: [
      Segmentado<int>(bloque: true, etiqueta: 'Periodo', valor: _horas, onChanged: (v) => setState(() => _horas = v), opciones: const [(24, 'Últimas 24 h', null), (168, 'Últimos 7 días', null)]),
      Pedido<J>(
        clave: _horas, cargar: () => s.api.energia(horas: _horas),
        builder: (context, e, err, cargando) => e == null
            ? (err != null ? ErrorCarga(detalle: '$err', onReintentar: () => setState(() {})) : const Cargando(texto: 'Calculando la energía…'))
            : TarjetaEnergia(titulo: 'Energía · ${_horas == 24 ? 'últimas 24 h' : 'últimos 7 días'}', solar: (e['solarKwh'] as num?)?.toDouble(), red: (e['redKwh'] as num?)?.toDouble(),
                costo: (e['costoRedCOP'] as num?)?.toDouble(), tarifa: (e['tarifaCOPkWh'] as num?)?.toDouble(),
                barras: [for (final x in (e['barras'] as List).cast<J>()) (x['label'] as String, (x['solar'] as num? ?? 0).toDouble(), (x['grid'] as num? ?? 0).toDouble())],
                derecha: Ficha(e['redKwh'] == null ? 'Red sin lecturas' : 'Estimado', tono: 'neutral'), nota: 'Solar: ${e['fuenteSolar']}. Red: ${e['fuenteRed']}.'),
      ),
      Pedido<List<J>>(
        clave: 'ordenes', cargar: () => s.api.ordenes(limite: 100),
        builder: (context, o, err, cargando) => Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const TituloTarjeta(icono: 'historial', titulo: 'Órdenes al equipo'),
          if (o == null) const Cargando(texto: 'Cargando las órdenes…')
          else RegistroOrdenes(items: [for (final x in o) (dia(fecha(x['timestamp'])), '${x['name']} · ${x['status'] == 'ON' ? 'Encender' : 'Apagar'}', '${_origen[x['source']] ?? x['source'] ?? 'Origen sin registrar'} · ${hm(fecha(x['timestamp'])!)}')]),
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
    final s = Siscan.of(context);
    final g = s.estado.base?.secador;
    if (!_listo && g != null) {
      _lat.text = g['latitude'] != null ? (g['latitude'] as num).toStringAsFixed(5).replaceAll('.', ',') : '';
      _lon.text = g['longitude'] != null ? (g['longitude'] as num).toStringAsFixed(5).replaceAll('.', ',') : '';
      _sitio.text = g['locationLabel'] as String? ?? '';
      _bloq = g['locationLocked'] == true;
      _listo = true;
    }
    return Scaffold(body: CuerpoPantalla(barra: const BarraApp(titulo: 'Ubicación del secador', atras: true), hijos: [
      Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TituloTarjeta(icono: 'ubicar', titulo: 'Ubicación', derecha: Ficha(_bloq ? 'Fijada a mano' : 'Por IP del ESP32', tono: 'neutral', icono: _bloq ? 'candado' : 'wifi')),
        Row(children: [Expanded(child: Campo(etiqueta: 'Latitud', controller: _lat, teclado: const TextInputType.numberWithOptions(decimal: true, signed: true))), const SizedBox(width: 12),
          Expanded(child: Campo(etiqueta: 'Longitud', controller: _lon, teclado: const TextInputType.numberWithOptions(decimal: true, signed: true)))]),
        const SizedBox(height: 14),
        Campo(etiqueta: 'Nombre del sitio (opcional)', controller: _sitio),
        const SizedBox(height: 8),
        Casilla(valor: _bloq, onChanged: (v) => setState(() => _bloq = v), texto: 'Bloquear la ubicación (ignorar la geolocalización por IP del ESP32)'),
        const SizedBox(height: 12),
        Boton('Usar mi ubicación actual', icono: 'ubicar', ocupado: _gps, onPressed: () async {
          setState(() => _gps = true);
          try {
            var p = await Geolocator.checkPermission();
            if (p == LocationPermission.denied && context.mounted) {
              // Divulgación destacada antes del permiso de Android (política de datos v0.2 · Ubicación).
              final ok = await showDialog<bool>(context: context, builder: (d) => AlertDialog(
                title: const Text('Ubicación del secador'),
                content: const Text('SISCAN usará la ubicación de este teléfono una sola vez para fijar dónde está el secador '
                    'y consultar su clima. Se envía al servidor del CISNA como ubicación del equipo; no se guarda en el teléfono ni se usa en segundo plano.'),
                actions: [TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Ahora no')), TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Continuar'))],
              ));
              if (ok != true) { if (mounted) setState(() => _gps = false); return; }
              p = await Geolocator.requestPermission();
            }
            if (p == LocationPermission.denied || p == LocationPermission.deniedForever) throw Exception();
            final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)));
            _lat.text = pos.latitude.toStringAsFixed(5).replaceAll('.', ',');
            _lon.text = pos.longitude.toStringAsFixed(5).replaceAll('.', ',');
            if (context.mounted) aviso(context, 'Ubicación tomada del teléfono', detalle: 'Revisa y guarda.');
          } catch (_) {
            if (context.mounted) aviso(context, 'No fue posible obtener tu ubicación. Revisa el permiso de ubicación.', error: true);
          }
          if (mounted) setState(() => _gps = false);
        }),
        const SizedBox(height: 8),
        Boton('Guardar ubicación y refrescar clima', variante: VarianteBoton.primary, onPressed: () async {
          final la = double.tryParse(_lat.text.replaceAll(',', '.').replaceAll('−', '-')), lo = double.tryParse(_lon.text.replaceAll(',', '.').replaceAll('−', '-'));
          if (la == null || lo == null || la.abs() > 90 || lo.abs() > 180) { aviso(context, 'Revisa la latitud y la longitud.', error: true); return; }
          await s.hacer(context, (h) => s.api.ubicacion(la, lo, _bloq, _sitio.text.trim(), h), 'Ubicación guardada', detalle: 'El clima se consulta con el sitio correcto.');
        }),
        const Pie('La ubicación del teléfono solo se usa cuando tocas «Usar mi ubicación actual»; no se guarda en el teléfono.'),
      ])),
    ]));
  }
}

/// Reloj inteligente: qué hace SISCAN en Wear OS y cómo se instala.
class PantallaReloj extends StatelessWidget {
  const PantallaReloj({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: CuerpoPantalla(barra: const BarraApp(titulo: 'Reloj inteligente', atras: true), hijos: [
        Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const TituloTarjeta(icono: 'reloj2', titulo: 'SISCAN en Wear OS'),
          Text('El reloj muestra el monitoreo del lote, las lecturas, el equipo, la predicción y las alertas. Con la sesión iniciada en este teléfono, '
              'también puede encender o apagar actuadores y registrar pesajes: el reloj le pide la orden al teléfono y el teléfono la envía con tu cuenta (ingresa con «Recordarme»).',
              style: TextStyle(fontSize: 14, height: 22 / 14, color: context.c.tinta)),
          const Pie('Instala SISCAN en el reloj desde el mismo paquete de la app. Sin sesión en el teléfono, el reloj solo lee.'),
        ])),
      ]));
}

/// Tus datos y privacidad (borrador técnico; docs/legal/politica-datos-app-siscan.md): política, exportar y borrar.
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
    final s = Siscan.of(context), c = context.c;
    return Scaffold(body: CuerpoPantalla(barra: const BarraApp(titulo: 'Tus datos', atras: true), hijos: [
      Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const TituloTarjeta(icono: 'candado', titulo: 'Política de tratamiento de datos'),
        Text('Versión $version', style: TextStyle(fontSize: 12.5, color: c.tintaSuave)),
        for (final (t, x) in secciones) ...[
          const SizedBox(height: 16),
          Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.tinta)),
          const SizedBox(height: 4),
          Text(x, style: TextStyle(fontSize: 14, height: 22 / 14, color: c.tinta)),
        ],
      ])),
      Tarjeta(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const TituloTarjeta(icono: 'usuario', titulo: 'Tus derechos en la app'),
        if (s.auth.session != null) Boton('Revocar la contraseña de aplicación', icono: 'candado', onPressed: () => launchUrl(Uri.parse('${s.auth.site}/wp-admin/profile.php#application-passwords-section'), mode: LaunchMode.externalApplication)),
        const SizedBox(height: 8),
        Boton('Borrar los datos de este teléfono', icono: 'borrar', variante: VarianteBoton.danger, onPressed: () async {
          final ok = await showDialog<bool>(context: context, builder: (d) => AlertDialog(title: const Text('Borrar los datos de este teléfono'),
              content: const Text('Se cierra la sesión y se borran la credencial, la copia del secador y tus preferencias. El servidor del CISNA no cambia.'),
              actions: [TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancelar')), TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Borrar'))]));
          if (ok != true || !context.mounted) return;
          await s.auth.signOut();
          await EstadoSecador.borrarCopia();
          if (context.mounted) await Preferencias.of(context).borrarTodo(context);
          if (context.mounted) aviso(context, 'Datos de este teléfono borrados');
        }),
      ])),
    ]));
  }
}
