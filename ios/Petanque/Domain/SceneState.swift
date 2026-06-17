import CoreGraphics
import Foundation

/// Класс детектируемого объекта.
enum DetectionClass: String, Codable, Hashable {
    case boule
    case cochonnet
}

/// Один объект, найденный детектором в кадре.
struct Detection: Codable, Hashable, Identifiable {
    let id: String
    let cls: DetectionClass
    let bbox: CGRect
    let score: Float
    let rawX1: Double?
    let rawY1: Double?
    let rawX2: Double?
    let rawY2: Double?
    let rawS0: Double?
    let rawS1: Double?

    init(id: String, cls: DetectionClass, bbox: CGRect, score: Float,
         rawX1: Double? = nil, rawY1: Double? = nil,
         rawX2: Double? = nil, rawY2: Double? = nil,
         rawS0: Double? = nil, rawS1: Double? = nil) {
        self.id = id
        self.cls = cls
        self.bbox = bbox
        self.score = score
        self.rawX1 = rawX1
        self.rawY1 = rawY1
        self.rawX2 = rawX2
        self.rawY2 = rawY2
        self.rawS0 = rawS0
        self.rawS1 = rawS1
    }
}

/// 3D-позиция в системе координат AR-сессии (метры).
struct Position3D: Codable, Hashable {
    var x: Double
    var y: Double
    var z: Double
}

/// Замер дистанции для одного шара.
struct BallMeasurement: Codable, Hashable, Identifiable {
    enum Method: String, Codable { case ar, geometry, fusion, lidar }

    let id: String
    var detection: Detection
    var position: Position3D?
    var distanceToCochonnet: Distance?
    var rank: Int?
    var method: Method?

    struct Distance: Codable, Hashable {
        var meters: Double
        var confidence: Double  // 0..1
    }
}

/// Состояние, которое UI рендерит каждый кадр.
struct SceneState: Codable, Hashable {
    var cochonnet: BallMeasurement?
    var balls: [BallMeasurement]
    var quality: Quality
    var hint: String?
    var frozen: Bool
    var timestamp: TimeInterval

    struct Quality: Codable, Hashable {
        var score: Int          // 0..100
        var reasons: [String]   // машинно-читаемые причины (для тестов)
    }

    static let empty = SceneState(
        cochonnet: nil,
        balls: [],
        quality: .init(score: 0, reasons: []),
        hint: nil,
        frozen: false,
        timestamp: 0
    )
}
