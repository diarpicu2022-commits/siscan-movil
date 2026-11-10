package co.gov.narino.cisna.siscan.reloj

import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import androidx.compose.ui.graphics.Color
import androidx.concurrent.futures.CallbackToFutureAdapter
import androidx.wear.protolayout.ActionBuilders
import androidx.wear.protolayout.ColorBuilders.argb
import androidx.wear.protolayout.DimensionBuilders.degrees
import androidx.wear.protolayout.DimensionBuilders.dp
import androidx.wear.protolayout.DimensionBuilders.expand
import androidx.wear.protolayout.DimensionBuilders.sp
import androidx.wear.protolayout.DimensionBuilders.wrap
import androidx.wear.protolayout.LayoutElementBuilders
import androidx.wear.protolayout.LayoutElementBuilders.Arc
import androidx.wear.protolayout.LayoutElementBuilders.ArcLine
import androidx.wear.protolayout.LayoutElementBuilders.Box
import androidx.wear.protolayout.LayoutElementBuilders.Column
import androidx.wear.protolayout.LayoutElementBuilders.FontStyle
import androidx.wear.protolayout.LayoutElementBuilders.Image
import androidx.wear.protolayout.LayoutElementBuilders.Row
import androidx.wear.protolayout.LayoutElementBuilders.Spacer
import androidx.wear.protolayout.LayoutElementBuilders.Text
import androidx.wear.protolayout.ModifiersBuilders
import androidx.wear.protolayout.ResourceBuilders
import androidx.wear.protolayout.TimelineBuilders
import androidx.wear.tiles.RequestBuilders
import androidx.wear.tiles.TileBuilders
import androidx.wear.tiles.TileService
import androidx.wear.watchface.complications.data.ComplicationData
import androidx.wear.watchface.complications.data.ComplicationType
import androidx.wear.watchface.complications.data.MonochromaticImage
import androidx.wear.watchface.complications.data.PlainComplicationText
import androidx.wear.watchface.complications.data.RangedValueComplicationData
import androidx.wear.watchface.complications.data.ShortTextComplicationData
import androidx.wear.watchface.complications.datasource.ComplicationDataSourceUpdateRequester
import androidx.wear.watchface.complications.datasource.ComplicationRequest
import androidx.wear.watchface.complications.datasource.SuspendingComplicationDataSourceService
import com.google.common.util.concurrent.ListenableFuture

/** Pide a la Tarjeta y a las complicaciones redibujarse cuando llega un estado nuevo. */
object Superficies {
    fun actualizar(c: Context) {
        runCatching { TileService.getUpdater(c).requestUpdate(TarjetaSiscan::class.java) }
        for (k in listOf(ComplicacionHumedad::class.java, ComplicacionTemperatura::class.java, ComplicacionAlertas::class.java, ComplicacionLote::class.java)) {
            runCatching { ComplicationDataSourceUpdateRequester.create(c, ComponentName(c, k)).requestUpdateAll() }
        }
    }
}

private fun <T : Any> listo(v: T): ListenableFuture<T> = CallbackToFutureAdapter.getFuture { it.set(v); "listo" }
private fun color(c: Color) = argb(android.graphics.Color.argb((c.alpha * 255).toInt(), (c.red * 255).toInt(), (c.green * 255).toInt(), (c.blue * 255).toInt()))

/** WatchTile: lote con el símbolo, anillo con la humedad, temperatura y tiempo restante, y «Abrir». */
class TarjetaSiscan : TileService() {
    private val imagenes = mapOf("simbolo" to R.drawable.siscan_simbolo_claro, "termometro" to R.drawable.sc_termometro, "reloj" to R.drawable.sc_reloj)

