// Корневой Gradle-файл. Плагины объявляются здесь с `apply false`, а
// подключаются в модулях. Все версии — через `gradle/libs.versions.toml`.
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.kotlin.serialization) apply false
    alias(libs.plugins.kotlin.compose) apply false
}
