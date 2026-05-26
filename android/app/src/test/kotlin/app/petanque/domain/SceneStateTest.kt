package app.petanque.domain

import kotlinx.serialization.json.Json
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class SceneStateTest {

    @Test
    fun emptyState() {
        val s = SceneState.Empty
        assertNull(s.cochonnet)
        assertTrue(s.balls.isEmpty())
        assertEquals(0, s.quality.score)
        assertEquals(false, s.frozen)
    }

    @Test
    fun defaultOverlaySettings() {
        val s = OverlaySettings.Default
        assertTrue(s.showBBox)
        assertTrue(s.showLabels)
        assertEquals(false, s.showCircles)
        assertEquals(0.074, s.bouleDiameterMeters, 1e-6)
        assertEquals(0.030, s.cochonnetDiameterMeters, 1e-6)
    }

    @Test
    fun sceneStateRoundtripJson() {
        val detection = Detection(
            id = "b1",
            cls = DetectionClass.BOULE,
            bbox = BBox(0.1f, 0.2f, 0.05f, 0.05f),
            score = 0.92f,
        )
        val ball = BallMeasurement(
            id = "b1",
            detection = detection,
            position = Position3D(1.0, 0.0, 2.0),
            distanceToCochonnet = Distance(1.23, 0.8),
            rank = 1,
            method = Method.FUSION,
        )
        val state = SceneState(
            cochonnet = null,
            balls = listOf(ball),
            quality = Quality(score = 80, reasons = listOf("ok")),
            hint = null,
            frozen = false,
            timestamp = 123.0,
        )

        val json = Json { encodeDefaults = true }
        val encoded = json.encodeToString(SceneState.serializer(), state)
        val decoded = json.decodeFromString(SceneState.serializer(), encoded)
        assertEquals(state, decoded)
    }
}
