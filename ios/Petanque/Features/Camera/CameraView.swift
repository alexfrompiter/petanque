import SwiftUI

/// Полноэкранный SwiftUI-компонент с preview камеры и обработкой состояний
/// (запрос разрешений, отказ, ошибка).
struct CameraView: View {
    @StateObject private var camera = CameraSession()

    var body: some View {
        ZStack {
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()

            statusOverlay
        }
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
    }

    @ViewBuilder
    private var statusOverlay: some View {
        switch camera.status {
        case .denied:
            CenterMessage(
                title: "Нет доступа к камере",
                subtitle: "Разрешите доступ в Настройках, чтобы видеть площадку.",
                action: openSettingsAction
            )
        case .failed(let message):
            CenterMessage(title: "Камера недоступна", subtitle: message, action: nil)
        case .authorizing:
            CenterMessage(title: "Запрос разрешения…", subtitle: nil, action: nil)
        case .idle, .running:
            EmptyView()
        }
    }

    private var openSettingsAction: CenterMessage.Action? {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return nil }
        return .init(title: "Открыть настройки") {
            UIApplication.shared.open(url)
        }
    }
}

private struct CenterMessage: View {
    struct Action { let title: String; let handler: () -> Void }

    let title: String
    let subtitle: String?
    let action: Action?

    var body: some View {
        VStack(spacing: 12) {
            Text(title).font(.headline).foregroundStyle(.white)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            if let action {
                Button(action.title, action: action.handler)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .background(.black.opacity(0.6), in: .rect(cornerRadius: 16))
        .padding(32)
    }
}
