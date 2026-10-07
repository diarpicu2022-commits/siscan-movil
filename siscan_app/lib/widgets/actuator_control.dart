
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'siscan_icon.dart';

enum ActuatorState { encendido, apagado, encendiendo, apagando, bloqueado, error }

enum ActuatorMode { automatico, manual }

/// Control de un actuador como palanca física (balancín 132 × 60, «ENC/APAG» grabados, perilla con estrías y
/// sombra dura). En automático la palanca está bloqueada («Controlado por el protocolo»); manual tiñe el control de
/// `panela` y contornea la tarjeta. Las resistencias (`guarded`) se encienden **manteniendo presionado 1.5 s**;
/// apagar siempre es inmediato. Se muestra la transición y el fallo con instrucción.
class ActuatorControl extends StatefulWidget {
  const ActuatorControl({super.key, required this.name, required this.glyph, required this.powerW, required this.state,
      required this.mode, this.guarded = false, this.errorText, this.lockReason, this.onToggle, this.onModeChange,
      this.holdDuration = const Duration(milliseconds: 1500)});
  final String name;
  final SiscanGlyph glyph;
  final double powerW;
  final ActuatorState state;
  final ActuatorMode mode;
  final bool guarded;
  final String? errorText, lockReason;
  final ValueChanged<bool>? onToggle;
  final ValueChanged<ActuatorMode>? onModeChange;
  final Duration holdDuration;

  @override
  State<ActuatorControl> createState() => _ActuatorControlState();
}

