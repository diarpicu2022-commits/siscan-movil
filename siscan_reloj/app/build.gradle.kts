// SISCAN en el reloj (Wear OS) · sistema de diseño SISCAN v2 (07-smartwatch.md).
import java.util.Properties

// Llave de publicación FUERA del repositorio (la misma del teléfono). Sin ella se firma con la de depuración.
val keyProps = Properties().apply {
    val f = file("C:/dev/siscan-keys/key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "co.gov.narino.cisna.siscan.reloj"
    compileSdk = 37

    defaultConfig {
        // Mismo paquete y misma llave que la app del teléfono: la capa de datos de Wear OS solo conecta apps iguales.
        applicationId = "co.gov.narino.cisna.siscan"
        minSdk = 30
        targetSdk = 36
        versionCode = 2
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
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    buildFeatures { compose = true }
    lint { abortOnError = true }
}

kotlin { jvmToolchain(21) }

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.runtime.compose)
    implementation(platform(libs.compose.bom))
    implementation(libs.compose.ui)
    implementation(libs.coroutines.android)
    implementation(libs.wear.compose.material3)
    implementation(libs.wear.compose.foundation)
    implementation(libs.androidx.wear)
    implementation(libs.wear.tiles)
    implementation(libs.wear.protolayout)
    implementation(libs.wear.protolayout.expression)
    implementation(libs.wear.complications.data.source)
    implementation(libs.concurrent.futures)
    implementation(libs.play.services.wearable)
    implementation(libs.coroutines.play.services)
    testImplementation(libs.junit)
}
