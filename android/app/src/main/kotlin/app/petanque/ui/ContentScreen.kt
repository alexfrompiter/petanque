package app.petanque.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.layout.weight
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import app.petanque.domain.OverlaySettings
import app.petanque.domain.SceneState
import app.petanque.ui.camera.CameraView
import app.petanque.ui.overlay.OverlayLayer

@Composable
fun ContentScreen() {
    val settings by remember { mutableStateOf(OverlaySettings.Default) }
    val state by remember { mutableStateOf(SceneState.Empty) }

    Box(modifier = Modifier.fillMaxSize().background(Color.Black)) {
        CameraView(modifier = Modifier.fillMaxSize())
        OverlayLayer(state = state, settings = settings, modifier = Modifier.fillMaxSize())

        Column(
            modifier = Modifier
                .fillMaxSize()
                .systemBarsPadding()
                .padding(16.dp)
        ) {
            TopBar()
            Spacer(modifier = Modifier.weight(1f))
            BottomHintBar(state = state)
        }
    }
}

@Composable
private fun TopBar() {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text(
            text = "Petanque",
            color = Color.White,
            fontWeight = FontWeight.SemiBold,
            style = MaterialTheme.typography.titleMedium
        )
    }
}

@Composable
private fun BottomHintBar(state: SceneState) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        modifier = Modifier
            .background(Color.Black.copy(alpha = 0.45f), shape = RoundedCornerShape(12.dp))
            .padding(12.dp)
    ) {
        QualityIndicator(score = state.quality.score)
        Text(
            text = state.hint ?: "Наведите камеру на площадку",
            color = Color.White,
            style = MaterialTheme.typography.bodyMedium,
            maxLines = 2
        )
    }
}

@Composable
private fun QualityIndicator(score: Int) {
    val filled = (score / 20).coerceIn(0, 5)
    Row(horizontalArrangement = Arrangement.spacedBy(2.dp)) {
        repeat(5) { i ->
            Box(
                modifier = Modifier
                    .size(8.dp)
                    .background(
                        color = if (i < filled) Color(0xFF4CAF50) else Color.White.copy(alpha = 0.3f),
                        shape = CircleShape
                    )
            )
        }
    }
}
