package co.gov.narino.cisna.siscan.reloj

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithCache
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathMeasure
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontVariation
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.em
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material3.Icon
import androidx.wear.compose.material3.Text

/* ------------------------------------------------------------------------------------------------------------------
 * Componentes Wear del sistema SISCAN v2 (components/Watch*, bundle.css .sc-w*). Las medidas son las de la esfera de
 * la documentación (224 px): Esfera() escala la densidad para que 1 px del sistema sea 1 dp en cualquier reloj.
 * ------------------------------------------------------------------------------------------------------------------ */

private fun peso(w: Int) = FontVariation.Settings(FontVariation.weight(w))
val Outfit = FontFamily(listOf(300, 600, 700).map { Font(R.font.outfit, FontWeight(it), variationSettings = peso(it)) })
val Jakarta = FontFamily(listOf(400, 600, 650, 700, 750, 800).map { Font(R.font.plus_jakarta_sans, FontWeight(it), variationSettings = peso(it)) })

val EaseEntrada = CubicBezierEasing(.22f, 1f, .36f, 1f)
val EaseSuave = CubicBezierEasing(.4f, 0f, .2f, 1f)

/** Movimiento reducido (ajuste de accesibilidad del reloj): todo queda quieto. */
val LocalSinMovimiento = staticCompositionLocalOf { false }

/** Fondo del reloj: negro OLED con tinte verde arriba; alerta roja o ámbar a pantalla completa (.sc-wscreen*). */
enum class Tinte { Normal, Alerta, Advertencia, Ambiente }

@Composable
fun Esfera(tinte: Tinte = Tinte.Normal, contenido: @Composable BoxScope.() -> Unit) {
    val d = LocalDensity.current
    val ancho = LocalConfiguration.current.screenWidthDp.toFloat()
    CompositionLocalProvider(LocalDensity provides Density(d.density * ancho / ScReloj.ESFERA, d.fontScale)) {
        Box(
            Modifier.fillMaxSize().clip(CircleShape).background(Color.Black).then(if (tinte == Tinte.Ambiente) Modifier else Modifier.fondoRadial(tinte)),
            contentAlignment = Alignment.Center,
            content = contenido,
        )
    }
}

/** radial-gradient(circle at 50% Y%, color, #000 fin%) sobre la esfera. */
private fun Modifier.fondoRadial(t: Tinte): Modifier = drawWithCache {
    val c = when (t) { Tinte.Alerta -> Color(0xFF3A1512); Tinte.Advertencia -> Color(0xFF33250C); else -> Color(0xFF0C1C13) }
    val y = if (t == Tinte.Normal) .35f else .30f
    val fin = if (t == Tinte.Normal) .72f else .75f
    val centro = Offset(size.width / 2, size.height * y)
    val radio = kotlin.math.hypot(size.width / 2, size.height * (1 - y))
    val b = Brush.radialGradient(0f to c, fin to Color.Black, 1f to Color.Black, center = centro, radius = radio)
    onDrawBehind { drawRect(b) }
}

/** Icono del sistema (VectorDrawable generado de los SVG del paquete). */
@Composable
fun Icono(nombre: String, tam: Dp, color: Color, modifier: Modifier = Modifier) {
    val id = iconoRes(nombre)
    Icon(painterResource(id), contentDescription = null, tint = color, modifier = modifier.size(tam))
}

fun iconoRes(nombre: String): Int = when (nombre) {
    "grano" -> R.drawable.sc_grano; "termometro" -> R.drawable.sc_termometro; "termometroTope" -> R.drawable.sc_termometro_tope
    "gotas" -> R.drawable.sc_gotas; "nubeSol" -> R.drawable.sc_nube_sol; "nube" -> R.drawable.sc_nube; "ventilador" -> R.drawable.sc_ventilador
    "resistencia" -> R.drawable.sc_resistencia; "ia" -> R.drawable.sc_ia; "x" -> R.drawable.sc_x; "check" -> R.drawable.sc_check
    "balanza" -> R.drawable.sc_balanza; "menos" -> R.drawable.sc_menos; "mas" -> R.drawable.sc_mas; "reloj" -> R.drawable.sc_reloj
    "alertas" -> R.drawable.sc_alertas; "aviso" -> R.drawable.sc_aviso; "wifi_no" -> R.drawable.sc_wifi_no; "candado" -> R.drawable.sc_candado
    "rayo" -> R.drawable.sc_rayo; "potencia" -> R.drawable.sc_potencia; "mano" -> R.drawable.sc_mano; "actualizar" -> R.drawable.sc_actualizar
    else -> R.drawable.sc_info
}

