package app.petanque.domain

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class DetectionClass {
    @SerialName("boule") BOULE,
    @SerialName("cochonnet") COCHONNET,
}

@Serializable
data class BBox(
    val x: Float,
    val y: Float,
    val w: Float,
    val h: Float,
)

@Serializable
data class Detection(
    val id: String,
    val cls: DetectionClass,
    val bbox: BBox,
    val score: Float,
)

@Serializable
data class Position3D(val x: Double, val y: Double, val z: Double)

@Serializable
data class Distance(val meters: Double, val confidence: Double)

@Serializable
enum class Method {
    @SerialName("ar") AR,
    @SerialName("geometry") GEOMETRY,
    @SerialName("fusion") FUSION,
    @SerialName("lidar") LIDAR,
}

@Serializable
data class BallMeasurement(
    val id: String,
    val detection: Detection,
    val position: Position3D? = null,
    val distanceToCochonnet: Distance? = null,
    val rank: Int? = null,
    val method: Method? = null,
)

@Serializable
data class Quality(
    val score: Int,
    val reasons: List<String> = emptyList(),
)

@Serializable
data class SceneState(
    val cochonnet: BallMeasurement? = null,
    val balls: List<BallMeasurement> = emptyList(),
    val quality: Quality,
    val hint: String? = null,
    val frozen: Boolean,
    val timestamp: Double,
) {
    companion object {
        val Empty = SceneState(
            cochonnet = null,
            balls = emptyList(),
            quality = Quality(score = 0),
            hint = null,
            frozen = false,
            timestamp = 0.0,
        )
    }
}
