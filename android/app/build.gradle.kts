plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.aplication_tesis"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.aplication_tesis"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // flutter.minSdkVersion (24) satisfies both sherpa_onnx (minSdk 21) and
        // flutter_gemma (minSdk 24); no override needed after removing vosk_flutter_2.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Qualcomm QNN / NPU acceleration libraries (libQnn*.so,
    // libLiteRtDispatch_Qualcomm.so) ship prebuilt at 4 KB page alignment and
    // would FAIL Google Play's 16 KB page-size requirement. We do not use the
    // Qualcomm NPU dispatch path — on-device Gemma runs on GPU (OpenCL) / CPU
    // via LiteRT, which falls back gracefully when these are absent. Excluding
    // them keeps every packaged .so 16 KB-aligned.
    packaging {
        jniLibs {
            excludes += listOf(
                "**/libQnn*.so",
                "**/libLiteRtDispatch_Qualcomm.so",
            )
        }
    }
}

flutter {
    source = "../.."
}
