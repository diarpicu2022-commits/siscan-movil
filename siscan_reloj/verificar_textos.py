"""Idiomas del reloj (anexo 2026-10-15, paso 4d): mismos nombres y marcadores en values, values-en y values-pt-rBR,
y ningún texto en español escrito a mano en el Kotlin (fuera de nombres propios, formatos y claves del servidor)."""
import re, sys, pathlib
res = pathlib.Path("app/src/main/res")
def leer(c):
    x = (res / c / "strings.xml").read_text(encoding="utf-8")
    # translatable="false" (SISCAN, el nombre de la app) no se traduce y no se compara.
    return {m[0]: m[2] for m in re.findall(r'<string name="(\w+)"([^>]*)>(.*?)</string>', x) if 'translatable="false"' not in m[1]}
es, en, pt = leer("values"), leer("values-en"), leer("values-pt-rBR")
fallas = []
for nombre, otro in (("en", en), ("pt", pt)):
    for k in es.keys() - otro.keys(): fallas.append(f"falta {k} en {nombre}")
    for k in otro.keys() - es.keys(): fallas.append(f"sobra {k} en {nombre}")
    for k in es.keys() & otro.keys():
        a, b = sorted(re.findall(r"%\d+\$[sd]|%%", es[k])), sorted(re.findall(r"%\d+\$[sd]|%%", otro[k]))
        if a != b: fallas.append(f"marcadores distintos en {k} ({nombre}): {a} / {b}")
rasgos = re.compile(r'"[^"$]*(?:[ñ¿¡áéíóú]|\b(?:el|la|los|del|con|sin|para|por|una|está|todavía)\b)[^"]*"')
permitidos = ("Secador 01", "America/Bogota", "No se pudo leer el secador")  # nombre del secador, zona horaria, registro interno
for f in sorted(pathlib.Path("app/src/main/java").rglob("*.kt")):
    for n, l in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
        s = l.strip()
        if s.startswith(("//", "*", "/**")): continue
        for m in rasgos.findall(l):
            if not any(p in m for p in permitidos): fallas.append(f"{f.name}:{n} español escrito a mano {m}")
print(f"{len(es)} cadenas en tres idiomas")
print("\n".join(fallas) if fallas else "0 fallas")
sys.exit(1 if fallas else 0)
