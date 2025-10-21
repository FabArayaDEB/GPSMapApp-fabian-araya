# ProGuard/R8 rules for release builds
-keep class androidx.core.content.FileProvider { *; }
# Keep Google Play services classes used by Maps/Location
-keep class com.google.android.gms.** { *; }
# Keep SupportMapFragment and related
-keep class com.google.android.gms.maps.** { *; }