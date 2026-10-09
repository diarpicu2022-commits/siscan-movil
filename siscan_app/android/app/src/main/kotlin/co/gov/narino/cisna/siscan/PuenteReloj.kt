package co.gov.narino.cisna.siscan

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.android.gms.wearable.WearableListenerService
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.security.KeyStore
import java.util.Locale
import java.util.concurrent.Executors
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * Sesión para el reloj: la cabecera de la contraseña de aplicación de quien ingresó con «Recordarme», cifrada con una
 * llave del Android Keystore que nunca sale del teléfono. La app la guarda al ingresar y la borra al cerrar sesión.
 */
object SesionReloj {
    private const val PREFS = "siscan_reloj_sesion"
    private const val ALIAS = "siscan_reloj"

    private fun llave(): SecretKey {
        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        (ks.getKey(ALIAS, null) as? SecretKey)?.let { return it }
        val g = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
        g.init(KeyGenParameterSpec.Builder(ALIAS, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM).setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build())
        return g.generateKey()
    }

    fun guardar(c: Context, cabecera: String, api: String) {
        val cifra = Cipher.getInstance("AES/GCM/NoPadding").apply { init(Cipher.ENCRYPT_MODE, llave()) }
        val datos = cifra.doFinal(cabecera.toByteArray())
        c.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putString("iv", Base64.encodeToString(cifra.iv, Base64.NO_WRAP))
            .putString("dato", Base64.encodeToString(datos, Base64.NO_WRAP))
            .putString("api", api).apply()
    }

    fun leer(c: Context): Pair<String, String>? = runCatching {
        val p = c.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val iv = Base64.decode(p.getString("iv", null) ?: return null, Base64.NO_WRAP)
        val dato = Base64.decode(p.getString("dato", null) ?: return null, Base64.NO_WRAP)
        val cifra = Cipher.getInstance("AES/GCM/NoPadding").apply { init(Cipher.DECRYPT_MODE, llave(), GCMParameterSpec(128, iv)) }
        String(cifra.doFinal(dato)) to (p.getString("api", null) ?: return null)
    }.getOrNull()

    fun borrar(c: Context) = c.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().clear().apply()
}

/**
 * Puente con SISCAN en el reloj (capa de datos de Wear OS): el reloj pide encender o apagar un actuador o registrar un
 * pesaje; el teléfono lo envía al servidor con la sesión guardada y devuelve el resultado en palabras de la persona.
 */
class PuenteReloj : WearableListenerService() {
    private val hilo = Executors.newSingleThreadExecutor()

    override fun onRequest(nodeId: String, path: String, data: ByteArray): Task<ByteArray>? {
        if (path != "/siscan/orden") return null
        return Tasks.call(hilo) { responder(JSONObject(String(data))).toString().toByteArray() }
    }

    private class Orden(val metodo: String, val ruta: String, val cuerpo: JSONObject, val hecho: String)

    private fun responder(o: JSONObject): JSONObject {
        fun r(ok: Boolean, t: String) = JSONObject().put("ok", ok).put("texto", t)
        val (cabecera, api) = SesionReloj.leer(this)
            ?: return r(false, "Ingresa en SISCAN del teléfono con «Recordarme» para mandar órdenes desde el reloj.")
        val orden = when (o.optString("tipo")) {
            "actuador" -> Orden("PUT", "/api/actuators/${o.getInt("id")}",
                JSONObject().put("status", if (o.getBoolean("on")) "ON" else "OFF").put("secadorId", 1).put("source", "WATCH"),
                "Se cumple cuando el ESP32 reporte.")
            "pesaje" -> Orden("POST", "/drying-batches/${o.getInt("lote")}/samples", JSONObject().put("sampleWeightGrams", o.getDouble("gramos")),
                String.format(Locale.US, "%.1f g", o.getDouble("gramos")).replace('.', ','))
            else -> return r(false, "Orden desconocida.")
        }
        return runCatching {
            val c = URL(api + orden.ruta).openConnection() as HttpURLConnection
            c.requestMethod = orden.metodo
            c.connectTimeout = 15_000
            c.readTimeout = 20_000
            c.doOutput = true
            c.setRequestProperty("Authorization", cabecera)
            c.setRequestProperty("Content-Type", "application/json")
            c.setRequestProperty("Accept", "application/json")
            c.outputStream.use { it.write(orden.cuerpo.toString().toByteArray()) }
            val codigo = c.responseCode
            val msg = runCatching { JSONObject((if (codigo < 400) c.inputStream else c.errorStream).bufferedReader().readText()).optString("message") }.getOrNull()
            c.disconnect()
            when {
                codigo in 200..299 -> r(true, orden.hecho)
                codigo == 401 || codigo == 403 -> { SesionReloj.borrar(this); r(false, "La sesión del teléfono venció. Ingresa de nuevo en SISCAN.") }
                codigo == 409 -> r(false, msg?.takeIf { it.isNotBlank() } ?: "El secador está en modo automático.")
                else -> r(false, msg?.takeIf { it.isNotBlank() } ?: "El servidor no aceptó la orden (código $codigo).")
            }
        }.getOrElse { r(false, "El teléfono no pudo conectarse con el secador.") }
    }
}
