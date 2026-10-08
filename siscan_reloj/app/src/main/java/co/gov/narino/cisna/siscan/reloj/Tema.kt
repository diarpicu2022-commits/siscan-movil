package co.gov.narino.cisna.siscan.reloj

import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontVariation
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.sp

/**
 * Colores de SISCAN en el reloj. Claro = tema «Día» del sistema (pergamino, papel, arena, tierra…).
 * Oscuro = derivado del bloque de identidad `monte` (decisión de Diego 2026-10-08: «derivarlo de cada sistema»):
 * fondo monte muy oscuro, tintas `sobre-monte`, acentos aclarados para pasar AA sobre el fondo oscuro.
 */
@Immutable
data class Paleta(
    val fondo: Color, val superficie: Color, val superficieFuerte: Color, val linea: Color,
    val tinta: Color, val tintaSuave: Color, val agua: Color, val cafeto: Color, val sol: Color,
    val oxido: Color, val panela: Color, val oscuro: Boolean,
)

val Claro = Paleta(
    fondo = Color(0xFFF3EADA), superficie = Color(0xFFFBF6EC), superficieFuerte = Color(0xFFEADFCB), linea = Color(0xFFD9C8AC),
    tinta = Color(0xFF2B1E15), tintaSuave = Color(0xFF66523F), agua = Color(0xFF3E7F92), cafeto = Color(0xFF2F6A3C),
    sol = Color(0xFFE9B44C), oxido = Color(0xFF8C2A1F), panela = Color(0xFF8A5700), oscuro = false,
)

val Oscuro = Paleta(
    fondo = Color(0xFF0F1F15), superficie = Color(0xFF1B3524), superficieFuerte = Color(0xFF24452F), linea = Color(0xFF3A5A44),
    tinta = Color(0xFFF3EADA), tintaSuave = Color(0xFFB9C9B4), agua = Color(0xFF8CC3D3), cafeto = Color(0xFF8FD19E),
    sol = Color(0xFFE9B44C), oxido = Color(0xFFF2A193), panela = Color(0xFFF0C46A), oscuro = true,
)

val LocalPaleta = staticCompositionLocalOf { Oscuro }

private fun fraunces(peso: Int) = Font(R.font.fraunces, FontWeight(peso), variationSettings = FontVariation.Settings(FontVariation.weight(peso)))
val Fraunces = FontFamily(fraunces(600))
val Atkinson = FontFamily(Font(R.font.atkinson_500, FontWeight(500)), Font(R.font.atkinson_700, FontWeight(700)))
val AtkinsonMono = FontFamily(Font(R.font.atkinson_mono_500, FontWeight(500)))

/** Tipos del sistema SISCAN adaptados a la esfera: la cifra en Atkinson Mono es lo más grande. */
object Tipo {
    val lectura = TextStyle(fontFamily = AtkinsonMono, fontWeight = FontWeight(500), fontSize = 40.sp, lineHeight = 42.sp, textAlign = TextAlign.Center, letterSpacing = (-0.5).sp)
    val unidad = TextStyle(fontFamily = AtkinsonMono, fontWeight = FontWeight(500), fontSize = 18.sp, lineHeight = 22.sp)
    val nombre = TextStyle(fontFamily = Fraunces, fontWeight = FontWeight(600), fontSize = 18.sp, lineHeight = 22.sp, textAlign = TextAlign.Center)
    val apoyo = TextStyle(fontFamily = Atkinson, fontWeight = FontWeight(500), fontSize = 15.sp, lineHeight = 19.sp, textAlign = TextAlign.Center)
    val rotulo = TextStyle(fontFamily = Atkinson, fontWeight = FontWeight(700), fontSize = 13.sp, lineHeight = 16.sp, letterSpacing = 1.2.sp, textAlign = TextAlign.Center)
    val dato = TextStyle(fontFamily = AtkinsonMono, fontWeight = FontWeight(500), fontSize = 15.sp, lineHeight = 19.sp)
}
