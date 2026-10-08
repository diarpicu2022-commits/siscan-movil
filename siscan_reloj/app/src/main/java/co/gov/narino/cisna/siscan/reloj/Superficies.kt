package co.gov.narino.cisna.siscan.reloj

import android.content.ComponentName
import android.content.Context
import androidx.concurrent.futures.CallbackToFutureAdapter
import androidx.wear.protolayout.ActionBuilders
import androidx.wear.protolayout.ColorBuilders.argb
import androidx.wear.protolayout.DimensionBuilders.degrees
import androidx.wear.protolayout.DimensionBuilders.dp
import androidx.wear.protolayout.DimensionBuilders.expand
import androidx.wear.protolayout.DimensionBuilders.sp
import androidx.wear.protolayout.LayoutElementBuilders
import androidx.wear.protolayout.LayoutElementBuilders.Arc
import androidx.wear.protolayout.LayoutElementBuilders.ArcLine
import androidx.wear.protolayout.LayoutElementBuilders.Box
import androidx.wear.protolayout.LayoutElementBuilders.Column
import androidx.wear.protolayout.LayoutElementBuilders.FontStyle
import androidx.wear.protolayout.LayoutElementBuilders.Text
import androidx.wear.protolayout.ModifiersBuilders
import androidx.wear.protolayout.ResourceBuilders
import androidx.wear.protolayout.TimelineBuilders
import androidx.wear.tiles.RequestBuilders
import androidx.wear.tiles.TileBuilders
import androidx.wear.tiles.TileService
import androidx.wear.watchface.complications.data.ComplicationData
import androidx.wear.watchface.complications.data.ComplicationType
import androidx.wear.watchface.complications.data.PlainComplicationText
import androidx.wear.watchface.complications.data.RangedValueComplicationData
import androidx.wear.watchface.complications.data.ShortTextComplicationData
import androidx.wear.watchface.complications.datasource.ComplicationDataSourceUpdateRequester
import androidx.wear.watchface.complications.datasource.ComplicationRequest
import androidx.wear.watchface.complications.datasource.SuspendingComplicationDataSourceService
import com.google.common.util.concurrent.ListenableFuture
import java.util.Locale

/** Pide a la Tarjeta y a la Complicación redibujarse cuando llega un estado nuevo o cambia el tema. */
object Superficies {
    fun actualizar(c: Context) {
        runCatching { TileService.getUpdater(c).requestUpdate(TarjetaSiscan::class.java) }
        runCatching { ComplicationDataSourceUpdateRequester.create(c, ComponentName(c, ComplicacionHumedad::class.java)).requestUpdateAll() }
    }
}

private fun <T : Any> listo(v: T): ListenableFuture<T> = CallbackToFutureAdapter.getFuture { it.set(v); "listo" }
private fun color(c: androidx.compose.ui.graphics.Color) = argb(android.graphics.Color.argb((c.alpha * 255).toInt(), (c.red * 255).toInt(), (c.green * 255).toInt(), (c.blue * 255).toInt()))
private fun n(v: Double, d: Int = 1) = "%.${d}f".format(Locale.US, v)

