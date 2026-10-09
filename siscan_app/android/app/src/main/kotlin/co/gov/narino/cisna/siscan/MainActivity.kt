package co.gov.narino.cisna.siscan

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
    }
}
