# kotlinx.serialization — оставляем сгенерированные сериализаторы.
-keep,includedescriptorclasses class app.petanque.**$$serializer { *; }
-keepclassmembers class app.petanque.** {
    *** Companion;
}
-keepclasseswithmembers class app.petanque.** {
    kotlinx.serialization.KSerializer serializer(...);
}
