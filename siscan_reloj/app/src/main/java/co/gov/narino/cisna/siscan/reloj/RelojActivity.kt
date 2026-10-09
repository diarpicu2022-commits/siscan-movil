package co.gov.narino.cisna.siscan.reloj

import android.content.Context
import android.os.Bundle
import android.os.VibrationEffect
import android.os.VibratorManager
import android.provider.Settings
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.wear.compose.foundation.pager.HorizontalPager
import androidx.wear.compose.foundation.pager.rememberPagerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.wear.ambient.AmbientLifecycleObserver
import androidx.wear.compose.foundation.CurvedTextStyle
import androidx.wear.compose.material3.TimeText
import androidx.wear.compose.material3.timeTextCurvedText
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.time.LocalDateTime
import java.time.ZoneId

/** SISCAN en el reloj (sistema de diseño v2, 07-smartwatch.md): de un vistazo, ¿cómo va el grano, funciona el equipo, hay algo que revisar? */
class RelojActivity : ComponentActivity() {
    private var ambiente by mutableStateOf(false)
    private val observador = AmbientLifecycleObserver(this, object : AmbientLifecycleObserver.AmbientLifecycleCallback {
        override fun onEnterAmbient(ambientDetails: AmbientLifecycleObserver.AmbientDetails) { ambiente = true }
        override fun onExitAmbient() { ambiente = false }
    })

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        lifecycle.addObserver(observador)
        // Solo la variante de depuración acepta otro servidor (verificación con el servidor de prueba); la publicada, nunca.
        if (applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE != 0) intent?.getStringExtra("api")?.let { Red.api = it }
        setContent { SiscanReloj(ambiente) }
    }
}

/** Hora de Colombia: las lecturas del servidor vienen en esa hora y el secador está en Nariño. */
fun ahoraColombia(): LocalDateTime = LocalDateTime.now(ZoneId.of("America/Bogota"))

/** Vibración del sistema: un pulso para advertencia, doble para crítica, corto para confirmar. */
fun vibrar(c: Context, patron: LongArray) = runCatching {
    val v = if (android.os.Build.VERSION.SDK_INT >= 31) (c.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager).defaultVibrator
    else @Suppress("DEPRECATION") (c.getSystemService(Context.VIBRATOR_SERVICE) as android.os.Vibrator)
    v.vibrate(VibrationEffect.createWaveform(patron, -1))
}

private data class Confirmar(val titulo: String, val texto: String, val error: Boolean)

@Composable
fun SiscanReloj(ambiente: Boolean) {
    val c = LocalContext.current
    val sinMov = remember { Settings.Global.getFloat(c.contentResolver, Settings.Global.ANIMATOR_DURATION_SCALE, 1f) == 0f }
    var estado by remember { mutableStateOf(Guardado.leer(c)) }
    var fallo by remember { mutableStateOf(false) }
    var ahora by remember { mutableStateOf(ahoraColombia()) }
    var intento by remember { mutableIntStateOf(0) }
    var alertaVista by remember { mutableStateOf<String?>(null) }
    var confirmar by remember { mutableStateOf<Confirmar?>(null) }
    var pendiente by remember { mutableStateOf<Int?>(null) }
    var enviandoPesaje by remember { mutableStateOf(false) }
    val alcance = rememberCoroutineScope()
    // En la raíz: la página se conserva aunque una alerta o una confirmación tapen el carrusel.
    val pager = rememberPagerState { 6 }

    // Consulta al abrir y cada minuto; si falla, queda lo guardado con su hora (nunca se presenta como recién leído).
    LaunchedEffect(intento) {
        while (true) {
            ahora = ahoraColombia()
            runCatching { Red.respuestas() }
                .onSuccess { r -> estado = Red.estado(r, ahora); fallo = false; Guardado.guardar(c, r, ahora); Superficies.actualizar(c) }
                .onFailure { fallo = true; android.util.Log.w("SISCAN", "No se pudo leer el secador", it) }
            delay(60_000)
        }
    }

    CompositionLocalProvider(LocalSinMovimiento provides (sinMov || ambiente)) {
        val e = estado
        if (ambiente) { Ambiente(e, ahora); return@CompositionLocalProvider }
        confirmar?.let { k -> Confirmacion(k.titulo, k.texto, k.error) { confirmar = null }; return@CompositionLocalProvider }
        if (e == null) { if (fallo) SinDatos { intento++ } else Cargando(); return@CompositionLocalProvider }

        val alerta = e.alerta?.takeIf { it.clave != alertaVista && !Guardado.descartada(c, it.clave) }
        if (alerta != null) {
            LaunchedEffect(alerta.clave) { vibrar(c, if (alerta.critica) longArrayOf(0, 180, 120, 180) else longArrayOf(0, 220)) }
            Alerta(alerta, onDescartar = { Guardado.descartar(c, alerta.clave); alertaVista = alerta.clave },
                onVer = { Guardado.descartar(c, alerta.clave); alertaVista = alerta.clave; alcance.launch { pager.scrollToPage(if (alerta.icono == "ventilador") 2 else 1) } })
            return@CompositionLocalProvider
        }

        fun resultado(r: Telefono.Resultado, ok: String) {
            confirmar = when (r) {
                is Telefono.Resultado.Hecho -> { vibrar(c, longArrayOf(0, 60)); Confirmar(ok, r.texto, false) }
                is Telefono.Resultado.Fallo -> Confirmar("No se envió", r.texto, true)
            }
            intento++
        }

        Esfera {
            HorizontalPager(pager, Modifier.fillMaxSize()) { i ->
                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    when (i) {
                        0 -> Monitoreo(e, ahora)
                        1 -> Lecturas(e, pager.currentPage == 1)
                        2 -> Equipo(e, pager.currentPage == 2, pendiente,
                            onOrden = { a, on ->
                                pendiente = a.id
                                alcance.launch {
                                    val r = Telefono.actuador(c, a.id, on)
                                    pendiente = null
                                    resultado(r, if (on) "${a.nombre} encendido" else "${a.nombre} apagado")
                                }
                            },
                            aviso = { t -> confirmar = Confirmar("Mantén presionado", "$t una resistencia: es una orden de riesgo.", true) })
                        3 -> Prediccion(e)
                        4 -> Lotes(e, pager.currentPage == 4)
                        else -> Pesaje(e, pager.currentPage == 5, enviandoPesaje) { g ->
                            enviandoPesaje = true
                            alcance.launch {
                                val r = Telefono.pesaje(c, e.loteId!!, g)
                                enviandoPesaje = false
                                resultado(r, "Pesaje registrado")
                            }
                        }
                    }
                }
            }
            // Hora curva en el borde superior (.sc-wtime), sin fondo; el arco de progreso deja libre la parte de arriba.
            // Sin indicador de páginas: el borde inferior es del arco; se navega deslizando entre tarjetas y con la corona.
            TimeText(backgroundColor = Color.Transparent) { t -> timeTextCurvedText(t, CurvedTextStyle(estiloHora)) }
        }
    }
}

