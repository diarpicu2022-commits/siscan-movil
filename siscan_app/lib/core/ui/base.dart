/// Componentes base del sistema de diseño SISCAN v2 en Flutter. Cada uno replica las medidas de su clase en
/// components/bundle.css (sc-card, sc-ctitle, sc-pill, sc-chip, sc-btn, sc-field, sc-seg, sc-switch, sc-check…).
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/siscan_theme.dart';
import '../theme/siscan_tokens.dart';

/// Ícono del sistema (Lucide + grano, secador y resistencia propios), trazo 1,75 en caja de 24.
class Icono extends StatelessWidget {
  const Icono(this.nombre, {super.key, this.size = 20, this.color, this.semantica});
  final String nombre;
  final double size;
  final Color? color;
  final String? semantica;
  @override
  Widget build(BuildContext context) {
    final col = color ?? DefaultTextStyle.of(context).style.color ?? context.c.tinta;
    final w = SvgPicture.asset('assets/sistema/iconos/$nombre.svg', width: size, height: size, theme: SvgTheme(currentColor: col),
        excludeFromSemantics: semantica == null, semanticsLabel: semantica);
    return SizedBox(width: size, height: size, child: w);
  }
}

/// Ventilador que gira y resistencia que brilla mientras están encendidos (04-movimiento: «siempre»).
class IconoEquipo extends StatefulWidget {
  const IconoEquipo({super.key, required this.calefactor, required this.encendido, this.size = 20, this.color});
  final bool calefactor, encendido;
  final double size;
  final Color? color;
  @override
  State<IconoEquipo> createState() => _IconoEquipoState();
}

class _IconoEquipoState extends State<IconoEquipo> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: SiscanMotion.ventilador);
  @override
  void dispose() { _a.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final mover = widget.encendido && !context.sinMovimiento;
    if (mover && !_a.isAnimating) { widget.calefactor ? _a.repeat(reverse: true) : _a.repeat(); }
    if (!mover && _a.isAnimating) _a.stop();
    final ic = Icono(widget.calefactor ? 'resistencia' : 'ventilador', size: widget.size, color: widget.color);
    if (!mover) return ic;
    return widget.calefactor ? FadeTransition(opacity: Tween(begin: .6, end: 1.0).animate(_a), child: ic) : RotationTransition(turns: _a, child: ic);
  }
}

/// sc-card: superficie, línea, radio lg y sombra de tarjeta.
class Tarjeta extends StatelessWidget {
  const Tarjeta({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color, this.gradiente, this.radio = SiscanRadius.lg});
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Gradient? gradiente;
  final double radio;
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(color: gradiente == null ? (color ?? context.c.superficie) : null, gradient: gradiente,
            border: Border.all(color: context.c.linea), borderRadius: BorderRadius.circular(radio), boxShadow: context.sombraTarjeta),
        child: child,
      );
}

/// sc-ctitle: ícono en cuadro superficie-hoja de 32, título 15/750 y algo a la derecha.
class TituloTarjeta extends StatelessWidget {
  const TituloTarjeta({super.key, required this.icono, required this.titulo, this.derecha});
  final String icono, titulo;
  final Widget? derecha;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: SiscanSpace.s4),
      child: Row(children: [
        Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: c.superficieHoja, borderRadius: BorderRadius.circular(10)),
            child: Icono(icono, size: 18, color: c.hoja)),
        const SizedBox(width: SiscanSpace.s3),
        Expanded(child: Semantics(container: true, header: true, child: Text(titulo, style: TextStyle(fontSize: 15, height: 20 / 15, fontWeight: FontWeight.w700, color: c.tinta)))),
        ?derecha,
      ]),
    );
  }
}

/// sc-pill (StatusPill): estado con ícono o punto y palabra; nunca solo color.
class Pildora extends StatelessWidget {
  const Pildora({super.key, required this.estado, this.texto, this.vivo = false, this.chica = false});
  final Estado estado;
  final String? texto;
  final bool vivo, chica;
  static const _etiqueta = {Estado.running: 'En operación', Estado.paused: 'En pausa', Estado.alert: 'Alerta', Estado.offline: 'Sin conexión'};
  static const _icono = {Estado.paused: 'pausa', Estado.alert: 'aviso', Estado.offline: 'wifiNo'};
  @override
  Widget build(BuildContext context) {
    final (st, sts) = colorEstado(context.c, estado);
    final ic = _icono[estado];
    return Container(
      padding: chica ? const EdgeInsets.symmetric(horizontal: 9, vertical: 3) : const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(color: sts, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ic != null ? Icono(ic, size: 13, color: st) : PuntoVivo(color: st, vivo: vivo),
        const SizedBox(width: 6),
        Text(texto ?? _etiqueta[estado]!, style: TextStyle(fontSize: chica ? 11.5 : 12, height: 16 / 12, fontWeight: FontWeight.w700, color: st)),
      ]),
    );
  }
}

