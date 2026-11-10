"""Mide sobre la captura si las letras de una caja caben en el círculo (la caja de uiautomator es un rectángulo y el texto
va centrado: sus esquinas pueden salir del círculo aunque ninguna letra lo haga).
Uso: python medir_glifos.py <captura.png> x1 y1 x2 y2 [diámetro]"""
import math, sys
from PIL import Image
im = Image.open(sys.argv[1]).convert("RGB")
x1, y1, x2, y2 = map(int, sys.argv[2:6]); d = int(sys.argv[6]) if len(sys.argv) > 6 else 454; r = d / 2
peor, n = 0.0, 0
for y in range(y1, min(y2, im.height)):
    for x in range(x1, min(x2, im.width)):
        R, G, B = im.getpixel((x, y))
        if 0.2126 * R + 0.7152 * G + 0.0722 * B > 140:  # tinta clara sobre el fondo oscuro del reloj
            n += 1; peor = max(peor, math.hypot(x + .5 - r, y + .5 - r))
print(f"píxeles de letra: {n} · el más lejano a {peor:.1f} px del centro (radio {r:.0f}) · {'dentro' if peor <= r else 'FUERA'}")
sys.exit(0 if n and peor <= r else 1)
