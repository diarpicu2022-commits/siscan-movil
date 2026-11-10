"""Corrige los SVG exportados del sistema para flutter_svg: pasa `rgba(r,g,b,a)` en `fill`, `stroke` y `stop-color` a
color hexadecimal más `fill-opacity` / `stroke-opacity` / `stop-opacity` (multiplicando la opacidad que ya hubiera).

Motivo (anexo 2026-10-12, verificación del 2026-10-15): flutter_svg descarta el alfa escrito dentro de `rgba()`. En la
escena de noche el halo de la luna (`rgba(230,240,220,0.1)`) salía casi opaco y el disco que recorta la luna creciente
quedaba como un eclipse; la cúpula del secador (`rgba(255,226,180,0.3)`) salía maciza. Chromium dibuja igual el archivo
antes y después: el dibujo del sistema no cambia.

Uso: python tools/svg_rgba_a_opacidad.py <carpeta con .svg> [...]. Correr después de tools/exportar_svg_sistema.mjs.
"""
import pathlib
import re
import sys

RGBA = re.compile(r'rgba\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*\)')
ETIQUETA = re.compile(r'<[a-zA-Z][^>]*>')
OPACIDAD = {'fill': 'fill-opacity', 'stroke': 'stroke-opacity', 'stop-color': 'stop-opacity'}


def num(v: float) -> str:
    s = f'{v:.4f}'.rstrip('0').rstrip('.')
    return s or '0'


def corregir_etiqueta(t: str) -> str:
    for attr, op in OPACIDAD.items():
        m = re.search(rf'(\s){re.escape(attr)}="(rgba\([^"]*\))"', t)
        if not m:
            continue
        c = RGBA.fullmatch(m.group(2))
        if not c:
            continue
        r, g, b = (round(float(x)) for x in c.groups()[:3])
        a = float(c.group(4))
        previa = re.search(rf'\s{re.escape(op)}="([\d.]+)"', t)
        total = a * (float(previa.group(1)) if previa else 1.0)
        t = t[:m.start()] + f'{m.group(1)}{attr}="#{r:02x}{g:02x}{b:02x}"' + t[m.end():]
        if previa:
            t = re.sub(rf'(\s){re.escape(op)}="[\d.]+"', rf'\g<1>{op}="{num(total)}"', t, count=1)
        else:
            cierre = '/>' if t.endswith('/>') else '>'
            t = t[: -len(cierre)] + f' {op}="{num(total)}"' + cierre
    return t


def main(carpetas: list[str]) -> None:
    n_arch = n_cambios = 0
    for carpeta in carpetas:
        for f in sorted(pathlib.Path(carpeta).glob('*.svg')):
            s = f.read_text(encoding='utf-8')
            nuevo = ETIQUETA.sub(lambda m: corregir_etiqueta(m.group(0)), s)
            if nuevo != s:
                n_cambios += len(RGBA.findall(s)) - len(RGBA.findall(nuevo))
                f.write_text(nuevo, encoding='utf-8')
                n_arch += 1
            restantes = len(RGBA.findall(nuevo))
            if restantes:
                print(f'AVISO {f.name}: quedan {restantes} rgba() fuera de fill/stroke/stop-color')
    print(f'{n_cambios} colores rgba() convertidos en {n_arch} archivos')


if __name__ == '__main__':
    main(sys.argv[1:] or ['siscan_app/assets/sistema/paisaje'])