/// Punto que late mientras el dato está en vivo (dur-latido); quieto con movimiento reducido.
class PuntoVivo extends StatefulWidget {
  const PuntoVivo({super.key, required this.color, this.vivo = true, this.hueco = false, this.size = 8});
  final Color color;
  final bool vivo, hueco;
  final double size;
  @override
  State<PuntoVivo> createState() => _PuntoVivoState();
}

class _PuntoVivoState extends State<PuntoVivo> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: SiscanMotion.latido);
  @override
  void dispose() { _a.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final mover = widget.vivo && !context.sinMovimiento;
    if (mover && !_a.isAnimating) _a.repeat(reverse: true);
    if (!mover && _a.isAnimating) _a.stop();
    final dot = Container(width: widget.size, height: widget.size, decoration: BoxDecoration(shape: BoxShape.circle,
        color: widget.hueco ? Colors.transparent : widget.color, border: widget.hueco ? Border.all(color: widget.color, width: 2) : null));
    return mover ? FadeTransition(opacity: Tween(begin: .45, end: 1.0).animate(CurvedAnimation(parent: _a, curve: SiscanMotion.suave)), child: dot) : dot;
  }
}

/// sc-livetag: punto + texto («En vivo», «Sin conexión · último dato…»).
class EtiquetaVivo extends StatelessWidget {
  const EtiquetaVivo({super.key, required this.texto, this.apagado = false, this.sobreOscuro = true});
  final String texto;
  final bool apagado, sobreOscuro;
  @override
  Widget build(BuildContext context) {
    final col = sobreOscuro ? context.c.sobreBosqueSuave : context.c.tintaSuave;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      PuntoVivo(color: apagado ? col : context.c.broteVivo, vivo: !apagado, hueco: apagado),
      const SizedBox(width: 8),
      Flexible(child: Text(texto, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: col))),
    ]);
  }
}

/// sc-chip: brote, café, neutral, predicción o advertencia.
class Ficha extends StatelessWidget {
  const Ficha(this.texto, {super.key, this.tono = 'brote', this.icono});
  final String texto, tono;
  final String? icono;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (fondo, tinta) = switch (tono) {
      'cafe' => (c.cafeSuave, c.cafe),
      'neutral' => (c.superficieFuerte, c.tintaSuave),
      'pred' => (mezcla(c.prediccion, .14, c.superficie), context.oscuro ? c.prediccion : mezcla(Colors.black, .32, c.prediccion)),
      'warn' => (c.pausaSuave, c.pausa),
      _ => (c.brote, c.marca),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icono != null) ...[Icono(icono!, size: 14, color: tinta), const SizedBox(width: 5)],
        Flexible(child: Text(texto, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, color: tinta))),
      ]),
    );
  }
}

enum VarianteBoton { primary, secondary, soft, ghost, danger }

