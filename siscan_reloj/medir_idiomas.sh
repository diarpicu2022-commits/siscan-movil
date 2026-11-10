#!/usr/bin/env bash
# Medición del reloj en tres idiomas (anexo de idiomas, paso 5): 7 páginas × es/en/pt-BR × 227 y 192 dp en el emulador.
# Cada página: captura, volcado de la interfaz y verificar_cajas.py (texto entero dentro del círculo y sin «…»).
# En inglés, además, ningún texto con rasgos del español fuera de los datos del servidor (I4).
# Uso: bash medir_idiomas.sh   (con el emulador Reloj_WearOS encendido y la app de depuración instalada)
set -u
# Git Bash convierte /sdcard/... en una ruta de Windows: se desactiva para adb.
export MSYS_NO_PATHCONV=1
PKG=co.gov.narino.cisna.siscan
ACT=co.gov.narino.cisna.siscan.reloj.RelojActivity
ADB="$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe"
OUT=../docs/ux/capturas/idiomas-reloj
mkdir -p "$OUT"
RES="$OUT/medicion.tsv"
printf 'idioma\tdp\tpagina\ttextos\tresultado\tdetalle\n' > "$RES"
FALLAS=0
for loc in es en pt-BR; do
  "$ADB" shell cmd locale set-app-locales $PKG --locales $loc >/dev/null
  for dp in 227 192; do
    if [ $dp = 227 ]; then "$ADB" shell wm density 320 >/dev/null; else "$ADB" shell wm density 378 >/dev/null; fi
    "$ADB" shell am force-stop $PKG
    "$ADB" shell input keyevent KEYCODE_WAKEUP
    "$ADB" shell am start -W -n $PKG/$ACT >/dev/null
    sleep 9
    for p in 0 1 2 3 4 5 6; do
      base="$OUT/$loc-$dp-p$p"
      "$ADB" shell uiautomator dump /sdcard/d.xml >/dev/null 2>&1
      "$ADB" pull /sdcard/d.xml "$base.xml" >/dev/null 2>&1
      "$ADB" exec-out screencap -p > "$base.png"
      if [ ! -s "$base.xml" ]; then printf '%s	%s	%s	0	FALLA	sin volcado de la interfaz
' "$loc" "$dp" "$p" >> "$RES"; FALLAS=$((FALLAS+1)); "$ADB" shell input swipe 400 227 54 227 250; sleep 2; continue; fi
      n=$(grep -o 'text="[^"]\+"' "$base.xml" | wc -l)
      if [ $p = 2 ] || [ $p = 3 ] || [ $p = 5 ]; then
        # Página con lista: se desplaza hasta el final y se mide también ese volcado (los dos se cruzan con --lista).
        for k in 1 2 3; do "$ADB" shell input swipe 227 400 227 80 300; sleep 1; done
        "$ADB" shell uiautomator dump /sdcard/d.xml >/dev/null 2>&1
        "$ADB" pull /sdcard/d.xml "$base-fin.xml" >/dev/null 2>&1
        "$ADB" exec-out screencap -p > "$base-fin.png"
        det=$( (python -I verificar_cajas.py "$base.xml" 454 --lista "$base-fin.xml"; python -I verificar_cajas.py "$base-fin.xml" 454 --lista "$base.xml") | grep -a '^FALLO ' | tr -d '\r' | tr '\n' ' ')
        n=$((n + $(grep -o 'text="[^"]\+"' "$base-fin.xml" | wc -l)))
      else
        det=$(python -I verificar_cajas.py "$base.xml" 454 | grep -a '^FALLO ' | tr -d '\r' | tr '\n' ' ')
      fi
      if [ "$loc" = en ]; then
        es=$(grep -o 'text="[^"]\+"' "$base.xml" | grep -iE '[ñ¿¡]|ción"|\b(el|la|los|del|con|sin|para|por|una|está|todavía)\b' | grep -viE 'juco|motil|secador 01|SISCAN' | tr '\n' ' ')
        [ -n "$es" ] && det="$det español suelto: $es"
      fi
      if [ -n "$det" ]; then r=FALLA; FALLAS=$((FALLAS+1)); else r=ok; fi
      printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$loc" "$dp" "$p" "$n" "$r" "$det" >> "$RES"
      "$ADB" shell input swipe 400 227 54 227 250
      sleep 2
    done
  done
done
"$ADB" shell wm density reset >/dev/null
"$ADB" shell cmd locale set-app-locales $PKG --locales "" >/dev/null
echo "páginas medidas: $(($(wc -l < "$RES") - 1)) · fallas: $FALLAS"
cat "$RES" | awk -F'\t' '$5=="FALLA"'
