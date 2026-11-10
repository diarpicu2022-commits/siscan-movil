"""Genera el módulo de la esfera SISCAN (Watch Face Format, solo recursos) desde las medidas del sistema de diseño v2.

components/WatchFace y WatchAmbient: la esfera de la documentación (224 px) se dibuja a 450, así que cada medida del
sistema va por 2 (hora 56 → 113, complicaciones 48 → 96, fecha 13 → 26). Colores del tema oscuro (Tokens.kt).
Uso: python tools/generar_esfera.py
"""
import os
import shutil
import xml.dom.minidom

AQUI = os.path.dirname(os.path.abspath(__file__))
B = os.path.join(AQUI, '..', 'siscan_reloj', 'esfera', 'src', 'main')
APP = 'co.gov.narino.cisna.siscan/co.gov.narino.cisna.siscan.reloj.'
BROTE, SUAVE, TEMP, ALERTA = '#FFA6D07A', '#FFA9BDAE', '#FFF08A5D', '#FFFF8E80'


def escribir(ruta, texto):
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    open(ruta, 'w', encoding='utf-8', newline='\n').write(texto)


def slot(i, x, clase, tipo_def, cuerpo, tipos):
    return (f'        <ComplicationSlot slotId="{i}" x="{x}" y="232" width="96" height="96" supportedTypes="{tipos}" isCustomizable="TRUE">\n'
            # El tipo de reserva debe estar entre los admitidos del espacio (si no, Wear OS rechaza la esfera).
            f'            <DefaultProviderPolicy defaultSystemProvider="EMPTY" defaultSystemProviderType="{tipo_def}"\n'
            f'                primaryProvider="{APP}{clase}" primaryProviderType="{tipo_def}" />\n'
            f'            <BoundingOval x="0" y="0" width="96" height="96" />\n'
            f'{cuerpo}        </ComplicationSlot>\n')


# Siempre activo: solo contornos, sin color de estado. Cada pieza de las complicaciones redondas se oculta (un Group
# alrededor de los espacios de complicación no se dibuja en el motor de Wear OS).
OCULTA = '                <Variant mode="AMBIENT" target="alpha" value="0" />\n'
FONDO = OCULTA + '                <Ellipse x="0" y="0" width="96" height="96"><Fill color="#FF14231B" /></Ellipse>\n'


def texto(y, h, tam, color, fam='jakarta_700'):
    return (f'            <PartText x="4" y="{y}" width="88" height="{h}">\n' + OCULTA +
            f'                <Text align="CENTER"><Font family="{fam}" size="{tam}" color="{color}"><Template>%s<Parameter expression="[COMPLICATION.TEXT]" /></Template></Font></Text>\n'
            f'            </PartText>\n')


def icono_texto(color):
    return (f'            <PartDraw x="0" y="0" width="96" height="96">\n{FONDO}            </PartDraw>\n'
            f'            <PartImage x="34" y="14" width="28" height="28" tintColor="{color}">\n' + OCULTA +
            f'                <Image resource="[COMPLICATION.MONOCHROMATIC_IMAGE]" />\n'
            f'            </PartImage>\n' + texto(46, 34, 26, '#FFFFFFFF'))


ANILLO = ('            <Complication type="RANGED_VALUE">\n'
          f'            <PartDraw x="0" y="0" width="96" height="96">\n{FONDO}'
          '                <Arc centerX="48" centerY="48" width="88" height="88" startAngle="0" endAngle="360"><Stroke color="#1FFFFFFF" thickness="8" cap="ROUND" /></Arc>\n'
          '                <Arc centerX="48" centerY="48" width="88" height="88" startAngle="0" endAngle="0">\n'
          '                    <Transform target="endAngle" value="clamp([COMPLICATION.RANGED_VALUE_VALUE], 0, 100) * 3.6" />\n'
          f'                    <Stroke color="{BROTE}" thickness="8" cap="ROUND" />\n'
          '                </Arc>\n'
          '            </PartDraw>\n' + texto(32, 32, 24, '#FFFFFFFF') +
          '            </Complication>\n'
          '            <Complication type="SHORT_TEXT">\n'
          f'            <PartDraw x="0" y="0" width="96" height="96">\n{FONDO}            </PartDraw>\n' + texto(32, 32, 24, '#FFFFFFFF') +
          '            </Complication>\n')

