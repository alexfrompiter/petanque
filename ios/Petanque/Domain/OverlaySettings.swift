import Foundation

/// Настройки оверлея — какие слои показывать.
///
/// Хранится в UserDefaults под ключом `overlay.settings.v1`.
struct OverlaySettings: Codable, Equatable {
    var showBBox: Bool
    var showLabels: Bool
    var showDistances: Bool
    var showLines: Bool
    var showCircles: Bool
    var showARDebug: Bool
    var showQuality: Bool

    /// Диаметр шара в метрах (по умолчанию 0.074 — середина диапазона FIPJP).
    var bouleDiameterMeters: Double
    /// Диаметр кошонета в метрах (стандарт ~0.030).
    var cochonnetDiameterMeters: Double

    static let `default` = OverlaySettings(
        showBBox: true,
        showLabels: true,
        showDistances: true,
        showLines: true,
        showCircles: false,
        showARDebug: false,
        showQuality: true,
        bouleDiameterMeters: 0.074,
        cochonnetDiameterMeters: 0.030
    )
}
