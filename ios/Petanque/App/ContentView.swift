import SwiftUI

struct ContentView: View {
    @State private var settings = OverlaySettings.default
    @State private var sceneState = SceneState.empty

    var body: some View {
        ZStack {
            CameraView()
                .ignoresSafeArea()

            OverlayView(state: sceneState, settings: settings)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack {
                TopBar()
                Spacer()
                BottomHintBar(state: sceneState)
            }
            .padding()
        }
    }
}

private struct TopBar: View {
    var body: some View {
        HStack {
            Text("Petanque")
                .font(.headline)
                .foregroundStyle(.white)
                .shadow(radius: 2)
            Spacer()
        }
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
