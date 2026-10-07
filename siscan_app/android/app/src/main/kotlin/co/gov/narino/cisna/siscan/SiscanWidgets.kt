package co.gov.narino.cisna.siscan

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Widgets SISCAN (referencia WidgetsMovil). Los datos los escribe la app con `home_widget` (lib/data/widget_sync.dart). */
private fun SharedPreferences.s(key: String, def: String = "—") = getString(key, null) ?: def

/** Abre la app en una pantalla concreta (siscan://inicio, siscan://controles). */
private fun open(context: Context, screen: String) =
    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("siscan://$screen"))

class MoistureWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray, data: SharedPreferences) {
        for (id in ids) {
            val v = RemoteViews(context.packageName, R.layout.widget_moisture).apply {
                setTextViewText(R.id.batch, data.s("batch", "SISCAN"))
                setTextViewText(R.id.moisture, data.s("moisture"))
                setTextViewText(R.id.phase, data.s("phase", "Abre la app"))
                setTextViewText(R.id.target, data.s("target", ""))
                setProgressBar(R.id.progress, 100, data.getInt("progress", 0), false)
                setTextViewText(R.id.updated, data.s("updated", "Sin datos todavía"))
                setOnClickPendingIntent(R.id.root, open(context, "inicio"))
            }
            manager.updateAppWidget(id, v)
        }
    }
}

class BatchWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray, data: SharedPreferences) {
        for (id in ids) {
            val v = RemoteViews(context.packageName, R.layout.widget_batch).apply {
                setTextViewText(R.id.batch, data.s("batch", "SISCAN"))
                setTextViewText(R.id.variety, data.s("variety", "Secador de café"))
                setTextViewText(R.id.moisture, data.s("moisture") + " %")
                setTextViewText(R.id.temperature, data.s("temperature") + " °C")
                setTextViewText(R.id.remaining, data.s("remaining"))
                setTextViewText(R.id.updated, data.s("updated", "Sin datos todavía"))
                setOnClickPendingIntent(R.id.root, open(context, "inicio"))
            }
            manager.updateAppWidget(id, v)
        }
    }
}

class EquipmentWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray, data: SharedPreferences) {
        val fanId = data.getInt("fanId", -1)
        val fanOn = data.getBoolean("fanOn", false)
        for (id in ids) {
            val v = RemoteViews(context.packageName, R.layout.widget_equipment).apply {
                setTextViewText(R.id.title, "Equipo · " + data.s("batch", "SISCAN"))
                setInt(R.id.fan, "setBackgroundResource", if (fanOn) R.drawable.sc_tile_fan_on else R.drawable.sc_tile_fan_off)
                val fg = context.getColor(if (fanOn) R.color.sc_sobre_monte else R.color.sc_tierra)
                setTextColor(R.id.fan_name, fg)
                setTextColor(R.id.fan_state, fg)
                setTextViewText(R.id.fan_state, if (fanId < 0) "Sin ventilador" else if (fanOn) "Encendido" else "Apagado")
                setContentDescription(R.id.fan, "Ventilador " + (if (fanOn) "encendido. Toca para apagar" else "apagado. Toca para encender"))
                setTextViewText(R.id.updated, data.s("updated", "Sin datos todavía"))
                if (fanId >= 0) {
                    // Solo el ventilador cambia desde el widget (en segundo plano, con la sesión guardada en la app).
                    val uri = Uri.parse("siscan://fan?id=$fanId&on=${if (fanOn) 0 else 1}")
                    setOnClickPendingIntent(R.id.fan, HomeWidgetBackgroundIntent.getBroadcast(context, uri))
                }
                // La resistencia nunca se enciende desde un widget: abre Controles, que exige mantener presionado.
                setOnClickPendingIntent(R.id.heater, open(context, "controles"))
                setOnClickPendingIntent(R.id.title, open(context, "controles"))
            }
            manager.updateAppWidget(id, v)
        }
    }
}
