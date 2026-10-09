"""Genera los recursos del reloj (siscan_reloj) desde el sistema de diseño SISCAN v2.

1. app/src/main/java/.../reloj/Tokens.kt: colores del tema oscuro (el reloj va siempre en oscuro, 07-smartwatch.md),
   duraciones y medidas del reloj, desde tokens.json.
2. app/src/main/res/drawable/sc_<icono>.xml: los iconos del sistema como VectorDrawable (trazo, mismo grosor), desde
   los SVG exportados del paquete (siscan_app/assets/sistema/iconos). Se convierten círculos, elipses, líneas, rectángulos
   y polilíneas a trazados, y se aplica la transformación de grupo.
3. app/src/main/res/font: Outfit y Plus Jakarta Sans del paquete (OFL).

No se edita a mano: se regenera. Uso: python tools/generar_reloj.py
"""
import json
import math
import os
import re
import shutil
import xml.etree.ElementTree as ET

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.join(AQUI, '..')
DS = r'C:\dev\siscan-ds-nuevo\siscan-design-system'
RELOJ = os.path.join(RAIZ, 'siscan_reloj', 'app', 'src', 'main')
PAQ = 'co.gov.narino.cisna.siscan.reloj'


def camel(n):
    p = n.split('-')
    return p[0] + ''.join(x[:1].upper() + x[1:] for x in p[1:])


def tokens():
    t = json.load(open(os.path.join(DS, 'tokens.json'), encoding='utf-8'))
    toks = t['color']['tokens']
    crudo = {c['name']: c['value'] for c in toks}

    def resolver(nombre, tema='oscuro'):
        v = crudo[nombre][tema] if isinstance(crudo[nombre], dict) else crudo[nombre]
        while isinstance(v, str) and v.startswith('{'):
            v = crudo[v.strip('{}')]
            v = v[tema] if isinstance(v, dict) else v
        m = re.match(r'var\(--([a-z0-9-]+)\)', v) if isinstance(v, str) else None
        return resolver(m.group(1), tema) if m else v

    L = ['// GENERADO por tools/generar_reloj.py desde tokens.json del sistema de diseño SISCAN v2. No editar a mano.',
         f'package {PAQ}', '', 'import androidx.compose.ui.graphics.Color', '',
         '/** Colores del tema oscuro: el reloj va siempre en oscuro sobre negro (07-smartwatch.md). */', 'object Sc {']
    for c in toks:
        h = resolver(c['name']).lstrip('#')
        if len(h) == 3:
            h = ''.join(x * 2 for x in h)
        L.append(f"    /** {c.get('usage', '')} */".replace('/**  */', '').rstrip())
        L.append(f"    val {camel(c['name'])} = Color(0xFF{h.upper()})")
    L.append('}')
    L += ['', '/** Duraciones del sistema (ms). */', 'object ScDur {']
    for x in t['duration']['tokens']:
        L.append(f"    const val {camel(x['name'].replace('dur-', ''))} = {int(float(x['value'].replace('ms', '')))}")
    L.append('}')
    tam = {x['name']: float(x['value'].replace('px', '')) for x in t['size']['tokens']}
    L += ['', '/** Medidas del reloj: la esfera de la documentación (224 px) equivale a la pantalla; toque mínimo 48. */', 'object ScReloj {',
          f"    const val ESFERA = {tam['size-reloj']}f", f"    const val TOQUE = {tam['size-toque-reloj']}f", '}', '']
    salida = os.path.join(RELOJ, 'java', *PAQ.split('.'), 'Tokens.kt')
    open(salida, 'w', encoding='utf-8', newline='\n').write('\n'.join(L))
    print('Tokens.kt', len(toks), 'colores')


def num(v):
    return float(v or 0)


def a_trazado(el):
    tag = el.tag.split('}')[-1]
    g = el.attrib.get
    if tag == 'path':
        return g('d')
    if tag == 'circle':
        cx, cy, r = num(g('cx')), num(g('cy')), num(g('r'))
        return f'M{cx - r},{cy}a{r},{r} 0 1,0 {2 * r},0a{r},{r} 0 1,0 {-2 * r},0'
    if tag == 'ellipse':
        cx, cy, rx, ry = num(g('cx')), num(g('cy')), num(g('rx')), num(g('ry'))
        return f'M{cx - rx},{cy}a{rx},{ry} 0 1,0 {2 * rx},0a{rx},{ry} 0 1,0 {-2 * rx},0'
    if tag == 'line':
        return f"M{num(g('x1'))},{num(g('y1'))}L{num(g('x2'))},{num(g('y2'))}"
    if tag in ('polyline', 'polygon'):
        p = re.findall(r'-?[\d.]+', g('points'))
        pts = [f'{p[i]},{p[i + 1]}' for i in range(0, len(p), 2)]
        return 'M' + 'L'.join(pts) + ('Z' if tag == 'polygon' else '')
    if tag == 'rect':
        x, y, w, h = num(g('x')), num(g('y')), num(g('width')), num(g('height'))
        r = min(num(g('rx') or g('ry')), w / 2, h / 2)
        if r <= 0:
            return f'M{x},{y}h{w}v{h}h{-w}Z'
        return (f'M{x + r},{y}h{w - 2 * r}a{r},{r} 0 0,1 {r},{r}v{h - 2 * r}a{r},{r} 0 0,1 {-r},{r}'
                f'h{-(w - 2 * r)}a{r},{r} 0 0,1 {-r},{-r}v{-(h - 2 * r)}a{r},{r} 0 0,1 {r},{-r}Z')
    return None


