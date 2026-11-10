"""Inventario de textos visibles para la traducción (anexo 2026-10-15 de idiomas, paso 1).

Recorre la app Flutter (lib/**/*.dart), el reloj (Kotlin y res/values/strings.xml) y la esfera (XML del Watch Face Format)
y lista las cadenas que parecen texto para personas: tienen letras y (un espacio, una tilde/ñ, o empiezan en mayúscula),
y no son rutas, claves, nombres de recursos, formatos de fecha ni código. Es una aproximación conservadora: sobra algo
(se revisa a mano), pero no debería faltar texto visible.

Uso: python tools/inventario_textos.py <salida.tsv>
"""
import pathlib
import re
import sys

RAIZ = pathlib.Path(__file__).resolve().parent.parent
LITERAL_DART = re.compile(r"(?<![A-Za-z0-9_])(?:r)?'((?:[^'\\\n]|\\.)*)'|\"((?:[^\"\\\n]|\\.)*)\"")
LITERAL_KT = re.compile(r'"((?:[^"\\\n]|\\.)*)"')
NO = re.compile(r'^(assets/|https?://|package:|dart:|[a-z_]+(\.[a-z_]+)+$|#|[A-Z_]+$|[a-z]+[A-Z][A-Za-z]*$|[a-z_0-9]+$|%|\$\{?[a-z]|[\d:./ -]+$)')
IGNORAR_LINEA = re.compile(r'^\s*(import |export |part |library|//|\*|/\*)|debugPrint|Log\.[dwie]\(|android\.util\.Log|semanticsLabel: null')


def es_texto(s):
    s2 = re.sub(r'\$\{[^}]*\}|\$[a-zA-Z_]+', '', s).strip()
    if len(s2) < 2 or NO.match(s2) or not re.search(r'[A-Za-zÁÉÍÓÚáéíóúñÑ]', s2):
        return False
    return ' ' in s2 or bool(re.search(r'[áéíóúñÁÉÍÓÚÑ¡¿«»·…]', s2)) or s2[:1].isupper()


def recorrer(base, patron, literal, zona):
    filas = []
    for f in sorted(base.glob(patron)):
        if any(p in f.parts for p in ('build', '.dart_tool', 'generated')):
            continue
        for n, linea in enumerate(f.read_text(encoding='utf-8').splitlines(), 1):
            if IGNORAR_LINEA.search(linea):
                continue
            for m in literal.finditer(linea):
                s = next(g for g in m.groups() if g is not None) if m.groups() else m.group(1)
                if es_texto(s):
                    filas.append((zona, f.relative_to(RAIZ).as_posix(), n, s))
    return filas


def main(salida):
    filas = []
    filas += recorrer(RAIZ / 'siscan_app/lib', '**/*.dart', LITERAL_DART, 'teléfono')
    filas += recorrer(RAIZ / 'siscan_reloj/app/src/main/java', '**/*.kt', LITERAL_KT, 'reloj')
    for f in sorted((RAIZ / 'siscan_reloj').glob('**/res/values/strings.xml')):
        if 'build' in f.parts:
            continue
        for n, linea in enumerate(f.read_text(encoding='utf-8').splitlines(), 1):
            m = re.search(r'<string name="([^"]+)"[^>]*>(.*)</string>', linea)
            if m:
                filas.append(('reloj (strings.xml)' if 'esfera' not in f.parts else 'esfera (strings.xml)', f.relative_to(RAIZ).as_posix(), n, m.group(2)))
    for f in sorted((RAIZ / 'siscan_reloj/esfera').glob('**/*.xml')):
        if 'build' in f.parts or f.name == 'strings.xml':
            continue
        for n, linea in enumerate(f.read_text(encoding='utf-8').splitlines(), 1):
            for m in re.finditer(r'(?:text|displayName|contentDescription|label)="([^"@]+)"', linea):
                if es_texto(m.group(1)):
                    filas.append(('esfera', f.relative_to(RAIZ).as_posix(), n, m.group(1)))
    pathlib.Path(salida).write_text('zona\tarchivo\tlínea\ttexto\n' + ''.join(f'{z}\t{a}\t{n}\t{t}\n' for z, a, n, t in filas), encoding='utf-8')
    por = {}
    for z, a, _, _ in filas:
        por.setdefault(z, {}).setdefault(a, 0)
        por[z][a] += 1
    for z, archivos in por.items():
        print(f'{z}: {sum(archivos.values())} cadenas en {len(archivos)} archivos')
        for a, k in sorted(archivos.items(), key=lambda x: -x[1]):
            print(f'    {k:4} {a}')


if __name__ == '__main__':
    main(sys.argv[1])
