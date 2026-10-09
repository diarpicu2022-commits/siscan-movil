#!/bin/sh
# Ayudas para recorrer la app en el emulador: tocar por texto accesible (uiautomator) y capturar.
export MSYS_NO_PATHCONV=1
export PYTHONUTF8=1 PYTHONIOENCODING=utf-8
APK=C:/dev/siscan-build/build/app/outputs/flutter-apk/app-debug.apk
A=~/AppData/Local/Android/Sdk/platform-tools/adb; S=${S:-emulator-5554}; D=${D:-/c/dev/siscan/docs/ux/capturas/apk-v2}
dump(){ $A -s $S shell uiautomator dump /sdcard/u.xml >/dev/null 2>&1; $A -s $S exec-out cat /sdcard/u.xml; }
tocar(){ # tocar "texto" [n-ésima coincidencia]; prefiere la coincidencia exacta
  dump | python -c "
import sys,re,html
x=sys.stdin.read(); t=sys.argv[1]; n=int(sys.argv[2])
ns=[]
for m in re.finditer(r'<node [^>]*>',x):
  g=lambda k: html.unescape(re.search(k+r'=\"([^\"]*)\"',m.group(0)).group(1))
  ns.append((g('text') or g('content-desc'), list(map(int,re.findall(r'\d+',g('bounds'))))))
ms=[v for v in ns if v[0].strip()==t] or [v for v in ns if t in v[0]]
if len(ms)<=n: print('NO: '+t,file=sys.stderr); sys.exit(1)
a,b,c,d=ms[n][1]; print((a+c)//2,(b+d)//2)" "$1" "${2:-0}" | { read X Y && $A -s $S shell input tap $X $Y; }
}
cap(){ $A -s $S exec-out screencap -p > $D/$1.png; }
bajar(){ $A -s $S shell input swipe 540 1900 540 ${1:-700} 450; sleep 1.5; }
mosaico(){ # mosaico salida f1 f2 ...
  o=$1; shift; (cd $D && python -c "
import sys
from PIL import Image
fs=sys.argv[2:]; ims=[Image.open(f+'.png').convert('RGB').resize((432,960)) for f in fs]
m=Image.new('RGB',(442*len(ims),960),'white')
for i,im in enumerate(ims): m.paste(im,(i*442,0))
m.save(sys.argv[1])" "$o" "$@"); }
