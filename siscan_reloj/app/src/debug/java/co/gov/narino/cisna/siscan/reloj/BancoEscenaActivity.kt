package co.gov.narino.cisna.siscan.reloj

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.withFrameNanos
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource

/**
 * Banco de la escena del reloj (solo depuración). Para cada opción (VectorDrawable o WebP) y cada momento, monta la
 * imagen a pantalla completa 8 veces (con `key` nuevo, así no se reutiliza el pintor) y mide en nanosegundos:
 *  · carga: `painterResource` en la composición (para el vector, leer el XML y armar el ImageVector; para el WebP, decodificar);
 *  · dibujo: el primer `drawContent` (para el vector, rasterizar en su caché; para el WebP, registrar la imagen).
 * Escribe cada medida en Logcat (etiqueta SISCAN-BANCO) y una línea «FIN» al terminar.
 *   adb shell am start -n co.gov.narino.cisna.siscan/co.gov.narino.cisna.siscan.reloj.BancoEscenaActivity
 */
class BancoEscenaActivity : ComponentActivity() {
    private val casos = listOf(
        "vector" to listOf(R.drawable.escena_reloj_vec_day, R.drawable.escena_reloj_vec_dusk, R.drawable.escena_reloj_vec_night),
        "webp" to listOf(R.drawable.escena_reloj_day, R.drawable.escena_reloj_dusk, R.drawable.escena_reloj_night),
    ).flatMap { (op, ids) -> ids.mapIndexed { i, id -> Triple(op, listOf("day", "dusk", "night")[i], id) } }
        .flatMap { c -> (0 until 8).map { r -> c to r } }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { Banco() }
    }

    @Composable
    private fun Banco() {
        var i by remember { mutableIntStateOf(0) }
        if (i >= casos.size) { LaunchedEffect(Unit) { Log.i("SISCAN-BANCO", "FIN") }; return }
        val (caso, rep) = casos[i]
        val (op, v, id) = caso
        key(i) {
            val t0 = System.nanoTime()
            val pintor = painterResource(id)
            val carga = System.nanoTime() - t0
            var medido = false
            Image(pintor, null, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize().drawWithContent {
                val t1 = System.nanoTime()
                drawContent()
                val dibujo = System.nanoTime() - t1
                if (!medido) { medido = true; Log.i("SISCAN-BANCO", "$op\t$v\t$rep\t$carga\t$dibujo\t${size.width.toInt()}") }
            })
        }
        LaunchedEffect(i) { withFrameNanos { }; withFrameNanos { }; i++ }
    }
}
