import AVFoundation
import Foundation

/// Управляет жизненным циклом AVCaptureSession.
///
/// На P0 задача — только показать preview с задней камеры и корректно
/// обработать разрешения. На P1 сюда добавится delegate-приёмник кадров,
/// который будет отдавать `CVPixelBuffer` детектору.
@MainActor
final class CameraSession: NSObject, ObservableObject {

    enum Status: Equatable {
        case idle
        case authorizing
        case denied
        case running
        case failed(String)
    }

    @Published private(set) var status: Status = .idle

    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "app.petanque.camera.session")

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStart()
        case .notDetermined:
            status = .authorizing
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    guard let self else { return }
                    if granted {
                        self.configureAndStart()
                    } else {
                        self.status = .denied
                    }
                }
            }
        case .denied, .restricted:
            status = .denied
        @unknown default:
            status = .denied
        }
    }

    func stop() {
        sessionQueue.async { [session] in
            if session.isRunning { session.stopRunning() }
        }
    }

    private func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .hd1920x1080

            self.session.inputs.forEach { self.session.removeInput($0) }

            guard
                let device = AVCaptureDevice.default(
                    .builtInWideAngleCamera, for: .video, position: .back
                ),
                let input = try? AVCaptureDeviceInput(device: device),
                self.session.canAddInput(input)
            else {
                self.session.commitConfiguration()
                Task { @MainActor in
                    self.status = .failed("Не удалось открыть заднюю камеру")
                }
                return
            }
            self.session.addInput(input)
            self.session.commitConfiguration()
            self.session.startRunning()

            Task { @MainActor in self.status = .running }
        }
    }
}
