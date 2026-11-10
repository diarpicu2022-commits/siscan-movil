package co.gov.narino.cisna.siscan.reloj

import android.app.Application
import android.content.Context
import android.content.res.Configuration
import android.content.res.Resources

/**
 * Textos del reloj desde strings.xml (`values`, `values-en`, `values-pt-rBR`). El reloj sigue el idioma de su sistema
 * (anexo de idiomas, I3). Sirve también donde no hay contexto a mano: Estado, Telefono, la tarjeta y las complicaciones.
 */
object Textos {
    private var r: Resources? = null
    fun iniciar(c: Context) { r = c.resources }
    /** Sin argumentos no se formatea: así un «%» suelto del texto no rompe nada. */
    fun s(id: Int, vararg args: Any): String {
        val res = r ?: return respaldo[id]?.let { if (args.isEmpty()) it else String.format(it, *args) } ?: ""
        return if (args.isEmpty()) res.getString(id) else res.getString(id, *args)
    }
    /** Sin recursos de Android (pruebas en la JVM): los textos en español que la prueba carga de values/strings.xml. */
    internal var respaldo: Map<Int, String> = emptyMap()
    internal var idiomaPrueba = "es"
    val idioma: String get() = r?.configuration?.locales?.get(0)?.language ?: idiomaPrueba
}

/** Inicia los textos una vez por proceso, antes que la actividad, la tarjeta o las complicaciones, y al cambiar el idioma. */
class AppReloj : Application() {
    override fun onCreate() { super.onCreate(); Textos.iniciar(this) }
    override fun onConfigurationChanged(newConfig: Configuration) { super.onConfigurationChanged(newConfig); Textos.iniciar(this) }
}
