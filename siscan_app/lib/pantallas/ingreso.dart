import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/contexto.dart';
import '../app/preferencias.dart';
import '../core/theme/siscan_theme.dart';
import '../core/theme/siscan_tokens.dart';
import '../core/ui/base.dart';
import '../core/ui/dominio.dart';
import '../core/ui/marco.dart';

/// Pantalla de carga (AndroidIngreso): bosque con el símbolo y el wordmark claros, «Leyendo el secador…».
class PantallaCarga extends StatelessWidget {
  const PantallaCarga({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(gradient: RadialGradient(center: const Alignment(0, -.2), radius: .9, colors: [const Color(0xFF23452F), c.bosqueHondo])),
        child: Stack(alignment: Alignment.center, children: [
          const Column(mainAxisSize: MainAxisSize.min, children: [Logo(variante: 'simbolo', claro: true, alto: 120), SizedBox(height: 18), Logo(variante: 'wordmark', claro: true, alto: 46)]),
          Positioned(bottom: 40 + MediaQuery.of(context).padding.bottom, child: Row(children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: c.sobreBosqueSuave)),
            const SizedBox(width: 10),
            Text('Leyendo el secador…', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.sobreBosqueSuave, decoration: TextDecoration.none, fontFamily: SiscanType.ui)),
          ])),
        ]),
      ),
    );
  }
}

/// Ingreso (AndroidIngreso): paisaje arriba con el logo en placa, hoja inferior con correo y contraseña de aplicación;
/// con huella activada, se entra tocando el sensor. Mirar el secador no pide cuenta.
class PantallaIngreso extends StatefulWidget {
  const PantallaIngreso({super.key, required this.onListo});
  final VoidCallback onListo;
  @override
  State<PantallaIngreso> createState() => _PantallaIngresoState();
}

class _PantallaIngresoState extends State<PantallaIngreso> {
  final _usuario = TextEditingController(), _clave = TextEditingController();
  bool _recordar = true, _conClave = false;
  String? _error;

  Future<void> _entrar() async {
    final s = Siscan.of(context);
    final e = await s.auth.signIn(_usuario.text, _clave.text, remember: _recordar);
    if (!mounted) return;
    setState(() => _error = e);
    if (e == null) widget.onListo();
  }

  Future<void> _huella() async {
    final s = Siscan.of(context);
    if (!await Preferencias.verificarHuella('Ingresa a SISCAN con tu huella')) return;
    await s.auth.restore();
    if (!mounted) return;
    if (s.auth.session != null) { widget.onListo(); } else { setState(() { _conClave = true; _error = 'No pudimos usar la credencial guardada. Ingresa con tu contraseña.'; }); }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c, s = Siscan.of(context), pref = Preferencias.of(context);
    final bio = pref.huella && !_conClave;
    return AnnotatedRegion<SystemUiOverlayStyle>(value: SystemUiOverlayStyle.dark, child: Scaffold(
      backgroundColor: c.superficie,
      body: ListenableBuilder(listenable: s.auth, builder: (context, _) => SingleChildScrollView(child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        child: IntrinsicHeight(child: Column(children: [
          SizedBox(height: 330, child: Stack(fit: StackFit.expand, children: [
            const Paisaje(encuadre: 'movil', variante: 'day'),
            Positioned(left: 18, top: 44 + MediaQuery.of(context).padding.top, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .75), borderRadius: BorderRadius.circular(14)),
              child: const Logo(alto: 40))),
          ])),
          Expanded(child: Transform.translate(offset: const Offset(0, -36), child: Container(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
            decoration: BoxDecoration(color: c.superficie, borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: const Color(0xFF10261B).withValues(alpha: .12), blurRadius: 24, offset: const Offset(0, -8))]),
            child: AutofillGroup(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: c.lineaFuerte.withValues(alpha: .5), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 14),
              Semantics(container: true, header: true, child: Text(bio ? 'Hola de nuevo' : 'Ingresa a SISCAN', style: TextStyle(fontFamily: SiscanType.display, fontSize: 26, fontWeight: FontWeight.w700, color: c.tinta))),
              const SizedBox(height: 6),
              Text(bio ? 'Usa tu huella para entrar rápido.' : 'Con tu cuenta del portal CISNA y una contraseña de aplicación.', style: TextStyle(fontSize: 14, color: c.tintaSuave)),
              const SizedBox(height: 14),
              if (_error != null) Container(
                margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: c.alertaSuave, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [Icono('aviso', size: 16, color: c.alerta), const SizedBox(width: 8), Expanded(child: Text(_error!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.alerta)))])),
              if (bio) Semantics(container: true, button: true, label: 'Toca el sensor de huella', child: InkWell(
                onTap: _huella, borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: c.superficieHoja, borderRadius: BorderRadius.circular(24), border: Border.all(color: c.hoja, width: 1.5)),
                  child: Column(children: [
                    Container(width: 84, height: 84, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: c.brote), child: Icono('huella', size: 44, color: c.hoja)),
                    const SizedBox(height: 12),
                    Text('Toca el sensor de huella', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.hoja)),
                  ]),
                ),
              ))
              else ...[
                Campo(etiqueta: 'Usuario o correo', icono: 'correo', controller: _usuario, grande: true, teclado: TextInputType.emailAddress, autofill: const [AutofillHints.username, AutofillHints.email]),
                const SizedBox(height: 14),
                Campo(etiqueta: 'Contraseña de aplicación', icono: 'candado', controller: _clave, grande: true, clave: true, autofill: const [AutofillHints.password],
                    pista: 'No es tu contraseña normal: la creas en tu perfil de WordPress y puedes revocarla cuando quieras.'),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: Casilla(valor: _recordar, onChanged: (v) => setState(() => _recordar = v), texto: 'Recordarme')),
                  TextButton(onPressed: () => launchUrl(s.auth.authorizeUrl, mode: LaunchMode.externalApplication), style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                      child: Text('Crear contraseña', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.hoja))),
                ]),
              ],
              const SizedBox(height: 14),
              Boton(bio ? 'Usar correo y contraseña' : 'Ingresar', variante: bio ? VarianteBoton.ghost : VarianteBoton.primary, grande: true, bloque: true, ocupado: s.auth.busy,
                  onPressed: bio ? () => setState(() => _conClave = true) : _entrar),
              if (!bio && pref.huella) TextButton.icon(onPressed: () => setState(() => _conClave = false), icon: Icono('huella', size: 18, color: c.hoja),
                  label: Text('Ingresar con huella', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: c.hoja))),
              const Spacer(),
              TextButton(onPressed: widget.onListo, style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                  child: Text('Ver el secador sin cuenta (solo lectura)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.hoja))),
              Text('Subsecretaría de Innovación · Gobernación de Nariño', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: c.tintaSuave)),
            ])),
          ))),
        ])),
      ))),
    ));
  }
}
