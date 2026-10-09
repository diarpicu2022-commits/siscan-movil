package co.gov.narino.cisna.siscan.reloj

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.time.LocalDateTime

/**
 * Lecturas públicas del servidor de SISCAN (las mismas del panel y la app), por Wi-Fi o LTE del reloj.
 * El reloj no guarda credenciales: las órdenes y los pesajes van por el teléfono (Telefono.kt).
 */
object Red {
    var api = "https://cisna.narino.gov.co/wp-json/secador/v1"
    private const val SECADOR = 1

    private fun texto(ruta: String): String {
        val c = URL(api + ruta).openConnection() as HttpURLConnection
        c.connectTimeout = 15_000
        c.readTimeout = 25_000
        c.setRequestProperty("Accept", "application/json")
        try {
            if (c.responseCode !in 200..299) throw IllegalStateException("HTTP ${c.responseCode} en $ruta")
            return c.inputStream.bufferedReader().use { it.readText() }
        } finally {
            c.disconnect()
        }
    }

    private fun aMapa(o: JSONObject): Map<String, Any?> = o.keys().asSequence().associateWith { k -> valor(o.get(k)) }
    private fun aLista(a: JSONArray): List<Any?> = (0 until a.length()).map { valor(a.get(it)) }
    private fun valor(v: Any?): Any? = when (v) {
        is JSONObject -> aMapa(v)
        is JSONArray -> aLista(v)
        JSONObject.NULL -> null
        else -> v
    }
    @Suppress("UNCHECKED_CAST")
    private fun mapas(v: Any?): List<Map<String, Any?>> = (v as? List<Any?>).orEmpty().filterIsInstance<Map<String, Any?>>()

    /** Respuestas crudas de cada ruta: se guardan tal cual para mostrarlas sin señal. */
    suspend fun respuestas(): Map<String, String> = withContext(Dispatchers.IO) {
        coroutineScope {
            val base = mapOf(
                "lotes" to async { texto("/drying-batches?secadorId=$SECADOR") },
                "lecturas" to async { texto("/readings?secadorId=$SECADOR&limit=200") },
                "actuadores" to async { texto("/api/actuators?secadorId=$SECADOR") },
                "reporte" to async { texto("/secadores/$SECADOR/report") },
                // Rutas del plugin 3.5.0: si faltan, la pantalla muestra su estado «sin dato».
                "control" to async { runCatching { texto("/secadores/$SECADOR/control") }.getOrNull() },
            ).mapValues { it.value.await() }
            val lotes = mapas(aLista(JSONArray(base["lotes"])))
            val elegido = lotes.firstOrNull { it["status"] == "RUNNING" } ?: lotes.maxByOrNull { Estado.hora(it["startedAt"] as? String) ?: LocalDateTime.MIN }
            val id = (elegido?.get("id") as? Number)?.toInt()
            val porLote = if (id == null) emptyMap() else mapOf(
                "resumen" to async { runCatching { texto("/drying-batches/$id/summary") }.getOrNull() },
                "prediccion" to async { runCatching { texto("/drying-batches/$id/prediction") }.getOrNull() },
                "calibracion" to async { runCatching { texto("/drying-batches/$id/calibration") }.getOrNull() },
            ).mapValues { it.value.await() }
            (base + porLote).filterValues { it != null }.mapValues { it.value!! }
        }
    }

    /** Del conjunto de respuestas al estado (puro salvo el parseo). */
    fun estado(r: Map<String, String>, ahora: LocalDateTime): Estado {
        fun obj(k: String) = r[k]?.let { runCatching { aMapa(JSONObject(it)) }.getOrNull() }
        return Estado.de(
            lotes = mapas(aLista(JSONArray(r["lotes"] ?: "[]"))),
            resumen = obj("resumen"),
            lecturas = mapas(obj("lecturas")?.get("readings")),
            actuadores = mapas(aLista(JSONArray(r["actuadores"] ?: "[]"))),
            reporte = obj("reporte") ?: emptyMap(),
            control = obj("control"),
            prediccion = obj("prediccion"),
            calibracion = obj("calibracion"),
            ahora = ahora,
        )
    }
}

/** Último estado bueno guardado en el reloj (respuestas crudas + hora de consulta), para mostrarlo sin señal. */
object Guardado {
    private const val PREFS = "siscan_reloj"

    fun guardar(c: Context, r: Map<String, String>, ahora: LocalDateTime) {
        val o = JSONObject().put("consultado", ahora.toString())
        r.forEach { (k, v) -> o.put(k, v) }
        c.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString("respuestas", o.toString()).apply()
    }

    fun leer(c: Context): Estado? = runCatching {
        val o = JSONObject(c.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString("respuestas", null) ?: return null)
        val r = o.keys().asSequence().filter { it != "consultado" }.associateWith { o.getString(it) }
        Red.estado(r, LocalDateTime.parse(o.getString("consultado")))
    }.getOrNull()

    /** Alertas que la persona ya descartó en el reloj (no se vuelven a mostrar a pantalla completa). */
    fun descartada(c: Context, clave: String) = c.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getStringSet("descartadas", emptySet())!!.contains(clave)
    fun descartar(c: Context, clave: String) {
        val p = c.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        p.edit().putStringSet("descartadas", (p.getStringSet("descartadas", emptySet())!! + clave).toList().takeLast(50).toSet()).apply()
    }
}
