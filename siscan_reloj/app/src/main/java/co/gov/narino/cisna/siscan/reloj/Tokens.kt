// GENERADO por tools/generar_reloj.py desde tokens.json del sistema de diseño SISCAN v2. No editar a mano.
package co.gov.narino.cisna.siscan.reloj

import androidx.compose.ui.graphics.Color

/** Colores del tema oscuro: el reloj va siempre en oscuro sobre negro (07-smartwatch.md). */
object Sc {
    /** Fondo de la página, detrás de las tarjetas. */
    val fondo = Color(0xFF0F1D16)
    /** Tarjetas, paneles, tablas y hojas del móvil. */
    val superficie = Color(0xFF172A20)
    /** Tarjetas con tinte verde: lote activo, estados en operación, resúmenes. */
    val superficieHoja = Color(0xFF1C3426)
    /** Campos en reposo, pistas de barras y anillos, filas seleccionadas. */
    val superficieFuerte = Color(0xFF24402F)
    /** Bordes de tarjeta y divisores. */
    val linea = Color(0xFF2C4636)
    /** Borde de controles (campo, interruptor apagado); 3:1 sobre fondo y superficie. */
    val lineaFuerte = Color(0xFF71897A)
    /** Texto principal y lecturas, sobre fondo, superficie, superficie-hoja y superficie-fuerte. */
    val tinta = Color(0xFFEEF3EA)
    /** Texto secundario, unidades, metadatos; sobre las mismas superficies. */
    val tintaSuave = Color(0xFFA9BDAE)
    /** Texto y controles deshabilitados (no informativo). */
    val deshabilitado = Color(0xFF4C6052)
    /** Barra lateral, encabezados oscuros y fondo del reloj. Texto encima: sobre-bosque. */
    val bosque = Color(0xFF0B1711)
    /** Parte baja del degradado de la barra lateral y de los encabezados móviles. */
    val bosqueHondo = Color(0xFF07110C)
    /** Texto e íconos sobre bosque y salvia. */
    val sobreBosque = Color(0xFFEEF3EA)
    /** Texto secundario sobre bosque (ítems de menú inactivos). */
    val sobreBosqueSuave = Color(0xFF93A99A)
    /** El verde salvia del ítem activo del menú y de la barra Android; texto sobre-bosque encima. */
    val salvia = Color(0xFF4F6E47)
    /** Segundo tono del degradado del ítem activo. Solo relleno. */
    val salviaClara = Color(0xFF6A8A5F)
    /** El verde del wordmark SISCAN: títulos de marca y enlaces. Como texto, sobre fondo, superficie y superficie-hoja. */
    val marca = Color(0xFF8FD19E)
    /** Primario de acción: botón principal, interruptor encendido, FAB. Como texto, sobre fondo y superficie. */
    val hoja = Color(0xFF6CC387)
    /** Texto sobre relleno hoja. */
    val sobreHoja = Color(0xFF0F1D16)
    /** El verde vivo de las curvas y puntos del panel aprobado: humedad de cámara, línea de progreso. Como texto, sobre fondo y superficie. */
    val esmeralda = Color(0xFF5FD08F)
    /** Fondo de chips y etiquetas verdes; detrás de texto marca u hoja. */
    val brote = Color(0xFF264A2C)
    /** El verde claro de las barras de energía y los puntos «En vivo». Solo relleno, nunca texto. */
    val broteVivo = Color(0xFFA6D07A)
    /** Las hojas lima del logo: extremo del degradado de progreso y destellos. Solo relleno. */
    val lima = Color(0xFFB7D65A)
    /** El grano del logo: humedad del grano, lotes, pesajes. Como texto, sobre fondo, superficie y cafe-suave. */
    val cafe = Color(0xFFD2A07A)
    /** Fondo teñido detrás de texto cafe. */
    val cafeSuave = Color(0xFF3A271C)
    /** Color del café pergamino seco: escala de humedad en objetivo. Solo relleno. */
    val pergamino = Color(0xFFD8B47C)
    /** Temperaturas (interior, tope, exterior). Como texto, sobre fondo y superficie. */
    val datoTemperatura = Color(0xFFF08A5D)
    /** Humedad relativa interior. */
    val datoHumedad = Color(0xFF5FD08F)
    /** Clima y humedad exterior; energía de la red eléctrica. */
    val datoExterior = Color(0xFF8AB4EF)
    /** Humedad del grano. */
    val datoGrano = Color(0xFFD2A07A)
    /** Energía solar y radiación, como texto, sobre fondo y superficie. */
    val datoSolar = Color(0xFFB7D65A)
    /** Barras de energía solar, como en el panel aprobado. */
    val datoSolarRelleno = Color(0xFFA6D07A)
    /** Barras de energía de la red eléctrica. */
    val datoElectrica = Color(0xFF8AB4EF)
    /** Banda y línea discontinua del objetivo de humedad (10 – 12 %). Solo líneas y rellenos. */
    val objetivo = Color(0xFFE3BF5A)
    /** Tramo predicho por la IA en la curva (línea punteada) y su chip. Como texto, sobre fondo y superficie. */
    val prediccion = Color(0xFFB3A8F0)
    /** En operación, dentro de rango, encendido. Siempre con punto y palabra. */
    val operando = Color(0xFF5FD08F)
    /** Fondo de la píldora En operación. */
    val operandoSuave = Color(0xFF173B27)
    /** En pausa, advertencia. Siempre con ícono y palabra. */
    val pausa = Color(0xFFF1B450)
    /** Fondo de la píldora En pausa y de advertencias. */
    val pausaSuave = Color(0xFF3E2C0F)
    /** Crítico: temperatura alta, sensor caído. Siempre con ícono y palabra. */
    val alerta = Color(0xFFFF8E80)
    /** Fondo de la píldora Alerta. */
    val alertaSuave = Color(0xFF45201C)
    /** Sin conexión: el secador no reporta. Gris, nunca rojo. */
    val fuera = Color(0xFF9AA5A0)
    /** Fondo de la píldora Sin conexión. */
    val fueraSuave = Color(0xFF26302B)
    /** Información contextual y enlaces de ayuda. */
    val info = Color(0xFF8AB4EF)
}

/** Duraciones del sistema (ms). */
object ScDur {
    const val rapida = 160
    const val media = 320
    const val lenta = 900
    const val ventilador = 1400
    const val aire = 2600
    const val latido = 2000
}

/** Medidas del reloj: la esfera de la documentación (224 px) equivale a la pantalla; toque mínimo 48. */
object ScReloj {
    const val ESFERA = 224.0f
    const val TOQUE = 48.0f
}
