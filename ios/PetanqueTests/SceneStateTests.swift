import XCTest
@testable import Petanque

final class SceneStateTests: XCTestCase {

    func testEmptyState() {
        let s = SceneState.empty
        XCTAssertNil(s.cochonnet)
        XCTAssertTrue(s.balls.isEmpty)
        XCTAssertEqual(s.quality.score, 0)
        XCTAssertFalse(s.frozen)
    }

    func testDefaultOverlaySettings() {
        let s = OverlaySettings.default
        XCTAssertTrue(s.showBBox)
        XCTAssertTrue(s.showLabels)
        XCTAssertFalse(s.showCircles)
        XCTAssertEqual(s.bouleDiameterMeters, 0.074, accuracy: 1e-6)
        XCTAssertEqual(s.cochonnetDiameterMeters, 0.030, accuracy: 1e-6)
    }

    func testSceneStateRoundtripCodable() throws {
        let detection = Detection(
            id: "b1",
            cls: .boule,
            bbox: .init(x: 0.1, y: 0.2, width: 0.05, height: 0.05),
            score: 0.92
        )
        let ball = BallMeasurement(
            id: "b1",
            detection: detection,
            position: .init(x: 1.0, y: 0.0, z: 2.0),
            distanceToCochonnet: .init(meters: 1.23, confidence: 0.8),
            rank: 1,
            method: .fusion
        )
        let state = SceneState(
            cochonnet: nil,
            balls: [ball],
            quality: .init(score: 80, reasons: ["ok"]),
            hint: nil,
            frozen: false,
            timestamp: 123.0
        )

        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(SceneState.self, from: data)
        XCTAssertEqual(decoded, state)
    }
}
