package co.gov.narino.cisna.siscan.reloj

import org.junit.Assert.assertEquals
import org.junit.Test

/** «El secador» (C2): cada momento del día tiene su propia escena y el encuadre es cuadrado. */
class SecadorTest {
    @Test fun cadaMomentoTieneSuEscena() {
        val ids = Momento.entries.map { EscenaReloj.recurso(it) }
        assertEquals(3, ids.toSet().size)
        assertEquals(R.drawable.escena_reloj_night, EscenaReloj.recurso(Momento.NOCHE))
    }

    @Test fun elEncuadreEsCuadrado() {
        val (_, _, ancho, alto) = EscenaReloj.VIEWBOX.split(" ").map { it.toFloat() }
        assertEquals(ancho, alto, 0f)
    }
}
