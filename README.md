# Petanque distance — мобильное приложение

Мобильное приложение для iOS и Android, которое с камеры телефона в реальном
времени распознаёт шары петанка и кошонет, считает расстояния от кошонета до
шаров и подсказывает, какой шар ближе.

## Документация проекта

Проект на этапе планирования. Все проектные решения и план — в `docs/`:

| Документ | О чём |
|---|---|
| [docs/01-vision-and-requirements.md](docs/01-vision-and-requirements.md) | Видение, сценарии, функциональные и нефункциональные требования |
| [docs/02-tech-stack.md](docs/02-tech-stack.md) | Выбор технологий и обоснование (Native iOS+Android, ARKit/ARCore, CoreML/TFLite, YOLOv8) |
| [docs/03-architecture.md](docs/03-architecture.md) | Слои приложения, поток данных, модель `SceneState` |
| [docs/04-distance-estimation.md](docs/04-distance-estimation.md) | Три метода измерения дистанции и стратегия fusion |
| [docs/05-ml-pipeline.md](docs/05-ml-pipeline.md) | Датасет, обучение модели, экспорт в CoreML/TFLite |
| [docs/06-ui-overlays.md](docs/06-ui-overlays.md) | UI, слои оверлея, настройки, доступность |
| [docs/07-roadmap.md](docs/07-roadmap.md) | Поэтапный план (P0–P7) с критериями выхода |

## Краткая суть

- **Платформы:** нативные приложения для iOS (Swift, SwiftUI, ARKit, CoreML)
  и Android (Kotlin, Compose, ARCore, TFLite).
- **Детекция:** YOLOv8n, обученная на 2 класса (`boule`, `cochonnet`).
- **Дистанция:** комбинация AR-плоскости + геометрии по известному диаметру
  шара (74 мм) + IMU-наклон камеры; LiDAR если есть.
- **UI:** полноэкранный preview камеры с настраиваемыми оверлеями (bbox,
  номера, дистанции, линии, окружности), индикатор качества и подсказки по
  позиционированию.

## Структура репозитория

```
ios/         — Xcode-проект (Swift + SwiftUI + ARKit + CoreML).         ← P0 готов
android/     — Gradle-проект (Kotlin + Compose + ARCore + TFLite).      ← P0 готов
ml/          — обучение моделей и экспорт. TODO
shared/      — JSON-схемы и калибровочные сцены.
docs/        — вся проектная документация.
```

## Статус

- ✅ **P0 (iOS)** — скелет приложения, AVFoundation preview, доменные модели,
  тесты, схема `SceneState`. См. [ios/README.md](ios/README.md) для запуска.
- ✅ **P0 (Android)** — Gradle-проект с Compose + CameraX preview, домен на
  kotlinx.serialization, JVM-тесты. См. [android/README.md](android/README.md).
- ⏳ **P1** — детекция шаров через CoreML/TFLite.

См. полный план в [docs/07-roadmap.md](docs/07-roadmap.md).