/** Color de cada magnitud (.sc-c-*). */
fun tono(t: String): Color = when (t) {
    "temperatura", "tope" -> Sc.datoTemperatura; "humedad" -> Sc.datoHumedad; "exterior" -> Sc.datoExterior; "grano" -> Sc.datoGrano
    "solar" -> Sc.datoSolar; "corriente" -> Sc.pausa; "pred" -> Sc.prediccion; else -> Sc.broteVivo
}

/** .sc-warc: arco de 270° que deja libre la parte de arriba para la hora; se llena con dur-lenta y ease-entrada. */
@Composable
fun ArcoReloj(valor: Float, color: Color = Sc.broteVivo) {
    val sinMov = LocalSinMovimiento.current
    val a = remember { Animatable(if (sinMov) valor.coerceIn(0f, 100f) else 0f) }
    LaunchedEffect(valor) { if (sinMov) a.snapTo(valor.coerceIn(0f, 100f)) else a.animateTo(valor.coerceIn(0f, 100f), tween(ScDur.lenta, easing = EaseEntrada)) }
    Canvas(Modifier.fillMaxSize()) {
        val k = size.width / 224f
        val r = 104f * k
        val tl = Offset(size.width / 2 - r, size.height / 2 - r)
        val s = Size(2 * r, 2 * r)
        val trazo = Stroke(9f * k, cap = StrokeCap.Round)
        drawArc(Color.White.copy(alpha = .1f), -45f, 270f, false, tl, s, style = trazo)
        if (a.value > 0f) drawArc(color, -45f, 270f * a.value / 100f, false, tl, s, style = trazo)
    }
}

/** .sc-wstack: columna centrada, separación 3, ancho máximo 168. */
@Composable
fun Pila(modifier: Modifier = Modifier, contenido: @Composable ColumnScope.() -> Unit) =
    Column(modifier.widthIn(max = 168.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(3.dp), content = contenido)

/** .sc-wk: rótulo con icono en brote-vivo (o predicción). */
@Composable
fun Rotulo(icono: String?, texto: String, color: Color = Sc.broteVivo) = Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
    if (icono != null) Icono(icono, 14.dp, color)
    Text(texto, style = TextStyle(fontFamily = Jakarta, fontSize = 13.sp, fontWeight = FontWeight(700), color = color))
}

/** .sc-wbig: cifra protagonista en Outfit (50 px; .sc-wbig-sm 34 px) con su unidad en tinta-suave. */
@Composable
fun Cifra(valor: String, unidad: String? = null, chica: Boolean = false) {
    val sinMov = LocalSinMovimiento.current
    // .sc-read: el número entra con un leve desplazamiento cuando cambia.
    val entrada by animateFloatAsState(1f, if (sinMov) tween(0) else tween(ScDur.media, easing = EaseEntrada), label = "cifra")
    Row(verticalAlignment = Alignment.Bottom, modifier = Modifier.alpha(entrada)) {
        Text(valor, maxLines = 1, style = TextStyle(fontFamily = Outfit, fontSize = if (chica) 34.sp else 50.sp, lineHeight = if (chica) 40.sp else 54.sp,
            fontWeight = FontWeight(700), color = Color.White, fontFeatureSettings = "tnum"))
        if (unidad != null) Text(unidad, modifier = Modifier.padding(start = 2.dp, bottom = if (chica) 6.dp else 8.dp),
            style = TextStyle(fontFamily = Outfit, fontSize = 20.sp, fontWeight = FontWeight(600), color = Sc.tintaSuave))
    }
}

/** .sc-wsub */
@Composable
fun Sub(texto: String, color: Color = Sc.tintaSuave) =
    Text(texto, textAlign = TextAlign.Center, style = TextStyle(fontFamily = Jakarta, fontSize = 12.5.sp, lineHeight = 16.sp, color = color, fontFeatureSettings = "tnum"))

