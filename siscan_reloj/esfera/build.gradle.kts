// Esfera SISCAN (WatchFace del sistema de diseño v2) en Watch Face Format: solo recursos, sin código.
// Los recursos los genera tools/generar_esfera.py.
import java.util.Properties

val keyProps = Properties().apply {
    val f = file("C:/dev/siscan-keys/key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

plugins {
    alias(libs.plugins.android.application)
}

android {
    namespace = "co.gov.narino.cisna.siscan.esfera"
    compileSdk = 37

    defaultConfig {
        applicationId = "co.gov.narino.cisna.siscan.esfera"
        // Watch Face Format v2: Wear OS 5 (API 34) o posterior.
        minSdk = 34
        targetSdk = 36
        versionCode = 1
        versionName = "0.2.0"
    }

    signingConfigs {
        if (keyProps.containsKey("storeFile")) {
            create("release") {
                storeFile = file(keyProps.getProperty("storeFile"))
                storePassword = keyProps.getProperty("storePassword")
                keyAlias = keyProps.getProperty("keyAlias")
                keyPassword = keyProps.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfigs.findByName("release")?.let { signingConfig = it }
            isMinifyEnabled = false
        }
    }
}
