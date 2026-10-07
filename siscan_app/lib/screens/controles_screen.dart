import 'package:flutter/material.dart';

import '../data/auth.dart';
import '../data/models.dart';
import '../data/overview_controller.dart';
import '../data/repository.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/actuator_control.dart';
import '../widgets/siscan_icon.dart';
import '../widgets/status_mark.dart';
import 'inicio_screen.dart' show sheetDecoration;
import 'login_screen.dart';

/// Controles (referencia `ControlesMovil`): una palanca por actuador. Automático = lo decide el protocolo del secador
/// (palanca bloqueada). Pasar a manual exige la sesión de «Gestor del Secador». Las órdenes van al backend real.
class ControlesScreen extends StatefulWidget {
  const ControlesScreen({super.key, required this.overview, required this.auth});
  final OverviewController overview;
  final AuthController auth;
  @override
  State<ControlesScreen> createState() => _ControlesScreenState();
}

class _ControlesScreenState extends State<ControlesScreen> {
  final _manual = <int>{};
  final _pending = <int, bool>{}; // id → estado pedido mientras responde el secador
  final _errors = <int, String>{};
  String? _notice;

  Future<bool> _ensureSession() async {
    if (widget.auth.session?.canControl == true) return true;
    final ok = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => LoginScreen(auth: widget.auth)));
    return ok == true && widget.auth.session?.canControl == true;
  }

  Future<void> _mode(Actuator a, ActuatorMode m) async {
    if (m == ActuatorMode.manual && !await _ensureSession()) return;
    setState(() {
      _notice = null;
      m == ActuatorMode.manual ? _manual.add(a.id) : _manual.remove(a.id);
    });
  }

  Future<void> _toggle(Actuator a, bool on) async {
    final session = widget.auth.session;
    if (session == null) return;
    setState(() {
      _pending[a.id] = on;
      _errors.remove(a.id);
    });
    try {
      await widget.overview.repo.setActuator(a.id, on, auth: session.header);
      await widget.overview.load();
    } on ApiException catch (e) {
      if (e.unauthorized) {
        // Sesión vencida: se cierra y todo vuelve a automático; la tarjeta explica qué hacer.
        await widget.auth.signOut();
        _manual.clear();
        _notice = e.message;
      } else {
        _errors[a.id] = e.message;
      }
    }
    if (mounted) setState(() => _pending.remove(a.id));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    return ListenableBuilder(
      listenable: Listenable.merge([widget.overview, widget.auth]),
      builder: (context, _) {
        final d = widget.overview.data;
        final head = Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: sheetDecoration(t, topRadius: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('¿Está funcionando el equipo?', style: SiscanType.seccion.copyWith(color: t.tierra)),
            const SizedBox(height: SiscanSpace.s2),
            if (widget.auth.session == null)
              Text('Para encender o apagar el equipo pasa a «Manual» e ingresa con tu cuenta de Gestor del Secador.', style: SiscanType.cuerpo.copyWith(color: t.tierraSuave))
            else
              Row(children: [
                SiscanIcon(SiscanGlyph.usuario, size: 18, color: t.tierraSuave),
                const SizedBox(width: SiscanSpace.s2),
                Expanded(child: Text('Ingresaste como ${widget.auth.session!.displayName}', style: SiscanType.nota.copyWith(color: t.tierraSuave))),
              ]),
            if (_notice != null) ...[
              const SizedBox(height: SiscanSpace.s3),
              Semantics(liveRegion: true, child: StatusMark(SiscanStatus.advertencia, label: _notice!)),
            ],
            if (d != null && d.offline) ...[
              const SizedBox(height: SiscanSpace.s3),
              const StatusMark(SiscanStatus.sinConexion, label: 'Modo offline'),
              const SizedBox(height: SiscanSpace.s2),
              Text('Sin conexión no se envían órdenes: el equipo sigue con su protocolo. Las palancas se activan al volver la red.',
                  style: SiscanType.nota.copyWith(color: t.tierra)),
            ] else if (d != null && !d.dryerReporting) ...[
              const SizedBox(height: SiscanSpace.s3),
              const StatusMark(SiscanStatus.desactualizado, label: 'El secador no está reportando'),
              const SizedBox(height: SiscanSpace.s2),
              Text('Las órdenes quedan registradas, pero el equipo las cumplirá cuando vuelva a conectarse.', style: SiscanType.nota.copyWith(color: t.tierra)),
            ],
          ]),
        );
        if (d == null) return head;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          head,
          for (final a in d.actuators) ...[
            const SizedBox(height: SiscanSpace.s4),
            ActuatorControl(
              key: Key('actuator-${a.id}'),
              name: a.name,
              glyph: a.kind == ActuatorKind.heater ? SiscanGlyph.resistencia : (a.kind == ActuatorKind.fan ? SiscanGlyph.ventilador : SiscanGlyph.energia),
              powerW: a.powerW,
              guarded: a.kind == ActuatorKind.heater,
              // Sin red: último estado conocido, en automático y sin poder cambiarlo (las órdenes no se encolan).
              mode: _manual.contains(a.id) && !d.offline ? ActuatorMode.manual : ActuatorMode.automatico,
              state: _pending.containsKey(a.id)
                  ? (_pending[a.id]! ? ActuatorState.encendiendo : ActuatorState.apagando)
                  : _errors.containsKey(a.id) ? ActuatorState.error : (a.on ? ActuatorState.encendido : ActuatorState.apagado),
              errorText: _errors[a.id],
              onModeChange: d.offline ? null : (m) => _mode(a, m),
              onToggle: (on) => _toggle(a, on),
            ),
          ],
        ]);
      },
    );
  }
}
