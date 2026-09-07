# ============================================================
# ML Kit Text Recognition — mantem so o alfabeto latino.
# O plugin referencia reconhecedores de outros scripts (chines,
# japones, coreano, devanagari) que NAO incluimos no app. O R8
# aborta ao ver essas classes ausentes; estas regras dizem para
# ele ignora-las com seguranca.
# ============================================================
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Preserva as classes do ML Kit efetivamente usadas (latino).
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
