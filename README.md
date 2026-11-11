# SISCAN móvil · Secado Inteligente de Café

SISCAN es la app del secador de café solar-eléctrico que hice en mi trabajo de grado de Ingeniería Electrónica, en el CISNA de la Gobernación de Nariño. Con el teléfono el caficultor ve cómo va el secado de su lote, cuánto le falta para llegar a la humedad buena y si el equipo está funcionando, sin tener que estar al pie del secador.

Este repo tiene la app del teléfono y la del reloj. Es el proyecto final de Diseño de Interfaces de Software (5.º semestre, Universidad Cooperativa de Colombia).

## Para qué sirve

El café pergamino se tiene que secar hasta quedar entre 10 y 12 % de humedad. Si se pasa o se queda corto, se pierde calidad y precio. En el ensayo de la tesis un lote secado al aire libre pasó de 44,4 % a 10,6 % en 12 pesajes. SISCAN junta esos datos y los muestra de forma que se entiendan en el patio, con sol y con las manos ocupadas.

| Pantalla | Qué muestra |
|---|---|
| Inicio | El lote que se está secando, la humedad, la temperatura, el tiempo que falta, la predicción de IA y las alertas |
| Lotes | Cada lote con su curva de secado y sus pesajes |
| Pesaje | Registrar una muestra pesada (Gravimet) y calibrar |
| Equipo | Si el secador está funcionando, el consumo de energía y su costo, y las órdenes al ventilador y a la resistencia |
| Más | Ingreso, huella, idioma, tema, mapa y «Tus datos» |

Además tiene widgets de inicio y de bloqueo, notificaciones de alerta, ingreso con huella y tres temas (Claro, Oscuro y «Según la hora»). Está en español, inglés y portugués de Brasil.

**El reloj (Wear OS)** muestra la humedad, el tiempo que falta y la alerta más grave, con una tarjeta, cuatro complicaciones y una esfera propia. Le pide los datos al teléfono emparejado.

## Cómo se usa

- **Sin cuenta**, la app es de solo lectura. Se ven los datos del secador en vivo, los lotes y las alertas.
- **Con cuenta**, se pueden registrar pesajes y mandar órdenes al secador. Se entra con un usuario del WordPress del CISNA (`cisna.narino.gov.co`) y una **contraseña de aplicación**, que es distinta de la contraseña normal y se puede revocar desde el perfil de WordPress.

Las órdenes llegan al secador de verdad, por eso las cuentas se dan solo a quien las va a usar. La cuenta de prueba para el profesor está en el documento de cuentas de prueba del portafolio (`docs/Cuentas de prueba.md` en el repo [mi-portafolio](https://github.com/diarpicu2022-commits/mi-portafolio)).

## Instalar

Los APK están en [Releases](https://github.com/diarpicu2022-commits/siscan-movil/releases). Se descarga el APK en el teléfono Android, se abre y se acepta instalar desde esa fuente. La versión publicada ahí es la 0.1.1. La actual del código es la 0.2.1.

## Cómo correrla desde el código

Necesitas Flutter (Dart 3.13 o superior) y, para el reloj, el SDK de Android con JDK 21.

```bash
cd siscan_app
flutter pub get
flutter run                     # en el teléfono conectado o el emulador
flutter test                    # pruebas de pantallas
flutter build apk --release     # APK de release

cd ../siscan_reloj
./gradlew assembleRelease       # app del reloj y esfera
```

En Windows conviene clonar el repo en una ruta sin «ñ» ni tildes (por ejemplo `C:\dev\siscan`), porque el analizador de Dart falla con esos caracteres en la ruta.

La app usa por defecto la API del CISNA (`https://cisna.narino.gov.co/wp-json/secador/v1`). Para apuntar a otra se compila con `--dart-define=SISCAN_API=<url>`.

## Cómo está hecho

- **Teléfono:** Flutter, con el puente nativo `PuenteReloj.kt` para hablar con el reloj. La sesión se guarda cifrada con el Android Keystore.
- **Reloj:** Kotlin con Compose para Wear OS, tarjeta, complicaciones y esfera en Watch Face Format v2.
- **Datos:** el plugin `secador-cafe-api` de WordPress en el servidor del CISNA, que recibe las lecturas del secador. El panel web y el firmware viven en el repo de la tesis, no en este.
- **Diseño:** sistema de diseño SISCAN v2 (`siscan-design-system.zip`). Los tokens están en `siscan_app/lib/core/theme/siscan_tokens.dart` y cada decisión con su verificación está en `docs/ux/anexos/`.

| Carpeta | Qué hay |
|---|---|
| `siscan_app/` | App del teléfono (Flutter) |
| `siscan_reloj/` | App del reloj y esfera (Wear OS) |
| `docs/ux/anexos/` | Anexos de diseño |
| `docs/legal/` | Política de tratamiento de datos (borrador, en español, inglés y portugués) |
| `CONTINUAR.md` | Estado del proyecto y lo que sigue |

## Datos personales

La app guarda solo lo necesario para la sesión y no rastrea a nadie. La política de tratamiento de datos (Ley 1581 de 2012) está dentro de la app en «Tus datos» y en `docs/legal/`. Es un borrador técnico y la tiene que revisar un abogado antes de publicar la app en una tienda.

## Lo que falta

- Probar el reloj con el teléfono en dispositivos reales.
- Publicar en Releases los APK de la versión 0.2.1.
- La sonda de humedad del grano está saturada, así que la humedad que se muestra sale de los pesajes, y la energía es estimada hasta que se instale el medidor AC.

## Autor

Diego Armando Pinta Cuasquen · [GitHub](https://github.com/diarpicu2022-commits) · [Portafolio](https://mi-portafolio-beta-kohl.vercel.app)
