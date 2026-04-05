# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile, LineNumberTable

-dontwarn io.flutter.**
-dontwarn kotlinx.**