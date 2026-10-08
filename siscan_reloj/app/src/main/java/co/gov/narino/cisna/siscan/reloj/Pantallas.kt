package co.gov.narino.cisna.siscan.reloj

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material3.Text
import java.time.Duration
import java.time.LocalDateTime
import java.time.format.TextStyle
import java.util.Locale
import kotlin.math.cos
import kotlin.math.sin

val ES = Locale.forLanguageTag("es-CO")
fun hm(t: LocalDateTime) = "%02d:%02d".format(t.hour, t.minute)
fun fechaCorta(t: LocalDateTime) = "${t.dayOfMonth} ${t.month.getDisplayName(TextStyle.SHORT, ES).trimEnd('.')}"
fun hace(t: LocalDateTime, ahora: LocalDateTime): String {
    val m = Duration.between(t, ahora).toMinutes()
    return when {
        m < 1 -> "hace instantes"
        m < 60 -> "hace $m min"
        m < 48 * 60 -> "hace ${m / 60} h"
        else -> "desde el ${fechaCorta(t)}"
    }
}
private fun num(v: Double, d: Int = 1) = "%.${d}f".format(Locale.US, v)

/**
 * Anillo de lecho (dirección A): el lecho de café del MoistureMeter enrollado alrededor de la esfera. El riel es el
 * agua por retirar; el tramo lleno, la que ya se retiró (`agua`, o `cafeto` al llegar al objetivo); una muesca marca
 * el objetivo al final. Granos punteados sobre el riel, como el lecho del sistema.
 */
@Composable
fun AnilloLecho(avance: Float?, enObjetivo: Boolean, modifier: Modifier = Modifier) {
    val p = LocalPaleta.current
    Canvas(modifier) {
        val g = 10.dp.toPx()
        val m = g / 2 + 4.dp.toPx()
        val tam = Size(size.width - m * 2, size.height - m * 2)
        val o = Offset(m, m)
        val inicio = 135f
        val barrido = 270f
        drawArc(p.superficieFuerte, inicio, barrido, false, o, tam, style = Stroke(g, cap = StrokeCap.Round))
        // Granos del lecho: puntos sobre el riel.
        drawArc(p.linea, inicio, barrido, false, o, tam, style = Stroke(3.dp.toPx(), cap = StrokeCap.Round,
            pathEffect = PathEffect.dashPathEffect(floatArrayOf(0.1f, 9.dp.toPx()))))
        if (avance != null && avance > 0f) {
            drawArc(if (enObjetivo) p.cafeto else p.agua, inicio, barrido * avance, false, o, tam, style = Stroke(g, cap = StrokeCap.Round))
        }
        // Muesca del objetivo (fin del riel).
        val ang = Math.toRadians((inicio + barrido).toDouble())
        val r = tam.width / 2
        val c = Offset(size.width / 2 + (r * cos(ang)).toFloat(), size.height / 2 + (r * sin(ang)).toFloat())
        drawCircle(p.fondo, g * 0.62f, c)
        drawCircle(p.cafeto, g * 0.42f, c)
    }
}

/** Glifos de estado del sistema: ✓ círculo (objetivo), ● (secando / en curso), ○ (en espera), ▲ (revisar). */
@Composable
fun Glifo(tipo: String, color: Color, modifier: Modifier = Modifier.size(14.dp)) {
    val fondo = LocalPaleta.current.fondo
    Canvas(modifier) {
        val w = size.width
        when (tipo) {
            "ok" -> {
                drawCircle(color, w / 2)
                val q = Path().apply { moveTo(w * 0.28f, w * 0.52f); lineTo(w * 0.44f, w * 0.68f); lineTo(w * 0.74f, w * 0.34f) }
                drawPath(q, fondo, style = Stroke(w * 0.13f, cap = StrokeCap.Round))
            }
            "punto" -> { drawCircle(color, w / 2, style = Stroke(w * 0.14f)); drawCircle(color, w * 0.22f) }
            "anillo" -> drawCircle(color, w / 2 - w * 0.08f, style = Stroke(w * 0.16f))
            "alerta" -> drawPath(Path().apply { moveTo(w / 2, w * 0.06f); lineTo(w * 0.96f, w * 0.92f); lineTo(w * 0.04f, w * 0.92f); close() }, color)
        }
    }
}