/// sc-btn: píldora de 44 px mínimo (52 en lg), primario en degradado esmeralda → hoja.
class Boton extends StatelessWidget {
  const Boton(this.texto, {super.key, this.onPressed, this.variante = VarianteBoton.secondary, this.icono, this.grande = false, this.bloque = false, this.ocupado = false});
  final String texto;
  final VoidCallback? onPressed;
  final VarianteBoton variante;
  final String? icono;
  final bool grande, bloque, ocupado;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final activo = onPressed != null && !ocupado;
    final (Color? fondo, Gradient? grad, Color borde, Color tinta) = !activo && !ocupado
        ? (c.superficieFuerte, null, c.superficieFuerte, c.deshabilitado)
        : switch (variante) {
            VarianteBoton.primary => (null, LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.esmeralda, c.hoja]), c.hoja, c.sobreHoja),
            VarianteBoton.soft => (c.brote, null, c.brote, c.marca),
            VarianteBoton.ghost => (Colors.transparent, null, Colors.transparent, c.hoja),
            VarianteBoton.danger => (Colors.transparent, null, c.alerta, c.alerta),
            VarianteBoton.secondary => (c.superficie, null, c.linea, c.tinta),
          };
    final radio = grande ? 16.0 : 999.0;
    final hijo = Row(mainAxisSize: bloque ? MainAxisSize.max : MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
      if (ocupado) ...[SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: tinta)), const SizedBox(width: 8)]
      else if (icono != null) ...[Icono(icono!, size: 18, color: tinta), const SizedBox(width: 8)],
      Flexible(child: Text(texto, textAlign: TextAlign.center, style: TextStyle(fontSize: grande ? 16 : 14, fontWeight: FontWeight.w700, color: tinta))),
    ]);
    return Semantics(container: true, 
      button: true, enabled: activo,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: activo ? onPressed : null,
          borderRadius: BorderRadius.circular(radio),
          child: Ink(
            decoration: BoxDecoration(color: fondo, gradient: grad, border: Border.all(color: borde, width: 1.5), borderRadius: BorderRadius.circular(radio),
                boxShadow: variante == VarianteBoton.primary && activo ? [BoxShadow(color: c.hoja.withValues(alpha: .25), blurRadius: 12, offset: const Offset(0, 4))] : null),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: grande ? 52 : SiscanSize.toque, minWidth: SiscanSize.toque),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: SiscanSpace.s5), child: Center(widthFactor: 1, child: hijo)),
            ),
          ),
        ),
      ),
    );
  }
}

/// sc-iconbtn: botón redondo de 44 con contador de alertas.
class BotonIcono extends StatelessWidget {
  const BotonIcono({super.key, required this.icono, required this.etiqueta, this.onPressed, this.cuenta = 0, this.oscuro = false});
  final String icono, etiqueta;
  final VoidCallback? onPressed;
  final int cuenta;
  final bool oscuro;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Tooltip(
      message: etiqueta,
      child: Semantics(container: true, 
        button: true, label: cuenta > 0 ? '$etiqueta, $cuenta' : etiqueta,
        child: InkResponse(
          onTap: onPressed, radius: 24,
          child: SizedBox(width: SiscanSize.toque, height: SiscanSize.toque, child: Stack(alignment: Alignment.center, children: [
            Icono(icono, color: oscuro ? c.sobreBosque : c.tintaSuave),
            if (cuenta > 0) Positioned(top: 5, right: 4, child: Cuenta(cuenta)),
          ])),
        ),
      ),
    );
  }
}

/// sc-count: número de alertas sobre un ícono.
class Cuenta extends StatelessWidget {
  const Cuenta(this.n, {super.key});
  final int n;
  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 18), height: 18, padding: const EdgeInsets.symmetric(horizontal: 5), alignment: Alignment.center,
        decoration: BoxDecoration(color: context.c.alerta, borderRadius: BorderRadius.circular(9), border: Border.all(color: context.c.superficie, width: 2)),
        child: Text('$n', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
      );
}

/// sc-field: rótulo arriba, caja con ícono y sufijo, pista o error.
class Campo extends StatefulWidget {
  const Campo({super.key, this.etiqueta, required this.controller, this.icono, this.sufijo, this.pista, this.error, this.clave = false,
      this.teclado, this.grande = false, this.placeholder, this.onChanged, this.autofill});
  final String? etiqueta, icono, sufijo, pista, error, placeholder;
  final TextEditingController controller;
  final bool clave, grande;
  final TextInputType? teclado;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofill;
  @override
  State<Campo> createState() => _CampoState();
}

