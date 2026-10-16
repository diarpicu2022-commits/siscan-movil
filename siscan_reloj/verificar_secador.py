"""Verificación medida de «El secador» en el reloj (paso 4 del anexo 2026-10-12, C2), sobre capturas reales del emulador.

1. Contraste sobre el render: dentro de cada caja (cifra, unidad, ícono de la placa y la hora sobre su banda), el fondo es
   el color más frecuente de la placa o de la banda, y la tinta es el píxel que más se aleja de él (el núcleo del glifo).
   Pisos: cifra AAA (texto grande 4,5; se informa también contra 7), unidad AA 4,5, ícono 3 (no texto), hora AA 4,5.
2. Ambiente (quemado OLED): porcentaje de píxeles encendidos (algún canal > 16/255) y luminancia media de la pantalla.

Uso: python verificar_secador.py <carpeta de capturas>   (espera 227-day.png … 192-night.png y ambiente.png)
La placa se busca en cada captura (sirve para cualquier posición); la banda de la hora es fija, a 454 × 454.
"""
import sys
from collections import Counter
from pathlib import Path

from PIL import Image


def lum(c):
    def f(v):
        v /= 255
        return v / 12.92 if v <= .03928 else ((v + .055) / 1.055) ** 2.4
    return .2126 * f(c[0]) + .7152 * f(c[1]) + .0722 * f(c[2])


def ratio(a, b):
    x, y = lum(a), lum(b)
    return (max(x, y) + .05) / (min(x, y) + .05)


def pixeles(im, caja):
    x0, y0, x1, y1 = caja
    return [im.getpixel((x, y)) for y in range(y0, y1) for x in range(x0, x1)]


def medir(im, caja_fondo, caja_tinta):
    fondo = Counter(pixeles(im, caja_fondo)).most_common(1)[0][0]
    tinta = max(pixeles(im, caja_tinta), key=lambda p: ratio(p, fondo))
    return fondo, tinta, ratio(tinta, fondo)


BOSQUE = (11, 23, 17)  # Sc.bosque: fondo de la placa y de la banda de la hora
HORA = ((192, 12, 262, 36), (197, 14, 256, 33))  # banda de la hora; tinta: solo los dígitos (fuera de la banda está el cielo)


def cajas_placa(im):
    """Busca la placa (bloque bosque por debajo de la banda de la hora) y, por columnas, ícono, cifra y unidad."""
    w, h = im.size
    pts = [(x, y) for y in range(80, h - 20) for x in range(20, w - 20) if im.getpixel((x, y)) == BOSQUE]
    x0, x1 = min(p[0] for p in pts), max(p[0] for p in pts)
    y0, y1 = min(p[1] for p in pts), max(p[1] for p in pts)
    yi0, yi1, cy, r = y0 + 6, y1 - 6, (y0 + y1) // 2, (y1 - y0) // 2
    # Lejos de las puntas redondeadas (ahí asoma la escena): columnas desde un radio adentro, filas en la franja central.
    cols = [x for x in range(x0 + r // 2, x1 - r // 2) if any(ratio(im.getpixel((x, y)), BOSQUE) > 1.5 for y in range(cy - 10, cy + 10))]
    grupos, g = [], [cols[0]]
    for x in cols[1:]:
        if x - g[-1] > 6:
            grupos.append(g)
            g = [x]
        else:
            g.append(x)
    grupos.append(g)
    caja = lambda gs, a=yi0, b=yi1: (min(gs[0]), a, max(gs[-1]) + 1, b)
    placa = (x0 + 4, y0 + 4, x1 - 4, y1 - 4)
    return placa, [('ícono grano', caja(grupos[:1], cy - 14, cy + 14), 3.0), ('cifra', caja(grupos[1:-1]), 4.5), ('unidad «%»', caja(grupos[-1:], cy - 14, cy + 22), 4.5)]


def main(carpeta):
    d = Path(carpeta)
    fallas = 0
    print('captura\telemento\tfondo\ttinta\tcontraste\tpiso\tresultado')
    for tam in (227, 192):
        for m in ('day', 'dusk', 'night'):
            im = Image.open(d / f'{tam}-{m}.png').convert('RGB')
            placa, elementos = cajas_placa(im)
            for nombre, cf, ct, piso in [(n, placa, c, k) for n, c, k in elementos] + [('hora', *HORA, 4.5)]:
                fondo, tinta, r = medir(im, cf, ct)
                ok = r >= piso
                fallas += not ok
                extra = f' (AAA normal 7: {"pasa" if r >= 7 else "no"})' if nombre == 'cifra' else ''
                print(f'{tam}-{m}\t{nombre}\t#{bytes(fondo).hex()}\t#{bytes(tinta).hex()}\t{r:.2f}\t{piso}\t{"pasa" if ok else "FALLA"}{extra}')
    amb = Image.open(d / 'ambiente.png').convert('RGB')
    px = list(amb.get_flattened_data()) if hasattr(amb, "get_flattened_data") else list(amb.getdata())
    encendidos = sum(1 for p in px if max(p) > 16) / len(px)
    apl = sum(lum(p) for p in px) / len(px)
    escena = sum(1 for p in px if max(p) - min(p) > 40) / len(px)  # píxeles de color saturado (la escena tiene verdes y cielo)
    print(f'ambiente\tpíxeles encendidos {encendidos * 100:.2f} %\tluminancia media {apl * 100:.2f} %\tpíxeles de color saturado {escena * 100:.3f} %')
    print(f'fallas de contraste: {fallas}')
    return fallas


def estados(carpeta):
    """Paso 6: contraste de cada texto de las pantallas de estado (cargando, sin conexión, dato viejo…). Cajas del árbol de
    accesibilidad (<captura>.xml, uiautomator); fondo = color más frecuente de la caja; tinta = núcleo del glifo. Piso AA."""
    import html
    import re
    d = Path(carpeta)
    fallas = 0
    print('captura	texto	fondo	tinta	contraste	piso	resultado')
    for x in sorted(d.glob('*.xml')):
        im = Image.open(x.with_suffix('.png')).convert('RGB')
        for m in re.finditer(r'<node [^>]*>', x.read_text(encoding='utf-8')):
            g = lambda k: html.unescape((re.search(k + r'="([^"]*)"', m.group(0)) or [None, ''])[1])
            texto = (g('text') or g('content-desc')).strip()
            b = [int(n) for n in re.findall(r'\d+', g('bounds'))]
            if not texto or len(b) != 4 or (b[2] - b[0]) * (b[3] - b[1]) > 454 * 454 * .5:
                continue
            fondo, tinta, r = medir(im, tuple(b), tuple(b))
            ok = r >= 4.5
            fallas += not ok
            print(f'{x.stem}	{texto}	#{bytes(fondo).hex()}	#{bytes(tinta).hex()}	{r:.2f}	4.5	{"pasa" if ok else "FALLA"}')
    print(f'fallas de contraste: {fallas}')
    return fallas


if __name__ == '__main__':
    if sys.argv[1] == '--estados':
        sys.exit(1 if estados(sys.argv[2]) else 0)
    sys.exit(1 if main(sys.argv[1]) else 0)
