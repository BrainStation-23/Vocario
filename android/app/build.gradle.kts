import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// Check for required files for production build
val keystoreFile = file("../@tanim2025__vocario-keystore.bak.jks")
val credentialsFile = file("../credentials.txt")

if (gradle.startParameter.taskNames.any { it.contains("Release") || it.contains("Bundle") }) {
    if (!keystoreFile.exists()) {
        throw GradleException(
            "ERROR: Keystore file not found at ${keystoreFile.absolutePath}\n" +
            "Please ensure '@tanim2025__vocario-keystore.bak.jks' exists in the android root directory."
        )
    }
    if (!credentialsFile.exists()) {
        throw GradleException(
            "ERROR: Credentials file not found at ${credentialsFile.absolutePath}\n" +
            "Please create 'credentials.txt' in the android root directory with keystore credentials."
        )
    }
}

val keystoreProperties = Properties()
if (credentialsFile.exists()) {
    val credentialsContent = credentialsFile.readText()
    val lines = credentialsContent.lines()
    
    for (line in lines) {
        if (line.startsWith("storePassword:")) {
            keystoreProperties["storePassword"] = line.substringAfter(":").trim()
        } else if (line.startsWith("keyPassword:")) {
            keystoreProperties["keyPassword"] = line.substringAfter(":").trim()
        } else if (line.startsWith("keyAlias:")) {
            keystoreProperties["keyAlias"] = line.substringAfter(":").trim()
        } else if (line.startsWith("storeFile:")) {
            keystoreProperties["storeFile"] = line.substringAfter(":").trim()
        }
    }
}

android {
    namespace = "com.brainstation23.vocario"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.brainstation23.vocario"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystoreFile.exists() && keystoreProperties.isNotEmpty()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreFile
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystoreFile.exists() && keystoreProperties.isNotEmpty()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
    }

    // Configure APK/AAB output file names
    applicationVariants.all {
        val variant = this
        variant.outputs.all {
            val output = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            if (variant.buildType.name == "release") {
                val versionCode = variant.versionCode
                output.outputFileName = "vocario_${versionCode}.apk"
            }
        }
    }

    // Post-build task to rename Flutter APK output
    tasks.whenTaskAdded {
        if (name == "assembleRelease") {
            doLast {
                val flutterApkDir = file("$buildDir/outputs/flutter-apk")
                val originalApk = file("$flutterApkDir/app-release.apk")
                if (originalApk.exists()) {
                    val versionCode = android.defaultConfig.versionCode
                    val renamedApk = file("$flutterApkDir/vocario_${versionCode}.apk")
                    originalApk.renameTo(renamedApk)
                    println("APK renamed to: vocario_${versionCode}.apk")
                }
            }
        }
        
        // Configure AAB output file names
        if (name == "bundleRelease") {
            doLast {
                val bundleFile = file("$buildDir/outputs/bundle/release/app-release.aab")
                if (bundleFile.exists()) {
                    val versionCode = android.defaultConfig.versionCode
                    val newBundleFile = file("$buildDir/outputs/bundle/release/vocario_${versionCode}.aab")
                    bundleFile.renameTo(newBundleFile)
                    println("AAB renamed to: vocario_${versionCode}.aab")
                }
            }
        }
    }
}

flutter {
    source = "../.."
}