class _CampoState extends State<Campo> {
  bool _ver = false;
  final _foco = FocusNode();
  @override
  void initState() { super.initState(); _foco.addListener(() => setState(() {})); }
  @override
  void dispose() { _foco.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final enfocado = _foco.hasFocus;
    final borde = widget.error != null ? c.alerta : enfocado ? c.esmeralda : c.lineaFuerte;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      if (widget.etiqueta != null) Padding(padding: const EdgeInsets.only(bottom: 6),
          child: Text(widget.etiqueta!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.tinta))),
      AnimatedContainer(
        duration: SiscanMotion.rapida,
        constraints: BoxConstraints(minHeight: widget.grande ? 52 : SiscanSize.toque),
        padding: EdgeInsets.symmetric(horizontal: widget.grande ? SiscanSpace.s4 : SiscanSpace.s3),
        decoration: BoxDecoration(color: c.superficie, borderRadius: BorderRadius.circular(widget.grande ? 14 : 12), border: Border.all(color: borde, width: 1.5),
            boxShadow: enfocado ? [BoxShadow(color: c.esmeralda.withValues(alpha: .18), spreadRadius: 4)] : null),
        child: Row(children: [
          if (widget.icono != null) ...[Icono(widget.icono!, size: 18, color: enfocado ? c.esmeralda : c.tintaSuave), const SizedBox(width: 8)],
          Expanded(child: TextField(
            controller: widget.controller, focusNode: _foco, obscureText: widget.clave && !_ver, keyboardType: widget.teclado,
            autofillHints: widget.autofill, onChanged: widget.onChanged,
            style: TextStyle(fontSize: 15, color: c.tinta, fontFamily: SiscanType.ui),
            decoration: InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: widget.placeholder, hintStyle: TextStyle(color: c.tintaSuave),
                contentPadding: const EdgeInsets.symmetric(vertical: 12)),
          )),
          if (widget.sufijo != null) Text(widget.sufijo!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.tintaSuave)),
          if (widget.clave) BotonIcono(icono: _ver ? 'ojoNo' : 'ojo', etiqueta: _ver ? 'Ocultar contraseña' : 'Mostrar contraseña', onPressed: () => setState(() => _ver = !_ver)),
        ]),
      ),
      if (widget.error != null || widget.pista != null) Padding(padding: const EdgeInsets.only(top: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.error != null) ...[Icono('aviso', size: 14, color: c.alerta), const SizedBox(width: 5)],
        Expanded(child: Text(widget.error ?? widget.pista!, style: TextStyle(fontSize: 12.5, height: 17 / 12.5, color: widget.error != null ? c.alerta : c.tintaSuave))),
      ])),
    ]);
  }
}

/// sc-seg: opciones en píldora sobre superficie-fuerte; la elegida en superficie con texto hoja.
class Segmentado<T> extends StatelessWidget {
  const Segmentado({super.key, required this.opciones, required this.valor, required this.onChanged, this.bloque = false, required this.etiqueta});
  final List<(T, String, String?)> opciones;
  final T valor;
  final ValueChanged<T>? onChanged;
  final bool bloque;
  final String etiqueta;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final hijos = opciones.map((o) {
      final on = o.$1 == valor;
      final w = Semantics(container: true, 
        selected: on, button: true, label: o.$2,
        child: GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!(o.$1),
          child: AnimatedContainer(
            duration: SiscanMotion.rapida,
            constraints: const BoxConstraints(minHeight: SiscanSize.toque),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: on ? c.superficie : Colors.transparent, borderRadius: BorderRadius.circular(999),
                boxShadow: on ? [BoxShadow(color: const Color(0xFF183024).withValues(alpha: .14), blurRadius: 3, offset: const Offset(0, 1))] : null),
            child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
              if (o.$3 != null) ...[Icono(o.$3!, size: 16, color: on ? c.hoja : c.tintaSuave), const SizedBox(width: 6)],
              Flexible(child: Text(o.$2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: on ? c.hoja : c.tintaSuave))),
            ]),
          ),
        ),
      );
      return bloque ? Expanded(child: w) : w;
    }).toList();
    return Semantics(container: true, 
      label: etiqueta,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: c.superficieFuerte, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: bloque ? MainAxisSize.max : MainAxisSize.min, children: [for (var i = 0; i < hijos.length; i++) ...[if (i > 0) const SizedBox(width: 2), hijos[i]]]),
      ),
    );
  }
}