/** .sc-livedot con .sc-live (pulso, dur-latido). */
@Composable
fun PuntoVivo(vivo: Boolean, color: Color = Sc.broteVivo) {
    val sinMov = LocalSinMovimiento.current
    val t = rememberInfiniteTransition(label = "latido")
    val p by t.animateFloat(0f, 1f, infiniteRepeatable(tween(ScDur.latido, easing = EaseSuave), RepeatMode.Restart), label = "p")
    Canvas(Modifier.size(8.dp)) {
        val r = size.width / 2
        if (vivo && !sinMov) {
            // box-shadow 0 → 8 px que se desvanece (60 % del ciclo).
            val f = (p / .6f).coerceAtMost(1f)
            drawCircle(color.copy(alpha = .6f * (1 - f)), radius = r + 8.dp.toPx() * f)
        }
        if (vivo) drawCircle(color, r) else drawCircle(color, r - 1.dp.toPx(), style = Stroke(2.dp.toPx()))
    }
}

/** .sc-wchip: estado del lote (o confianza, en predicción). */
@Composable
fun Chip(texto: String, pred: Boolean = false, vivo: Boolean? = null) = Row(
    Modifier.padding(top = 6.dp).clip(RoundedCornerShape(999.dp)).background(if (pred) Color(0xFF1F1A3A) else Color(0xFF12291C)).padding(horizontal = 12.dp, vertical = 6.dp),
    verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp),
) {
    if (vivo != null) PuntoVivo(vivo)
    Text(texto, maxLines = 1, overflow = TextOverflow.Ellipsis, style = TextStyle(fontFamily = Jakarta, fontSize = 12.5.sp, fontWeight = FontWeight(750), color = if (pred) Sc.prediccion else Sc.broteVivo))
}

/** .sc-wlist: lista a lo ancho (172) bajo la hora. */
@Composable
fun Lista(titulo: String, destacado: String? = null, contenido: @Composable ColumnScope.() -> Unit) =
    Column(Modifier.width(172.dp).padding(top = 30.dp), verticalArrangement = Arrangement.spacedBy(5.dp)) {
        Text(
            androidx.compose.ui.text.buildAnnotatedString {
                append(titulo)
                if (destacado != null) { pushStyle(androidx.compose.ui.text.SpanStyle(color = Color.White)); append(destacado); pop() }
            },
            modifier = Modifier.align(Alignment.CenterHorizontally).padding(vertical = 4.dp),
            style = TextStyle(fontFamily = Jakarta, fontSize = 14.sp, fontWeight = FontWeight(800), color = Sc.broteVivo),
        )
        contenido()
    }

/** .sc-wrow: lectura con icono en el color de su magnitud. */
@Composable
fun FilaLectura(icono: String, color: Color, rotulo: String, valor: String) = Row(
    Modifier.heightIn(min = 33.dp).clip(RoundedCornerShape(18.dp)).background(Color(0xFF14231B)).padding(horizontal = 12.dp)
        .semantics(mergeDescendants = true) {},
    verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp),
) {
    Icono(icono, 16.dp, color)
    Text(rotulo, Modifier.weight(1f), maxLines = 1, overflow = TextOverflow.Ellipsis, style = TextStyle(fontFamily = Jakarta, fontSize = 12.5.sp, color = Sc.tintaSuave))
    Text(valor, maxLines = 1, style = TextStyle(fontFamily = Jakarta, fontSize = 14.sp, fontWeight = FontWeight(700), color = Color.White, fontFeatureSettings = "tnum"))
}

