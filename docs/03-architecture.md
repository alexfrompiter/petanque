# 03. Архитектура приложения

## Уровни (одинаковы для iOS и Android)

```
┌─────────────────────────────────────────────────────────────┐
│ UI Layer (SwiftUI / Jetpack Compose)                        │
│  • CameraView (полноэкранный preview)                       │
│  • OverlayView (слои: bbox, метки, дистанции, окружности)   │
│  • SettingsSheet, HintBanner, QualityIndicator              │
└──────────────────┬──────────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────────┐
│ Presentation / State (ViewModel)                            │
│  • SceneState: {balls[], cochonnet, distances[], quality}   │
│  • OverlaySettings (какие слои включены)                    │
│  • HintsEngine (правила подсказок по позиционированию)      │
└──────────────────┬──────────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────────┐
│ Domain                                                       │
│  • DistanceEstimator (AR-метод + геометрия-метод + fusion)  │
│  • SceneRanker (сортировка по дистанции к кошонету)         │
│  • Tracker (ID-стабилизация шаров между кадрами)            │
│  • QualityScorer (оценка надёжности измерения)              │
└──────┬──────────────────┬───────────────────────┬───────────┘
       │                  │                       │
┌──────▼──────┐  ┌────────▼────────┐  ┌───────────▼──────────┐
│ Detector    │  │ ARSession       │  │ Motion / Calibration │
│ (CoreML /   │  │ (ARKit /        │  │ (CoreMotion /        │
│  TFLite)    │  │  ARCore)        │  │  SensorManager)      │
└──────┬──────┘  └────────┬────────┘  └───────────┬──────────┘
       │                  │                       │
┌──────▼──────────────────▼───────────────────────▼───────────┐
│ Camera pipeline (AVFoundation / CameraX)                    │
│  • Кадры → детектор; intrinsics → AR; timestamps синхр.     │
└─────────────────────────────────────────────────────────────┘
```

## Поток данных (один кадр)

1. Камера выдаёт кадр (`CVPixelBuffer` / `Image`) + intrinsics.
2. Параллельно:
   - **Detector** прогоняет кадр через CoreML/TFLite модель → массив
     `Detection { class, bbox, score }`.
   - **ARSession** обновляет позу устройства и плоскости.
3. **Tracker** сопоставляет новые детекции с предыдущими ID (IoU + Kalman или
   ByteTrack).
4. Для каждой детекции **DistanceEstimator** вычисляет 3D-координату на
   плоскости земли:
   - Метод A (AR): берём точку основания bbox, делаем `raycast`/`hit-test` по
     горизонтальной плоскости → world coordinate.
   - Метод B (геометрия): из размера bbox в пикселях, фокусного расстояния,
     pitch и известного диаметра шара (74 мм) считаем дальность.
   - **Fusion**: если оба метода дают результат и они согласуются (Δ < 10%),
     берём AR; иначе помечаем измерение как «низкое доверие» и показываем
     худший индикатор качества.
5. **SceneRanker**: находит кошонет (класс `cochonnet`), считает евклидовы
   дистанции от каждого шара к нему по 3D-координатам на плоскости земли,
   сортирует.
6. **QualityScorer**: оценивает кадр (0–100) по:
   - углу наклона камеры (оптимум 30–55° к плоскости),
   - найден ли кошонет,
   - доле перекрытых шаров,
   - стабильности AR-плоскости.
7. **HintsEngine**: на основе оценки качества генерирует подсказку
   («опустите телефон ниже», «обойдите с другой стороны», …).
8. ViewModel публикует `SceneState`, UI перерисовывает оверлей.

## Модель данных (общий контракт, JSON-схема в `shared/schema/`)

```ts
type Detection = {
  id: string;            // стабильный ID от трекера
  cls: 'boule' | 'cochonnet';
  bbox: { x: number; y: number; w: number; h: number };  // в координатах кадра
  score: number;         // confidence детектора
};

type Position3D = { x: number; y: number; z: number };  // метры, frame: AR world

type BallMeasurement = {
  id: string;
  position: Position3D | null;        // null если не удалось локализовать
  distanceToCochonnet: { meters: number; confidence: 0..1 } | null;
  rank: number | null;                // 1 — ближайший
  method: 'ar' | 'geometry' | 'fusion';
};

type SceneState = {
  cochonnet: BallMeasurement | null;
  balls: BallMeasurement[];
  quality: { score: number; reasons: string[] };
  hint: string | null;
  frozen: boolean;       // снимок (заморозка) включён?
  timestamp: number;
};
```

## Слой оверлеев (визуал)

Каждый слой — независимый toggle в настройках:
- `bbox` — рамки вокруг шаров и кошонета.
- `labels` — номера (1, 2, 3…) + цвет команды (этап 2).
- `distances` — текст с дистанцией возле каждого шара.
- `lines` — линии от кошонета к каждому шару.
- `circles` — окружности на плоскости земли вокруг кошонета (радиусы:
  ближайший шар, ½×, 2× — настраивается).
- `arDebug` — точки фичей и плоскости ARKit/ARCore (для отладки).
- `quality` — индикатор и подсказка сверху.

Реализация: единый `OverlayView`, который читает `SceneState` и
`OverlaySettings` и рисует на `Canvas` (Compose) / `Canvas`-аналоге
(SwiftUI `Canvas`). 3D → 2D-проекция кругов делается через AR-камеру (для
правильной перспективы кругов на земле).

## Тестируемость

- **DistanceEstimator** — чистая функция от (детекции, intrinsics, поза,
  плоскость) → измерения. Покрывается unit-тестами с фиктивными сценами.
- **SceneRanker / Tracker / QualityScorer / HintsEngine** — чистые функции
  над структурами. Юнит-тесты.
- **End-to-end** — на наборе записанных сцен (`shared/calibration/`) с
  известными «правильными» дистанциями (рулетка). Прогон через офлайн-режим
  детектора на iOS и Android, сверка погрешности.
