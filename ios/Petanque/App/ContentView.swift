import AVFoundation
import SwiftUI

@MainActor
struct ContentView: View {
    @State private var settings = OverlaySettings.default
    @State private var sceneState = SceneState.empty
    @State private var previewLayer: AVCaptureVideoPreviewLayer?
    private let detector = YOLODetector()

    private let visionQueue = DispatchQueue(
        label: "app.petanque.vision",
        qos: .userInitiated
    )

    var body: some View {
        ZStack {
            CameraView(onFrame: { [detector, visionQueue] ciImage in
                visionQueue.async {
                    let detections = detector.processFrame(ciImage)
                    let boules = detections.filter { $0.cls == .boule }
                    let cochonnets = detections.filter { $0.cls == .cochonnet }
                    let bestCochonnet = cochonnets.max(by: { $0.score < $1.score })

                    var balls = boules.map { BallMeasurement(
                        id: $0.id, detection: $0, position: nil,
                        distanceToCochonnet: nil, rank: nil, method: nil
                    )}

                    if let bestCochonnet {
                        let center = bboxCenter(bestCochonnet.bbox)
                        balls.sort { bboxCenter($0.detection.bbox).distance(to: center)
                            < bboxCenter($1.detection.bbox).distance(to: center) }
                        for (index, _) in balls.enumerated() { balls[index].rank = index + 1 }
                    }

                    let state = SceneState(
                        cochonnet: bestCochonnet.map { BallMeasurement(
                            id: $0.id, detection: $0, position: nil,
                            distanceToCochonnet: nil, rank: nil, method: nil
                        )},
                        balls: balls,
                        quality: .init(score: detections.isEmpty ? 0 : 75, reasons: []),
                        hint: detections.isEmpty ? "Наведите камеру на площадку" : nil,
                        frozen: false, timestamp: Date().timeIntervalSince1970
                    )

                    Task { @MainActor in
                        sceneState = state
                    }
                }
            }, previewLayer: $previewLayer)
                .ignoresSafeArea()

            OverlayView(state: sceneState, settings: settings, previewLayer: previewLayer)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack {
                Spacer()
                BottomHintBar(state: sceneState)
            }
            .padding()
        }
    }
}

private func bboxCenter(_ bbox: CGRect) -> CGPoint {
    CGPoint(x: bbox.midX, y: bbox.midY)
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        let dx = x - other.x
        let dy = y - other.y
        return sqrt(dx * dx + dy * dy)
    }
}

private struct BottomHintBar: View {
    let state: SceneState

    var body: some View {
        HStack(spacing: 8) {
            QualityIndicator(score: state.quality.score)
            Text(state.hint ?? "Наведите камеру на площадку")
                .font(.subheadline)
                .foregroundStyle(.white)
                .lineLimit(2)
            Spacer()
        }
        .padding(12)
        .background(.black.opacity(0.45), in: .rect(cornerRadius: 12))
    }
}

private struct QualityIndicator: View {
    let score: Int

    var body: some View {
        let filled = max(0, min(5, score / 20))
        HStack(spacing: 2) {
            ForEach(0..<5) { i in
                Circle()
                    .fill(i < filled ? Color.green : Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

#Preview {
    ContentView()
}
