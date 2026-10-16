"""Convierte la escena `Landscape` del sistema (SVG ya corregido con svg_rgba_a_opacidad.py) a VectorDrawable de Android
con un encuadre propio (viewBox), para el reloj. Paso 4 del anexo 2026-10-12, contrato C2.

Cubre lo que usa la escena: rect (con rx), circle, ellipse y path; grupos con translate/rotate; fill, stroke y sus
opacidades; opacity de grupo (se multiplica en cada hijo: VectorDrawable no tiene alfa de grupo); y degradados
linear/radial en unidades del objeto (la caja del objeto se calcula aquí, porque VectorDrawable usa coordenadas absolutas).

Uso: python tools/svg_escena_a_vector.py <entrada.svg> <salida.xml> "<x> <y> <ancho> <alto>"
"""
import re
import sys
import xml.etree.ElementTree as ET

NS = '{http://www.w3.org/2000/svg}'
NOMBRES = {'white': '#ffffff', 'black': '#000000'}


def color(v):
    v = NOMBRES.get(v, v)
    if v.startswith('#') and len(v) == 4:
        v = '#' + ''.join(ch * 2 for ch in v[1:])
    if not re.fullmatch(r'#[0-9a-fA-F]{6}', v or ''):
        raise ValueError(f'color no soportado: {v}')
    return v[1:].upper()


def argb(hex6, alfa):
    return f'#{round(max(0.0, min(1.0, alfa)) * 255):02X}{hex6}'


def num(v):
    return f'{v:.3f}'.rstrip('0').rstrip('.')


def caja_trazado(d):
    """Caja de un trazado con comandos absolutos (los únicos que usan degradado en la escena)."""
    xs, ys = [], []
    for cmd, args in re.findall(r'([MLCHVZQSTA])([^MLCHVZQSTAmlchvzqsta]*)', d):
        n = [float(x) for x in re.findall(r'-?\d*\.?\d+(?:e-?\d+)?', args)]
        if cmd == 'H':
            xs += n
        elif cmd == 'V':
            ys += n
        elif cmd in 'MLCQST':
            xs += n[0::2]
            ys += n[1::2]
    if re.search(r'[mlchvqsta]', d):
        raise ValueError('degradado sobre trazado relativo: caja no exacta')
    return min(xs), min(ys), max(xs), max(ys)


def elipse(cx, cy, rx, ry):
    return (f'M{num(cx - rx)},{num(cy)} a{num(rx)},{num(ry)} 0 1,0 {num(2 * rx)},0 '
            f'a{num(rx)},{num(ry)} 0 1,0 {num(-2 * rx)},0 Z')


def rectangulo(x, y, w, h, rx):
    if not rx:
        return f'M{num(x)},{num(y)} h{num(w)} v{num(h)} h{num(-w)} Z'
    rx = min(rx, w / 2, h / 2)
    return (f'M{num(x + rx)},{num(y)} h{num(w - 2 * rx)} a{num(rx)},{num(rx)} 0 0,1 {num(rx)},{num(rx)} '
            f'v{num(h - 2 * rx)} a{num(rx)},{num(rx)} 0 0,1 {num(-rx)},{num(rx)} h{num(-(w - 2 * rx))} '
            f'a{num(rx)},{num(rx)} 0 0,1 {num(-rx)},{num(-rx)} v{num(-(h - 2 * rx))} '
            f'a{num(rx)},{num(rx)} 0 0,1 {num(rx)},{num(-rx)} Z')


def grupo_transform(t):
    """translate(x y) o rotate(a cx cy) → atributos de <group>."""
    m = re.fullmatch(r'\s*translate\(\s*([-\d.]+)[ ,]+([-\d.]+)\s*\)\s*', t)
    if m:
        return f'android:translateX="{m.group(1)}" android:translateY="{m.group(2)}"'
    m = re.fullmatch(r'\s*rotate\(\s*([-\d.]+)(?:[ ,]+([-\d.]+)[ ,]+([-\d.]+))?\s*\)\s*', t)
    if m:
        return f'android:rotation="{m.group(1)}" android:pivotX="{m.group(2) or 0}" android:pivotY="{m.group(3) or 0}"'
    raise ValueError(f'transform no soportado: {t}')


