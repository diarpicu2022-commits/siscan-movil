"""Genera la escena de «El secador» del reloj (paso 4 del anexo 2026-10-12, C2): WebP de 454 px por momento.

Toma los SVG de la app ya corregidos (svg_rgba_a_opacidad.py), aplica el encuadre del reloj (el mismo de
EscenaReloj.VIEWBOX en siscan_reloj/.../Secador.kt), los renderiza con Edge sin ventana (motor Chromium, el del sistema
de diseño) y los guarda como WebP calidad 95 en siscan_reloj/app/src/main/res/drawable-nodpi/escena_reloj_<momento>.webp.
Se eligió mapa de bits por medición (banco del 2026-10-15): ver el anexo.

Uso (desde la raíz del repositorio): python tools/generar_escena_reloj.py
"""
import pathlib
import subprocess
import tempfile

from PIL import Image

EDGE = r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
VIEWBOX = '540 40 560 560'
LADO = 454
RAIZ = pathlib.Path(__file__).resolve().parent.parent
SVG = RAIZ / 'siscan_app/assets/sistema/paisaje'
SALIDA = RAIZ / 'siscan_reloj/app/src/main/res/drawable-nodpi'

with tempfile.TemporaryDirectory() as tmp:
    for m in ('day', 'dusk', 'night'):
        s = (SVG / f'{m}-completo.svg').read_text(encoding='utf-8').replace('viewBox="0 0 1200 600"', f'viewBox="{VIEWBOX}"', 1)
        svg, png = pathlib.Path(tmp, f'{m}.svg'), pathlib.Path(tmp, f'{m}.png')
        svg.write_text(s, encoding='utf-8')
        subprocess.run([EDGE, '--headless=new', '--disable-gpu', '--hide-scrollbars', f'--screenshot={png}',
                        f'--window-size={LADO},{LADO}', svg.as_uri()], check=True, capture_output=True)
        Image.open(png).convert('RGB').save(SALIDA / f'escena_reloj_{m}.webp', 'WEBP', quality=95, method=6)
        print(m, (SALIDA / f'escena_reloj_{m}.webp').stat().st_size, 'B')
