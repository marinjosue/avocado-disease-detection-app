# Required by vosk_flutter_2 (offline speech recognition): the plugin talks
# to the native Vosk library through JNA, whose generated classes must be
# kept intact by R8/ProGuard in release builds.
-keep class com.sun.jna.* { *; }
-keepclassmembers class * extends com.sun.jna.* { public *; }
