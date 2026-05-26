# 02. Технологический стек

## Резюме выбора (рекомендация)

| Слой | Выбор | Причина |
|---|---|---|
| Платформы | **Native iOS (Swift) + Native Android (Kotlin)** | AR-функциональность и работа с камерой/IMU — самая «горячая» часть. Нативный путь даёт прямой доступ к ARKit/ARCore, LiDAR, CoreML, NNAPI без прослоек. |
| UI iOS | SwiftUI + UIKit (где надо) | Современный декларативный UI, легко строить настраиваемый оверлей. |
| UI Android | Jetpack Compose | Аналог SwiftUI, declarative overlay. |
| Камера + кадры | iOS: `AVFoundation` + `ARKit`. Android: `CameraX` + `ARCore` | Прямой доступ к буферам, синхронизация с IMU. |
| AR / 3D-геометрия | **ARKit** (iOS) / **ARCore** (Android) | Плоскость земли, hit-test, world coordinates. Базовый источник дистанции. |
| LiDAR (опционально) | ARKit Scene Reconstruction (iPhone Pro/iPad Pro) | Если есть — повышаем точность. Не обязательный. |
| ML-инференс | iOS: **CoreML** (через `Vision`). Android: **TFLite** + NNAPI/GPU delegate | Аппаратное ускорение, минимум зависимостей. |
| Модель детекции | **YOLOv8n / YOLOv11n** (или RT-DETR-small), кастомно обученная на 2 класса: `boule`, `cochonnet` | Лёгкая, быстрая, проверенная на mobile. Экспорт в CoreML и TFLite из единого PyTorch-чекпойнта. |
| Tracker (между кадрами) | ByteTrack или встроенный Vision/MLKit object tracker | Стабильная нумерация шаров между кадрами, без «прыжков». |
| Sensor fusion | CoreMotion (iOS), SensorManager (Android) | Угол наклона камеры (pitch) для геометрической оценки. |
| Хранилище (этап 2) | SQLite (через GRDB на iOS / Room на Android) | Локальная история партий. |
| CI | GitHub Actions (lint + unit-тесты на оба проекта; на этапе 2 — TestFlight/Internal track) | Стандартно. |

## Почему не cross-platform (RN/Flutter)?

**Плюсы cross-platform.** Одна кодовая база на TypeScript/Dart, быстрее MVP
для обычных CRUD-приложений.

**Минусы для нашей задачи.**
1. AR в RN и Flutter — это всегда обёртка над нативом, и обёртки исторически
   отстают по фичам и иногда ломаются на новых версиях OS.
2. Передача каждого кадра камеры через JS/Dart-мост — узкое место.
   `react-native-vision-camera` решает это через worklets, но всё равно
   архитектура усложняется.
3. CoreML и TFLite всё равно вызываются нативно — приходится писать нативный
   код по сути на обеих сторонах, и вы получаете worst-of-both.
4. UI этого приложения простой (камера на весь экран + оверлей). Главный плюс
   cross-platform (быстро рисовать кучу экранов) тут не реализуется.

**Когда пересмотреть.** Если выяснится, что одна команда тянет только один
язык, можно перейти на Flutter + ar_flutter_plugin для прототипа и нативные
платформенные каналы для CV — но MVP всё равно потребует нативного кода.

## Версии и инструменты (на момент 2026-05)

- iOS: Xcode 16+, Swift 6, iOS 17+ (требуется для современного ARKit API).
- Android: Android Studio Ladybug+, Kotlin 2.x, minSdk 28 (Android 9,
  требование ARCore), targetSdk 35.
- PyTorch для обучения моделей, `ultralytics` для YOLO,
  `coremltools` + `tflite` для экспорта.

## Структура репозитория (предлагаемая)

```
petanque/
├── README.md
├── docs/                       # вся проектная документация
├── ios/                        # Xcode-проект (App + AR + CoreML)
│   └── Petanque/
├── android/                    # Gradle-проект (App + AR + TFLite)
│   └── app/
├── ml/                         # обучение моделей и экспорт
│   ├── data/                   # симлинки/инструкции к датасету (сам датасет вне репо)
│   ├── train/                  # скрипты обучения
│   ├── export/                 # CoreML/TFLite экспорт
│   └── models/                 # готовые веса (через Git LFS либо releases)
├── shared/                     # общие артефакты
│   ├── schema/                 # JSON-схемы (history, settings)
│   └── calibration/            # эталонные изображения, тестовые сцены
└── .github/workflows/
```

`ios/` и `android/` — независимые приложения, делят только спецификации,
ML-веса и набор тестовых данных через `shared/` и `ml/models/`.
