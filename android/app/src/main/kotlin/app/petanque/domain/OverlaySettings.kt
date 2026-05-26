package app.petanque.domain

import kotlinx.serialization.Serializable

@Serializable
data class OverlaySettings(
    val showBBox: Boolean,
    val showLabels: Boolean,
    val showDistances: Boolean,
    val showLines: Boolean,
    val showCircles: Boolean,
    val showARDebug: Boolean,
    val showQuality: Boolean,
    /// Диаметр шара в метрах (по умолчанию середина диапазона FIPJP).
    val bouleDiameterMeters: Double,
    /// Диаметр кошонета в метрах.
    val cochonnetDiameterMeters: Double,
) {
    companion object {
        val Default = OverlaySettings(
            showBBox = true,
            showLabels = true,
            showDistances = true,
            showLines = true,
            showCircles = false,
            showARDebug = false,
            showQuality = true,
            bouleDiameterMeters = 0.074,
            cochonnetDiameterMeters = 0.030,
        )
    }
}
