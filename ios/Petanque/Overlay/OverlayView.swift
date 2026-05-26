import SwiftUI

/// Заглушка слоя оверлея. На P0 — рисует только пустой Canvas + (опц.)
/// прямоугольники по детекциям (пока их нет, остаётся пустым).
///
/// Реальная отрисовка bbox / labels / distances / lines / circles появится
/// на P1–P4. Сейчас структура нужна, чтобы зафиксировать контракт «UI зависит
/// от SceneState + OverlaySettings».
struct OverlayView: View {
    let state: SceneState
    let settings: OverlaySettings

    var body: some View {
        Canvas { ctx, size in
            guard settings.showBBox else { return }

            for ball in state.balls {
                let rect = scale(ball.detection.bbox, to: size)
                let color: Color = (ball.rank == 1) ? .green : .white
                ctx.stroke(
                    Path(roundedRect: rect, cornerRadius: 4),
                    with: .color(color),
                    lineWidth: 2
                )
            }

            if let coch = state.cochonnet {
                let rect = scale(coch.detection.bbox, to: size)
                ctx.stroke(
                    Path(roundedRect: rect, cornerRadius: 4),
                    with: .color(.yellow),
                    lineWidth: 2
                )
            }
        }
    }

    private func scale(_ bbox: CGRect, to size: CGSize) -> CGRect {
        // На P0 bbox ещё не приходят, но как только начнут — здесь будет
        // правильное преобразование из координат кадра детектора в координаты
        // экрана с учётом resizeAspectFill preview-layer.
        CGRect(
            x: bbox.origin.x * size.width,
            y: bbox.origin.y * size.height,
            width: bbox.size.width * size.width,
            height: bbox.size.height * size.height
        )
    }
}