/** Línea de estado común a la app, la Tarjeta y la lectura de pantalla. */
fun lineaEstado(e: Estado): String {
    val obj = num(e.objetivo, 0) + " %"
    return when {
        e.humedad == null -> "Sin muestras"
        e.enObjetivo -> "$obj alcanzado"
        e.enCurso -> "Secando · meta $obj"
        else -> "Terminado · meta $obj"
    }
}

/** «Actualizado 08:43» solo si el secador reporta; si no, desde cuándo calla. */
fun lineaFrescura(e: Estado, ahora: LocalDateTime): String =
    if (e.reportando(ahora)) "Actualizado ${hm(e.consultado)}"
    else "Sin reportes · ${e.ultimaLectura?.let { if (Duration.between(it, ahora).toHours() < 48) hace(it, ahora) else fechaCorta(it) } ?: "nunca"}"

/** 1 · Humedad: la cifra es lo más grande; debajo el lote, el estado con su glifo y cuándo se actualizó. */
@Composable
fun PantallaHumedad(e: Estado, ahora: LocalDateTime) {
    val p = LocalPaleta.current
    val reporta = e.reportando(ahora)
    // Una sola línea de estado con el objetivo: la esfera muestra como máximo tres datos.
    val estado = when {
        e.humedad == null -> Triple("anillo", lineaEstado(e), p.tintaSuave)
        e.enObjetivo -> Triple("ok", lineaEstado(e), p.cafeto)
        e.enCurso -> Triple("punto", lineaEstado(e), p.agua)
        else -> Triple("anillo", lineaEstado(e), p.tintaSuave)
    }
    val frase = "Humedad ${e.humedad?.let { num(it) } ?: "sin dato"} por ciento, objetivo ${num(e.objetivo, 0)}. ${e.lote ?: ""}. ${estado.second}."
    Box(Modifier.fillMaxSize().background(p.fondo), contentAlignment = Alignment.Center) {
        AnilloLecho(e.avance, e.enObjetivo, Modifier.fillMaxSize())
        Column(Modifier.padding(horizontal = 40.dp, vertical = 30.dp).semantics(mergeDescendants = true) { contentDescription = frase }, horizontalAlignment = Alignment.CenterHorizontally) {
            Text(if (e.enCurso) "HUMEDAD DEL CAFÉ" else "HUMEDAD FINAL", style = Tipo.rotulo, color = p.tintaSuave)
            Row(verticalAlignment = Alignment.Bottom) {
                Text(e.humedad?.let { num(it) } ?: "—", style = Tipo.lectura, color = p.tinta, maxLines = 1)
                Text(" %", style = Tipo.unidad, color = p.tintaSuave, modifier = Modifier.padding(bottom = 6.dp))
            }
            Spacer(Modifier.height(2.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Glifo(estado.first, estado.third)
                Spacer(Modifier.width(6.dp))
                Text(estado.second, style = Tipo.apoyo.copy(fontWeight = Tipo.rotulo.fontWeight), color = estado.third)
            }
            Text(e.lote ?: "Sin lotes", style = Tipo.nombre, color = p.tinta, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(lineaFrescura(e, ahora),
                style = Tipo.apoyo.copy(fontSize = Tipo.rotulo.fontSize), color = if (reporta) p.tintaSuave else p.panela, maxLines = 1, overflow = TextOverflow.Ellipsis)
        }
    }
}

/**
 * 2 · Equipo: solo estado (el reloj no manda órdenes; las resistencias exigen mantener presionado en el teléfono).
 * El resumen en palabras va arriba; cada fila lleva el nombre completo y el glifo del sistema (● encendido, ○ apagado),
 * que se distinguen por forma y no solo por color.
 */
@Composable
fun PantallaEquipo(e: Estado, ahora: LocalDateTime) {
    val p = LocalPaleta.current
    val reporta = e.reportando(ahora)
    val encendidos = e.equipo.count { it.encendido }
    val resumen = when {
        e.equipo.isEmpty() -> "Sin equipo registrado"
        encendidos == 0 -> "Todo apagado"
        encendidos == e.equipo.size -> "Todo encendido"
        else -> "$encendidos de ${e.equipo.size} encendidos"
    }
    Column(
        Modifier.fillMaxSize().background(p.fondo).padding(horizontal = 46.dp, vertical = 36.dp),
        verticalArrangement = Arrangement.spacedBy(2.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        // Sin reportes recientes, la fecha del último estado va en el rótulo (la parte ancha de la esfera), en panela.
        Text(
            if (reporta) "EQUIPO" else "EQUIPO · AL ${e.ultimaLectura?.let { fechaCorta(it).uppercase(ES) } ?: "—"}",
            style = Tipo.rotulo, color = if (reporta) p.tintaSuave else p.panela, modifier = Modifier.semantics { heading() },
        )
        Text(resumen, style = Tipo.nombre, color = p.tinta)
        Spacer(Modifier.height(4.dp))
        e.equipo.take(4).forEach { q ->
            Row(
                Modifier.fillMaxWidth().heightIn(min = 26.dp)
                    .semantics(mergeDescendants = true) { contentDescription = "${q.nombre}, ${if (q.encendido) "encendido" else "apagado"}" },
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Glifo(if (q.encendido) "punto" else "anillo", if (q.encendido) p.cafeto else p.tintaSuave, Modifier.size(12.dp))
                Spacer(Modifier.width(8.dp))
                Text(q.nombre, style = Tipo.apoyo.copy(textAlign = androidx.compose.ui.text.style.TextAlign.Start), color = if (q.encendido) p.tinta else p.tintaSuave, maxLines = 1, overflow = TextOverflow.Ellipsis)
            }
        }
    }
}

/** 3 · Alerta: la más grave, o «Sin alertas activas» con cuántas quedan por revisar. */
@Composable
fun PantallaAlerta(e: Estado) {
    val p = LocalPaleta.current
    Column(
        Modifier.fillMaxSize().background(p.fondo).padding(horizontal = 30.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        if (e.alerta != null) {
            Glifo("alerta", p.oxido, Modifier.size(26.dp))
            Spacer(Modifier.height(6.dp))
            Text("REVISA", style = Tipo.rotulo, color = p.oxido)
            Text(e.alerta, style = Tipo.nombre, color = p.tinta, maxLines = 3, overflow = TextOverflow.Ellipsis)
        } else {
            Glifo("ok", p.cafeto, Modifier.size(26.dp))
            Spacer(Modifier.height(6.dp))
            Text("Sin alertas activas", style = Tipo.nombre, color = p.tinta)
        }
        if (e.alertasSinRevisar > 0) Text("${e.alertasSinRevisar} avisos anteriores en el panel", style = Tipo.apoyo, color = p.tintaSuave)
    }
}

/** 4 · Tema: claro, oscuro o como el reloj (pedido del profesor: poder cambiar de modo). */
@Composable
fun PantallaTema(actual: String, onTema: (String) -> Unit) {
    val p = LocalPaleta.current
    Column(
        Modifier.fillMaxSize().background(p.fondo).padding(horizontal = 30.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text("TEMA", style = Tipo.rotulo, color = p.tintaSuave, modifier = Modifier.semantics { heading() })
        listOf("claro" to "Claro", "oscuro" to "Oscuro", "sistema" to "Como el reloj").forEach { (k, t) ->
            val on = actual == k
            Box(
                Modifier.fillMaxWidth().heightIn(min = 48.dp).clip(RoundedCornerShape(50))
                    .background(if (on) p.cafeto else p.superficie)
                    .border(1.dp, if (on) p.cafeto else p.linea, RoundedCornerShape(50))
                    .selectable(selected = on, role = Role.RadioButton) { onTema(k) },
                contentAlignment = Alignment.Center,
            ) { Text(t, style = Tipo.apoyo.copy(fontWeight = Tipo.rotulo.fontWeight), color = if (on) p.fondo else p.tinta) }
        }
    }
}

@Composable
fun PantallaCargando() {
    val p = LocalPaleta.current
    Box(Modifier.fillMaxSize().background(p.fondo), contentAlignment = Alignment.Center) {
        Text("Consultando el secador…", style = Tipo.apoyo, color = p.tintaSuave)
    }
}

@Composable
fun PantallaSinDatos(error: String?) {
    val p = LocalPaleta.current
    Column(Modifier.fillMaxSize().background(p.fondo).padding(horizontal = 30.dp), verticalArrangement = Arrangement.Center, horizontalAlignment = Alignment.CenterHorizontally) {
        Glifo("anillo", p.panela, Modifier.size(22.dp).clip(CircleShape))
        Spacer(Modifier.height(6.dp))
        Text("Sin conexión", style = Tipo.nombre, color = p.tinta)
        Text(error?.let { "No se pudo consultar el secador. Se reintenta solo." } ?: "Se reintenta solo.", style = Tipo.apoyo, color = p.tintaSuave)
    }
}
