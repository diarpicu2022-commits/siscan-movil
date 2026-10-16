package co.gov.narino.cisna.siscan.reloj

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDateTime

/** Regla única del momento del día (anexo 2026-10-12-invernadero-y-tema-por-hora, paso 1): mismos casos que el teléfono. */
class MomentoTest {
    private fun col(h: Int, m: Int = 0, s: Int = 0, dia: Int = 12) = LocalDateTime.of(2026, 10, dia, h, m, s)

    @Test fun `limites del momento en hora de Colombia`() {
        assertEquals(Momento.NOCHE, Momento.de(col(5, 59, 59)))
        assertEquals(Momento.DIA, Momento.de(col(6)))
        assertEquals(Momento.DIA, Momento.de(col(16, 59, 59)))
        assertEquals(Momento.ATARDECER, Momento.de(col(17)))
        assertEquals(Momento.ATARDECER, Momento.de(col(18, 59, 59)))
        assertEquals(Momento.NOCHE, Momento.de(col(19)))
        assertEquals(Momento.NOCHE, Momento.de(col(0)))
    }

    @Test fun `claro solo de 6 a 19`() {
        assertFalse(Momento.de(col(5, 59)).claro)
        assertTrue(Momento.de(col(6)).claro)
        assertTrue(Momento.de(col(18, 59)).claro)
        assertFalse(Momento.de(col(19)).claro)
    }

    @Test fun `variantes de la escena`() {
        assertEquals("day", Momento.de(col(10)).variante)
        assertEquals("dusk", Momento.de(col(18)).variante)
        assertEquals("night", Momento.de(col(2)).variante)
    }

    @Test fun `proximo cambio`() {
        assertEquals(col(6), Momento.proximoCambio(col(5, 59)))
        assertEquals(col(17), Momento.proximoCambio(col(6))) // en el límite: el siguiente, no el mismo
        assertEquals(col(19), Momento.proximoCambio(col(18, 59)))
        assertEquals(col(6, dia = 13), Momento.proximoCambio(col(19)))
        assertEquals(LocalDateTime.of(2026, 11, 1, 6, 0), Momento.proximoCambio(LocalDateTime.of(2026, 10, 31, 20, 0)))
    }

    @Test fun `cruce de las 19 en vivo - la espera llega justo despues del limite`() {
        val t = col(18, 59, 30)
        val espera = java.time.Duration.between(t, Momento.proximoCambio(t)).toMillis() + 1_000
        assertEquals(31_000, espera)
        assertEquals(Momento.NOCHE, Momento.de(t.plusNanos(espera * 1_000_000)))
        assertEquals(Momento.ATARDECER, Momento.de(t.plusSeconds(29)))
    }
}