TEMPERATURA = '            <Complication type="SHORT_TEXT">\n' + icono_texto(TEMP) + '            </Complication>\n'

ALERTAS = ('            <Complication type="RANGED_VALUE">\n'
           '            <Condition>\n'
           '                <Expressions><Expression name="hay"><![CDATA[[COMPLICATION.RANGED_VALUE_VALUE] > 0]]></Expression></Expressions>\n'
           '                <Compare expression="hay">\n' + icono_texto(ALERTA) +
           '                </Compare>\n'
           '                <Default>\n' + icono_texto(TEMP) +
           '                </Default>\n'
           '            </Condition>\n'
           '            </Complication>\n'
           '            <Complication type="SHORT_TEXT">\n' + icono_texto(TEMP) + '            </Complication>\n')


def lote():
    t = '<Template>%s<Parameter expression="[COMPLICATION.TEXT]" /></Template>'
    return ('        <ComplicationSlot slotId="3" x="45" y="334" width="360" height="36" supportedTypes="LONG_TEXT" isCustomizable="TRUE">\n'
            '            <DefaultProviderPolicy defaultSystemProvider="EMPTY" defaultSystemProviderType="LONG_TEXT"\n'
            f'                primaryProvider="{APP}ComplicacionLote" primaryProviderType="LONG_TEXT" />\n'
            '            <BoundingBox x="0" y="0" width="360" height="36" />\n'
            '            <Complication type="LONG_TEXT">\n'
            '                <PartText x="0" y="0" width="360" height="36">\n'
            '                    <Variant mode="AMBIENT" target="alpha" value="0" />\n'
            f'                    <Text align="CENTER" ellipsis="TRUE"><Font family="jakarta_400" size="25" color="{SUAVE}">{t}</Font></Text>\n'
            '                </PartText>\n'
            '                <PartText x="0" y="0" width="360" height="36" alpha="0">\n'
            '                    <Variant mode="AMBIENT" target="alpha" value="255" />\n'
            f'                    <Text align="CENTER" ellipsis="TRUE"><Font family="jakarta_400" size="26" color="#FF8A9A90">{t}</Font></Text>\n'
            '                </PartText>\n'
            '            </Complication>\n'
            '        </ComplicationSlot>\n')


def cara():
    fecha = '<Template>%s %s %s<Parameter expression="[DAY_OF_WEEK_S]" /><Parameter expression="[DAY]" /><Parameter expression="[MONTH_S]" /></Template>'
    return f'''<?xml version="1.0" encoding="utf-8"?>
<!-- GENERADO por tools/generar_esfera.py. Esfera SISCAN según components/WatchFace y WatchAmbient del sistema de diseño v2.
     La esfera de la documentación (224 px) se dibuja a 450: cada medida va por 2 (hora 56 → 113, complicaciones 48 → 96). -->
<WatchFace width="450" height="450">
    <Metadata key="CLOCK_TYPE" value="DIGITAL" />
    <Metadata key="PREVIEW_TIME" value="10:24:00" />
    <Scene backgroundColor="#FF000000">
        <!-- .sc-wscreen: negro OLED con un leve tinte verde arriba. En siempre activo, negro puro. -->
        <PartDraw x="0" y="0" width="450" height="450">
            <Variant mode="AMBIENT" target="alpha" value="0" />
            <Rectangle x="0" y="0" width="450" height="450">
                <Fill color="#FF0C1C13"><RadialGradient centerX="225" centerY="158" radius="375" colors="#FF0C1C13 #FF000000 #FF000000" positions="0 0.72 1" /></Fill>
            </Rectangle>
        </PartDraw>
        <!-- .sc-wdate -->
        <PartText x="65" y="70" width="320" height="34">
            <Variant mode="AMBIENT" target="alpha" value="0" />
            <Text align="CENTER"><Font family="jakarta_700" size="26" color="{BROTE}">{fecha}</Font></Text>
        </PartText>
        <!-- .sc-wclock: Outfit 600 -->
        <DigitalClock x="25" y="102" width="400" height="126">
            <Variant mode="AMBIENT" target="alpha" value="0" />
            <TimeText format="hh:mm" hourFormat="SYNC_TO_DEVICE" align="CENTER" x="0" y="0" width="400" height="126">
                <Font family="outfit_600" size="113" color="#FFFFFFFF" />
            </TimeText>
        </DigitalClock>
        <!-- .sc-wamb-clock: siempre activo. El sistema pide solo contorno, pero Watch Face Format no dibuja contornos en la
             hora (TimeText ni PartText con Outline, probado en el emulador): Outfit 300 rellena en tinta-suave, sin color de estado. -->
        <DigitalClock x="25" y="140" width="400" height="130" alpha="0">
            <Variant mode="AMBIENT" target="alpha" value="255" />
            <TimeText format="hh:mm" hourFormat="SYNC_TO_DEVICE" align="CENTER" x="0" y="0" width="400" height="130">
                <Font family="outfit_300" size="117" color="#FFA9BDAE" />
            </TimeText>
        </DigitalClock>
        <!-- .sc-wcomps: humedad del grano en anillo, temperatura interior y alertas (en rojo solo si hay) -->
{slot(0, 65, 'ComplicacionHumedad', 'RANGED_VALUE', ANILLO, 'RANGED_VALUE SHORT_TEXT')}{slot(1, 177, 'ComplicacionTemperatura', 'SHORT_TEXT', TEMPERATURA, 'SHORT_TEXT')}{slot(2, 289, 'ComplicacionAlertas', 'RANGED_VALUE', ALERTAS, 'RANGED_VALUE SHORT_TEXT')}
        <!-- .sc-wsub: lote y tiempo restante -->
{lote()}    </Scene>
</WatchFace>
'''