class _ActuatorControlState extends State<ActuatorControl> with SingleTickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(vsync: this, duration: widget.holdDuration);

  bool get _on => widget.state == ActuatorState.encendido || widget.state == ActuatorState.apagando;
  bool get _busy => widget.state == ActuatorState.encendiendo || widget.state == ActuatorState.apagando;
  bool get _enabled => widget.mode == ActuatorMode.manual && !_busy && widget.state != ActuatorState.bloqueado && widget.onToggle != null;

  @override
  void initState() {
    super.initState();
    _hold.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _hold.reset();
        widget.onToggle?.call(true);
      }
    });
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  void _tap() {
    if (!_enabled) return;
    if (_on) {
      widget.onToggle!(false); // apagar es inmediato, sin confirmación
    } else if (!widget.guarded) {
      widget.onToggle!(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final manual = widget.mode == ActuatorMode.manual;
    final (word, wordColor, detail) = switch (widget.state) {
      ActuatorState.encendido => ('Encendido', t.cafeto, manual ? 'En modo manual' : 'Controlado por el protocolo'),
      ActuatorState.apagado => ('Apagado', t.tierra, manual ? (widget.guarded ? 'Mantén presionado para encender' : 'Toca para encender') : 'Controlado por el protocolo'),
      ActuatorState.encendiendo => ('Encendiendo…', t.bruma, 'Esperando la respuesta del secador'),
      ActuatorState.apagando => ('Apagando…', t.bruma, 'Esperando la respuesta del secador'),
      ActuatorState.bloqueado => ('Bloqueado', t.tierra, widget.lockReason ?? 'No disponible ahora'),
      ActuatorState.error => ('Error', t.oxido, widget.errorText ?? 'No fue posible encender. Verifica la conexión del dispositivo.'),
    };
    final iconBg = switch (widget.state) { ActuatorState.encendido => t.cafetoSuave, ActuatorState.error => t.oxidoSuave, _ => t.arena };
    final reduce = MediaQuery.of(context).disableAnimations;
    return Semantics(
      container: true,
      label: '${widget.name}, $word, ${manual ? 'modo manual' : 'modo automático'}',
      child: AnimatedContainer(
        duration: reduce ? Duration.zero : const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(SiscanSpace.s5),
        decoration: BoxDecoration(
          color: t.papel,
          borderRadius: BorderRadius.circular(SiscanRadius.hoja),
          border: Border.all(color: manual ? t.panela : t.linea, width: manual ? 2 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44, height: 44, alignment: Alignment.center,
              decoration: BoxDecoration(color: iconBg, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomRight: Radius.circular(12), bottomLeft: Radius.circular(4))),
              child: SiscanIcon(widget.glyph, size: 24, color: widget.state == ActuatorState.error ? t.oxido : t.tierra),
            ),
            const SizedBox(width: SiscanSpace.s3),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.name, style: SiscanType.cuerpoFuerte.copyWith(color: t.tierra)),
              Text.rich(TextSpan(style: SiscanType.nota.copyWith(color: t.tierraSuave), children: [
                const TextSpan(text: 'Nominal '),
                TextSpan(text: '${widget.powerW.toStringAsFixed(0)} W', style: SiscanType.tabla.copyWith(fontSize: 13, color: t.tierra)),
              ])),
            ])),
          ]),
          const SizedBox(height: SiscanSpace.s4),
          Row(children: [
            Semantics(
              button: true, enabled: _enabled, toggled: _on,
              label: widget.guarded && !_on ? 'Mantener presionado para encender' : (_on ? 'Apagar' : 'Encender'),
              excludeSemantics: true,
              onTap: _enabled ? () => _on || !widget.guarded ? _tap() : widget.onToggle!(true) : null,
              // Mantener presionado se escucha en el dedo directamente (sin esperar al reconocedor de toques, que
              // compite con el desplazamiento de la pantalla): empieza al apoyar y se cancela al levantar.
              child: Listener(
                key: const Key('lever'),
                onPointerDown: (_) { if (_enabled && widget.guarded && !_on) _hold.forward(from: 0); },
                onPointerUp: (_) { if (_hold.isAnimating) { _hold.reverse(); } else if (!(widget.guarded && !_on)) { _tap(); } },
                onPointerCancel: (_) { if (_hold.isAnimating) _hold.reverse(); },
                child: AnimatedBuilder(animation: _hold, builder: (context, _) => _Lever(on: _on, enabled: _enabled, manual: manual, error: widget.state == ActuatorState.error,
                    locked: widget.state == ActuatorState.bloqueado || !manual, hold: _hold.value, reduce: reduce)),
              ),
            ),
            const SizedBox(width: SiscanSpace.s4),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(word, style: SiscanType.cuerpoFuerte.copyWith(fontSize: 22, height: 1.15, color: wordColor)),
              const SizedBox(height: 2),
              Text(detail, style: SiscanType.nota.copyWith(color: widget.state == ActuatorState.error ? t.oxido : t.tierra)),
            ])),
          ]),
          const SizedBox(height: SiscanSpace.s4),
          _ModeSwitch(mode: widget.mode, onChange: widget.onModeChange),
          if (manual && widget.guarded) ...[
            const SizedBox(height: SiscanSpace.s3),
            Container(
              padding: const EdgeInsets.all(SiscanSpace.s3),
              decoration: BoxDecoration(color: t.panelaSuave, borderRadius: BorderRadius.circular(SiscanRadius.etiqueta)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SiscanIcon(SiscanGlyph.alerta, size: 18, color: t.panela),
                const SizedBox(width: SiscanSpace.s2),
                Expanded(child: Text('La resistencia eleva la temperatura de la cámara. Verifica que el ventilador esté encendido.',
                    style: SiscanType.nota.copyWith(color: t.tierra))),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

class _Lever extends StatelessWidget {
  const _Lever({required this.on, required this.enabled, required this.manual, required this.error, required this.locked, required this.hold, required this.reduce});
  final bool on, enabled, manual, error, locked, reduce;
  final double hold;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    const w = 132.0, h = 60.0, knob = 58.0;
    final border = error ? t.oxido : (on ? t.cafeto : (manual ? t.panela : t.lineaFuerte));
    return SizedBox(
      width: w, height: h + 3,
      child: Stack(children: [
        Container(
          width: w, height: h,
          decoration: BoxDecoration(color: on ? t.cafeto : t.arena, borderRadius: BorderRadius.circular(SiscanRadius.control), border: Border.all(color: border, width: 2)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(SiscanRadius.control - 2),
            child: Stack(children: [
              if (on) Positioned.fill(child: CustomPaint(painter: _Stripes(t.monte.withValues(alpha: .45)))),
              if (locked && !on) Positioned.fill(child: CustomPaint(painter: _Stripes(t.linea))),
              // Relleno de «mantener presionado» (resistencias).
              if (hold > 0) Positioned(left: 0, top: 0, bottom: 0, width: w * hold, child: ColoredBox(color: t.panela.withValues(alpha: .35))),
              Align(
                alignment: on ? Alignment.centerLeft : Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(on ? 'ENC' : 'APAG', style: SiscanType.etiqueta.copyWith(color: on ? t.papel : t.tierraSuave, letterSpacing: 1.2)),
                ),
              ),
            ]),
          ),
        ),
        AnimatedPositioned(
          duration: reduce ? Duration.zero : const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          left: on ? w - knob - 2 : 2, top: 2,
          child: Container(
            width: knob, height: h - 4,
            decoration: BoxDecoration(
              color: t.papel, borderRadius: BorderRadius.circular(SiscanRadius.control - 2),
              border: Border.all(color: t.lineaFuerte),
              boxShadow: [BoxShadow(color: t.lineaFuerte, offset: const Offset(0, 3))],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 0; i < 3; i++) Container(width: 2, height: 18, margin: const EdgeInsets.symmetric(horizontal: 2.5), color: enabled ? t.tierra : t.tierraSuave),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Stripes extends CustomPainter {
  _Stripes(this.color);
  final Color color;
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = color..strokeWidth = 6;
    for (double x = -s.height; x < s.width; x += 14) {
      c.drawLine(Offset(x, s.height), Offset(x + s.height, 0), p);
    }
  }
  @override
  bool shouldRepaint(_Stripes o) => o.color != color;
}

/// Selector Automático / Manual (manual en `panela`, visible a distancia).
class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, this.onChange});
  final ActuatorMode mode;
  final ValueChanged<ActuatorMode>? onChange;
  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    Widget option(ActuatorMode m, String label, SiscanGlyph g) {
      final sel = mode == m;
      final manual = m == ActuatorMode.manual;
      return Expanded(
        child: Semantics(
          button: true, selected: sel, label: label, excludeSemantics: true,
          child: InkWell(
            key: Key('mode-${m.name}'),
            onTap: onChange == null || sel ? null : () => onChange!(m),
            borderRadius: BorderRadius.circular(SiscanRadius.control - 2),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                color: sel ? (manual ? t.panelaSuave : t.papel) : null,
                borderRadius: BorderRadius.circular(SiscanRadius.control - 2),
                border: sel ? Border.all(color: manual ? t.panela : t.tierraSuave, width: 1.5) : null,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SiscanIcon(g, size: 18, color: sel && manual ? t.panela : t.tierra),
                const SizedBox(width: 6),
                Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: SiscanType.cuerpoFuerte.copyWith(fontSize: 15, color: sel && manual ? t.panela : t.tierra))),
              ]),
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: t.arena, borderRadius: BorderRadius.circular(SiscanRadius.control)),
      child: Row(children: [
        option(ActuatorMode.automatico, 'Automático', SiscanGlyph.sincronizar),
        const SizedBox(width: 4),
        option(ActuatorMode.manual, 'Manual', SiscanGlyph.mano),
      ]),
    );
  }
}
