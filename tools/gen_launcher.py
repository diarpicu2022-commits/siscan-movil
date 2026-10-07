"""Ícono de la app: el nombre SISCAN en Fraunces 600 (SOFT 100, WONK 1) sobre monte — sin símbolo provisional (README · Marca)."""
import json, os
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
from PIL import Image, ImageDraw, ImageFont

t = json.load(open('tokens.json', encoding='utf8'))
cols = {c['name']: c['value'] for c in t['color']['tokens']}
def col(n):
    v = cols[n]['dia']
    while v.startswith('{'): v = cols[v.strip('{}')]['dia']
    return v
MONTE, SOBRE = col('monte'), col('sobre-monte')

tmp = 'tools/_fraunces600.ttf'
f = TTFont('siscan_app/assets/fonts/Fraunces-Variable.ttf')
axes = {a.axisTag for a in f['fvar'].axes}
loc = {k: v for k, v in {'wght': 600, 'SOFT': 100, 'WONK': 1, 'opsz': 72}.items() if k in axes}
instantiateVariableFont(f, loc).save(tmp)

def draw(size, safe, bg=MONTE):
    """safe = fracción del lado donde cabe el texto (adaptive: 66 % del lienzo de 108 dp es visible)."""
    im = Image.new('RGBA', (size, size), bg)
    d = ImageDraw.Draw(im)
    lo, hi = 4, size
    while lo < hi:  # el cuerpo más grande cuyo ancho cabe en la zona segura
        mid = (lo + hi + 1) // 2
        w = d.textbbox((0, 0), 'SISCAN', font=ImageFont.truetype(tmp, mid))[2]
        lo, hi = (mid, hi) if w <= size * safe else (lo, mid - 1)
    font = ImageFont.truetype(tmp, lo)
    x0, y0, x1, y1 = d.textbbox((0, 0), 'SISCAN', font=font)
    d.text(((size - (x1 - x0)) / 2 - x0, (size - (y1 - y0)) / 2 - y0), 'SISCAN', font=font, fill=SOBRE)
    return im, lo

res = 'siscan_app/android/app/src/main/res'
for dpi, px in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
    im, _ = draw(px * 4, 0.80)
    im.resize((px, px), Image.LANCZOS).save(f'{res}/mipmap-{dpi}/ic_launcher.png')
    fg, _ = draw(px * 4 * 108 // 48, 0.80 * 66 / 108, bg=(0, 0, 0, 0))  # primer plano adaptativo (108 dp, zona visible 66 dp)
    fgpx = px * 108 // 48
    fg = fg.resize((fgpx, fgpx), Image.LANCZOS)
    os.makedirs(f'{res}/mipmap-{dpi}', exist_ok=True)
    fg.save(f'{res}/mipmap-{dpi}/ic_launcher_foreground.png')
os.makedirs(f'{res}/mipmap-anydpi-v26', exist_ok=True)
open(f'{res}/mipmap-anydpi-v26/ic_launcher.xml', 'w', encoding='utf8').write(
    '<?xml version="1.0" encoding="utf-8"?>\n<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
    '    <background android:drawable="@color/sc_monte"/>\n    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
    '    <monochrome android:drawable="@mipmap/ic_launcher_foreground"/>\n</adaptive-icon>\n')
big, size = draw(1024, 0.80)
big.save('siscan_app/android/ic_launcher_1024.png')
os.remove(tmp)
print('ok', MONTE, SOBRE)
