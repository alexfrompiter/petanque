package app.petanque.ui.overlay

import androidx.compose.foundation.Canvas
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import app.petanque.domain.OverlaySettings
import app.petanque.domain.SceneState

/// Слой оверлея. На P0 — рисует bbox по детекциям, если они есть в state.
/// Реальные слои `labels`/`distances`/`lines`/`circles` появятся на P1–P4.
@Composable
fun OverlayLayer(
    state: SceneState,
    settings: OverlaySettings,
    modifier: Modifier = Modifier,
) {
    Canvas(modifier = modifier) {
        if (!settings.showBBox) return@Canvas

        val w = size.width
        val h = size.height

        for (ball in state.balls) {
            val color = if (ball.rank == 1) Color(0xFF4CAF50) else Color.White
            drawBBox(ball.detection.bbox.toOffset(w, h), ball.detection.bbox.toSize(w, h), color)
        }

        state.cochonnet?.let { coch ->
            drawBBox(coch.detection.bbox.toOffset(w, h), coch.detection.bbox.toSize(w, h), Color(0xFFE8C24A))
        }
    }
}

private fun androidx.compose.ui.graphics.drawscope.DrawScope.drawBBox(
    topLeft: Offset, size: Size, color: Color
) {
    drawRect(color = color, topLeft = topLeft, size = size, style = Stroke(width = 4f))
}

private fun app.petanque.domain.BBox.toOffset(w: Float, h: Float) = Offset(x * w, y * h)
private fun app.petanque.domain.BBox.toSize(w: Float, h: Float) = Size(this.w * w, this.h * h)
