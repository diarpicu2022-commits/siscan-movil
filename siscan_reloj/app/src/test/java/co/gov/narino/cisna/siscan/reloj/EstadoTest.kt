package co.gov.narino.cisna.siscan.reloj

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDateTime

class EstadoTest {
    private val ahora = LocalDateTime.of(2026, 10, 8, 8, 0)
    private val lotes = listOf(
        mapOf("id" to 3, "name" to "Lote juco", "status" to "COMPLETED", "startedAt" to "2026-08-11 11:56:38"),
        mapOf("id" to 2, "name" to "LOTE EL MOTILON", "status" to "COMPLETED", "startedAt" to "2026-08-05 22:46:00"),
    )
    private val resumen = mapOf("batch" to mapOf("name" to "Lote juco", "lastMoisturePct" to 10.59, "gravimetInitialMoisturePct" to 57, "targetMoisturePct" to 11))
    private val lecturas = listOf(
        mapOf("sensorType" to "POWER_TOTAL_W", "value" to 0, "timestamp" to "2026-08-19 14:53:49"),
        mapOf("sensorType" to "TEMPERATURE_TOPE", "value" to 16.7, "timestamp" to "2026-08-19 14:50:00"),
    )
    private val equipo = listOf(mapOf("name" to "Ventiladores", "type" to "FAN", "status" to "OFF"), mapOf("name" to "Calefactor 1", "type" to "HEATER", "status" to "ON"))

    @Test fun `sin lote activo muestra el último con su humedad final y avance completo`() {
        val e = Estado.de(lotes, resumen, lecturas, equipo, mapOf("alertsDetail" to emptyList<Any>(), "alertsUnreadTotal" to 107), ahora)
        assertEquals("Lote juco", e.lote)
        assertFalse(e.enCurso)
        assertEquals(10.59, e.humedad!!, 0.001)
        assertTrue(e.enObjetivo)
        assertEquals(1f, e.avance!!, 0.001f)
        assertEquals(16.7, e.temperatura!!, 0.001)
        assertFalse(e.reportando(ahora)) // la última lectura es de agosto
        assertEquals(107, e.alertasSinRevisar)
        assertNull(e.alerta)
        assertTrue(e.equipo[1].resistencia && e.equipo[1].encendido)
    }

    @Test fun `con lote en curso lo prefiere y elige la alerta más grave`() {
        val conActivo = lotes + mapOf("id" to 4, "name" to "Lote B", "status" to "RUNNING", "startedAt" to "2026-10-07 06:00:00")
        val r = mapOf("batch" to mapOf("name" to "Lote B", "lastMoisturePct" to 30.0, "gravimetInitialMoisturePct" to 53, "targetMoisturePct" to 11))
        val reporte = mapOf("alertsDetail" to listOf(mapOf("level" to "WARNING", "title" to "Humedad alta"), mapOf("level" to "CRITICAL", "title" to "Temperatura alta")), "alertsUnreadTotal" to 2)
        val e = Estado.de(conActivo, r, listOf(mapOf("sensorType" to "TEMPERATURE_TOPE", "value" to 41, "timestamp" to "2026-10-08 07:55:00")), emptyList(), reporte, ahora)
        assertEquals("Lote B", e.lote)
        assertTrue(e.enCurso)
        assertEquals(23f / 42f, e.avance!!, 0.001f)
        assertTrue(e.reportando(ahora))
        assertEquals("Temperatura alta", e.alerta)
    }
}
