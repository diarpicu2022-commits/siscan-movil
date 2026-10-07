"""Recursos Android de los widgets SISCAN (referencia WidgetsMovil). Colores siempre @color/sc_* (generados de tokens)."""
import os

R = 'siscan_app/android/app/src/main/res'
A = 'xmlns:android="http://schemas.android.com/apk/res/android"'
H = '<?xml version="1.0" encoding="utf-8"?>\n'

def shape(fill, radius='20dp', stroke=None, extra=''):
    s = f'<solid android:color="@color/{fill}"/>'
    s += f'<corners android:radius="{radius}"/>' if not radius.startswith('<') else radius
    if stroke:
        s += f'<stroke android:width="1dp" android:color="@color/{stroke}"/>'
    return s + extra

LEAF = '<corners android:topLeftRadius="8dp" android:topRightRadius="8dp" android:bottomRightRadius="8dp" android:bottomLeftRadius="3dp"/>'

def pressable(face, edge):
    # Pulsador del sistema: cara + canto inferior de 3 dp.
    return (f'<layer-list {A}>\n  <item><shape><solid android:color="@color/{edge}"/><corners android:radius="16dp"/></shape></item>\n'
            f'  <item android:bottom="3dp"><shape><solid android:color="@color/{face}"/><corners android:radius="16dp"/></shape></item>\n</layer-list>\n')

files = {
    'drawable/sc_widget_bg.xml': f'<shape {A} android:shape="rectangle">{shape("sc_papel", "20dp", "sc_linea")}</shape>\n',
    'drawable/sc_widget_bg_anil.xml': f'<shape {A} android:shape="rectangle">{shape("sc_anil", "20dp")}</shape>\n',
    'drawable/sc_widget_bg_critica.xml': f'<shape {A} android:shape="rectangle"><solid android:color="@color/sc_oxido_suave"/><corners android:radius="20dp"/><stroke android:width="2dp" android:color="@color/sc_oxido"/></shape>\n',
    'drawable/sc_leaf_monte.xml': f'<shape {A} android:shape="rectangle"><solid android:color="@color/sc_monte"/>{LEAF}</shape>\n',
    'drawable/sc_icon_chip.xml': f'<shape {A} android:shape="rectangle"><solid android:color="@color/sc_papel"/>{LEAF}</shape>\n',
    'drawable/sc_tile_fan_on.xml': pressable('sc_cafeto', 'sc_monte'),
    'drawable/sc_tile_fan_off.xml': pressable('sc_arena', 'sc_linea_fuerte'),
    'drawable/sc_tile_heater.xml': pressable('sc_panela_suave', 'sc_linea'),
    'drawable/sc_bed_progress.xml': (f'<layer-list {A}>\n'
        '  <item android:id="@android:id/background"><shape><solid android:color="@color/sc_arena"/><corners android:radius="6dp"/><stroke android:width="1dp" android:color="@color/sc_linea_fuerte"/></shape></item>\n'
        '  <item android:id="@android:id/progress"><clip><shape><solid android:color="@color/sc_dato_agua"/><corners android:radius="6dp"/></shape></clip></item>\n</layer-list>\n'),
}

def tv(id_, size, color, extra=''):
    i = f'android:id="@+id/{id_}" ' if id_ else ''
    return f'<TextView {i}android:layout_width="wrap_content" android:layout_height="wrap_content" android:textSize="{size}sp" android:textColor="@color/{color}" {extra}/>'

def rotulo(text):
    return tv(None, 10, 'sc_tierra_suave', f'android:text="{text}" android:textStyle="bold" android:letterSpacing="0.08"')

def head(icon, id_, default):
    return (f'<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:gravity="center_vertical" android:orientation="horizontal">'
            f'<FrameLayout android:layout_width="22dp" android:layout_height="22dp" android:background="@drawable/sc_leaf_monte">'
            f'<ImageView android:layout_width="14dp" android:layout_height="14dp" android:layout_gravity="center" android:src="@drawable/sc_ic_{icon}" android:tint="@color/sc_sobre_monte" android:importantForAccessibility="no"/></FrameLayout>'
            f'<TextView android:id="@+id/{id_}" android:layout_width="0dp" android:layout_weight="1" android:layout_height="wrap_content" android:layout_marginStart="8dp" '
            f'android:textColor="@color/sc_tierra" android:textSize="12sp" android:textStyle="bold" android:maxLines="1" android:ellipsize="end" android:text="{default}"/></LinearLayout>')

UPDATED = ('<TextView android:id="@+id/updated" android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="6dp" '
           'android:fontFamily="monospace" android:textColor="@color/sc_tierra_suave" android:textSize="10sp" android:maxLines="1" android:ellipsize="end"/>')

def root(body, pad='14dp', bg='sc_widget_bg'):
    return (H + f'<LinearLayout {A} android:id="@+id/root" android:layout_width="match_parent" android:layout_height="match_parent" '
            f'android:orientation="vertical" android:padding="{pad}" android:background="@drawable/{bg}">\n{body}\n</LinearLayout>\n')

