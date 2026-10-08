package co.gov.narino.cisna.siscan.reloj

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.focusable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.pager.VerticalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.input.rotary.onRotaryScrollEvent
import androidx.compose.ui.platform.LocalContext
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.time.LocalDateTime
import java.time.ZoneId

/** SISCAN en el reloj: «¿cómo va el secado y tengo que hacer algo?» de un vistazo (dirección A · Medidor de lecho). */
class RelojActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { SiscanReloj() }
    }
}

/** Hora de Colombia: las lecturas del servidor vienen en esa hora. */
fun ahoraColombia(): LocalDateTime = LocalDateTime.now(ZoneId.of("America/Bogota"))

@Composable
fun SiscanReloj() {
    val contexto = LocalContext.current
    var tema by remember { mutableStateOf(Guardado.tema(contexto)) }
    val oscuro = when (tema) { "claro" -> false; "oscuro" -> true; else -> isSystemInDarkTheme() }
    var estado by remember { mutableStateOf(Guardado.leer(contexto)) }
    var error by remember { mutableStateOf<String?>(null) }
    var ahora by remember { mutableStateOf(ahoraColombia()) }

    // Consulta al abrir y luego cada minuto; si falla, queda lo guardado con su hora.
    LaunchedEffect(Unit) {
        while (true) {
            ahora = ahoraColombia()
            runCatching { Red.estado(ahora) }
                .onSuccess { estado = it; error = null; Guardado.guardar(contexto, it); Superficies.actualizar(contexto) }
                .onFailure { error = it.message }
            delay(60_000)
        }
    }

    CompositionLocalProvider(LocalPaleta provides if (oscuro) Oscuro else Claro) {
        val e = estado
        if (e == null) {
            if (error == null) PantallaCargando() else PantallaSinDatos(error)
            return@CompositionLocalProvider
        }
        val paginas: List<@Composable () -> Unit> = listOf(
            { PantallaHumedad(e, ahora) },
            { PantallaEquipo(e, ahora) },
            { PantallaAlerta(e) },
            { PantallaTema(tema) { t -> tema = t; Guardado.guardarTema(contexto, t); Superficies.actualizar(contexto) } },
        )
        val pager = rememberPagerState { paginas.size }
        val foco = remember { FocusRequester() }
        val alcance = rememberCoroutineScope()
        var giro by remember { mutableStateOf(0f) }
        VerticalPager(
            state = pager,
            modifier = Modifier
                .fillMaxSize()
                // Corona: un gesto = una página.
                .onRotaryScrollEvent { ev ->
                    giro += ev.verticalScrollPixels
                    if (kotlin.math.abs(giro) > 40f && !pager.isScrollInProgress) {
                        val destino = (pager.currentPage + if (giro > 0) 1 else -1).coerceIn(0, paginas.size - 1)
                        giro = 0f
                        alcance.launch { pager.animateScrollToPage(destino) }
                    }
                    true
                }
                .focusRequester(foco)
                .focusable(),
        ) { i -> paginas[i]() }
        LaunchedEffect(Unit) { foco.requestFocus() }
    }
}
