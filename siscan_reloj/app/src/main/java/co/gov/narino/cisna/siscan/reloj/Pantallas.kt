package co.gov.narino.cisna.siscan.reloj

import androidx.compose.foundation.background
import androidx.compose.foundation.focusable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.rotary.onRotaryScrollEvent
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.foundation.rotary.RotaryScrollableDefaults
import androidx.wear.compose.foundation.rotary.rotaryScrollable
import androidx.wear.compose.material3.Text
import java.time.LocalDateTime
import kotlin.math.abs
import kotlin.math.roundToInt

private fun Estado.Prediccion?.listoEn() = this?.takeIf { it.estado == "EN_CURSO" }?.horas

/** Lista que se desplaza con la corona cuando no cabe en la esfera (Equipo con cuatro actuadores, por ejemplo). */
@Composable
private fun Desplazable(activa: Boolean, contenido: @Composable () -> Unit) {
    val s = rememberScrollState()
    val foco = remember { FocusRequester() }
    Column(
        Modifier.fillMaxSize().verticalScroll(s).rotaryScrollable(RotaryScrollableDefaults.behavior(s), foco).padding(bottom = 36.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) { contenido() }
    LaunchedEffect(activa) { if (activa) runCatching { foco.requestFocus() } }
}

/** Estado del lote para el chip: «Lote juco · Secando», o «Sin conexión · 19 ago» si el secador no reporta. */
private fun chipLote(e: Estado, ahora: LocalDateTime): Pair<String, Boolean> = when {
    e.lote == null -> "Sin lotes" to false
    !e.reportando(ahora) -> "Sin conexión · ${Estado.dia(e.ultimaLectura)}" to false
    e.enCurso -> "${e.lote} · Secando" to true
    else -> "${e.lote} · Terminado" to false
}

/** WatchMonitor: arco de avance, humedad del grano, objetivo y estado del lote. */
@Composable
fun Monitoreo(e: Estado, ahora: LocalDateTime) = Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
    ArcoReloj(e.avance ?: 0f)
    Pila(Modifier.semantics(mergeDescendants = true) {}) {
        Rotulo("grano", "Humedad del grano")
        Cifra(Estado.cifra(e.humedad), "%")
        Sub("Objetivo ${Estado.cifra(e.objetivo - 1, 0)} – ${Estado.cifra(e.objetivo + 1, 0)} %")
        val (t, vivo) = chipLote(e, ahora)
        Chip(t, vivo = vivo)
    }
}

/** WatchReadings: interior, humedad relativa y exterior, cada una con el color de su magnitud. */
@Composable
fun Lecturas(e: Estado, activa: Boolean) = Desplazable(activa) {
    Lista("Lecturas") {
        val filas = listOf(
            Triple("TEMPERATURE_TOPE", "Interior", "temperatura") to "termometro",
            Triple("HUMIDITY_TOPE", "HR interior", "humedad") to "gotas",
            Triple("TEMPERATURE_EXTERIOR", "Exterior", "exterior") to "nubeSol",
            Triple("HUMIDITY_EXTERIOR", "HR exterior", "exterior") to "nube",
        )
        var alguna = false
        for ((f, ic) in filas) {
            val l = e.lectura(f.first) ?: continue
            alguna = true
            val v = if (f.first.startsWith("TEMP")) "${Estado.cifra(l.valor)}°" else "${Estado.cifra(l.valor, 0)} %"
            FilaLectura(ic, tono(f.third), f.second, v)
        }
        if (!alguna) Sub("El secador todavía no envía lecturas.")
        else Sub("Último dato ${Estado.dia(e.ultimaLectura)} · ${Estado.hm(e.ultimaLectura)}")
    }
}

/** WatchActuators: chips que encienden y apagan por el teléfono. Encender una resistencia exige mantener presionado. */
@Composable
fun Equipo(e: Estado, activa: Boolean, pendiente: Int?, onOrden: (Estado.Equipo, Boolean) -> Unit, aviso: (String) -> Unit) = Desplazable(activa) {
    val auto = e.modo == "AUTO"
    Lista("Equipo · ", when (e.modo) { "AUTO" -> "Automático"; "MANUAL" -> "Manual"; else -> "—" }) {
        if (e.equipo.isEmpty()) Sub("No hay actuadores registrados.")
        for (a in e.equipo) {
            val estado = when {
                pendiente == a.id -> if (a.encendido) "Apagando…" else "Encendiendo…"
                auto -> if (a.encendido) "Encendido · protocolo" else "Apagado · protocolo"
                else -> if (a.encendido) "Encendido" else "Apagado"
            }
            ChipActuador(
                a.nombre, a.resistencia, a.encendido, estado, habilitado = !auto && pendiente == null,
                onClick = { if (a.resistencia && !a.encendido) aviso("Mantén presionado para encender") else onOrden(a, !a.encendido) },
                onLong = if (a.resistencia && !a.encendido) ({ onOrden(a, true) }) else null,
            )
        }
        Sub(if (auto) "El protocolo decide. Cambia a Manual en el teléfono." else "Para encender una resistencia, mantén presionado su chip. Las órdenes van por el teléfono.")
    }
}

