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

/** Lecturas públicas del servidor de SISCAN (las mismas que usan el panel y la app). El reloj nunca manda órdenes. */
object Red {
    private const val API = "https://cisna.narino.gov.co/wp-json/secador/v1"
    private const val SECADOR = 1

    private fun texto(ruta: String): String {
        val c = URL(API + ruta).openConnection() as HttpURLConnection
        c.connectTimeout = 15_000
        c.readTimeout = 20_000
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

    suspend fun estado(ahora: LocalDateTime): Estado = withContext(Dispatchers.IO) {
        coroutineScope {
            val lotesTxt = async { texto("/drying-batches?secadorId=$SECADOR") }
            val lectTxt = async { texto("/readings?secadorId=$SECADOR&limit=400") }
            val actTxt = async { texto("/api/actuators?secadorId=$SECADOR") }
            val repTxt = async { texto("/secadores/$SECADOR/report") }
            val lotes = mapas(aLista(JSONArray(lotesTxt.await())))
            val elegido = lotes.firstOrNull { it["status"] == "RUNNING" } ?: lotes.maxByOrNull { Estado.hora(it["startedAt"] as? String) ?: LocalDateTime.MIN }
            val resumen = elegido?.get("id")?.let { id -> runCatching { aMapa(JSONObject(texto("/drying-batches/$id/summary"))) }.getOrNull() }
            Estado.de(
                lotes = lotes,
                resumen = resumen,
                lecturas = mapas(aMapa(JSONObject(lectTxt.await()))["readings"]),
                actuadores = mapas(aLista(JSONArray(actTxt.await()))),
                reporte = aMapa(JSONObject(repTxt.await())),
                ahora = ahora,
            )
        }
    }
}

/** Último estado bueno guardado en el reloj, para mostrarlo sin señal (con su hora). */
object Guardado {
    private const val PREFS = "siscan_reloj"

    fun guardar(c: Context, e: Estado) {
        val o = JSONObject()
            .put("lote", e.lote).put("enCurso", e.enCurso).put("humedad", e.humedad).put("inicial", e.inicial).put("objetivo", e.objetivo)
            .put("temperatura", e.temperatura).put("temperaturaEn", e.temperaturaEn?.toString()).put("ultimaLectura", e.ultimaLectura?.toString())
            .put("alerta", e.alerta).put("alertasSinRevisar", e.alertasSinRevisar).put("consultado", e.consultado.toString())
            .put("equipo", JSONArray(e.equipo.map { JSONObject().put("n", it.nombre).put("r", it.resistencia).put("on", it.encendido) }))
        c.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString("estado", o.toString()).apply()
    }

    fun leer(c: Context): Estado? = runCatching {
        val o = JSONObject(c.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString("estado", null) ?: return null)
        fun dbl(k: String) = if (o.isNull(k)) null else o.getDouble(k)
        fun fecha(k: String) = if (o.isNull(k)) null else LocalDateTime.parse(o.getString(k))
        val eq = o.getJSONArray("equipo")
        Estado(
            lote = if (o.isNull("lote")) null else o.getString("lote"), enCurso = o.getBoolean("enCurso"),
            humedad = dbl("humedad"), inicial = dbl("inicial"), objetivo = o.getDouble("objetivo"),
            temperatura = dbl("temperatura"), temperaturaEn = fecha("temperaturaEn"), ultimaLectura = fecha("ultimaLectura"),
            equipo = (0 until eq.length()).map { eq.getJSONObject(it).let { x -> Estado.Equipo(x.getString("n"), x.getBoolean("r"), x.getBoolean("on")) } },
            alerta = if (o.isNull("alerta")) null else o.getString("alerta"), alertasSinRevisar = o.getInt("alertasSinRevisar"),
            consultado = LocalDateTime.parse(o.getString("consultado")),
        )
    }.getOrNull()

    /** Tema elegido: «claro», «oscuro» o «sistema». */
    fun tema(c: Context): String = c.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString("tema", "sistema") ?: "sistema"
    fun guardarTema(c: Context, t: String) = c.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString("tema", t).apply()
}
