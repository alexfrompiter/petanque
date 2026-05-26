# Petanque — iOS

Нативное iOS-приложение проекта Petanque (см. корневой
[../README.md](../README.md) и [../docs/](../docs/)).

## Требования

- macOS 14+
- Xcode 16+
- iOS 17+ устройство **или** симулятор (для камеры/AR — только устройство)
- [XcodeGen](https://github.com/yonoz/XcodeGen) — для генерации
  `.xcodeproj` из `project.yml`

Установка XcodeGen:

```bash
brew install xcodegen
```

## Сборка

```bash
cd ios
xcodegen generate   # создаст Petanque.xcodeproj из project.yml
open Petanque.xcodeproj
```

Дальше — обычный flow Xcode: выбрать симулятор/устройство, ⌘R.

> `Petanque.xcodeproj` находится в `.gitignore` — он генерируется из
> `project.yml`. Если меняешь структуру файлов (добавляешь/убираешь
> исходники) — просто перегенерируй проект.

## Структура

```
ios/
├── project.yml                  — спецификация Xcode-проекта (источник истины)
├── Petanque/
│   ├── Info.plist               — usage descriptions, supported orientations
│   ├── App/
│   │   ├── PetanqueApp.swift    — @main
│   │   └── ContentView.swift    — корневой view
│   ├── Features/
│   │   └── Camera/              — AVFoundation pipeline + preview
│   │       ├── CameraView.swift
│   │       ├── CameraPreviewView.swift
│   │       └── CameraSession.swift
│   ├── Overlay/                 — слой подсветки (заглушка на P0)
│   │   └── OverlayView.swift
│   ├── Domain/                  — модели предметной области
│   │   ├── SceneState.swift
│   │   └── OverlaySettings.swift
│   └── Resources/
│       └── Assets.xcassets/     — иконки и цвета
└── PetanqueTests/               — unit-тесты
    └── SceneStateTests.swift
```

## Запуск тестов

```bash
xcodebuild test \
  -project Petanque.xcodeproj \
  -scheme Petanque \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Что сделано (P0)

- [x] Скелет проекта через XcodeGen.
- [x] Заглушка камеры (AVFoundation preview).
- [x] Пустой OverlayView поверх preview.
- [x] Доменные модели `SceneState`, `OverlaySettings`.
- [x] Запрос разрешения на камеру через `NSCameraUsageDescription`.
- [ ] Детекция (P1).
- [ ] AR-сессия и оценка дистанций (P2).

См. [../docs/07-roadmap.md](../docs/07-roadmap.md).
