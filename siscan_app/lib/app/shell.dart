import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/ui/marco.dart';
import '../pantallas/equipo.dart';
import '../pantallas/ingreso.dart';
import '../pantallas/inicio.dart';
import '../pantallas/lotes.dart';
import '../pantallas/mas.dart';
import '../pantallas/pesaje.dart';
import 'contexto.dart';
import 'notificaciones.dart';
import 'preferencias.dart';
import 'widgets_inicio.dart';

/// Arranque: pantalla de carga → ingreso (salvo sesión guardada o vista pública elegida antes) → pestañas.
class Arranque extends StatefulWidget {
  const Arranque({super.key});
  @override
  State<Arranque> createState() => _ArranqueState();
}

class _ArranqueState extends State<Arranque> {
  String _fase = 'carga';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fase == 'carga') _preparar();
  }
  Future<void> _preparar() async {
    final s = Siscan.of(context), pref = Preferencias.of(context);
    final inicio = DateTime.now();
    final p = await SharedPreferences.getInstance();
    // Con huella activada se pide la huella en el ingreso; sin ella, se recupera la sesión guardada.
    if (!pref.huella) await s.auth.restore();
    final espera = const Duration(milliseconds: 900) - DateTime.now().difference(inicio);
    if (espera > Duration.zero) await Future.delayed(espera);
    if (!mounted) return;
    setState(() => _fase = s.auth.session != null || (p.getBool('siscan_publico') == true && !pref.huella) ? 'app' : 'ingreso');
  }
  @override
  Widget build(BuildContext context) => switch (_fase) {
        'carga' => const PantallaCarga(),
        'ingreso' => PantallaIngreso(onListo: () async {
            (await SharedPreferences.getInstance()).setBool('siscan_publico', true);
            if (mounted) setState(() => _fase = 'app');
          }),
        _ => Contenedor(onIngresar: () => setState(() => _fase = 'ingreso')),
      };
}

/// Contenedor con la barra inferior (Inicio · Lotes · Pesaje · Equipo · Más).
class Contenedor extends StatefulWidget {
  const Contenedor({super.key, required this.onIngresar});
  final VoidCallback onIngresar;
  @override
  State<Contenedor> createState() => _ContenedorState();
}

class _ContenedorState extends State<Contenedor> {
  Pestana _p = Pestana.inicio;
  @override
  void initState() {
    super.initState();
    Notificaciones.toque.addListener(_ruta);
    WidgetsInicio.toque.addListener(_ruta);
    WidgetsBinding.instance.addPostFrameCallback((_) { _ruta(); WidgetsInicio.escuchar(Siscan.of(context).estado); });
  }
  @override
  void dispose() {
    Notificaciones.toque.removeListener(_ruta);
    WidgetsInicio.toque.removeListener(_ruta);
    super.dispose();
  }
  void _ruta() {
    final r = Notificaciones.toque.value ?? WidgetsInicio.toque.value;
    if (r == null) return;
    Notificaciones.toque.value = null;
    WidgetsInicio.toque.value = null;
    final p = switch (r) { 'equipo' => Pestana.equipo, 'pesaje' => Pestana.pesaje, 'lotes' => Pestana.lotes, 'mas' => Pestana.mas, _ => Pestana.inicio };
    Navigator.of(context).popUntil((x) => x.isFirst);
    setState(() => _p = p);
  }
  @override
  Widget build(BuildContext context) {
    final s = Siscan.of(context);
    return Scaffold(
      body: IndexedStack(index: _p.index, children: [
        PantallaInicio(irA: (p) => setState(() => _p = p)),
        PantallaLotes(onIngresar: widget.onIngresar),
        PantallaPesaje(onIngresar: widget.onIngresar),
        PantallaEquipo(onIngresar: widget.onIngresar),
        PantallaMas(onIngresar: widget.onIngresar),
      ]),
      bottomNavigationBar: ListenableBuilder(listenable: s.estado, builder: (context, _) =>
          BarraInferior(activa: _p, alertas: s.estado.base?.alertas.length ?? 0, onCambio: (p) => setState(() => _p = p))),
    );
  }
}