/** WatchPrediction: «Listo en», rango y confianza en el color de la predicción (modelo de la tesis). */
@Composable
fun Prediccion(e: Estado) = Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
    val p = e.prediccion
    ArcoReloj((p?.confianza ?: 0).toFloat(), Sc.prediccion)
    Pila(Modifier.semantics(mergeDescendants = true) {}) {
        when (p?.estado) {
            "EN_CURSO" -> {
                Rotulo("ia", "Listo en", Sc.prediccion)
                Cifra(Estado.duracion(p.horas), chica = true)
                Sub("entre ${Estado.duracion(p.min)} y ${Estado.duracion(p.max)}")
                Chip("Confianza ${p.confianza ?: "—"} %", pred = true)
            }
            "OBJETIVO_ALCANZADO" -> {
                Rotulo("ia", if (e.enCurso) "Ya está" else "Terminó", Sc.prediccion)
                Cifra("Listo", chica = true)
                Sub("${Estado.cifra(e.humedad)} %: ${if (e.enCurso) "retíralo" else "en el objetivo"}")
                Chip("Modelo de la tesis", pred = true)
            }
            "SOBRESECADO" -> { Rotulo("ia", "Predicción", Sc.prediccion); Cifra("Pasado", chica = true); Sub("Bajó del 10 %: sobre-secado") }
            "NO_ALCANZABLE" -> { Rotulo("ia", "Predicción", Sc.prediccion); Cifra("No llega", chica = true); Sub("Con este aire no alcanza el objetivo") }
            null -> { Rotulo("ia", "Predicción", Sc.prediccion); Cifra("—", chica = true); Sub("No disponible por ahora") }
            else -> { Rotulo("ia", "Predicción", Sc.prediccion); Cifra("—", chica = true); Sub("Pocos pesajes para predecir") }
        }
    }
}

/** WatchBatches: lotes con su humedad; el activo resaltado. */
@Composable
fun Lotes(e: Estado, activa: Boolean) = Desplazable(activa) {
    Lista("Lotes") {
        if (e.lotes.isEmpty()) Sub("No hay lotes registrados.")
        for (l in e.lotes) FilaLote(l.nombre, if (l.enCurso) "Secando" else l.sitio, l.humedad?.let { "${Estado.cifra(it)} %" } ?: "—", l.enCurso)
    }
}

/** WatchWeigh: − y + de 0,1 g (o la corona), humedad resultante y rango de retiro; «Guardar» va por el teléfono. */
@Composable
fun Pesaje(e: Estado, activa: Boolean, enviando: Boolean, onGuardar: (Double) -> Unit) {
    val seca = e.materiaSeca
    if (!e.enCurso || e.loteId == null || seca == null) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Pila { Rotulo("balanza", "Pesaje"); Titulo2("Sin lote activo"); Sub("Inicia un lote en el teléfono para pesar la muestra.") }
        }
        return
    }
    var g by remember(e.loteId) { mutableFloatStateOf(((e.ultimoPeso ?: (seca / .88)) * 10).roundToInt() / 10f) }
    var giro by remember { mutableFloatStateOf(0f) }
    val foco = remember { FocusRequester() }
    fun paso(d: Float) { g = ((g + d) * 10).roundToInt() / 10f }
    Box(
        Modifier.fillMaxSize()
            .onRotaryScrollEvent { ev -> giro += ev.verticalScrollPixels; while (abs(giro) >= 24f) { paso(if (giro > 0) .1f else -.1f); giro -= if (giro > 0) 24f else -24f }; true }
            .focusRequester(foco).focusable(),
        contentAlignment = Alignment.Center,
    ) {
        val hum = (1 - seca / g) * 100
        // .sc-wweigh: la fila − cifra + necesita más que los 168 de la pila (botones con 48 de toque): se le da su ancho.
        Column(Modifier.padding(top = 16.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = androidx.compose.foundation.layout.Arrangement.spacedBy(3.dp)) {
            Rotulo("balanza", "Peso de la muestra")
            Fila(0.dp) {
                BotonRedondo("menos", "Restar 0,1 gramos") { paso(-.1f) }
                Box(Modifier.semantics(mergeDescendants = true) { contentDescription = "${Estado.cifra(g.toDouble())} gramos"; liveRegion = LiveRegionMode.Polite }) {
                    Cifra(Estado.cifra(g.toDouble()), "g", chica = true)
                }
                BotonRedondo("mas", "Sumar 0,1 gramos") { paso(.1f) }
            }
            Box(Modifier.widthIn(max = 180.dp)) { Sub("= ${Estado.cifra(hum)} % · retira ${Estado.cifra(seca / .90)} – ${Estado.cifra(seca / .88)} g") }
            BotonAccion(if (enviando) "Enviando…" else "Guardar", habilitado = !enviando) { onGuardar(g.toDouble()) }
        }
    }
    LaunchedEffect(activa) { if (activa) runCatching { foco.requestFocus() } }
}