def fuentes():
    """La esfera no admite ejes variables: instancias fijas de Outfit (300, 600) y Plus Jakarta Sans (400, 700)."""
    from fontTools.ttLib import TTFont
    from fontTools.varLib.instancer import instantiateVariableFont
    src = os.path.join(AQUI, '..', 'siscan_app', 'assets', 'fonts', 'nuevas')
    dest = os.path.join(B, 'res', 'font')
    os.makedirs(dest, exist_ok=True)
    for fam, archivo, peso in [('outfit', 'Outfit', 300), ('outfit', 'Outfit', 600), ('jakarta', 'PlusJakartaSans', 400), ('jakarta', 'PlusJakartaSans', 700)]:
        instantiateVariableFont(TTFont(os.path.join(src, archivo + '.ttf')), {'wght': peso}).save(os.path.join(dest, f'{fam}_{peso}.ttf'))


def main():
    fuentes()
    x = cara()
    xml.dom.minidom.parseString(x.encode('utf-8'))  # bien formado
    escribir(os.path.join(B, 'res', 'raw', 'watchface.xml'), x)
    escribir(os.path.join(B, 'res', 'xml', 'watch_face_info.xml'), '''<?xml version="1.0" encoding="utf-8"?>
<WatchFaceInfo>
    <Preview value="@drawable/preview" />
    <Category value="CATEGORY_EMPTY" />
    <AvailableInRetail value="true" />
    <MultipleInstancesAllowed value="false" />
    <Editable value="true" />
</WatchFaceInfo>
''')
    escribir(os.path.join(B, 'res', 'values', 'strings.xml'), '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <string name="nombre">SISCAN</string>\n</resources>\n')
    escribir(os.path.join(B, 'AndroidManifest.xml'), '''<?xml version="1.0" encoding="utf-8"?>
<!-- Esfera SISCAN: humedad del grano en anillo, temperatura interior, alertas y el lote (07-smartwatch.md · Fuera de la app). -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-feature android:name="android.hardware.type.watch" />
    <application android:label="@string/nombre" android:icon="@drawable/preview" android:hasCode="false">
        <property android:name="com.google.wear.watchface.format.version" android:value="2" />
        <property android:name="com.google.wear.watchface.format.publisher" android:value="CISNA · Gobernación de Nariño" />
    </application>
</manifest>
''')
    previa = os.path.join(B, 'res', 'drawable', 'preview.png')
    if not os.path.exists(previa):
        os.makedirs(os.path.dirname(previa), exist_ok=True)
        shutil.copy(os.path.join(AQUI, '..', 'siscan_reloj', 'app', 'src', 'main', 'res', 'drawable-nodpi', 'siscan_simbolo_claro.png'), previa)
    print('esfera generada')


if __name__ == '__main__':
    main()
