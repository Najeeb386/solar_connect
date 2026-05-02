@echo off
echo Temporarily modifying build.gradle for debug build...

REM Backup original build.gradle
copy android\app\build.gradle.kts android\app\build.gradle.kts.backup

REM Create a simplified build.gradle for testing
(
echo import java.util.Properties
echo import java.io.FileInputStream
echo.
echo plugins {
echo     id("com.android.application")
echo     id("kotlin-android")
echo     id("dev.flutter.flutter-gradle-plugin")
echo }
echo.
echo android {
echo     namespace = "com.solarpartner"
echo     compileSdk = 36
echo     ndkVersion = "28.2.13676358"
echo.
echo     compileOptions {
echo         sourceCompatibility = JavaVersion.VERSION_17
echo         targetCompatibility = JavaVersion.VERSION_17
echo     }
echo.
echo     kotlinOptions {
echo         jvmTarget = "17"
echo     }
echo.
echo     defaultConfig {
echo         applicationId = "com.solarpartner"
echo         minSdk = 24
echo         targetSdk = 36
echo         versionCode = 2
echo         versionName = "1.0.2"
echo     }
echo.
echo     buildTypes {
echo         debug {
echo             isMinifyEnabled = false
echo             isShrinkResources = false
echo         }
echo         release {
echo             isMinifyEnabled = false
echo             isShrinkResources = false
echo         }
echo     }
echo }
echo.
echo dependencies {
echo     implementation("com.google.android.play:app-update:2.1.0")
echo     implementation("com.google.android.play:review:2.0.1")
echo     implementation("com.google.android.play:asset-delivery:2.1.0")
echo     implementation("com.google.android.play:feature-delivery:2.1.0")
echo }
echo.
echo flutter {
echo     source = "../.."
echo }
) > android\app\build.gradle.kts

echo Building debug APK...
flutter build apk --debug

echo Restoring original build.gradle...
move android\app\build.gradle.kts.backup android\app\build.gradle.kts

echo Build complete!