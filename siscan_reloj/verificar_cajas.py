"""Comprobación de cajas en la esfera redonda: cada texto visible debe caber entero dentro del círculo y sin «…».
Uso: python verificar_cajas.py <dump.xml> [diámetro_px] [--debe "texto" ...] [--lista otro_dump.xml]
--lista: en una página con desplazamiento, lo que toca el borde de arriba o de abajo está a medio desplazar; no cuenta
como fallo si aparece entero (dentro del círculo) en el otro volcado de la misma página (el del inicio o el del final)."""
import math, re, sys
x = open(sys.argv[1], encoding='utf8').read()
args = sys.argv[2:]
debe = [args[i + 1] for i, a in enumerate(args) if a == '--debe']
lista = [args[i + 1] for i, a in enumerate(args) if a == '--lista']
libres = [a for i, a in enumerate(args) if a not in ('--debe', '--lista') and (i == 0 or args[i - 1] not in ('--debe', '--lista'))]
d = int(libres[0]) if libres else 454
r = d / 2
def enteros(xml):
    # Textos que caben enteros dentro del círculo en un volcado.
    out = set()
    for t, b in re.findall(r'text="([^"]*)"[^>]*?bounds="(\[\d+,\d+\]\[\d+,\d+\])"', xml):
        x1, y1, x2, y2 = map(int, re.findall(r'\d+', b))
        if t and max(math.hypot(px - r, py - r) for px, py in [(x1, y1), (x2, y1), (x1, y2), (x2, y2)]) <= r + 2:
            out.add(t)
    return out
otros = set().union(*[enteros(open(f, encoding='utf8').read()) for f in lista]) if lista else set()
fallos = 0
for t, b in re.findall(r'text="([^"]*)"[^>]*?bounds="(\[\d+,\d+\]\[\d+,\d+\])"', x):
    if not t:
        continue
    x1, y1, x2, y2 = map(int, re.findall(r'\d+', b))
    # Margen de 2 px por el antialias del borde.
    fuera = max(math.hypot(px - r, py - r) for px, py in [(x1, y1), (x2, y1), (x1, y2), (x2, y2)]) > r + 2
    corte = '…' in t or y2 <= y1
    if fuera and lista and (y1 <= 2 or y2 >= d - 2) and t in otros:
        print(f'parcial {t!r:28} [{x1},{y1}]-[{x2},{y2}] a medio desplazar; entero en el otro volcado')
        continue
    fallos += fuera or corte
    print(('FALLO ' if fuera or corte else 'ok    ') + f'{t!r:30} [{x1},{y1}]-[{x2},{y2}]' + (' fuera del círculo' if fuera else '') + (' recortado' if corte else ''))
vistos = re.findall(r'text="([^"]*)"', x)
for t in debe:
    if not any(t in v for v in vistos):
        fallos += 1
        print(f'FALLO {t!r:30} no aparece (desbordado o ausente)')
print('FALLOS:', fallos)
sys.exit(1 if fallos else 0)
