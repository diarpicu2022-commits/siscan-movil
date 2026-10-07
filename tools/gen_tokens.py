"""Genera lib/theme/tokens.dart desde tokens.json del sistema SISCAN (ningún color escrito a mano).
Uso: python tools/gen_tokens.py <ruta a tokens.json> siscan_app/lib/theme/tokens.dart
"""
import json
import re
import sys

src, out = sys.argv[1], sys.argv[2]
t = json.load(open(src, encoding="utf8"))
colors = {c["name"]: c["value"] for c in t["color"]["tokens"]}


def resolve(name, theme):
    v = colors[name].get(theme, colors[name]["dia"])
    while isinstance(v, str) and v.startswith("{"):
        ref = v.strip("{}")
        v = colors[ref].get(theme, colors[ref]["dia"])
    return v


def camel(n):
    p = n.split("-")
    return p[0] + "".join(x.capitalize() for x in p[1:])


names = list(colors)
fields = [camel(n) for n in names]
lines = [
    "// GENERADO por tools/gen_tokens.py desde siscan-design-system/tokens.json. No editar a mano.",
    "import 'package:flutter/material.dart';",
    "",
    "/// Tokens de color de SISCAN (temas «Día» y «Pleno sol») como ThemeExtension: ningún widget usa Color(0x…) directo.",
    "@immutable",
    "class SiscanTokens extends ThemeExtension<SiscanTokens> {",
]
lines += [f"  final Color {f};" for f in fields]
lines.append("  const SiscanTokens({" + ", ".join(f"required this.{f}" for f in fields) + "});")
lines.append("")
for theme, label in (("dia", "dia"), ("sol", "sol")):
    lines.append(f"  static const {label} = SiscanTokens(")
    for n, f in zip(names, fields):
        hexv = resolve(n, theme).lstrip("#")
        lines.append(f"    {f}: Color(0xFF{hexv.upper()}),")
    lines.append("  );")
    lines.append("")
lines += [
    "  @override",
    "  SiscanTokens copyWith() => this;",
    "",
    "  @override",
    "  SiscanTokens lerp(SiscanTokens? other, double t) => t < .5 ? this : (other ?? this);",
    "}",
    "",
]
# Espaciado y radios.
sp = {s["name"]: float(re.sub(r"[^0-9.]", "", s["value"])) for s in t["spacing"]["tokens"]}
rd = {s["name"]: float(re.sub(r"[^0-9.]", "", s["value"])) for s in t["radius"]["tokens"]}
lines.append("/// Espaciado del sistema (px lógicos).")
lines.append("abstract final class SiscanSpace {")
for k, v in sp.items():
    lines.append(f"  static const double {camel(k).replace('espacio', 's')} = {v};")
lines.append("}")
lines.append("")
lines.append("/// Radios por significado (etiqueta = lo preciso, control = lo que se acciona, hoja, loma, grano).")
lines.append("abstract final class SiscanRadius {")
for k, v in rd.items():
    lines.append(f"  static const double {camel(k).replace('radio', '').lstrip('-')[0].lower() + camel(k).replace('radio', '')[1:]} = {v};")
lines.append("}")
open(out, "w", encoding="utf8").write("\n".join(lines) + "\n")
print(f"{len(fields)} colores, {len(sp)} espacios, {len(rd)} radios -> {out}")
