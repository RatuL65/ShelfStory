plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ADD THIS LINE
}

android {
    namespace = "com.example.shelf_story"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.shelf_story"
        minSdk = flutter.minSdkVersion  // CHANGED: Increased from flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // ADD THIS LINE
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    
    // Firebase Auth
    implementation("com.google.firebase:firebase-auth")
    
    // Google Play Services Auth (for Google Sign-In)
    implementation("com.google.android.gms:play-services-auth:21.2.0")
    
    // MultiDex support
    implementation("androidx.multidex:multidex:2.0.1")
}
