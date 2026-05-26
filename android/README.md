# Petanque — Android

Нативное Android-приложение проекта Petanque (см. корневой
[../README.md](../README.md) и [../docs/](../docs/)).

## Требования

- JDK 17+
- Android Studio Ladybug (2024.2) или новее
- Android SDK API 35; minSdk 28
- Реальное устройство для камеры (эмулятор покажет preview, но без AR на P2)

## Сборка

Из директории `android/`:

```bash
# первая установка — пусть Android Studio сам сгенерирует gradle-wrapper.jar
# (или: gradle wrapper, если у вас установлен системный Gradle)

./gradlew assembleDebug          # отладочная сборка APK
./gradlew installDebug           # установить на подключённое устройство
./gradlew test                   # юнит-тесты (JVM)
./gradlew connectedAndroidTest   # инструментальные тесты (нужно устройство/эмулятор)
```

> `gradle/wrapper/gradle-wrapper.jar` намеренно не закоммичен. Сгенерируйте
> его один раз через Android Studio (открытие проекта запросит download)
> либо командой `gradle wrapper --gradle-version 8.10.2`, если у вас стоит
> системный Gradle. После этого `./gradlew` будет работать сам.

## Структура

```
android/
├── settings.gradle.kts          — модули проекта
├── build.gradle.kts             — root build script (только plugin aliases)
├── gradle.properties            — глобальные настройки Gradle
├── gradle/
│   └── libs.versions.toml       — version catalog (источник истины для версий)
└── app/
    ├── build.gradle.kts         — конфиг app-модуля
    ├── proguard-rules.pro
    └── src/
        ├── main/
        │   ├── AndroidManifest.xml
        │   ├── kotlin/app/petanque/
        │   │   ├── PetanqueApplication.kt
        │   │   ├── MainActivity.kt
        │   │   ├── domain/         — SceneState, OverlaySettings, Detection…
        │   │   └── ui/
        │   │       ├── ContentScreen.kt
        │   │       ├── theme/      — Color/Theme/Type
        │   │       ├── camera/     — CameraX preview + permission flow
        │   │       └── overlay/    — Canvas-слой (заглушка на P0)
        │   └── res/                — strings, themes, backup rules
        └── test/kotlin/app/petanque/domain/
            └── SceneStateTest.kt   — Codable/serialization roundtrip
```

## Что сделано (P0)

- [x] Структура Gradle-проекта с version catalog.
- [x] Compose + CameraX preview задней камеры.
- [x] Запрос разрешения на камеру + экран отказа со ссылкой на настройки.
- [x] Доменные модели (`SceneState`, `OverlaySettings`) + JSON-сериализация.
- [x] Заглушка `OverlayLayer` поверх preview.
- [x] JVM-юнит-тесты на дефолты и serialization roundtrip.
- [ ] Детекция (P1).
- [ ] ARCore-сессия и оценка дистанций (P2).

См. [../docs/07-roadmap.md](../docs/07-roadmap.md).
