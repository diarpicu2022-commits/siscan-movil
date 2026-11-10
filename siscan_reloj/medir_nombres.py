"""Nombres de los actuadores en Equipo del reloj: ¿alguno se corta contra el interruptor? La caja de uiautomator llega
recortada, así que se mide sobre la captura: si la tinta del nombre llega a 2 px del borde de la columna (la caja más
ancha de los nombres en esa captura, que es el ancho disponible), está cortado. Un «…» no se ve en el volcado (el texto
llega completo): se confirma en la captura.
Uso: python medir_nombres.py <carpeta>   (lee *-p3.xml / *-p3-fin.xml con su .png)"""
import re, sys, pathlib
from PIL import Image
NOMBRES = ("Ventiladores", "Calefactor", "Luces incandescentes")
fallas = 0
for xml in sorted(pathlib.Path(sys.argv[1]).glob("*-p3*.xml")):
    im = Image.open(xml.with_suffix(".png")).convert("RGB")
    nodos = [(t, *map(int, re.findall(r"\d+", b))) for t, b in re.findall(r'text="([^"]*)"[^>]*?bounds="(\[\d+,\d+\]\[\d+,\d+\])"', xml.read_text(encoding="utf8")) if t in NOMBRES]
    columna = max((n[3] for n in nodos), default=0)
    for t, x1, y1, x2, y2 in nodos:
        cols = [x for x in range(x1, x2) if any(sum(im.getpixel((x, y))) > 600 for y in range(y1, min(y2, im.height)))]
        derecha = max(cols) if cols else x1
        corte = derecha >= columna - 2
        lineas = round((y2 - y1) / 29) or 1
        fallas += corte
        print(f"{xml.stem:18} {t:22} columna hasta {columna} · tinta hasta {derecha} · {lineas} línea(s) · {'CORTADO' if corte else 'entero'}")
print("cortados:", fallas); sys.exit(1 if fallas else 0)
