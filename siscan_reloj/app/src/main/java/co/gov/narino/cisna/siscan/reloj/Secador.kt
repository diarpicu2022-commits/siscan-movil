package co.gov.narino.cisna.siscan.reloj

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.unit.dp

/**
 * «El secador» (contrato C2 del anexo 2026-10-12, opción A del 2026-10-15): la escena del sistema recortada a la esfera,
 * con la luz de la hora (`Momento`), y la humedad del grano en una placa centrada sobre las montañas, dentro del 70 %
 * central (enmienda a C2 del 2026-10-15, aprobada por Diego: «abajo» tapaba el centro de la cúpula). La interfaz
 * sigue oscura sobre negro; en ambiente esta página no existe (la raíz dibuja `Ambiente()`), así que la escena nunca
 * queda encendida en siempre activo.
 */
object EscenaReloj {
    /** Encuadre del lienzo 1200 × 600 de `Landscape`: cuadrado de 560 centrado en la cúpula (x 600–1040), luna o sol
     *  arriba a la derecha. El dibujo termina en y = 600, así que el secador queda en el tercio inferior. */
    const val VIEWBOX = "540 40 560 560"

    /** Mapa de bits WebP de 454 px por momento (elegido por medición: ver el anexo, paso 4). */
    fun recurso(m: Momento): Int = when (m) {
        Momento.DIA -> R.drawable.escena_reloj_day
        Momento.ATARDECER -> R.drawable.escena_reloj_dusk
        Momento.NOCHE -> R.drawable.escena_reloj_night
    }

    /** Solo en la variante de depuración: fija el momento para las capturas (`adb shell am start … --es momento night`). */
    var momentoForzado: Momento? = null
}

@Composable
fun ElSecador(e: Estado) {
    val vivo by momentoEnVivo()
    val m = EscenaReloj.momentoForzado ?: vivo
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        // La escena es decorado: no entra al lector (contentDescription nulo); lo que se lee es la placa.
        Image(painterResource(EscenaReloj.recurso(m)), contentDescription = null, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize())
        // Placa centrada (40–60 % del alto), sobre las montañas: el secador, que el dibujo deja entre el 62 % y el 89 %, se
        // ve entero.
        Box(
            Modifier.align(Alignment.Center)
                .clearAndSetSemantics { contentDescription = "Humedad del grano ${Estado.cifra(e.humedad)} %" }
                .clip(RoundedCornerShape(999.dp)).background(Sc.bosque).padding(horizontal = 14.dp, vertical = 2.dp),
        ) {
            Fila(6.dp) {
                Icono("grano", 16.dp, Sc.datoGrano)
                Cifra(Estado.cifra(e.humedad), "%", chica = true)
            }
        }
    }
}