def grupo_android(t):
    """transform de SVG (rotate/translate/scale) → atributos de <group>."""
    at = {}
    for fn, args in re.findall(r'(rotate|translate|scale)\(([^)]*)\)', t or ''):
        a = [float(x) for x in re.findall(r'-?[\d.]+', args)]
        if fn == 'rotate':
            at['android:rotation'] = a[0]
            if len(a) == 3:
                at['android:pivotX'], at['android:pivotY'] = a[1], a[2]
        elif fn == 'translate':
            at['android:translateX'] = a[0]
            at['android:translateY'] = a[1] if len(a) > 1 else 0
        else:
            at['android:scaleX'] = a[0]
            at['android:scaleY'] = a[1] if len(a) > 1 else a[0]
    return at


def iconos():
    ns = '{http://www.w3.org/2000/svg}'
    src = os.path.join(RAIZ, 'siscan_app', 'assets', 'sistema', 'iconos')
    dest = os.path.join(RELOJ, 'res', 'drawable')
    os.makedirs(dest, exist_ok=True)
    n = 0
    for f in sorted(os.listdir(src)):
        raiz = ET.parse(os.path.join(src, f)).getroot()
        ancho = raiz.attrib.get('stroke-width', '1.75')

        def pintar(el, sangria):
            out = []
            for h in el:
                tag = h.tag.replace(ns, '')
                if tag == 'g':
                    at = grupo_android(h.attrib.get('transform'))
                    attrs = ''.join(f' {k}="{v:g}"' for k, v in at.items())
                    out.append(f'{sangria}<group{attrs}>')
                    out += pintar(h, sangria + '    ')
                    out.append(f'{sangria}</group>')
                    continue
                d = a_trazado(h)
                if not d:
                    continue
                relleno = h.attrib.get('fill')
                lleno = relleno not in (None, 'none')
                trazo = h.attrib.get('stroke', '')
                attrs = f' android:pathData="{d}"'
                if lleno:
                    attrs += ' android:fillColor="#FFFFFFFF"'
                if trazo != 'none':
                    attrs += f' android:strokeColor="#FFFFFFFF" android:strokeWidth="{h.attrib.get("stroke-width", ancho)}" android:strokeLineCap="round" android:strokeLineJoin="round"'
                if h.tag.replace(ns, '') == 'g':
                    continue
                out.append(f'{sangria}<path{attrs} />')
            return out

        cuerpo = pintar(raiz, '    ')
        nombre = 'sc_' + re.sub(r'([A-Z])', lambda m: '_' + m.group(1).lower(), f[:-4])
        xml = ['<?xml version="1.0" encoding="utf-8"?>',
               f'<!-- GENERADO por tools/generar_reloj.py desde el icono «{f[:-4]}» del sistema SISCAN v2. -->',
               '<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="24dp" android:height="24dp"',
               '    android:viewportWidth="24" android:viewportHeight="24">'] + cuerpo + ['</vector>', '']
        open(os.path.join(dest, nombre + '.xml'), 'w', encoding='utf-8', newline='\n').write('\n'.join(xml))
        n += 1
    print(n, 'iconos')


def fuentes():
    src = os.path.join(RAIZ, 'siscan_app', 'assets', 'fonts', 'nuevas')
    dest = os.path.join(RELOJ, 'res', 'font')
    os.makedirs(dest, exist_ok=True)
    shutil.copy(os.path.join(src, 'Outfit.ttf'), os.path.join(dest, 'outfit.ttf'))
    shutil.copy(os.path.join(src, 'PlusJakartaSans.ttf'), os.path.join(dest, 'plus_jakarta_sans.ttf'))
    print('fuentes')


if __name__ == '__main__':
    tokens()
    iconos()
    fuentes()
