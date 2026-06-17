import CoreImage
import CoreML
import CoreVideo

final class YOLODetector: @unchecked Sendable {
    private let model: Detector?
    private let confidenceThreshold: Float = 0.25
    private let target: CGFloat = 640

    private let ciContext = CIContext()

    init() {
        model = try? Detector(configuration: MLModelConfiguration())
    }

    func processFrame(_ ciImage: CIImage) -> [Detection] {
        guard let model else { return [] }

        let imageW = ciImage.extent.width
        let imageH = ciImage.extent.height

        guard
            let pixelBuffer = letterboxTo640(ciImage),
            let output = try? model.prediction(image: pixelBuffer)
        else { return [] }

        let gain = min(target / imageW, target / imageH)
        let scaledW = imageW * gain
        let scaledH = imageH * gain
        let padX = (target - scaledW) / 2
        let padY = (target - scaledH) / 2

        let multiArray = output.var_1198
        let count = multiArray.shape[1].intValue
        let stride = multiArray.shape[2].intValue
        guard stride == 6 else { return [] }

        var detections: [Detection] = []
        let ptr = UnsafeMutablePointer<Float>(OpaquePointer(multiArray.dataPointer))

        for i in 0..<count {
            let offset = i * stride
            let x1 = Double(ptr[offset])
            let y1 = Double(ptr[offset + 1])
            let x2 = Double(ptr[offset + 2])
            let y2 = Double(ptr[offset + 3])
            let s0 = Double(ptr[offset + 4])
            let s1 = Double(ptr[offset + 5])

            let score: Float
            let cls: DetectionClass
            if Float(s0) > Float(s1) {
                score = Float(s0); cls = .boule
            } else {
                score = Float(s1); cls = .cochonnet
            }
            guard score >= confidenceThreshold else { continue }

            let x1n = (CGFloat(x1) - padX) / scaledW
            let y1n = (CGFloat(y1) - padY) / scaledH
            let x2n = (CGFloat(x2) - padX) / scaledW
            let y2n = (CGFloat(y2) - padY) / scaledH

            let bbox = CGRect(x: x1n, y: y1n,
                              width: x2n - x1n, height: y2n - y1n)

            detections.append(Detection(
                id: UUID().uuidString, cls: cls,
                bbox: bbox, score: score,
                rawX1: x1, rawY1: y1, rawX2: x2, rawY2: y2,
                rawS0: s0, rawS1: s1
            ))
        }
        return detections
    }

    private func letterboxTo640(_ ciImage: CIImage) -> CVPixelBuffer? {
        let gain = min(target / ciImage.extent.width, target / ciImage.extent.height)
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: gain, y: gain))
        let sw = scaled.extent.width
        let sh = scaled.extent.height
        let dx = (target - sw) / 2
        let dy = (target - sh) / 2

        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, Int(target), Int(target),
                            kCVPixelFormatType_32BGRA, [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
        ] as CFDictionary, &pixelBuffer)
        guard let pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        memset(CVPixelBufferGetBaseAddress(pixelBuffer), 0, CVPixelBufferGetDataSize(pixelBuffer))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

        let translated = scaled.transformed(by: CGAffineTransform(translationX: dx, y: dy))
        ciContext.render(translated, to: pixelBuffer)
        return pixelBuffer
    }
}