    override fun onTileRequest(pedido: RequestBuilders.TileRequest): ListenableFuture<TileBuilders.Tile> {
        val e = Guardado.leer(this)
        val ahora = ahoraColombia()
        fun texto(t: String, tam: Float, c: Color, peso: Int = LayoutElementBuilders.FONT_WEIGHT_NORMAL) = Text.Builder().setText(t).setMaxLines(1)
            .setFontStyle(FontStyle.Builder().setSize(sp(tam)).setColor(color(c)).setWeight(peso).build()).build()
        fun icono(id: String, tam: Float, c: Color) = Image.Builder().setResourceId(id).setWidth(dp(tam)).setHeight(dp(tam))
            .setColorFilter(LayoutElementBuilders.ColorFilter.Builder().setTint(color(c)).build()).build()
        fun dato(ic: String, t: String) = Row.Builder().setVerticalAlignment(LayoutElementBuilders.VERTICAL_ALIGN_CENTER)
            .addContent(icono(ic, 13f, Sc.tintaSuave)).addContent(Spacer.Builder().setWidth(dp(4f)).build())
            .addContent(texto(t, 12f, Sc.tintaSuave, LayoutElementBuilders.FONT_WEIGHT_BOLD)).build()

        val abrir = ModifiersBuilders.Clickable.Builder().setId("abrir").setOnClick(
            ActionBuilders.LaunchAction.Builder().setAndroidActivity(
                ActionBuilders.AndroidActivity.Builder().setPackageName(packageName).setClassName(RelojActivity::class.java.name).build()).build()).build()

        val col = Column.Builder().setHorizontalAlignment(LayoutElementBuilders.HORIZONTAL_ALIGN_CENTER)
        // .sc-wk: símbolo claro y lote en brote-vivo.
        col.addContent(Row.Builder().setVerticalAlignment(LayoutElementBuilders.VERTICAL_ALIGN_CENTER)
            .addContent(Image.Builder().setResourceId("simbolo").setWidth(dp(18f)).setHeight(dp(18f)).build())
            .addContent(Spacer.Builder().setWidth(dp(5f)).build())
            .addContent(texto(e?.lote ?: "SISCAN", 13f, Sc.broteVivo, LayoutElementBuilders.FONT_WEIGHT_BOLD)).build())
        col.addContent(Spacer.Builder().setHeight(dp(4f)).build())
        // RingGauge 84, trazo 7: pista blanca al 12 % y avance en brote-vivo desde arriba.
        val av = (e?.avance ?: 0f) / 100f
        val anillo = Box.Builder().setWidth(dp(84f)).setHeight(dp(84f))
            .addContent(Arc.Builder().setAnchorAngle(degrees(0f)).setAnchorType(LayoutElementBuilders.ARC_ANCHOR_START)
                .addContent(ArcLine.Builder().setLength(degrees(360f)).setThickness(dp(7f)).setColor(color(Color.White.copy(alpha = .12f))).build()).build())
            .addContent(Arc.Builder().setAnchorAngle(degrees(0f)).setAnchorType(LayoutElementBuilders.ARC_ANCHOR_START)
                .addContent(ArcLine.Builder().setLength(degrees(360f * av)).setThickness(dp(7f)).setColor(color(Sc.broteVivo)).build()).build())
            .addContent(texto(e?.humedad?.let { "${Estado.cifra(it)} %" } ?: "—", 18f, Color.White, LayoutElementBuilders.FONT_WEIGHT_BOLD))
            .build()
        col.addContent(anillo)
        col.addContent(Spacer.Builder().setHeight(dp(4f)).build())
        val temp = e?.lectura("TEMPERATURE_TOPE")?.valor
        val listo = e?.prediccion?.takeIf { it.estado == "EN_CURSO" }?.horas
        val tiempo = when {
            e == null -> "Abre la app"
            !e.reportando(ahora) -> "Sin conexión"
            listo != null -> Estado.duracion(listo)
            e.enCurso -> "Secando"
            else -> "Terminado"
        }
        col.addContent(Row.Builder().addContent(dato("termometro", temp?.let { "${Estado.cifra(it)}°" } ?: "—"))
            .addContent(Spacer.Builder().setWidth(dp(12f)).build()).addContent(dato("reloj", tiempo)).build())
        col.addContent(Spacer.Builder().setHeight(dp(4f)).build())
        // .sc-wcta-sm: «Abrir» en brote-vivo (34 × 90), con 48 de toque.
        col.addContent(Box.Builder().setWidth(wrap()).setHeight(dp(48f)).setVerticalAlignment(LayoutElementBuilders.VERTICAL_ALIGN_CENTER)
            .setModifiers(ModifiersBuilders.Modifiers.Builder().setClickable(abrir).build())
            .addContent(Box.Builder().setWidth(dp(90f)).setHeight(dp(34f))
                .setModifiers(ModifiersBuilders.Modifiers.Builder().setBackground(ModifiersBuilders.Background.Builder().setColor(color(Sc.broteVivo))
                    .setCorner(ModifiersBuilders.Corner.Builder().setRadius(dp(17f)).build()).build()).build())
                .addContent(texto("Abrir", 13f, Sc.bosqueHondo, LayoutElementBuilders.FONT_WEIGHT_BOLD)).build()).build())

        val raiz = Box.Builder().setWidth(expand()).setHeight(expand())
            .setModifiers(ModifiersBuilders.Modifiers.Builder().setBackground(ModifiersBuilders.Background.Builder().setColor(color(Color.Black)).build())
                .setSemantics(ModifiersBuilders.Semantics.Builder().setContentDescription(descripcion(e, tiempo)).build()).build())
            .addContent(col.build()).build()
        return listo(TileBuilders.Tile.Builder().setResourcesVersion("2").setFreshnessIntervalMillis(15 * 60_000)
            .setTileTimeline(TimelineBuilders.Timeline.fromLayoutElement(raiz)).build())
    }