# Humedad (2×2): cifra grande, fase en Fraunces itálica (serif), objetivo y avance del lecho.
files['layout/widget_moisture.xml'] = root(
    head('humedad', 'batch', 'Lote') +
    '<LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_marginTop="4dp" android:orientation="horizontal" android:gravity="bottom">'
    + tv('moisture', 34, 'sc_tierra', 'android:fontFamily="monospace" android:text="—"')
    + tv(None, 14, 'sc_tierra_suave', 'android:fontFamily="monospace" android:layout_marginStart="2dp" android:layout_marginBottom="6dp" android:text="%"') + '</LinearLayout>'
    + tv('phase', 14, 'sc_bruma', 'android:fontFamily="serif" android:textStyle="bold|italic" android:text="Secando"')
    + tv('target', 12, 'sc_tierra_suave')
    + '<ProgressBar android:id="@+id/progress" style="@android:style/Widget.ProgressBar.Horizontal" android:layout_width="match_parent" android:layout_height="10dp" '
      'android:layout_marginTop="6dp" android:max="100" android:progress="0" android:progressDrawable="@drawable/sc_bed_progress"/>'
    + UPDATED)

# Lote (4×2): banda con la etiqueta del lote, y tres cifras (humedad · temperatura · faltan).
col = lambda label, id_, color: (f'<LinearLayout android:layout_width="0dp" android:layout_weight="1" android:layout_height="wrap_content" android:orientation="vertical">'
                                 + rotulo(label) + tv(id_, 22, color, 'android:fontFamily="monospace" android:text="—"') + '</LinearLayout>')
files['layout/widget_batch.xml'] = root(
    '<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:background="@color/sc_pintura_loma" '
    'android:paddingStart="14dp" android:paddingEnd="14dp" android:paddingTop="10dp" android:paddingBottom="8dp">'
    + tv('batch', 11, 'sc_arcilla', 'android:background="@color/sc_papel" android:paddingStart="6dp" android:paddingEnd="6dp" android:textStyle="bold" android:letterSpacing="0.12" android:textAllCaps="true" android:text="Lote"')
    + tv('variety', 13, 'sc_tierra', 'android:background="@color/sc_papel" android:paddingStart="6dp" android:paddingEnd="6dp" android:fontFamily="serif" android:textStyle="bold|italic" android:maxLines="1" android:ellipsize="end"')
    + '</LinearLayout>'
    '<LinearLayout android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1" android:orientation="horizontal" android:paddingStart="14dp" android:paddingEnd="14dp" android:paddingTop="8dp">'
    + col('HUMEDAD', 'moisture', 'sc_tierra') + col('TEMPERATURA', 'temperature', 'sc_tierra') + col('FALTAN', 'remaining', 'sc_anil') + '</LinearLayout>'
    + UPDATED.replace('android:layout_marginTop="6dp"', 'android:paddingStart="14dp" android:paddingEnd="14dp" android:paddingBottom="10dp"'),
    pad='0dp')

# Equipo (4×2): ventilador conmutable; la resistencia NUNCA desde el widget (abre la app).
tile = lambda id_, bg, icon, name, state_id, state, color, desc: (
    f'<LinearLayout android:id="@+id/{id_}" android:layout_width="0dp" android:layout_weight="1" android:layout_height="match_parent" android:layout_margin="3dp" '
    f'android:orientation="vertical" android:padding="10dp" android:background="@drawable/{bg}" android:contentDescription="{desc}">'
    f'<FrameLayout android:layout_width="26dp" android:layout_height="26dp" android:background="@drawable/sc_icon_chip">'
    f'<ImageView android:id="@+id/{id_}_icon" android:layout_width="18dp" android:layout_height="18dp" android:layout_gravity="center" android:src="@drawable/sc_ic_{icon}" android:importantForAccessibility="no"/></FrameLayout>'
    '<FrameLayout android:layout_width="0dp" android:layout_height="0dp" android:layout_weight="1"/>'
    + tv(f'{id_}_name', 13, color, f'android:text="{name}" android:textStyle="bold"')
    + tv(state_id, 11, color if id_ == 'fan' else 'sc_panela', f'android:text="{state}" android:textStyle="bold"')
    + '</LinearLayout>')
files['layout/widget_equipment.xml'] = root(
    head('ventilador', 'title', 'Equipo')
    + '<LinearLayout android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1" android:layout_marginTop="6dp" android:orientation="horizontal">'
    + tile('fan', 'sc_tile_fan_on', 'ventilador', 'Ventilador', 'fan_state', 'Encendido', 'sc_sobre_monte', 'Ventilador')
    + tile('heater', 'sc_tile_heater', 'resistencia', 'Resistencia', 'heater_state', 'Abrir en la app', 'sc_tierra', 'Resistencia: abrir en la app')
    + '</LinearLayout>' + UPDATED, pad='12dp')

for n, cx, cy, mw, mh in [('moisture', 2, 2, 110, 110), ('batch', 4, 2, 250, 110), ('equipment', 4, 2, 250, 110)]:
    files[f'xml/widget_{n}_info.xml'] = (H + f'<appwidget-provider {A} android:initialLayout="@layout/widget_{n}" android:previewLayout="@layout/widget_{n}" '
        f'android:minWidth="{mw}dp" android:minHeight="{mh}dp" android:targetCellWidth="{cx}" android:targetCellHeight="{cy}" '
        f'android:resizeMode="horizontal|vertical" android:updatePeriodMillis="1800000" android:widgetCategory="home_screen|keyguard" '
        f'android:description="@string/widget_{n}_desc"/>\n')

files['values/siscan_strings.xml'] = (H + '<resources>\n'
    '    <string name="widget_moisture_desc">Humedad del lote y avance del secado</string>\n'
    '    <string name="widget_batch_desc">Lote activo: humedad, temperatura y tiempo restante</string>\n'
    '    <string name="widget_equipment_desc">Ventilador (se cambia aquí) y resistencia (se abre en la app)</string>\n</resources>\n')

for path, body in files.items():
    full = os.path.join(R, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    if not body.startswith('<?xml'):
        body = H + body
    open(full, 'w', encoding='utf8').write(body)
    print(path)