/** .sc-wtoggle: chip a lo ancho (48) que enciende o apaga; el ventilador gira y la resistencia brilla. */
@Composable
fun ChipActuador(nombre: String, resistencia: Boolean, encendido: Boolean, estado: String, habilitado: Boolean, onClick: () -> Unit, onLong: (() -> Unit)? = null) {
    val sinMov = LocalSinMovimiento.current
    val t = rememberInfiniteTransition(label = "act")
    val giro by t.animateFloat(0f, 360f, infiniteRepeatable(tween(ScDur.ventilador, easing = LinearEasing)), label = "giro")
    val brillo by t.animateFloat(1f, .45f, infiniteRepeatable(tween(ScDur.latido / 2, easing = EaseSuave), RepeatMode.Reverse), label = "brillo")
    val perilla by animateFloatAsState(if (encendido) 12f else 0f, tween(if (sinMov) 0 else ScDur.rapida), label = "perilla")
    Row(
        Modifier.heightIn(min = ScReloj.TOQUE.dp).clip(RoundedCornerShape(24.dp)).background(if (encendido) Color(0xFF1D4A2C) else Color(0xFF14231B))
            .then(
                if (onLong != null) Modifier.combinedClickableSeguro(habilitado, onClick, onLong) else Modifier.clickable(enabled = habilitado, role = Role.Switch, onClick = onClick),
            )
            .alpha(if (habilitado) 1f else .6f)
            .padding(horizontal = 10.dp)
            .semantics(mergeDescendants = true) { contentDescription = "$nombre, $estado" },
        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Box(Modifier.size(30.dp).clip(CircleShape).background(if (encendido) Sc.broteVivo else Color.White.copy(alpha = .08f)), contentAlignment = Alignment.Center) {
            Icono(
                if (resistencia) "resistencia" else "ventilador", 18.dp, if (encendido) Sc.bosqueHondo else Sc.tintaSuave,
                Modifier.then(if (encendido && !resistencia && !sinMov) Modifier.rotate(giro) else Modifier)
                    .then(if (encendido && resistencia && !sinMov) Modifier.alpha(brillo) else Modifier),
            )
        }
        Column(Modifier.weight(1f)) {
            // Los nombres del servidor («Ventiladores», «Calefactor 3») son más largos que los del sistema: una línea, y si no
            // caben a 13,5 se reducen hasta 11,5 antes que cortarse.
            BasicText(nombre, maxLines = 1, softWrap = false, autoSize = TextAutoSize.StepBased(minFontSize = 11.5.sp, maxFontSize = 13.5.sp, stepSize = .5.sp),
                style = TextStyle(fontFamily = Jakarta, fontSize = 13.5.sp, fontWeight = FontWeight(700), color = Color.White))
            Text(estado, maxLines = 1, overflow = TextOverflow.Ellipsis, style = TextStyle(fontFamily = Jakarta, fontSize = 11.sp, color = Sc.tintaSuave))
        }
        Box(Modifier.size(30.dp, 18.dp).clip(RoundedCornerShape(9.dp)).background(if (encendido) Sc.broteVivo else Color.White.copy(alpha = .2f))) {
            Box(Modifier.offset(x = (3 + perilla).dp, y = 3.dp).size(12.dp).clip(CircleShape).background(Color.White))
        }
    }
}

@OptIn(androidx.compose.foundation.ExperimentalFoundationApi::class)
private fun Modifier.combinedClickableSeguro(habilitado: Boolean, onClick: () -> Unit, onLong: () -> Unit) =
    this.then(Modifier.combinedClickable(enabled = habilitado, role = Role.Switch, onClick = onClick, onLongClick = onLong))

/** .sc-wbatch: lote con su humedad; el activo en verde con el grano en lima. */
@Composable
fun FilaLote(nombre: String, estado: String, valor: String, activo: Boolean) = Row(
    Modifier.heightIn(min = 44.dp).clip(RoundedCornerShape(22.dp)).background(if (activo) Color(0xFF1D4A2C) else Color(0xFF14231B)).padding(horizontal = 12.dp)
        .semantics(mergeDescendants = true) {},
    verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp),
) {
    Icono("grano", 16.dp, if (activo) Sc.lima else Sc.tintaSuave)
    Column(Modifier.weight(1f)) {
        Text(nombre, maxLines = 1, overflow = TextOverflow.Ellipsis, style = TextStyle(fontFamily = Jakarta, fontSize = 13.sp, fontWeight = FontWeight(700), color = Color.White))
        Text(estado, maxLines = 1, style = TextStyle(fontFamily = Jakarta, fontSize = 11.sp, color = Sc.tintaSuave))
    }
    Text(valor, style = TextStyle(fontFamily = Jakarta, fontSize = 14.sp, fontWeight = FontWeight(800), color = Color.White, fontFeatureSettings = "tnum"))
}

