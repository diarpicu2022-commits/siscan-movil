"""Convierte iconos SVG del sistema SISCAN (trazo 1.75, un punto relleno) a VectorDrawable de Android."""
import re, sys, xml.etree.ElementTree as ET
def conv(src, out, color='#FF2B1E15'):
    root = ET.parse(src).getroot()
    ns = '{http://www.w3.org/2000/svg}'
    paths = []
    for el in root.iter():
        tag = el.tag.replace(ns, '')
        fill = el.get('fill', 'none')
        if tag == 'path':
            d = el.get('d')
        elif tag == 'circle':
            cx, cy, r = float(el.get('cx')), float(el.get('cy')), float(el.get('r'))
            d = f'M{cx-r},{cy} a{r},{r} 0 1,0 {2*r},0 a{r},{r} 0 1,0 {-2*r},0'
        elif tag == 'rect':
            x, y, w, h = (float(el.get(k, 0)) for k in ('x', 'y', 'width', 'height'))
            d = f'M{x},{y} h{w} v{h} h{-w} z'
        elif tag == 'line':
            d = f"M{el.get('x1')},{el.get('y1')} L{el.get('x2')},{el.get('y2')}"
        elif tag in ('polyline', 'polygon'):
            pts = el.get('points').split()
            d = 'M' + ' L'.join(pts) + (' z' if tag == 'polygon' else '')
        else:
            continue
        filled = fill not in ('none', None) and el.get('stroke') == 'none'
        paths.append((d, filled))
    body = []
    for d, filled in paths:
        if filled:
            body.append(f'    <path android:fillColor="{color}" android:pathData="{d}"/>')
        else:
            body.append(f'    <path android:strokeColor="{color}" android:strokeWidth="1.75" android:strokeLineCap="round" android:strokeLineJoin="round" android:fillColor="#00000000" android:pathData="{d}"/>')
    open(out, 'w', encoding='utf8').write('<?xml version="1.0" encoding="utf-8"?>\n<!-- Icono del sistema SISCAN convertido desde SVG (tools/svg2vector.py). -->\n<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="24dp" android:height="24dp" android:viewportWidth="24" android:viewportHeight="24">\n' + '\n'.join(body) + '\n</vector>\n')
if __name__ == '__main__':
    for name in sys.argv[1:]:
        conv(f'siscan_app/assets/icons/{name}.svg', f'siscan_app/android/app/src/main/res/drawable/sc_ic_{name.replace("-","_")}.xml')
        print(name)