/** Tarjeta (Tile): humedad grande, objetivo, lote y el arco del lecho. Respeta el tema elegido en el reloj. */
class TarjetaSiscan : TileService() {
    override fun onTileRequest(pedido: RequestBuilders.TileRequest): ListenableFuture<TileBuilders.Tile> {
        val e = Guardado.leer(this)
        val tema = Guardado.tema(this)
        val nocheSistema = (resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) == android.content.res.Configuration.UI_MODE_NIGHT_YES
        val p = when (tema) { "claro" -> Claro; "oscuro" -> Oscuro; else -> if (nocheSistema) Oscuro else Claro }
        fun texto(t: String, tam: Float, c: androidx.compose.ui.graphics.Color, negrita: Boolean = false) = Text.Builder().setText(t).setMaxLines(1)
            .setFontStyle(FontStyle.Builder().setSize(sp(tam)).setColor(color(c)).setWeight(if (negrita) LayoutElementBuilders.FONT_WEIGHT_BOLD else LayoutElementBuilders.FONT_WEIGHT_NORMAL).build()).build()
        val contenido = Column.Builder()
        if (e == null) {
            contenido.addContent(texto("SISCAN", 18f, p.tinta, true)).addContent(texto("Abre la app para consultar", 14f, p.tintaSuave))
        } else {
            contenido.addContent(texto(if (e.enCurso) "HUMEDAD DEL CAFÉ" else "HUMEDAD FINAL", 12f, p.tintaSuave, true))
                .addContent(texto((e.humedad?.let { n(it) } ?: "—") + " %", 36f, p.tinta, true))
                .addContent(texto(lineaEstado(e), 14f, if (e.enObjetivo) p.cafeto else if (e.enCurso) p.agua else p.tintaSuave))
                .addContent(texto(e.lote ?: "", 15f, p.tinta))
                // Igual que la app: un dato viejo nunca se presenta como recién actualizado.
                .addContent(texto(lineaFrescura(e, ahoraColombia()), 12f, if (e.reportando(ahoraColombia())) p.tintaSuave else p.panela))
        }
        val av = e?.avance ?: 0f
        val riel = Arc.Builder().setAnchorAngle(degrees(225f)).setAnchorType(LayoutElementBuilders.ARC_ANCHOR_START)
            .addContent(ArcLine.Builder().setLength(degrees(270f)).setThickness(dp(7f)).setColor(color(p.superficieFuerte)).build()).build()
        val lleno = Arc.Builder().setAnchorAngle(degrees(225f)).setAnchorType(LayoutElementBuilders.ARC_ANCHOR_START)
            .addContent(ArcLine.Builder().setLength(degrees(270f * av)).setThickness(dp(7f)).setColor(color(if (e?.enObjetivo == true) p.cafeto else p.agua)).build()).build()
        val clic = ModifiersBuilders.Clickable.Builder().setId("abrir").setOnClick(
            ActionBuilders.LaunchAction.Builder().setAndroidActivity(
                ActionBuilders.AndroidActivity.Builder().setPackageName(packageName).setClassName(RelojActivity::class.java.name).build()).build()).build()
        val raiz = Box.Builder().setWidth(expand()).setHeight(expand())
            .setModifiers(ModifiersBuilders.Modifiers.Builder().setClickable(clic).setBackground(ModifiersBuilders.Background.Builder().setColor(color(p.fondo)).build())
                .setPadding(ModifiersBuilders.Padding.Builder().setAll(dp(4f)).build()).build())
            .addContent(riel).addContent(lleno).addContent(contenido.build()).build()
        return listo(TileBuilders.Tile.Builder().setResourcesVersion("1").setFreshnessIntervalMillis(15 * 60_000)
            .setTileTimeline(TimelineBuilders.Timeline.fromLayoutElement(raiz)).build())
    }

    override fun onTileResourcesRequest(pedido: RequestBuilders.ResourcesRequest): ListenableFuture<ResourceBuilders.Resources> =
        listo(ResourceBuilders.Resources.Builder().setVersion("1").build())
}

/** Complicación: humedad del lote (RANGED_VALUE 0–60 %) o «10.6 %» (SHORT_TEXT). La esfera la tiñe. */
class ComplicacionHumedad : SuspendingComplicationDataSourceService() {
    override fun getPreviewData(type: ComplicationType): ComplicationData? = datos(type, 14.5, 11.0)

    override suspend fun onComplicationRequest(request: ComplicationRequest): ComplicationData? {
        val e = Guardado.leer(this)
        return datos(request.complicationType, e?.humedad, e?.objetivo ?: 11.0)
    }

    private fun datos(type: ComplicationType, h: Double?, objetivo: Double): ComplicationData? {
        val desc = PlainComplicationText.Builder(if (h == null) "Humedad del café sin dato" else "Humedad del café ${n(h)} por ciento, objetivo ${n(objetivo, 0)}").build()
        return when (type) {
            ComplicationType.RANGED_VALUE -> RangedValueComplicationData.Builder(value = (h ?: 0.0).toFloat().coerceIn(0f, 60f), min = 0f, max = 60f, contentDescription = desc)
                .setText(PlainComplicationText.Builder(h?.let { n(it, 0) } ?: "—").build()).build()
            ComplicationType.SHORT_TEXT -> ShortTextComplicationData.Builder(PlainComplicationText.Builder(h?.let { n(it) + "%" } ?: "—").build(), desc)
                .setTitle(PlainComplicationText.Builder("Café").build()).build()
            else -> null
        }
    }
}
