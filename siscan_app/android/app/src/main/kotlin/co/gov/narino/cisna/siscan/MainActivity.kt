package co.gov.narino.cisna.siscan

import android.app.LocaleManager
import android.os.Build
import android.os.LocaleList
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** FlutterFragmentActivity: el ingreso con huella (local_auth) usa el diálogo biométrico del sistema. */
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Sesión para el reloj: la app la guarda al ingresar con «Recordarme» y la borra al cerrar sesión.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "siscan/reloj").setMethodCallHandler { call, res ->
            when (call.method) {
                "guardar" -> { SesionReloj.guardar(this, call.argument<String>("cabecera")!!, call.argument<String>("api")!!); res.success(null) }
                "borrar" -> { SesionReloj.borrar(this); res.success(null) }
                else -> res.notImplemented()
            }
        }
        // Idioma por app de Android 13+ (Ajustes › Idiomas de apps), el mismo que se elige en Más › Idioma (anexo de idiomas,
        // I2). `leer` devuelve la etiqueta («en», «pt-BR») o '' si sigue al teléfono; null en Android 12 o anterior.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "siscan/idioma").setMethodCallHandler { call, res ->
            // `sistema`: el idioma del teléfono, aunque SISCAN tenga otro propio (para «Ahora: …» bajo «Como el teléfono»).
            if (call.method == "sistema") { res.success(android.content.res.Resources.getSystem().configuration.locales.toLanguageTags()); return@setMethodCallHandler }
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) { res.success(null); return@setMethodCallHandler }
            val lm = getSystemService(LocaleManager::class.java)
            when (call.method) {
                "leer" -> res.success(lm.applicationLocales.toLanguageTags())
                "fijar" -> {
                    val etiqueta = call.argument<String>("etiqueta").orEmpty()
                    lm.applicationLocales = if (etiqueta.isEmpty()) LocaleList.getEmptyLocaleList() else LocaleList.forLanguageTags(etiqueta)
                    res.success(null)
                }
                else -> res.notImplemented()
            }
        }
    }
}
