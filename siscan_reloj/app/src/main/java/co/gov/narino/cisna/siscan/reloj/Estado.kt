package co.gov.narino.cisna.siscan.reloj

import java.time.Duration
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale

/** Lo que el reloj muestra del secador (07-smartwatch.md): una idea por pantalla. Todo sale del servidor de SISCAN. */
data class Estado(
    val loteId: Int?,
    val lote: String?,
    /** El lote está secando ahora (si no, es el último lote terminado). */
    val enCurso: Boolean,
    val humedad: Double?,
    val inicial: Double?,
    val objetivo: Double,
    val lecturas: List<Lectura>,
    /** Última lectura de cualquier sensor: dice si el secador está reportando. */
    val ultimaLectura: LocalDateTime?,
    val equipo: List<Equipo>,
    /** Modo pedido: AUTO o MANUAL (null si el servidor aún no tiene la ruta del plugin 3.5.0). */
    val modo: String?,
    val alerta: Alerta?,
    /** Alertas activas (críticas y advertencias), para la complicación de la esfera. */
    val alertasActivas: Int,
    val alertasSinRevisar: Int,
    val prediccion: Prediccion?,
    val lotes: List<Lote>,
    /** Materia seca de la muestra (g) y último peso: para registrar el pesaje con su humedad resultante. */
    val materiaSeca: Double?,
    val ultimoPeso: Double?,
    val consultado: LocalDateTime,
) {
    data class Lectura(val tipo: String, val valor: Double, val en: LocalDateTime?)
    data class Equipo(val id: Int, val nombre: String, val resistencia: Boolean, val encendido: Boolean, val vatios: Double)
    data class Alerta(val clave: String, val critica: Boolean, val titulo: String, val texto: String, val icono: String)
    data class Prediccion(val estado: String, val horas: Double?, val min: Double?, val max: Double?, val confianza: Int?)
    data class Lote(val id: Int, val nombre: String, val enCurso: Boolean, val sitio: String, val humedad: Double?)

    /** Avance del secado (0–100), como el arco de la pantalla de monitoreo. */
    val avance: Float?
        get() {
            val h = humedad ?: return null
            val i = inicial ?: return null
            if (i <= objetivo) return null
            return ((i - h) / (i - objetivo) * 100).toFloat().coerceIn(0f, 100f)
        }

    fun lectura(tipo: String): Lectura? = lecturas.firstOrNull { it.tipo == tipo }

    /** Reglas del sistema (01-secado): sin dato 10 min = sin conexión. */
    fun reportando(ahora: LocalDateTime): Boolean = ultimaLectura != null && Duration.between(ultimaLectura, ahora).toMinutes() <= 10

    companion object {
        private val SERVIDOR: DateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
        private val es = Locale.forLanguageTag("es-CO")
        private val MESES = listOf("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")

        /** Las horas del servidor vienen en hora de Colombia sin zona («2026-08-19 14:53:49»). */
        fun hora(s: String?): LocalDateTime? = s?.takeIf { it.length >= 19 }?.let { runCatching { LocalDateTime.parse(it.substring(0, 19).replace('T', ' '), SERVIDOR) }.getOrNull() }

        /** Cifra con coma decimal y punto de miles, como todo el sistema. */
        fun cifra(v: Double?, d: Int = 1): String {
            if (v == null) return "—"
            val s = String.format(Locale.US, "%,.${d}f", v)
            return s.replace(',', '\u0000').replace('.', ',').replace('\u0000', '.')
        }

        /** «5 h 40», «2 d 3 h», «35 min». */
        fun duracion(horas: Double?): String {
            if (horas == null) return "—"
            val m = (horas * 60).toLong()
            return when {
                m < 60 -> "$m min"
                m < 48 * 60 -> if (m % 60 == 0L) "${m / 60} h" else "${m / 60} h ${m % 60}"
                else -> "${m / 1440} d ${(m % 1440) / 60} h"
            }
        }

        fun dia(d: LocalDateTime?): String = d?.let { "${it.dayOfMonth} ${MESES[it.monthValue - 1]}" } ?: "—"
        fun hm(d: LocalDateTime?): String = d?.let { String.format(Locale.US, "%02d:%02d", it.hour, it.minute) } ?: "—"

        private fun icono(a: Map<String, Any?>): String {
            val t = "${a["title"] ?: ""} ${a["message"] ?: ""} ${a["type"] ?: ""}".lowercase(es)
            return when {
                "humedad" in t || "humidity" in t -> "gotas"
                "temperatura" in t || "temperature" in t -> "termometro"
                "tormenta" in t || "lluvia" in t || "clima" in t -> "nube"
                "conexi" in t || "reporta" in t || "offline" in t -> "wifi_no"
                "ventilador" in t || "resistencia" in t || "actuador" in t -> "ventilador"
                else -> "aviso"
            }
        }

        @Suppress("UNCHECKED_CAST")
        private fun mapa(v: Any?) = v as? Map<String, Any?>

        /** De la respuesta de cada ruta al estado. Puro: se prueba sin red. */
        fun de(
            lotes: List<Map<String, Any?>>,
            resumen: Map<String, Any?>?,
            lecturas: List<Map<String, Any?>>,
            actuadores: List<Map<String, Any?>>,
            reporte: Map<String, Any?>,
            control: Map<String, Any?>?,
            prediccion: Map<String, Any?>?,
            calibracion: Map<String, Any?>?,
            ahora: LocalDateTime,
        ): Estado {
            val activo = lotes.firstOrNull { it["status"] == "RUNNING" }
            val lote = activo ?: lotes.maxByOrNull { hora(it["startedAt"] as? String) ?: LocalDateTime.MIN }
            val b = mapa(resumen?.get("batch")) ?: lote
            fun d(k: String) = (b?.get(k) as? Number)?.toDouble()
            val ultimas = lecturas.groupBy { it["sensorType"] as? String }.mapNotNull { (tipo, xs) ->
                val x = xs.maxByOrNull { hora(it["timestamp"] as? String) ?: LocalDateTime.MIN } ?: return@mapNotNull null
                val v = (x["value"] as? Number)?.toDouble() ?: return@mapNotNull null
                Lectura(tipo ?: return@mapNotNull null, v, hora(x["timestamp"] as? String))
            }
            @Suppress("UNCHECKED_CAST")
            val detalle = (reporte["alertsDetail"] as? List<Map<String, Any?>>).orEmpty()
            val activas = detalle.filter { it["level"] == "CRITICAL" || it["level"] == "WARNING" }
            val grave = activas
                .sortedBy { if (it["level"] == "CRITICAL") 0 else 1 }.firstOrNull()
            val pred = prediccion?.let { p ->
                fun n(k: String) = (p[k] as? Number)?.toDouble()
                Prediccion(p["estado"] as? String ?: "", n("horasRestantes"), n("horasMin"), n("horasMax"), n("confianza")?.toInt())
            }
            return Estado(
                loteId = (b?.get("id") as? Number)?.toInt(),
                lote = b?.get("name") as? String,
                enCurso = activo != null,
                humedad = d("lastMoisturePct"),
                inicial = d("gravimetInitialMoisturePct") ?: d("firstMoisturePct"),
                objetivo = d("targetMoisturePct") ?: 11.0,
                lecturas = ultimas,
                ultimaLectura = ultimas.mapNotNull { it.en }.maxOrNull(),
                equipo = actuadores.mapNotNull {
                    val id = (it["id"] as? Number)?.toInt() ?: (it["id"] as? String)?.toIntOrNull() ?: return@mapNotNull null
                    Equipo(id, it["name"] as? String ?: "Equipo", it["type"] == "HEATER", it["status"] == "ON",
                        (it["powerW"] as? Number)?.toDouble() ?: (it["powerW"] as? String)?.toDoubleOrNull() ?: 0.0)
                },
                modo = control?.get("pedido") as? String,
                alerta = grave?.let {
                    val titulo = (it["title"] ?: it["message"]) as? String ?: "Alerta"
                    Alerta(it["id"]?.toString() ?: "$titulo:${it["at"] ?: it["timestamp"] ?: ""}", it["level"] == "CRITICAL", titulo,
                        (it["description"] as? String) ?: listOfNotNull(b?.get("name") as? String, "Secador 01").joinToString(" · "), icono(it))
                },
                alertasActivas = activas.size,
                alertasSinRevisar = (reporte["alertsUnreadTotal"] as? Number)?.toInt() ?: 0,
                prediccion = pred,
                lotes = lotes.take(6).mapNotNull {
                    val id = (it["id"] as? Number)?.toInt() ?: return@mapNotNull null
                    Lote(id, it["name"] as? String ?: "Lote", it["status"] == "RUNNING",
                        if (it["dryingSite"] == "OPEN_AIR") "Aire libre" else "Secador", (it["lastMoisturePct"] as? Number)?.toDouble())
                },
                materiaSeca = (calibracion?.get("dryMatterGrams") as? Number)?.toDouble()
                    ?: d("gravimetInitialWeightGrams")?.let { w -> w * (1 - (d("gravimetInitialMoisturePct") ?: 53.0) / 100) },
                ultimoPeso = d("lastSampleWeightGrams"),
                consultado = ahora,
            )
        }
    }
}