def convertir(entrada, salida, vista):
    raiz = ET.parse(entrada).getroot()
    grads = {}
    for g in raiz.iter():
        tag = g.tag.replace(NS, '')
        if tag in ('linearGradient', 'radialGradient'):
            paradas = [(float(s.get('offset', 0)), color(s.get('stop-color', '#000000')), float(s.get('stop-opacity', 1)))
                       for s in g if s.tag.replace(NS, '') == 'stop']
            grads[g.get('id')] = (tag, {k: g.get(k) for k in ('x1', 'y1', 'x2', 'y2', 'cx', 'cy', 'r')}, paradas)

    vx, vy, vw, vh = (float(x) for x in vista.split())
    out = []
    cuenta = {'trazados': 0}

    def pintar(el, d, caja, est, ind):
        fill, stroke = est['fill'], est['stroke']
        op = est['opacity']
        atrs = [f'android:pathData="{d}"']
        hijos = []
        if fill and fill != 'none':
            fa = op * est['fill-opacity']
            m = re.fullmatch(r'url\(#(.+)\)', fill)
            if m:
                tipo, a, paradas = grads[m.group(1)]
                x0, y0, x1, y1 = caja
                w, h = x1 - x0, y1 - y0
                def f(v, d0):
                    v = a.get(v) if a.get(v) is not None else d0
                    return float(v[:-1]) / 100 if str(v).endswith('%') else float(v)
                items = ''.join(f'<item android:offset="{num(o)}" android:color="{argb(c, al)}"/>' for o, c, al in paradas)
                if tipo == 'linearGradient':
                    g = (f'<gradient android:type="linear" android:startX="{num(x0 + f("x1", 0) * w)}" android:startY="{num(y0 + f("y1", 0) * h)}" '
                         f'android:endX="{num(x0 + f("x2", 1) * w)}" android:endY="{num(y0 + f("y2", 0) * h)}">{items}</gradient>')
                else:
                    g = (f'<gradient android:type="radial" android:centerX="{num(x0 + f("cx", .5) * w)}" android:centerY="{num(y0 + f("cy", .5) * h)}" '
                         f'android:gradientRadius="{num(f("r", .5) * max(w, h))}">{items}</gradient>')
                hijos.append(f'<aapt:attr name="android:fillColor">{g}</aapt:attr>')
                atrs.append(f'android:fillAlpha="{num(fa)}"')
            else:
                atrs.append(f'android:fillColor="{argb(color(fill), fa)}"')
        if stroke and stroke != 'none':
            atrs.append(f'android:strokeColor="{argb(color(stroke), op * est["stroke-opacity"])}"')
            atrs.append(f'android:strokeWidth="{est["stroke-width"]}"')
            if est.get('stroke-linecap'):
                atrs.append(f'android:strokeLineCap="{est["stroke-linecap"]}"')
            if est.get('stroke-linejoin'):
                atrs.append(f'android:strokeLineJoin="{est["stroke-linejoin"]}"')
        if len(atrs) == 1:
            return
        cuenta['trazados'] += 1
        sangria = '  ' * ind
        if hijos:
            out.append(f'{sangria}<path {" ".join(atrs)}>{"".join(hijos)}</path>')
        else:
            out.append(f'{sangria}<path {" ".join(atrs)}/>')

    def recorrer(el, est, ind):
        tag = el.tag.replace(NS, '')
        if tag in ('defs', 'linearGradient', 'radialGradient', 'stop', 'title'):
            return
        e = dict(est)
        for k in ('fill', 'stroke', 'stroke-width', 'stroke-linecap', 'stroke-linejoin'):
            if el.get(k) is not None:
                e[k] = el.get(k)
        for k in ('fill-opacity', 'stroke-opacity'):
            if el.get(k) is not None:
                e[k] = float(el.get(k))
        e['opacity'] = est['opacity'] * float(el.get('opacity', 1))
        t = el.get('transform')
        if t:
            out.append(f'{"  " * ind}<group {grupo_transform(t)}>')
            ind += 1
        g = lambda k, d=0.0: float(el.get(k, d))
        if tag in ('g', 'svg'):
            for h in el:
                recorrer(h, e, ind)
        elif tag == 'rect':
            x, y, w, h = g('x'), g('y'), g('width'), g('height')
            pintar(el, rectangulo(x, y, w, h, g('rx')), (x, y, x + w, y + h), e, ind)
        elif tag == 'circle':
            cx, cy, r = g('cx'), g('cy'), g('r')
            pintar(el, elipse(cx, cy, r, r), (cx - r, cy - r, cx + r, cy + r), e, ind)
        elif tag == 'ellipse':
            cx, cy, rx, ry = g('cx'), g('cy'), g('rx'), g('ry')
            pintar(el, elipse(cx, cy, rx, ry), (cx - rx, cy - ry, cx + rx, cy + ry), e, ind)
        elif tag == 'path':
            d = el.get('d')
            caja = caja_trazado(d) if str(e.get('fill', '')).startswith('url(') else None
            pintar(el, d, caja, e, ind)
        else:
            raise ValueError(f'elemento no soportado: {tag}')
        if t:
            out.append(f'{"  " * (ind - 1)}</group>')

    inicial = {'fill': '#000000', 'stroke': None, 'stroke-width': '1', 'opacity': 1.0, 'fill-opacity': 1.0, 'stroke-opacity': 1.0}
    out.append(f'  <group android:translateX="{num(-vx)}" android:translateY="{num(-vy)}">')
    for h in raiz:
        recorrer(h, inicial, 2)
    out.append('  </group>')
    cab = ('<?xml version="1.0" encoding="utf-8"?>\n'
           '<!-- Escena Landscape del sistema SISCAN v2, encuadre del reloj. GENERADO por tools/svg_escena_a_vector.py: no editar a mano. -->\n'
           '<vector xmlns:android="http://schemas.android.com/apk/res/android" xmlns:aapt="http://schemas.android.com/aapt" '
           f'android:width="{num(vw)}dp" android:height="{num(vh)}dp" android:viewportWidth="{num(vw)}" android:viewportHeight="{num(vh)}">\n')
    open(salida, 'w', encoding='utf-8').write(cab + '\n'.join(out) + '\n</vector>\n')
    return cuenta['trazados']


if __name__ == '__main__':
    print(convertir(sys.argv[1], sys.argv[2], sys.argv[3]), 'trazados')