    private fun descripcion(e: Estado?, tiempo: String) = if (e == null) "SISCAN: abre la app para leer el secador"
    else "SISCAN, ${e.lote ?: "sin lote"}: humedad del grano ${Estado.cifra(e.humedad)} por ciento, $tiempo"

    override fun onTileResourcesRequest(pedido: RequestBuilders.ResourcesRequest): ListenableFuture<ResourceBuilders.Resources> {
        val r = ResourceBuilders.Resources.Builder().setVersion("2")
        imagenes.forEach { (k, id) ->
            r.addIdToImageMapping(k, ResourceBuilders.ImageResource.Builder()
                .setAndroidResourceByResId(ResourceBuilders.AndroidImageResourceByResId.Builder().setResourceId(id).build()).build())
        }
        return listo(r.build())
    }
}

/** Toque en una complicación: abre la app. */
private fun abrirApp(c: Context): PendingIntent =
    PendingIntent.getActivity(c, 0, Intent(c, RelojActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK), PendingIntent.FLAG_IMMUTABLE)

private fun icono(c: Context, id: Int) = MonochromaticImage.Builder(Icon.createWithResource(c, id)).build()
private fun texto(t: String) = PlainComplicationText.Builder(t).build()

/** Complicación de la esfera: humedad del grano en anillo (avance del secado) o «12,4 %». */
class ComplicacionHumedad : SuspendingComplicationDataSourceService() {
    override fun getPreviewData(type: ComplicationType): ComplicationData? = datos(type, 12.4, 88f)
    override suspend fun onComplicationRequest(request: ComplicationRequest): ComplicationData? {
        val e = Guardado.leer(this)
        return datos(request.complicationType, e?.humedad, e?.avance)
    }
    private fun datos(type: ComplicationType, h: Double?, avance: Float?): ComplicationData? {
        val desc = texto(if (h == null) "Humedad del grano sin dato" else "Humedad del grano ${Estado.cifra(h)} por ciento")
        return when (type) {
            ComplicationType.RANGED_VALUE -> RangedValueComplicationData.Builder(value = avance ?: 0f, min = 0f, max = 100f, contentDescription = desc)
                .setText(texto(h?.let { Estado.cifra(it) } ?: "—")).setMonochromaticImage(icono(this, R.drawable.sc_grano)).setTapAction(abrirApp(this)).build()
            ComplicationType.SHORT_TEXT -> ShortTextComplicationData.Builder(texto(h?.let { "${Estado.cifra(it)}%" } ?: "—"), desc)
                .setMonochromaticImage(icono(this, R.drawable.sc_grano)).setTapAction(abrirApp(this)).build()
            else -> null
        }
    }
}

