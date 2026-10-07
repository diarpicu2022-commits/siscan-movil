# Política de tratamiento de datos — App SISCAN (Android)

> **Borrador técnico** (2026-10-07), versión 0.1. Debe revisarlo un abogado antes de publicarlo para terceros.

- **Responsable:** proyecto SISCAN — Secado Inteligente de Café (Gobernación de Nariño · CISNA). Contacto: el que defina
  el responsable antes de publicar (pendiente).
- **Qué datos guarda la app en el teléfono:**
  1. El **último estado del secador** (lecturas, lote, equipo, alertas) para mostrarlo sin señal. No son datos personales.
  2. Si la persona ingresa como Gestor del Secador: su **usuario** y su **contraseña de aplicación** de WordPress, cifrados
     en el almacén seguro del teléfono (Android Keystore), solo para enviar órdenes al secador.
- **Qué NO hace:** no usa ubicación, cámara, contactos ni rastreo; no tiene publicidad ni analítica; no comparte datos
  con terceros. El único servidor con el que habla es `cisna.narino.gov.co` (lecturas públicas y órdenes autenticadas).
- **Finalidad:** mostrar el estado del secado y permitir al personal autorizado encender o apagar el equipo.
- **Conservación:** hasta que la persona cierre sesión (borra la credencial) o desinstale la app (borra todo).
- **Seguridad:** credencial cifrada; conexión HTTPS; la contraseña de aplicación se puede revocar en WordPress en cualquier momento.
- **Derechos del titular** (Ley 1581 de 2012, Decreto 1377 de 2013 compilado en el Decreto 1074 de 2015): conocer,
  actualizar, rectificar y suprimir sus datos, y revocar la autorización. En la app: **Ajustes → Cerrar sesión** borra la
  credencial; **Ajustes → Borrar datos de este teléfono** borra también el estado guardado. Los datos de la cuenta de
  WordPress los gestiona el administrador del sitio.
- **Menores:** la app es para personal de operación del secador; no está dirigida a menores.
- **Cambios:** una nueva versión de esta política se mostrará en la app con su fecha.
