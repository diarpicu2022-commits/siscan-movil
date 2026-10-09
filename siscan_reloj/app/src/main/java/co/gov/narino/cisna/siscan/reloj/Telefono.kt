package co.gov.narino.cisna.siscan.reloj

import android.content.Context
import com.google.android.gms.wearable.CapabilityClient
import com.google.android.gms.wearable.Wearable
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withTimeout
import org.json.JSONObject

/**
 * Órdenes y pesajes desde el reloj (decisión de Diego: «por el teléfono con sesión»). El reloj no guarda credenciales:
 * le pide la acción a SISCAN en el teléfono por la capa de datos de Wear OS; el teléfono la envía al servidor con la
 * sesión de quien ingresó y devuelve el resultado. Sin teléfono o sin sesión, el reloj lo dice y no hace nada.
 */
object Telefono {
    const val CAPACIDAD = "siscan_puente"
    const val RUTA = "/siscan/orden"

    sealed interface Resultado {
        data class Hecho(val texto: String) : Resultado
        data class Fallo(val texto: String) : Resultado
    }

    private suspend fun pedir(c: Context, cuerpo: JSONObject): Resultado = runCatching {
        withTimeout(25_000) {
            val nodos = Wearable.getCapabilityClient(c).getCapability(CAPACIDAD, CapabilityClient.FILTER_REACHABLE).await().nodes
            val nodo = nodos.firstOrNull { it.isNearby } ?: nodos.firstOrNull()
                ?: return@withTimeout Resultado.Fallo("El teléfono no está cerca o no tiene SISCAN abierto.")
            val r = JSONObject(String(Wearable.getMessageClient(c).sendRequest(nodo.id, RUTA, cuerpo.toString().toByteArray()).await()))
            if (r.optBoolean("ok")) Resultado.Hecho(r.optString("texto")) else Resultado.Fallo(r.optString("texto", "No se pudo enviar."))
        }
    }.getOrElse { Resultado.Fallo("No hubo respuesta del teléfono. Revisa la conexión del reloj.") }

    suspend fun actuador(c: Context, id: Int, encender: Boolean): Resultado =
        pedir(c, JSONObject().put("tipo", "actuador").put("id", id).put("on", encender))

    suspend fun pesaje(c: Context, lote: Int, gramos: Double): Resultado =
        pedir(c, JSONObject().put("tipo", "pesaje").put("lote", lote).put("gramos", gramos))
}
