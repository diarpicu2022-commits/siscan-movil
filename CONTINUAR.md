# SISCAN — dónde vamos y cómo seguir

Actualizado: 2026-10-15 (noche). Léelo primero al retomar. El detalle de cada pieza está en los anexos que se enlazan.

## Repositorios y carpetas

| Qué | Dónde |
|---|---|
| App Android (Flutter) + reloj Wear OS + esfera | `C:\dev\siscan` (= `App Mobile`), GitHub `diarpicu2022-commits/siscan-movil` |
| Tesis: plugin WordPress, panel web, firmware, PCB, ML | `C:\Users\Cisna\Documents\Tesis\secador-cafe` |
| Sistema de diseño SISCAN v2 | `C:\dev\siscan-ds-nuevo\siscan-design-system` |
| APK publicadas a mano | `C:\Users\Cisna\Documents\Proyectos Personales\APKs` |
| Videos de presentación | `C:\dev\siscan\brag-output\` |
| Sustentación (diapositivas y documento) | `C:\dev\siscan\docs\sustentacion\` |

Flujo de git: rama base `develop`, una rama `feature/…` por cambio, PR con la plantilla de 4 secciones, Conventional
Commits, autor Diego Armando Pinta Cuasquen. Nunca firmar con Claude.

## Estado por pieza

### 1. Panel web (plugin `secador-cafe-api` 3.5.0) — hecho
- Panel con el sistema v2 en `wordpress-plugin/secador-cafe-api/paginas/panel-siscan.html`, generado por
  `web-src/siscan/construir.py` (React 18 + Leaflet 1.9.4 incluidos dentro del HTML).
- Arreglos del 2026-10-09 (todos medidos con `web-src/siscan/verificar.mjs`, 0 fallos):
  barra lateral a todo el alto y sin desbordar; mapa real (OpenStreetMap, clic derecho para ubicar); Monitoreo por filas
  sin huecos; Calibración ordenada; botón de tema legible en claro; etiqueta de la curva al pasar el puntero; nota de
  energía dentro de su recuadro; Groq con recuperación si retira el modelo (404 → elige otro; `pruebas/prueba-groq.php` 4/4).
- Cerrar sesión lleva a `/secador-cafe/publico` (Diego lo dejó así).
- Anexo: `Tesis/secador-cafe/ux/anexos/2026-10-08-panel-siscan-sistema-v2.md` (con enmiendas).
- **Pendiente (Diego):** subir al servidor `paginas/panel-siscan.html` e `inc/inteligencia.php` (o el zip
  `despliegue/secador-cafe-api-3.5.0.zip`: copiar todo, incluidas `inc/`, `modelos/`, `marca/`, `paginas/`).

### 2. App Android `siscan_app` (SISCAN 0.2.1) — hecha, PR #2 abierto
- Sistema v2 completo, widgets de inicio, huella, notificaciones, puente con el reloj (`PuenteReloj.kt`,
  canal `siscan/reloj`, cabecera cifrada con Android Keystore). Botón flotante corregido (commit 003e349).
- Pruebas: `test/pantallas_test.dart` 45/45. Anexo: `docs/ux/anexos/2026-10-08-apk-siscan-sistema-v2.md`.
- APK: `SISCAN-0.2.1.apk`. Rama `feature/apk-sistema-v2` → PR #2 (abierto).

### 3. Reloj `siscan_reloj` + esfera — hecho, PR #3 abierto
- Compose para Wear OS, tarjeta, 4 complicaciones, esfera en Watch Face Format v2; pide las órdenes al teléfono por la
  capa de datos (capacidad `siscan_puente`), no guarda claves.
- Anexo: `docs/ux/anexos/2026-10-09-reloj-siscan-sistema-v2.md`. APK: `SISCAN-reloj-0.2.0.apk`, `SISCAN-esfera-0.2.0.apk`.
- Rama `feature/reloj-sistema-v2` (incluye la de la APK) → PR #3 (abierto).
- **Pendiente:** probar reloj ↔ teléfono en dispositivos reales.

### 4. Videos (skill `brag` + Hyperframes) — hechos
- `brag-output/que-es-siscan/brag.mp4` (24 s) y `brag-output/lanzamiento/brag.mp4` (22,7 s), con póster como fotograma 0,
  `brag.jpg` y `share-copy.txt`. Se regeneran con `construir.py` dentro de cada carpeta y luego
  `npx hyperframes render --quality high --output ../brag.mp4` desde `composition/`.
- Herramientas instaladas: FFmpeg 9.0.2 (winget; las terminales abiertas antes no lo ven) y Chrome de Hyperframes.
- `brag-output/` no está en git ni en `.gitignore`: **decidir** si se sube o se excluye.

### 5. Sustentación del trabajo de grado — hecha (versión de electrónica)
- Tesis: «Diseño e implementación de un sistema autónomo de secado híbrido solar-eléctrico con control automatizado para
  café pergamino en el departamento de Nariño». Ingeniería Electrónica, Universidad de Nariño. Director: Germán Obando.
  Modalidad pasantía (Interacción Social), CISNA · Gobernación de Nariño.
- **Usar estos dos** (foco en arquitectura de hardware y de software, sin nada del sistema de diseño, por pedido de Diego):
  - `docs/sustentacion/SISCAN-sustentacion-electronica.pptx` — 19 diapositivas, notas del orador con tiempos (15 min).
  - `docs/sustentacion/SISCAN-documento-de-defensa-electronica.docx` — 13 páginas: qué/con qué/por qué/para qué de cada
    parte, cifras con su fuente, 12 preguntas del jurado y guion.
- Se regeneran con `python construir_pptx.py` y `python construir_docx.py` (en esa carpeta). Imágenes en `img/`
  (renders de la PCB hechos con `kicad-cli pcb render`, caja, capturas). Fuentes Outfit y Plus Jakarta Sans en `fuentes/`:
  instalarlas en el computador de la sustentación.
- `SISCAN-sustentacion.pptx` y `SISCAN-documento-de-defensa.docx` son la primera versión (con sistema de diseño):
  **obsoletos**; borrarlos cuando Diego los cierre.
- Anexo: `docs/ux/anexos/2026-10-09-sustentacion.md`.
- **Pendiente:** visto bueno de Diego a los rótulos de 14–17 pt en diagramas y tablas; ensayar en el proyector real.

### 6. Escena del secador en Inicio, «El secador» en el reloj y tema «Según la hora»: plan completo (2026-10-15)
- Rama `feature/invernadero-y-tema-por-hora` (desde `feature/reloj-sistema-v2`; PR apilado sobre #3). **Sin commit.**
- Anexo y contrato: `docs/ux/anexos/2026-10-12-invernadero-y-tema-por-hora.md` (C1–C3 y enmiendas E1–E10, todas
  aprobadas por Diego el 2026-10-15).
- **Pasos 1 a 5 aprobados; paso 6 (estados) hecho, esperando el visto bueno final.**
  - Teléfono: Inicio con la escena por hora y la tarjeta de vidrio con la cifra grande (E8); Más › Tema con cuatro
    opciones y luna (E7); Más › Acerca de y licencias (E9); estados de cargando, error, vacío, copia guardada, dato
    viejo y solo lectura con golden.
  - Reloj: página «El secador» con la placa centrada (E6), escena WebP por momento, sin escena en ambiente; estados
    capturados en el emulador.
  - Sistema de diseño: `luna` añadida a `components/bundle.js` y `bundle.local.js` (E10; esa carpeta no es git).
- Medición final: `flutter analyze` 0 avisos; batería del teléfono **91/91** (dos corridas; también se arregló el
  `04v-pesaje` que fallaba por fechas, con la hora inyectable `ahora()` de `estado.dart`); reloj 11/11 y assembleDebug
  bien; los dos árboles idénticos; emuladores cerrados.
- Herramientas nuevas: `tools/svg_rgba_a_opacidad.py` (correr después de exportar la escena), `tools/generar_escena_reloj.py`,
  `tools/svg_escena_a_vector.py` (solo para el banco), `siscan_reloj/verificar_secador.py` (contraste del reloj; `--estados`).
- Pruebas en un equipo: `--dart-define=SISCAN_HORA=18:58:30` (teléfono, fuera de release) y `--es momento day|dusk|night`
  y `--es api …` (reloj, solo depuración).

**Qué falta para abrir el PR de esta rama:**
1. Visto bueno de Diego al paso 6.
2. Decidir qué entra en el commit y qué no: `brag-output/` y `docs/sustentacion/` están sin seguimiento y no son de este
   trabajo (rama aparte o `.gitignore`); `PLAN.md` aparece modificado desde antes y hay que revisarlo.
3. Commits en Conventional Commits, por partes: `feat(app)` momento, tema por hora, cabecera, selector, licencias y
   estados; `fix(app)` SVG rgba, hora inyectable y goldens `04v`; `feat(reloj)` El secador; `test` goldens y mediciones;
   `docs(ux)` anexo, capturas y referentes. Autor Diego Armando Pinta Cuasquen, sin firma de Claude.
4. Base del PR: `feature/reloj-sistema-v2` (PR #3), o `develop` si #2 y #3 ya entraron (en ese caso, rebase).
5. Descripción con la plantilla de 4 secciones y pantallazos: `docs/ux/capturas/invernadero/paso5/*-recorrido.png`,
   `paso6/paso6-telefono-estados.png`, `paso6/2026-10-15-reloj-lamina.png`, `reloj/2026-10-15-reloj-lamina.png` y
   `docs/ux/anexos/ref/2026-10-15-e8-tarjeta-antes-despues-web.png`.
6. Legal: actualizar la política de datos (`docs/legal/politica-datos-app-siscan.md`) para nombrar la preferencia de tema
   (`siscan_tema`, solo en el teléfono). No hace falta consentimiento nuevo. Los avisos de Lucide ya se muestran en la app
   (E9).
7. Probar en un Android de gama baja real (desenfoque 14) y TalkBack con voz (solo se verificó el árbol de accesibilidad).
8. Fuera de esta rama: idiomas es/en/pt (`feature/idiomas`); en el sistema de diseño, documentar la luna y la licencia de
   Lucide; en el reloj, distinguir «sin red con copia» de «el secador no reporta».

## Hechos de la tesis que no hay que olvidar (para no volver a equivocarse)
- Lote 3 «juco» = protocolo **A** (aire libre), 12 pesajes, 44,4 → 10,6 %. Lote 2 «El Motilón» = protocolo **B** (secador
  solar sin actuadores), 22 pesajes. Ensayo del 5 al 19 de agosto de 2026; 34 pesajes, 139.831 lecturas.
- La sonda de humedad del grano está **saturada y no mide**: la humedad es la de Gravimet.
- La energía es **estimada**; el medidor AC definitivo está pendiente.
- El prototipo está en la **residencia del autor**, no en el CISNA (montaje en el CISNA depende de una licitación).
- PID escrito y compilando, ganancias **provisionales** (falta el ensayo de escalón). PCB v2 diseñada, **sin fabricar**.
  Firmware v2 (dos nodos) compila, **sin probar** en banco. Protocolos C y D pendientes de cosecha. Una réplica por tratamiento.
- Fuentes: `Tesis/secador-cafe/presentacion/` (presentación anterior), `ARQUITECTURA_V2.md`, `firmware*/README.md`,
  `Pcb/secador_cafe_pcb/README_ESQUEMATICO.md`, `ml/RESULTADOS.md`, `ml/REDES_NEURONALES.md`, `ml/datos/`.

## Próximos pasos sugeridos
1. Diego: subir el plugin actualizado y grabar el firmware cuando toque.
2. Revisar y fusionar PR #2 y PR #3 hacia `develop`.
3. Decidir qué hacer con `brag-output/` y `docs/sustentacion/` en git (rama `chore/…` o `docs/…` + PR).
4. Probar reloj ↔ teléfono en dispositivos reales.
5. Ensayar la sustentación con el documento de defensa abierto.
6. Legal (regla global): política de tratamiento v0.2 es borrador técnico; revisión de abogado antes de publicar en tiendas.
