import 'package:flutter/material.dart';

import 'theme/theme.dart';
import 'theme/tokens.dart';
import 'theme/typography.dart';
import 'widgets/connection_status.dart';
import 'widgets/landscape_band.dart';
import 'widgets/siscan_icon.dart';

/// Destinos de la navegación inferior móvil (plataformas.md): Inicio · Controles · Predicción · Alertas.
enum AppTab { inicio, controles, prediccion, alertas }

extension AppTabInfo on AppTab {
  String get label => switch (this) { AppTab.inicio => 'Inicio', AppTab.controles => 'Controles', AppTab.prediccion => 'Predicción', AppTab.alertas => 'Alertas' };
  SiscanGlyph get glyph => switch (this) { AppTab.inicio => SiscanGlyph.solar, AppTab.controles => SiscanGlyph.ventilador, AppTab.prediccion => SiscanGlyph.prediccion, AppTab.alertas => SiscanGlyph.alerta };
}

/// Esqueleto de la app (referencia `InicioMovil`): banda `monte` con el wordmark y la conexión, paisaje «loma» de 84 px,
/// contenido que sube 28 px sobre la banda y navegación inferior en `papel` (destinos ≥ 48 px, activo en arcilla).
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.pageBuilder, required this.sol, required this.onSol, this.sync = SyncStatus.conectado, this.initial = AppTab.inicio, this.alertCount = 0, this.account});
  /// Construye cada destino; recibe cómo ir a otro (p. ej. «Ver las alertas» desde Inicio).
  final Widget Function(AppTab tab, ValueChanged<AppTab> goTo) pageBuilder;
  final bool sol;
  final ValueChanged<bool> onSol;
  final SyncStatus sync;
  final AppTab initial;
  final int alertCount;
  /// Fila de la cuenta en Ajustes (ingresar / cerrar sesión).
  final Widget? account;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AppTab _tab = widget.initial;

  void _openSettings() {
    final t = context.sc;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.papel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(SiscanRadius.hoja))),
      builder: (_) => _SettingsSheet(sol: widget.sol, account: widget.account, onSol: (v) { widget.onSol(v); Navigator.pop(context); }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: t.pergamino,
      // Banda y contenido en una sola columna: lo que va después se pinta encima, así la hoja que sube 28 px queda
      // sobre la banda (en un CustomScrollView la primera sección se pinta por encima y la tapaba).
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            color: t.monte,
            padding: EdgeInsets.only(top: top + 14),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
                child: Row(children: [
                  Semantics(header: true, child: Text('SISCAN', style: SiscanType.seccion.copyWith(color: t.sobreMonte,
                      fontVariations: const [FontVariation('SOFT', 100), FontVariation('WONK', 1), FontVariation('wght', 600)]))),
                  const SizedBox(width: SiscanSpace.s3),
                  // La píldora cede ancho antes que el wordmark o el botón de Ajustes (nunca se desborda).
                  Expanded(child: Align(alignment: Alignment.centerRight, child: ConnectionStatus(widget.sync, onDark: true))),
                  IconButton(
                    onPressed: _openSettings, tooltip: 'Ajustes', padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: SiscanIcon(SiscanGlyph.usuario, size: 24, color: t.sobreMonte, semanticLabel: 'Ajustes'),
                  ),
                ]),
              ),
              const LandscapeBand(),
            ]),
          ),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: SiscanSpace.s4), child: KeyedSubtree(key: ValueKey(_tab), child: widget.pageBuilder(_tab, (v) => setState(() => _tab = v)))),
          ),
          const SizedBox(height: SiscanSpace.s4),
        ]),
      ),
      bottomNavigationBar: _BottomNav(current: _tab, alertCount: widget.alertCount, onTap: (v) => setState(() => _tab = v)),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.current, required this.onTap, required this.alertCount});
  final AppTab current;
  final ValueChanged<AppTab> onTap;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    return Container(
      decoration: BoxDecoration(color: t.papel, border: Border(top: BorderSide(color: t.linea))),
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
      child: Row(children: [
        for (final tab in AppTab.values)
          Expanded(
            child: Semantics(
              button: true, selected: tab == current,
              label: tab.label + (tab == AppTab.alertas && alertCount > 0 ? ', $alertCount sin revisar' : ''),
              excludeSemantics: true,
              child: InkWell(
                key: Key('nav-${tab.name}'),
                borderRadius: BorderRadius.circular(14),
                onTap: () => onTap(tab),
                child: AnimatedContainer(
                  duration: MediaQuery.of(context).disableAnimations ? Duration.zero : const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(minHeight: 56),
                  decoration: BoxDecoration(color: tab == current ? t.arcillaSuave : null, borderRadius: BorderRadius.circular(14)),
                  child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Stack(clipBehavior: Clip.none, children: [
                      SiscanIcon(tab.glyph, size: 24, color: tab == current ? t.arcilla : t.tierraSuave),
                      if (tab == AppTab.alertas && alertCount > 0)
                        Positioned(right: -10, top: -6, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: t.oxido, borderRadius: BorderRadius.circular(SiscanRadius.grano)),
                          child: Text('$alertCount', style: SiscanType.tabla.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: t.sobreOxido)),
                        )),
                    ]),
                    const SizedBox(height: 4),
                    Text(tab.label, style: SiscanType.etiqueta.copyWith(letterSpacing: 0, color: tab == current ? t.arcilla : t.tierraSuave)),
                  ]),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({required this.sol, required this.onSol, this.account});
  final bool sol;
  final Widget? account;
  final ValueChanged<bool> onSol;

  @override
  Widget build(BuildContext context) {
    final t = context.sc;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(SiscanSpace.s5, SiscanSpace.s5, SiscanSpace.s5, SiscanSpace.s4),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Ajustes', style: SiscanType.seccion.copyWith(color: t.tierra)),
          const SizedBox(height: SiscanSpace.s4),
          if (account != null) ...[account!, Divider(height: SiscanSpace.s6, color: t.linea)],
          MergeSemantics(
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pleno sol', style: SiscanType.cuerpoFuerte.copyWith(color: t.tierra)),
                Text('Fondos más claros y tintas más oscuras para leer bajo el sol directo.', style: SiscanType.nota.copyWith(color: t.tierraSuave)),
              ])),
              const SizedBox(width: SiscanSpace.s3),
              Switch(value: sol, onChanged: onSol, activeThumbColor: t.papel, activeTrackColor: t.cafeto,
                  inactiveThumbColor: t.lineaFuerte, inactiveTrackColor: t.arena, trackOutlineColor: WidgetStatePropertyAll(t.lineaFuerte)),
            ]),
          ),
        ]),
      ),
    );
  }
}
