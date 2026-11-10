#!/usr/bin/env bash
# Paso 6 del anexo de idiomas: la app del teléfono en el emulador, en es, en y pt-BR (idioma por app de Android).
# Por idioma: las 5 pestañas (captura y volcado), español suelto en inglés, notificaciones (canales y textos publicados,
# leídos con dumpsys) y la descripción del widget de inicio que guarda la app.
# Uso: bash medir_telefono.sh   (emulador encendido, app de depuración instalada y permiso de notificaciones dado)
set -u
PKG=co.gov.narino.cisna.siscan
ADB() { MSYS_NO_PATHCONV=1 "$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe" "$@"; }
OUT=../docs/ux/capturas/idiomas-telefono
mkdir -p "$OUT"
RES="$OUT/medicion.tsv"
printf 'idioma\tqué\tresultado\tdetalle\n' > "$RES"
FALLAS=0
# Rasgos del español; quedan fuera los nombres propios y lo que trae el servidor (I4).
RASGOS='[ñ¿¡]|ción\b|\b(el|la|los|las|del|con|sin|para|por|una|está|todavía|hace|hoy|ayer)\b'
PERMITIDOS='juco|motil|secador 01|siscan|ventiladores|calefactor|luces incandescentes|tradicional \(secado al sol\)|cenicaf|nariño|gobernación|subsecretaría|secado inteligente de café|vereda'
anotar() { printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" >> "$RES"; [ "$3" = FALLA ] && FALLAS=$((FALLAS+1)); }
textos() { grep -ao '\(text\|content-desc\)="[^"]\+"' "$1" | sed 's/^[a-z-]*="//; s/"$//' | sed 's/&#10;/ /g'; }
for loc in es en pt-BR; do
  ADB shell cmd locale set-app-locales $PKG --locales $loc >/dev/null
  ADB shell am force-stop $PKG
  ADB shell input keyevent KEYCODE_WAKEUP
  ADB shell am start -W -n $PKG/.MainActivity >/dev/null
  sleep 14
  for i in 0 1 2 3 4; do
    x=$((1080 * (2 * i + 1) / 10))
    ADB shell input tap $x 2280
    sleep 4
    base="$OUT/$loc-pestana$i"
    ADB shell uiautomator dump /sdcard/d.xml >/dev/null 2>&1
    ADB pull /sdcard/d.xml "$base.xml" >/dev/null 2>&1
    ADB exec-out screencap -p > "$base.png"
    if [ ! -s "$base.xml" ]; then anotar $loc "pestaña $i" FALLA "sin volcado"; continue; fi
    n=$(textos "$base.xml" | wc -l)
    det=""
    if [ $loc = en ]; then
      det=$(textos "$base.xml" | grep -iE "$RASGOS" | grep -viE "$PERMITIDOS" | tr '\n' '|')
    fi
    if [ -n "$det" ]; then anotar $loc "pestaña $i ($n textos)" FALLA "español suelto: $det"; else anotar $loc "pestaña $i ($n textos)" ok ""; fi
  done
  # Notificaciones: en Más (pestaña 4), el interruptor de Notificaciones. Se busca por su etiqueta en el volcado.
  etiqueta=$(case $loc in es) echo Notificaciones;; en) echo Notifications;; *) echo Notificações;; esac)
  b=$(grep -ao "content-desc=\"[^\"]*$etiqueta[^\"]*\"[^>]*bounds=\"[^\"]*\"" "$OUT/$loc-pestana4.xml" | head -1 | grep -o 'bounds="[^"]*"' | grep -o '[0-9]\+' | tr '\n' ' ')
  if [ -n "$b" ]; then
    set -- $b; ADB shell input tap $(( ($1 + $3) / 2 )) $(( ($2 + $4) / 2 )); sleep 12
    ADB shell dumpsys notification --noredact > "$OUT/$loc-notificaciones.txt"
    canales=$(grep -a "mId='alertas'\|mId='recordatorios'\|mId='actividad'" -A1 "$OUT/$loc-notificaciones.txt" | grep -ao "mName=[^,]*" | sort -u | tr '\n' '|')
    publicadas=$(grep -a "pkg=$PKG" -A40 "$OUT/$loc-notificaciones.txt" | grep -aoE "android.(title|text)=String \([^)]*\)" | sort -u | tr '\n' '|')
    anotar $loc "canales" ok "$canales"
    anotar $loc "notificaciones publicadas" ok "${publicadas:-ninguna (sin alertas nuevas ni lote en curso)}"
    if [ $loc = en ]; then
      es=$(printf '%s\n%s\n' "$canales" "$publicadas" | tr '|' '\n' | grep -iE "$RASGOS" | grep -viE "$PERMITIDOS" | tr '\n' '|')
      [ -n "$es" ] && anotar $loc "notificaciones" FALLA "español suelto: $es"
    fi
    ADB shell input tap $(( ($1 + $3) / 2 )) $(( ($2 + $4) / 2 )); sleep 2   # se vuelve a apagar
  else
    anotar $loc "notificaciones" FALLA "no se encontró el interruptor «$etiqueta»"
  fi
  # Widget de inicio: descripción que guarda la app para el lector de pantalla.
  desc=$(ADB shell run-as $PKG cat shared_prefs/HomeWidgetPreferences.xml 2>/dev/null | grep -ao 'name="descripcion">[^<]*' | sed 's/.*>//')
  if [ -z "$desc" ]; then anotar $loc "widget" FALLA "sin descripción guardada"
  elif [ $loc = en ] && printf '%s' "$desc" | grep -iE "$RASGOS" | grep -qviE "$PERMITIDOS"; then anotar $loc "widget" FALLA "español suelto: $desc"
  else anotar $loc "widget" ok "$desc"; fi
done
ADB shell cmd locale set-app-locales $PKG --locales "" >/dev/null
echo "fallas: $FALLAS"
cut -f1-4 "$RES"
