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
        mapOf("id" to 3, "name" to "Lote juco", "status" to "COMPLETED", "startedAt" to "2026-08-11 11:56:38", "dryingSite" to "OPEN_AIR", "lastMoisturePct" to 10.59),
        mapOf("id" to 2, "name" to "LOTE EL MOTILON", "status" to "COMPLETED", "startedAt" to "2026-08-05 22:46:00", "dryingSite" to "DRYER", "lastMoisturePct" to 3.9),
    )
    private val resumen = mapOf("batch" to mapOf("id" to 3, "name" to "Lote juco", "lastMoisturePct" to 10.59, "gravimetInitialMoisturePct" to 57, "targetMoisturePct" to 11,
        "gravimetInitialWeightGrams" to 595, "lastSampleWeightGrams" to 285.6))
    private val lecturas = listOf(
        mapOf("sensorType" to "POWER_TOTAL_W", "value" to 0, "timestamp" to "2026-08-19 14:53:49"),
        mapOf("sensorType" to "TEMPERATURE_TOPE", "value" to 16.7, "timestamp" to "2026-08-19 14:50:00"),
        mapOf("sensorType" to "TEMPERATURE_TOPE", "value" to 15.9, "timestamp" to "2026-08-19 13:50:00"),
        mapOf("sensorType" to "HUMIDITY_TOPE", "value" to 59.3, "timestamp" to "2026-08-19 14:50:00"),
    )
    private val equipo = listOf(
        mapOf("id" to "1", "name" to "Ventiladores", "type" to "FAN", "status" to "OFF", "powerW" to "210"),
        mapOf("id" to 2, "name" to "Calefactor 1", "type" to "HEATER", "status" to "ON", "powerW" to 1500.0),
    )
    private fun de(lotes: List<Map<String, Any?>> = this.lotes, resumen: Map<String, Any?>? = this.resumen, lecturas: List<Map<String, Any?>> = this.lecturas,
                   reporte: Map<String, Any?> = mapOf("alertsDetail" to emptyList<Any>(), "alertsUnreadTotal" to 107),
                   control: Map<String, Any?>? = null, prediccion: Map<String, Any?>? = null, calibracion: Map<String, Any?>? = null) =
        Estado.de(lotes, resumen, lecturas, equipo, reporte, control, prediccion, calibracion, ahora)

    @Test fun `sin lote activo muestra el último con su humedad final y el avance completo`() {
        val e = de()
        assertEquals("Lote juco", e.lote)
        assertEquals(3, e.loteId)
        assertFalse(e.enCurso)
        assertEquals(10.59, e.humedad!!, 0.001)
        assertEquals(100f, e.avance!!, 0.001f)
        assertEquals(16.7, e.lectura("TEMPERATURE_TOPE")!!.valor, 0.001) // la más reciente, no la primera
        assertFalse(e.reportando(ahora)) // la última lectura es de agosto
        assertEquals(107, e.alertasSinRevisar)
        assertNull(e.alerta)
        assertEquals(0, e.alertasActivas)
        assertTrue(e.equipo[1].resistencia && e.equipo[1].encendido)
        assertEquals(1, e.equipo[0].id) // el servidor a veces manda el id como texto
        assertEquals(210.0, e.equipo[0].vatios, 0.001)
        assertNull(e.modo) // sin la ruta del plugin 3.5.0: «—» en la pantalla
        assertEquals(595 * (1 - .57), e.materiaSeca!!, 0.001) // sin calibración: por la humedad inicial
    }

    @Test fun `con lote en curso lo prefiere, cuenta las alertas activas y elige la más grave`() {
        val conActivo = lotes + mapOf("id" to 4, "name" to "Lote B", "status" to "RUNNING", "startedAt" to "2026-10-07 06:00:00")
        val r = mapOf("batch" to mapOf("id" to 4, "name" to "Lote B", "lastMoisturePct" to 30.0, "gravimetInitialMoisturePct" to 53, "targetMoisturePct" to 11))
        val reporte = mapOf("alertsDetail" to listOf(
            mapOf("level" to "WARNING", "title" to "Humedad relativa alta"), mapOf("level" to "CRITICAL", "title" to "Temperatura alta", "at" to "2026-10-08 07:50:00"),
            mapOf("level" to "INFO", "title" to "Lote finalizado")), "alertsUnreadTotal" to 2)
        val e = de(conActivo, r, listOf(mapOf("sensorType" to "TEMPERATURE_TOPE", "value" to 41, "timestamp" to "2026-10-08 07:55:00")), reporte,
            control = mapOf("pedido" to "AUTO"), calibracion = mapOf("dryMatterGrams" to 94.0))
        assertEquals("Lote B", e.lote)
        assertTrue(e.enCurso)
        assertEquals(23f / 42f * 100, e.avance!!, 0.01f)
        assertTrue(e.reportando(ahora))
        assertEquals("Temperatura alta", e.alerta!!.titulo)
        assertTrue(e.alerta!!.critica)
        assertEquals("termometro", e.alerta!!.icono)
        assertEquals(2, e.alertasActivas)
        assertEquals("AUTO", e.modo)
        assertEquals(94.0, e.materiaSeca!!, 0.001) // la calibración manda sobre la humedad inicial
    }

    @Test fun `predicción de la tesis y lotes para las pantallas`() {
        val e = de(prediccion = mapOf("estado" to "EN_CURSO", "horasRestantes" to 5.67, "horasMin" to 4.83, "horasMax" to 6.5, "confianza" to 82))
        assertEquals("EN_CURSO", e.prediccion!!.estado)
        assertEquals(82, e.prediccion!!.confianza)
        assertEquals("5 h 40", Estado.duracion(e.prediccion!!.horas))
        assertEquals(listOf("Aire libre", "Secador"), e.lotes.map { it.sitio })
    }

    @Test fun `formato del sistema con coma decimal, punto de miles y duraciones`() {
        assertEquals("12,4", Estado.cifra(12.36))
        assertEquals("1.500", Estado.cifra(1500.0, 0))
        assertEquals("—", Estado.cifra(null))
        assertEquals("35 min", Estado.duracion(35 / 60.0))
        assertEquals("6 h", Estado.duracion(6.0))
        assertEquals("2 d 3 h", Estado.duracion(51.0))
        assertEquals("19 ago", Estado.dia(Estado.hora("2026-08-19 14:53:49")))
        assertEquals("14:53", Estado.hm(Estado.hora("2026-08-19T14:53:49")))
    }
}