/** .sc-wround (36 dibujado, 48 de toque). */
@Composable
fun BotonRedondo(icono: String, etiqueta: String, onClick: () -> Unit) = Box(
    Modifier.size(ScReloj.TOQUE.dp).clip(CircleShape).clickable(role = Role.Button, onClick = onClick).semantics { contentDescription = etiqueta },
    contentAlignment = Alignment.Center,
) { Box(Modifier.size(36.dp).clip(CircleShape).background(Color(0xFF1F3328)), contentAlignment = Alignment.Center) { Icono(icono, 18.dp, Color.White) } }

/** .sc-wbtn (48): confirmar en brote-vivo; .sc-wbtn-ghost para descartar. */
@Composable
fun BotonCirculo(icono: String, etiqueta: String, fantasma: Boolean = false, onClick: () -> Unit) = Box(
    Modifier.size(48.dp).clip(CircleShape).background(if (fantasma) Color(0xFF26302B) else Sc.broteVivo).clickable(role = Role.Button, onClick = onClick)
        .semantics { contentDescription = etiqueta },
    contentAlignment = Alignment.Center,
) { Icono(icono, 20.dp, if (fantasma) Color.White else Sc.bosqueHondo) }

/** .sc-wcta (40 dibujado, 48 de toque). */
@Composable
fun BotonAccion(texto: String, chico: Boolean = false, habilitado: Boolean = true, onClick: () -> Unit) = Box(
    Modifier.heightIn(min = ScReloj.TOQUE.dp).clip(RoundedCornerShape(999.dp)).clickable(enabled = habilitado, role = Role.Button, onClick = onClick),
    contentAlignment = Alignment.Center,
) {
    Box(
        Modifier.heightIn(min = if (chico) 34.dp else 40.dp).widthIn(min = if (chico) 90.dp else 120.dp).clip(RoundedCornerShape(999.dp))
            .background(if (habilitado) Sc.broteVivo else Sc.broteVivo.copy(alpha = .4f)).padding(horizontal = 16.dp),
        contentAlignment = Alignment.Center,
    ) { Text(texto, style = TextStyle(fontFamily = Jakarta, fontSize = if (chico) 13.sp else 14.sp, fontWeight = FontWeight(800), color = Sc.bosqueHondo)) }
}

/** .sc-wtitle2 */
@Composable
fun Titulo2(texto: String) = Text(texto, textAlign = TextAlign.Center, style = TextStyle(fontFamily = Jakarta, fontSize = 18.sp, lineHeight = 22.sp, fontWeight = FontWeight(800), color = Color.White))

/** .sc-wc-check: el círculo y el check se dibujan (dur-lenta, luego dur-media). */
@Composable
fun CheckDibujado() {
    val sinMov = LocalSinMovimiento.current
    val c = remember { Animatable(if (sinMov) 1f else 0f) }
    val t = remember { Animatable(if (sinMov) 1f else 0f) }
    LaunchedEffect(Unit) {
        if (!sinMov) { c.animateTo(1f, tween(ScDur.lenta, easing = EaseSuave)); t.animateTo(1f, tween(ScDur.media, easing = EaseEntrada)) }
    }
    Canvas(Modifier.size(64.dp).padding(bottom = 0.dp)) {
        val k = size.width / 64f
        drawArc(Sc.broteVivo, -90f, 360f * c.value, false, Offset(4f * k, 4f * k), Size(56f * k, 56f * k), style = Stroke(4f * k))
        val p = Path().apply { moveTo(20f * k, 33f * k); lineTo(28f * k, 41f * k); lineTo(44f * k, 24f * k) }
        val m = PathMeasure().apply { setPath(p, false) }
        val parcial = Path()
        m.getSegment(0f, m.length * t.value, parcial, true)
        drawPath(parcial, Sc.broteVivo, style = Stroke(5f * k, cap = StrokeCap.Round, join = StrokeJoin.Round))
    }
    Spacer(Modifier.size(4.dp))
}

/** Fila con separación del sistema. */
@Composable
fun Fila(espacio: Dp, contenido: @Composable RowScope.() -> Unit) = Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(espacio), content = contenido)

val estiloHora = TextStyle(fontFamily = Jakarta, fontSize = 12.sp, fontWeight = FontWeight(700), color = Sc.tintaSuave, letterSpacing = .02.em)
