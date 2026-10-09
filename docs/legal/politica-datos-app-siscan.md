# Política de tratamiento de datos — App SISCAN (Android)

> **Borrador técnico**, versión 0.2 · vigente desde el 8 de octubre de 2026 (reemplaza la 0.1 del 7 de octubre).
> Debe revisarlo un abogado antes de publicarlo para terceros. El mismo texto se muestra dentro de la app en
> **Más → Tus datos y privacidad** (`lib/pantallas/mas.dart`, `PantallaPrivacidad.secciones`).

- **Responsable:** proyecto SISCAN — Secado Inteligente de Café (Gobernación de Nariño · CISNA). Contacto: el que defina
  el responsable antes de publicar (pendiente).
- **Qué guarda la app en el teléfono:**
  1. El **último estado del secador** (lecturas, lote, equipo, alertas) para mostrarlo sin señal. No son datos personales.
  2. Si la persona ingresa como Gestor del Secador: su **usuario** y su **contraseña de aplicación** de WordPress, cifrados
     en el almacén seguro del teléfono (Android Keystore), para enviar órdenes y registrar pesajes.
  3. Sus elecciones de **tema**, **notificaciones** e **ingreso con huella**.
- **Huella (opcional):** la verifica el sensor del teléfono; la app nunca recibe ni guarda la huella, solo desbloquea la
  credencial cifrada. Se activa en Más → Ingreso con huella, después de confirmar la huella una vez.
- **Ubicación (opcional, solo a pedido):** se usa únicamente cuando un administrador toca «Usar mi ubicación actual» en
  Más → Ubicación del secador. Se envía al servidor del CISNA como ubicación **del secador**, no de la persona. No se
  guarda en el teléfono ni se usa en segundo plano. Android pide el permiso en ese momento.
- **Notificaciones (opcional):** si se activan, la app consulta el servidor cada 15 minutos (solo lectura) para avisar
  alertas, hora de pesar y lote listo, y muestra el avance del lote en la pantalla de bloqueo. Android pide el permiso al
  activarlas.
- **Inteligencia artificial:** la predicción de la tesis y la red neuronal corren en el servidor del CISNA. La «segunda
  opinión» la genera Groq desde ese servidor con datos del lote y del secador; no recibe datos personales.
- **Qué NO hace:** no usa cámara ni contactos; no tiene publicidad, analítica ni rastreo; no comparte datos con
  terceros. El único servidor con el que habla es `cisna.narino.gov.co` por HTTPS.
- **Finalidad:** mostrar el estado del secado y permitir al personal autorizado registrar pesajes y operar el equipo.
- **Conservación:** hasta cerrar sesión (borra la credencial), usar «Borrar los datos de este teléfono» o desinstalar.
- **Seguridad:** credencial cifrada; HTTPS; la contraseña de aplicación se revoca en WordPress en cualquier momento
  (Más → Tus datos → Revocar la contraseña de aplicación).
- **Derechos del titular** (Ley 1581 de 2012, Decreto 1377 de 2013 compilado en el Decreto 1074 de 2015): conocer,
  actualizar, rectificar y suprimir sus datos, y revocar la autorización. En la app: **Cerrar sesión**, **Borrar los
  datos de este teléfono** y **Revocar la contraseña de aplicación**. Los datos de la cuenta de WordPress los gestiona el
  administrador del sitio.
- **Menores:** la app es para personal de operación del secador; no está dirigida a menores.
- **Cambios:** una nueva versión se mostrará en la app con su fecha y, si cambia lo que se trata, se volverá a pedir la
  autorización.

## Pendiente antes de publicar en tiendas
- Contacto del responsable y URL pública de esta política.
- Google Play: formulario de Seguridad de los datos (credencial cifrada; ubicación aproximada/precisa solo a pedido, no
  recopilada por la app sino enviada como dato del equipo), divulgación destacada de ubicación antes del permiso.
- Revisión por abogado.