/// sc-switch: pista de 50×28, pulgar blanco con ✓ cuando está encendido.
class Interruptor extends StatelessWidget {
  const Interruptor({super.key, required this.valor, required this.onChanged, required this.etiqueta});
  final bool valor;
  final ValueChanged<bool>? onChanged;
  final String etiqueta;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final des = onChanged == null;
    return Semantics(container: true, 
      toggled: valor, enabled: !des, label: etiqueta,
      child: GestureDetector(
        onTap: des ? null : () => onChanged!(!valor),
        child: SizedBox(
          width: 56, height: SiscanSize.toque,
          child: Center(child: Opacity(
            opacity: des ? .55 : 1,
            child: AnimatedContainer(
              duration: SiscanMotion.rapida, width: 50, height: 28,
              decoration: BoxDecoration(color: valor ? c.hoja : c.superficieFuerte, borderRadius: BorderRadius.circular(999), border: Border.all(color: valor ? c.hoja : c.lineaFuerte, width: 2)),
              child: AnimatedAlign(
                duration: SiscanMotion.rapida, curve: SiscanMotion.suave, alignment: valor ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(margin: const EdgeInsets.all(3), width: 18, height: 18, alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: valor ? Colors.white : c.lineaFuerte),
                    child: valor ? Icono('check', size: 12, color: c.hoja) : null),
              ),
            ),
          )),
        ),
      ),
    );
  }
}

/// sc-check: casilla de 20 con borde línea-fuerte; marcada en hoja.
class Casilla extends StatelessWidget {
  const Casilla({super.key, required this.valor, required this.onChanged, required this.texto});
  final bool valor;
  final ValueChanged<bool> onChanged;
  final String texto;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(container: true, 
      checked: valor, label: texto,
      child: InkWell(
        onTap: () => onChanged(!valor),
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SiscanSize.toque),
          child: Row(children: [
            AnimatedContainer(duration: SiscanMotion.rapida, width: 20, height: 20, alignment: Alignment.center,
                decoration: BoxDecoration(color: valor ? c.hoja : Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(color: valor ? c.hoja : c.lineaFuerte, width: 2)),
                child: valor ? Icono('check', size: 13, color: c.sobreHoja) : null),
            const SizedBox(width: 10),
            Expanded(child: Text(texto, style: TextStyle(fontSize: 14, color: c.tinta))),
          ]),
        ),
      ),
    );
  }
}

/// sc-progress: barra de 8 con degradado hoja → brote vivo → lima (o violeta para la predicción).
class Progreso extends StatelessWidget {
  const Progreso({super.key, required this.valor, this.prediccion = false, required this.etiqueta});
  final double valor;
  final bool prediccion;
  final String etiqueta;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final v = valor.clamp(0, 100) / 100;
    return Semantics(container: true, 
      label: etiqueta, value: '${(v * 100).round()} %',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(height: 8, color: c.superficieFuerte, child: FractionallySizedBox(
          alignment: Alignment.centerLeft, widthFactor: v.toDouble(),
          child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), gradient: LinearGradient(
              colors: prediccion ? [c.prediccion, mezcla(Colors.white, .45, c.prediccion)] : [c.hoja, c.broteVivo, c.lima], stops: prediccion ? null : const [0, .7, 1]))),
        )),
      ),
    );
  }
}

/// sc-toast: confirmación breve en bosque con ícono redondo (✓ o aviso).
void aviso(BuildContext context, String titulo, {String? detalle, bool error = false, String? accion, VoidCallback? onAccion}) {
  final c = context.c;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating, elevation: 0, backgroundColor: Colors.transparent, padding: EdgeInsets.zero,
      duration: Duration(seconds: error ? 6 : 3),
      content: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
        decoration: BoxDecoration(color: c.bosque, borderRadius: BorderRadius.circular(16), boxShadow: context.sombraFlotante),
        child: Row(children: [
          Container(width: 30, height: 30, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: error ? const Color(0xFFFF8E80) : c.broteVivo),
              child: Icono(error ? 'aviso' : 'check', size: 16, color: c.bosque)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.sobreBosque)),
            if (detalle != null) Text(detalle, style: TextStyle(fontSize: 13, color: c.sobreBosqueSuave)),
          ])),
          if (accion != null) TextButton(onPressed: onAccion, child: Text(accion, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c.lima))),
        ]),
      ),
    ));
}

/// Pie de tarjeta (sc-foot): ícono pequeño y texto en tinta suave.
class Pie extends StatelessWidget {
  const Pie(this.texto, {super.key, this.icono = 'info'});
  final String texto, icono;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: SiscanSpace.s4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Icono(icono, size: 14, color: context.c.tintaSuave)),
          const SizedBox(width: 6),
          Expanded(child: Text(texto, style: TextStyle(fontSize: 13, height: 18 / 13, color: context.c.tintaSuave))),
        ]),
      );
}
