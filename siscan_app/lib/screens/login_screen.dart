import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/auth.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/landscape_band.dart';
import '../widgets/siscan_icon.dart';

/// Ingresar (referencia `LoginMovil`): «¡Hola! Bienvenido a SISCAN» sobre el paisaje y la hoja del formulario.
/// Usuario de WordPress del CISNA + **contraseña de aplicación** (no la contraseña normal); «Recordarme» la guarda
/// cifrada en el teléfono. Solo hace falta para controlar el equipo: mirar el secador no pide cuenta.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth});
  final AuthController auth;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController(), _pass = TextEditingController();
  bool _remember = true, _show = false;
  String? _error;

  Future<void> _submit() async {
    final err = await widget.auth.signIn(_user.text, _pass.text, remember: _remember);
    if (!mounted) return;
    if (err == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    InputDecoration deco(String hint, SiscanGlyph g, {Widget? suffix}) => InputDecoration(
          hintText: hint,
          hintStyle: SiscanType.cuerpo.copyWith(color: t.tierraSuave),
          filled: true, fillColor: t.papel,
          prefixIcon: Container(margin: const EdgeInsets.all(6), width: 40, decoration: BoxDecoration(color: t.arena, borderRadius: BorderRadius.circular(8)), child: Center(child: SiscanIcon(g, size: 20, color: t.tierra))),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(SiscanRadius.control), borderSide: BorderSide(color: t.lineaFuerte, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(SiscanRadius.control), borderSide: BorderSide(color: t.anil, width: 2)),
        );
    return Scaffold(
      backgroundColor: t.pergamino,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            color: t.monte,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(false), tooltip: 'Volver',
                icon: Transform.flip(flipX: true, child: SiscanIcon(SiscanGlyph.flecha, size: 24, color: t.sobreMonte)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('¡Hola!', style: SiscanType.titulo.copyWith(color: t.sobreMonte)),
                  Text('Bienvenido a SISCAN', style: SiscanType.cita.copyWith(color: t.sobreMonteSuave)),
                ]),
              ),
              const LandscapeBand(height: 72),
            ]),
          ),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SiscanSpace.s4),
              // Superficie Material (no una caja con color): la casilla y los botones pintan su respuesta encima.
              child: Material(
                color: t.papel,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SiscanRadius.loma)),
                child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: AutofillGroup(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Ingresar', style: SiscanType.titulo.copyWith(color: t.tierra)),
                  const SizedBox(height: SiscanSpace.s2),
                  Text('Para controlar el equipo. Mirar el secador no pide cuenta.', style: SiscanType.nota.copyWith(color: t.tierraSuave)),
                  const SizedBox(height: SiscanSpace.s5),
                  Text('Usuario o correo de WordPress', style: SiscanType.cuerpoFuerte.copyWith(fontSize: 14, color: t.tierra)),
                  const SizedBox(height: 6),
                  TextField(key: const Key('login-user'), controller: _user, autofillHints: const [AutofillHints.username], textInputAction: TextInputAction.next,
                      style: SiscanType.cuerpo.copyWith(color: t.tierra), decoration: deco('nombre@correo.com', SiscanGlyph.correo)),
                  const SizedBox(height: SiscanSpace.s4),
                  Text('Contraseña de aplicación', style: SiscanType.cuerpoFuerte.copyWith(fontSize: 14, color: t.tierra)),
                  const SizedBox(height: 6),
                  TextField(
                    key: const Key('login-pass'), controller: _pass, obscureText: !_show, autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _submit(), style: SiscanType.tabla.copyWith(fontSize: 16, color: t.tierra),
                    decoration: deco('xxxx xxxx xxxx xxxx xxxx xxxx', SiscanGlyph.candado, suffix: IconButton(
                      tooltip: _show ? 'Ocultar' : 'Mostrar', onPressed: () => setState(() => _show = !_show),
                      icon: SiscanIcon(_show ? SiscanGlyph.ojoCerrado : SiscanGlyph.ojo, size: 22, color: t.tierraSuave),
                    )),
                  ),
                  const SizedBox(height: 6),
                  Text('No es tu contraseña normal: la creas en tu perfil de WordPress y puedes revocarla cuando quieras.',
                      style: SiscanType.nota.copyWith(color: t.tierraSuave)),
                  TextButton(
                    onPressed: () => launchUrl(widget.auth.authorizeUrl, mode: LaunchMode.externalApplication),
                    style: TextButton.styleFrom(foregroundColor: t.arcilla, padding: EdgeInsets.zero, minimumSize: const Size(48, 44)),
                    child: Text('Crear una contraseña de aplicación', style: SiscanType.cuerpoFuerte.copyWith(fontSize: 14, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.wavy)),
                  ),
                  CheckboxListTile(
                    value: _remember, onChanged: (v) => setState(() => _remember = v ?? false),
                    contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, dense: true,
                    activeColor: t.cafeto, checkColor: t.papel,
                    title: Text('Recordarme en este equipo', style: SiscanType.cuerpo.copyWith(fontSize: 15, color: t.tierra)),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: SiscanSpace.s2),
                    Semantics(liveRegion: true, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SiscanIcon(SiscanGlyph.alerta, size: 18, color: t.oxido),
                      const SizedBox(width: SiscanSpace.s2),
                      Expanded(child: Text(_error!, style: SiscanType.nota.copyWith(color: t.oxido, fontWeight: FontWeight.w700))),
                    ])),
                  ],
                  const SizedBox(height: SiscanSpace.s4),
                  ListenableBuilder(
                    listenable: widget.auth,
                    builder: (context, _) => SizedBox(
                      width: double.infinity, height: 56,
                      child: FilledButton(
                        key: const Key('login-submit'),
                        onPressed: widget.auth.busy ? null : _submit,
                        style: FilledButton.styleFrom(backgroundColor: t.arcilla, foregroundColor: t.sobreArcilla,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SiscanRadius.control))),
                        child: Text(widget.auth.busy ? 'Verificando…' : 'Ingresar', style: SiscanType.cuerpoFuerte.copyWith(fontSize: 17)),
                      ),
                    ),
                  ),
                ]),
              ),
              ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
