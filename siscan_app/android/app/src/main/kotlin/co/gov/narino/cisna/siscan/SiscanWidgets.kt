package co.gov.narino.cisna.siscan

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

/**
 * Widgets SISCAN (HomeWidget del sistema de diseño v2, 2×2 y 4×2). La app dibuja el widget con los componentes del
 * sistema y lo guarda como imagen (lib/app/widgets_inicio.dart); aquí solo se muestra y se abre la app al tocarlo.
 */
private fun pintar(context: Context, manager: AppWidgetManager, ids: IntArray, data: SharedPreferences, clave: String) {
    val ruta = data.getString(clave, null)
    val imagen = ruta?.let { if (File(it).exists()) BitmapFactory.decodeFile(it) else null }
    for (id in ids) {
        val v = RemoteViews(context.packageName, R.layout.widget_moisture).apply {
            if (imagen != null) setImageViewBitmap(R.id.img, imagen) else setImageViewResource(R.id.img, R.mipmap.ic_launcher)
            setContentDescription(R.id.img, data.getString("descripcion", null) ?: "SISCAN: abre la app para cargar el secador.")
            setOnClickPendingIntent(R.id.root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("siscan://inicio")))
        }
        manager.updateAppWidget(id, v)
    }
}

class MoistureWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray, data: SharedPreferences) = pintar(context, manager, ids, data, "img_s")
}

class BatchWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray, data: SharedPreferences) = pintar(context, manager, ids, data, "img_m")
}
