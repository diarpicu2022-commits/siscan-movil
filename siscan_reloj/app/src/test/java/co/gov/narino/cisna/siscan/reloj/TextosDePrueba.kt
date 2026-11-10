package co.gov.narino.cisna.siscan.reloj

import java.io.File

/** Carga en Textos los textos en español de values/strings.xml, para las pruebas en la JVM (sin recursos de Android). */
object TextosDePrueba {
    fun cargar() {
        val xml = File("src/main/res/values/strings.xml").readText()
        val mapa = Regex("""<string name="(\w+)"[^>]*>(.*?)</string>""").findAll(xml).mapNotNull { m ->
            val id = runCatching { R.string::class.java.getField(m.groupValues[1]).getInt(null) }.getOrNull() ?: return@mapNotNull null
            id to m.groupValues[2].replace("\\'", "'").replace("\\\"", "\"").replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">")
        }.toMap()
        Textos.respaldo = mapa
    }
}
