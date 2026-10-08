package co.gov.narino.cisna.siscan.reloj

import java.time.Duration
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

/** Lo que el reloj muestra del secador (dirección A «Medidor de lecho»). Todo sale de las lecturas públicas del servidor. */
data class Estado(
    val lote: String?,
    /** El lote está secando ahora (si no, es el último lote terminado). */
    val enCurso: Boolean,
    val humedad: Double?,
    val inicial: Double?,
    val objetivo: Double,
    /** Temperatura interior y cuándo se midió. */
    val temperatura: Double?,
    val temperaturaEn: LocalDateTime?,
    /** Última lectura de cualquier sensor: dice si el secador está reportando. */
    val ultimaLectura: LocalDateTime?,
    val equipo: List<Equipo>,
    val alerta: String?,
    val alertasSinRevisar: Int,
    val consultado: LocalDateTime,
) {
    data class Equipo(val nombre: String, val resistencia: Boolean, val encendido: Boolean)

    /** Fracción del agua por retirar que ya se retiró (0–1), como el lecho del MoistureMeter. */
    val avance: Float?
        get() {
            val h = humedad ?: return null
            val i = inicial ?: return null
            if (i <= objetivo) return null
            return ((i - h) / (i - objetivo)).toFloat().coerceIn(0f, 1f)
        }

    val enObjetivo: Boolean get() = humedad != null && humedad <= objetivo

    /** «Medido» solo si la lectura tiene menos de 15 min (regla del sistema SISCAN). */
    fun reportando(ahora: LocalDateTime): Boolean = ultimaLectura != null && Duration.between(ultimaLectura, ahora).toMinutes() <= 15

    companion object {
        private val SERVIDOR: DateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")

        /** Las horas del servidor vienen en hora de Colombia sin zona («2026-08-19 14:53:49»). */
        fun hora(s: String?): LocalDateTime? = s?.takeIf { it.length >= 19 }?.let { runCatching { LocalDateTime.parse(it.substring(0, 19), SERVIDOR) }.getOrNull() }

        /** De la respuesta de cada ruta al estado. Puro: se prueba sin red. */
        fun de(
            lotes: List<Map<String, Any?>>,
            resumen: Map<String, Any?>?,
            lecturas: List<Map<String, Any?>>,
            actuadores: List<Map<String, Any?>>,
            reporte: Map<String, Any?>,
            ahora: LocalDateTime,
        ): Estado {
            val activo = lotes.firstOrNull { it["status"] == "RUNNING" }
            val lote = activo ?: lotes.maxByOrNull { hora(it["startedAt"] as? String) ?: LocalDateTime.MIN }
            @Suppress("UNCHECKED_CAST")
            val b = (resumen?.get("batch") as? Map<String, Any?>) ?: lote
            fun d(k: String) = (b?.get(k) as? Number)?.toDouble()
            val porTipo = lecturas.groupBy { it["sensorType"] as? String }
            val temp = (porTipo["TEMPERATURE_TOPE"] ?: porTipo["TEMPERATURE_INTERIOR"])
                ?.maxByOrNull { hora(it["timestamp"] as? String) ?: LocalDateTime.MIN }
            val ultima = lecturas.mapNotNull { hora(it["timestamp"] as? String) }.maxOrNull()
            @Suppress("UNCHECKED_CAST")
            val detalle = (reporte["alertsDetail"] as? List<Map<String, Any?>>).orEmpty()
            val grave = detalle.sortedBy { when (it["level"]) { "CRITICAL" -> 0; "WARNING" -> 1; else -> 2 } }.firstOrNull()
            return Estado(
                lote = b?.get("name") as? String,
                enCurso = activo != null,
                humedad = d("lastMoisturePct"),
                inicial = d("gravimetInitialMoisturePct") ?: d("firstMoisturePct"),
                objetivo = d("targetMoisturePct") ?: 11.0,
                temperatura = (temp?.get("value") as? Number)?.toDouble(),
                temperaturaEn = hora(temp?.get("timestamp") as? String),
                ultimaLectura = ultima,
                equipo = actuadores.map {
                    Equipo(it["name"] as? String ?: "Equipo", it["type"] == "HEATER", it["status"] == "ON")
                },
                alerta = (grave?.get("title") ?: grave?.get("message")) as? String,
                alertasSinRevisar = (reporte["alertsUnreadTotal"] as? Number)?.toInt() ?: 0,
                consultado = ahora,
            )
        }
    }
}