/** Complicación: temperatura interior del secador. */
class ComplicacionTemperatura : SuspendingComplicationDataSourceService() {
    override fun getPreviewData(type: ComplicationType): ComplicationData? = datos(type, 42.0)
    override suspend fun onComplicationRequest(request: ComplicationRequest): ComplicationData? =
        datos(request.complicationType, Guardado.leer(this)?.lectura("TEMPERATURE_TOPE")?.valor)
    private fun datos(type: ComplicationType, t: Double?): ComplicationData? = if (type != ComplicationType.SHORT_TEXT) null else
        ShortTextComplicationData.Builder(texto(t?.let { "${Estado.cifra(it, 0)}°" } ?: "—"), texto(if (t == null) "Temperatura interior sin dato" else "Temperatura interior ${Estado.cifra(t)} grados"))
            .setMonochromaticImage(icono(this, R.drawable.sc_termometro)).setTapAction(abrirApp(this)).build()
}

/** Complicación: alertas activas. RANGED_VALUE (0–10) para que la esfera la pinte en rojo solo si hay alertas. */
class ComplicacionAlertas : SuspendingComplicationDataSourceService() {
    override fun getPreviewData(type: ComplicationType): ComplicationData? = datos(type, 1)
    override suspend fun onComplicationRequest(request: ComplicationRequest): ComplicationData? = datos(request.complicationType, Guardado.leer(this)?.alertasActivas)
    private fun datos(type: ComplicationType, n: Int?): ComplicationData? {
        val desc = texto(if (n == null) "Alertas sin dato" else "$n ${if (n == 1) "alerta activa" else "alertas activas"}")
        return when (type) {
            ComplicationType.RANGED_VALUE -> RangedValueComplicationData.Builder(value = (n ?: 0).toFloat().coerceAtMost(10f), min = 0f, max = 10f, contentDescription = desc)
                .setText(texto(n?.toString() ?: "—")).setMonochromaticImage(icono(this, R.drawable.sc_alertas)).setTapAction(abrirApp(this)).build()
            ComplicationType.SHORT_TEXT -> ShortTextComplicationData.Builder(texto(n?.toString() ?: "—"), desc)
                .setMonochromaticImage(icono(this, R.drawable.sc_alertas)).setTapAction(abrirApp(this)).build()
            else -> null
        }
    }
}

/** Complicación: «Lote B · listo en 5 h 40» (la línea de la esfera). */
class ComplicacionLote : SuspendingComplicationDataSourceService() {
    override fun getPreviewData(type: ComplicationType): ComplicationData? = datos(type, "Lote B · listo en 5 h 40")
    override suspend fun onComplicationRequest(request: ComplicationRequest): ComplicationData? {
        val e = Guardado.leer(this) ?: return datos(request.complicationType, "SISCAN · abre la app")
        val listo = e.prediccion?.takeIf { it.estado == "EN_CURSO" }?.horas
        val lote = e.lote ?: "Sin lotes"
        val t = when {
            !e.reportando(ahoraColombia()) -> "$lote · sin conexión"
            listo != null -> "$lote · listo en ${Estado.duracion(listo)}"
            e.enCurso -> "$lote · secando"
            else -> "$lote · terminado"
        }
        return datos(request.complicationType, t)
    }
    private fun datos(type: ComplicationType, t: String): ComplicationData? = if (type != ComplicationType.LONG_TEXT) null else
        androidx.wear.watchface.complications.data.LongTextComplicationData.Builder(texto(t), texto(t))
            .setMonochromaticImage(icono(this, R.drawable.sc_grano)).setTapAction(abrirApp(this)).build()
}
