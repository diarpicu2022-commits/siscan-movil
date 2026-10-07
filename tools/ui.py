"""Ayudante de emulador: tocar por texto/descripción (uiautomator), arrastrar y capturar. Uso: ui.py tap "Widgets" """
import os, re, subprocess, sys, time
ADB = os.path.expandvars(r'%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe')
def sh(*a, out=False):
    r = subprocess.run([ADB, 'shell', *a], capture_output=True, text=True, encoding='utf8', errors='replace')
    return r.stdout
def nodes():
    sh('uiautomator', 'dump', '/sdcard/u.xml')
    x = sh('cat', '/sdcard/u.xml')
    for m in re.finditer(r'<node [^>]*>', x):
        n = m.group(0)
        t = re.search(r' text="([^"]*)"', n).group(1); d = re.search(r'content-desc="([^"]*)"', n).group(1)
        b = list(map(int, re.findall(r'\d+', re.search(r'bounds="([^"]*)"', n).group(1))))
        yield t, d, b
def find(q, contains=True):
    for t, d, b in nodes():
        if (q in t or q in d) if contains else (q == t or q == d):
            return b
def center(b): return (b[0] + b[2]) // 2, (b[1] + b[3]) // 2
cmd = sys.argv[1]
if cmd == 'tap':
    b = find(sys.argv[2], len(sys.argv) < 4)
    if not b: print('NO', sys.argv[2]); sys.exit(1)
    sh('input', 'tap', *map(str, center(b))); print('tap', sys.argv[2], center(b))
elif cmd == 'drag':  # drag "texto" x y
    b = find(sys.argv[2]); x, y = center(b)
    sh('input', 'draganddrop', str(x), str(y), sys.argv[3], sys.argv[4], '2500'); print('drag', x, y)
elif cmd == 'list':
    for t, d, b in nodes():
        if t or d: print(t, '|', d, '|', b)
