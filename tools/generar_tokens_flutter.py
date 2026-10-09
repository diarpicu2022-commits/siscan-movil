"""Genera siscan_app/lib/core/theme/siscan_tokens.dart desde tokens.json del sistema de diseño SISCAN v2.

Lo que pide 06-arquitectura.md: SiscanColors como ThemeExtension (claro y oscuro), SiscanType, SiscanSpace, SiscanRadius,
SiscanMotion; nombres en camelCase (superficie-hoja → superficieHoja). No se edita a mano: se regenera.

Uso: python tools/generar_tokens_flutter.py [tokens.json]
"""
import json
import os
import re
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
ENTRADA = sys.argv[1] if len(sys.argv) > 1 else r'C:\dev\siscan-ds-nuevo\siscan-design-system\tokens.json'
SALIDA = os.path.join(AQUI, '..', 'siscan_app', 'lib', 'core', 'theme', 'siscan_tokens.dart')


def camel(n):
    p = n.split('-')
    return p[0] + ''.join(x[:1].upper() + x[1:] for x in p[1:])


def color(hexa):
    h = hexa.lstrip('#')
    if len(h) == 3:
        h = ''.join(c * 2 for c in h)
    return 'Color(0xFF' + h.upper() + ')'


def px(v):
    return float(str(v).replace('px', ''))


def sombras(v):
    out = []
    for parte in re.split(r',\s*(?![^()]*\))', v):
        m = re.match(r'\s*(-?[\d.]+)(?:px)?\s+(-?[\d.]+)(?:px)?\s+(-?[\d.]+)(?:px)?(?:\s+(-?[\d.]+)(?:px)?)?\s+rgba\(([\d.]+),\s*([\d.]+),\s*([\d.]+),\s*([\d.]+)\)', parte)
        if not m:
            continue
        x, y, blur, spread, r, g, b, a = m.groups()
        out.append(f'BoxShadow(offset: Offset({float(x)}, {float(y)}), blurRadius: {float(blur)}, spreadRadius: {float(spread or 0)}, color: Color.fromRGBO({r}, {g}, {b}, {a}))')
    return '[' + ', '.join(out) + ']'


def main():
    t = json.load(open(ENTRADA, encoding='utf-8'))
    toks = t['color']['tokens']
    crudo = {c['name']: c['value'] for c in toks}

    def resolver(nombre, tema):
        v = crudo[nombre][tema] if isinstance(crudo[nombre], dict) else crudo[nombre]
        while isinstance(v, str) and v.startswith('{'):
            v = crudo[v.strip('{}')]
            v = v[tema] if isinstance(v, dict) else v
        m = re.match(r'var\(--([a-z0-9-]+)\)', v) if isinstance(v, str) else None
        return resolver(m.group(1), tema) if m else v

    nombres = [c['name'] for c in toks]
    L = ['// GENERADO por tools/generar_tokens_flutter.py desde tokens.json del sistema de diseño SISCAN v2. No editar a mano.',
         "import 'package:flutter/material.dart';", '',
         '/// Colores del sistema (temas claro y oscuro). El reloj usa siempre el oscuro.',
         '@immutable', 'class SiscanColors extends ThemeExtension<SiscanColors> {', '  const SiscanColors({']
    L += [f'    required this.{camel(n)},' for n in nombres]
    L += ['  });']
    for c in toks:
        L.append(f"  /// {c.get('usage', '')}".rstrip())
        L.append(f'  final Color {camel(c["name"])};')
    for tema in ('claro', 'oscuro'):
        L.append(f'  static const {tema} = SiscanColors(')
        L += [f'    {camel(n)}: {color(resolver(n, tema))},' for n in nombres]
        L.append('  );')
    L.append('  @override')
    L.append('  SiscanColors copyWith() => this;')
    L.append('  @override')
    L.append('  SiscanColors lerp(ThemeExtension<SiscanColors>? other, double t) {')
    L.append('    if (other is! SiscanColors) return this;')
    L.append('    return SiscanColors(')
    L += [f'      {camel(n)}: Color.lerp({camel(n)}, other.{camel(n)}, t)!,' for n in nombres]
    L += ['    );', '  }', '}', '']

    fam = {'display': 'Outfit', 'ui': 'PlusJakartaSans'}
    L += ['/// Estilos de texto del sistema. Outfit (display) para saludos y cifras protagonistas; Plus Jakarta Sans (ui) para todo lo demás.',
          'class SiscanType {', '  SiscanType._();', "  static const display = 'Outfit';", "  static const ui = 'PlusJakartaSans';",
          '  static const _tab = [FontFeature.tabularFigures()];']
    for g in t['type']['groups']:
        for st in g['styles']:
            f = fam[st.get('family', g['family'])]
            size = px(st['fontSize'])
            lh = px(st['lineHeight']) / size
            ls = st.get('letterSpacing')
            ls = float(ls.replace('em', '')) * size if ls else 0.0
            tab = ', fontFeatures: _tab' if st['name'].startswith('lectura') else ''
            L.append(f"  /// {st.get('usage', '')}")
            L.append(f"  static const {camel(st['name'])} = TextStyle(fontFamily: '{f}', fontSize: {size}, height: {lh:.4f}, fontWeight: FontWeight.w{st['fontWeight']}, letterSpacing: {ls:.3f}{tab});")
    L += ['}', '']

    def grupo(clase, clave, doc):
        L.append(f'/// {doc}')
        L.append(f'class {clase} {{')
        L.append(f'  {clase}._();')
        for x in t[clave]['tokens']:
            n = camel(re.sub(r'^(space|radius|size)-', '', x['name']))
            n = 's' + n if n[0].isdigit() else n
            L.append(f"  /// {x.get('usage', '')}")
            L.append(f"  static const double {n} = {px(x['value'])};")
        L.append('}')
        L.append('')

    grupo('SiscanSpace', 'spacing', 'Espaciado (base de 4).')
    grupo('SiscanRadius', 'radius', 'Radios.')
    grupo('SiscanSize', 'size', 'Medidas fijas (toque mínimo, íconos, reloj).')

    L += ['/// Duraciones y curvas. Las de «SIEMPRE» se mantienen mientras el estado exista; con movimiento reducido, quietas.',
          'class SiscanMotion {', '  SiscanMotion._();']
    for x in t['duration']['tokens']:
        L.append(f"  /// {x.get('usage', '')}")
        L.append(f"  static const {camel(x['name'].replace('dur-', ''))} = Duration(milliseconds: {int(px(x['value'].replace('ms', '')))});")
    for x in t['easing']['tokens']:
        nums = re.findall(r'[\d.]+', x['value'])
        L.append(f"  /// {x.get('usage', '')}")
        L.append(f"  static const {camel(x['name'].replace('ease-', ''))} = Cubic({', '.join(nums)});")
    L += ['}', '']

    L += ['/// Sombras por tema.', 'class SiscanShadow {', '  SiscanShadow._();']
    for x in t['shadow']['tokens']:
        n = camel(x['name'].replace('sombra-', ''))
        for tema in ('claro', 'oscuro'):
            L.append(f"  static const {n}{tema.capitalize()} = {sombras(x['value'][tema])};")
        L.append(f"  static List<BoxShadow> {n}(Brightness b) => b == Brightness.dark ? {n}Oscuro : {n}Claro;")
    L += ['}', '']

    os.makedirs(os.path.dirname(SALIDA), exist_ok=True)
    open(SALIDA, 'w', encoding='utf-8', newline='\n').write('\n'.join(L))
    print(os.path.abspath(SALIDA), len(nombres), 'colores')


if __name__ == '__main__':
    main()