/** WatchAlert: pantalla completa tintada, icono, dato y dos botones (descartar, ver). */
@Composable
fun Alerta(a: Estado.Alerta, onDescartar: () -> Unit, onVer: () -> Unit) = Esfera(if (a.critica) Tinte.Alerta else Tinte.Advertencia) {
    Pila(Modifier.semantics { liveRegion = LiveRegionMode.Assertive }) {
        Box(
            Modifier.padding(bottom = 4.dp).size(46.dp).clip(CircleShape).background(if (a.critica) Sc.alerta else Sc.pausa),
            contentAlignment = Alignment.Center,
        ) { Icono(a.icono, 24.dp, if (a.critica) Color.White else Color(0xFF1A1205)) }
        Titulo2(a.titulo)
        Sub(a.texto)
        Fila(14.dp) {
            BotonCirculo("x", "Descartar", fantasma = true, onClick = onDescartar)
            BotonCirculo("check", "Ver detalle", onClick = onVer)
        }
    }
}

/** WatchConfirm: el círculo y el check se dibujan; se cierra sola a los 2 s. */
@Composable
fun Confirmacion(titulo: String, texto: String, error: Boolean, onFin: () -> Unit) = Esfera(if (error) Tinte.Advertencia else Tinte.Normal) {
    Pila(Modifier.semantics { liveRegion = LiveRegionMode.Assertive }) {
        if (error) Box(Modifier.padding(bottom = 4.dp).size(46.dp).clip(CircleShape).background(Sc.pausa), contentAlignment = Alignment.Center) { Icono("aviso", 24.dp, Color(0xFF1A1205)) }
        else CheckDibujado()
        Titulo2(titulo)
        Sub(texto)
    }
    LaunchedEffect(Unit) { kotlinx.coroutines.delay(if (error) 3500 else 2000); onFin() }
}

/** WatchAmbient: solo contornos, sin color de estado ni animación. */
@Composable
fun Ambiente(e: Estado?, @Suppress("UNUSED_PARAMETER") ahoraColombia: LocalDateTime) = Esfera(Tinte.Ambiente) {
    // La hora es la del reloj (su zona); solo los datos del secador van en hora de Colombia.
    val ahora = LocalDateTime.now()
    Pila {
        Text(
            // Formato de hora del reloj (12 o 24 h), como la esfera.
            if (android.text.format.DateFormat.is24HourFormat(androidx.compose.ui.platform.LocalContext.current)) Estado.hm(ahora)
            else String.format(java.util.Locale.US, "%d:%02d", (ahora.hour + 11) % 12 + 1, ahora.minute),
            style = TextStyle(fontFamily = Outfit, fontSize = 58.sp, lineHeight = 60.sp, fontWeight = FontWeight(300), color = Color(0xFFA9BDAE), drawStyle = Stroke(1.4f)),
        )
        if (e != null) {
            Fila(5.dp) {
                Icono("grano", 14.dp, Color(0xFF8A9A90))
                Text("${Estado.cifra(e.humedad)} % · ${e.lote ?: "SISCAN"}", style = TextStyle(fontFamily = Jakarta, fontSize = 13.sp, color = Color(0xFF8A9A90)))
            }
            val listo = e.prediccion.listoEn()
            Text(if (listo != null) "Listo en ${Estado.duracion(listo)}" else if (e.enCurso) "Secando" else "Sin lote en curso",
                style = TextStyle(fontFamily = Jakarta, fontSize = 13.sp, color = Color(0xFF8A9A90)))
        }
    }
}

/** Cargando la primera vez (no hay copia guardada). */
@Composable
fun Cargando() = Esfera {
    Pila(Modifier.semantics { liveRegion = LiveRegionMode.Polite }) {
        androidx.compose.foundation.Image(androidx.compose.ui.res.painterResource(R.drawable.siscan_simbolo_claro), null, Modifier.size(46.dp))
        Spacer(Modifier.height(6.dp))
        Sub("Leyendo el secador…")
    }
}

/** Sin señal y sin copia: qué pasó y cómo seguir. */
@Composable
fun SinDatos(onReintentar: () -> Unit) = Esfera(Tinte.Advertencia) {
    Pila {
        Box(Modifier.padding(bottom = 4.dp).size(46.dp).clip(CircleShape).background(Sc.pausa), contentAlignment = Alignment.Center) { Icono("wifi_no", 24.dp, Color(0xFF1A1205)) }
        Titulo2("Sin conexión")
        Sub("El reloj no pudo leer el secador. Revisa el Wi-Fi o el teléfono.")
        BotonAccion("Reintentar", chico = true, onClick = onReintentar)
    }
}

