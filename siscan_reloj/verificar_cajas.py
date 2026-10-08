"""Comprobación de cajas en la esfera redonda: cada texto visible debe caber entero dentro del círculo y sin «…».
Uso: python verificar_cajas.py <dump.xml> [diámetro_px] [--debe "texto" ...]"""
import math, re, sys
x = open(sys.argv[1], encoding='utf8').read()
args = sys.argv[2:]
debe = [args[i + 1] for i, a in enumerate(args) if a == '--debe']
libres = [a for i, a in enumerate(args) if a != '--debe' and (i == 0 or args[i - 1] != '--debe')]
d = int(libres[0]) if libres else 454
r = d / 2
fallos = 0
for t, b in re.findall(r'text="([^"]*)"[^>]*?bounds="(\[\d+,\d+\]\[\d+,\d+\])"', x):
    if not t:
        continue
    x1, y1, x2, y2 = map(int, re.findall(r'\d+', b))
    # Margen de 2 px por el antialias del borde.
    fuera = max(math.hypot(px - r, py - r) for px, py in [(x1, y1), (x2, y1), (x1, y2), (x2, y2)]) > r + 2
    corte = '…' in t or y2 <= y1
    fallos += fuera or corte
    print(('FALLO ' if fuera or corte else 'ok    ') + f'{t!r:30} [{x1},{y1}]-[{x2},{y2}]' + (' fuera del círculo' if fuera else '') + (' recortado' if corte else ''))
vistos = re.findall(r'text="([^"]*)"', x)
for t in debe:
    if not any(t in v for v in vistos):
        fallos += 1
        print(f'FALLO {t!r:30} no aparece (desbordado o ausente)')
print('FALLOS:', fallos)
sys.exit(1 if fallos else 0)
