package co.gov.narino.cisna.siscan.reloj

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import kotlinx.coroutines.delay
import java.time.Duration
import java.time.LocalDateTime

/**
 * Momento del día: la misma regla que el teléfono (`siscan_app/lib/core/momento.dart`, 03-ilustración). Día 6–17,
 * atardecer 17–19, noche el resto, en hora de Colombia (`ahoraColombia()`): solo el reloj del dispositivo, sin ubicación.
 * Elige la variante de la escena de «El secador»; `claro` queda listo por si se aprueba un tema por hora en el reloj.
 */
enum class Momento(val variante: String) {
    DIA("day"), ATARDECER("dusk"), NOCHE("night");

    /** Claro de 6:00 a 19:00 (día y atardecer), oscuro de noche: la regla del tema «Según la hora» del teléfono. */
    val claro: Boolean get() = this != NOCHE

    companion object {
        val LIMITES = listOf(6, 17, 19)

        fun de(colombia: LocalDateTime): Momento = when (colombia.hour) {
            in 6 until 17 -> DIA
            in 17 until 19 -> ATARDECER
            else -> NOCHE
        }

        /** Siguiente cambio de momento, estrictamente después de `colombia` (hora de pared de Colombia). */
        fun proximoCambio(colombia: LocalDateTime): LocalDateTime {
            val hoy = colombia.toLocalDate()
            return (0L..1L).flatMap { d -> LIMITES.map { h -> hoy.plusDays(d).atTime(h, 0) } }.first { it.isAfter(colombia) }
        }
    }
}

/** Momento en vivo: se recompone al cruzar cada límite, sin reiniciar la app (un segundo de margen por si el temporizador se adelanta). */
@Composable
fun momentoEnVivo(ahora: () -> LocalDateTime = ::ahoraColombia): State<Momento> {
    val estado = remember { mutableStateOf(Momento.de(ahora())) }
    LaunchedEffect(Unit) {
        while (true) {
            val t = ahora()
            estado.value = Momento.de(t)
            delay(Duration.between(t, Momento.proximoCambio(t)).toMillis() + 1_000)
        }
    }
    return estado
}
