import AVFoundation
import SwiftUI

struct OverlayView: View {
    let state: SceneState
    let settings: OverlaySettings
    let previewLayer: AVCaptureVideoPreviewLayer?

    var body: some View {
        Canvas { ctx, size in
            guard settings.showBBox else { return }

            guard let previewLayer else { return }

            for ball in state.balls {
                if let rect = convertRect(ball.detection.bbox, layer: previewLayer, canvasSize: size) {
                    let color: Color = (ball.rank == 1) ? .green : .white
                    ctx.stroke(Path(roundedRect: rect, cornerRadius: 4),
                               with: .color(color), lineWidth: 2)
                    let label = Text("\(ball.rank ?? 0)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                    ctx.draw(label, at: CGPoint(x: rect.midX, y: rect.midY))
                }
            }

            if let coch = state.cochonnet {
                if let rect = convertRect(coch.detection.bbox, layer: previewLayer, canvasSize: size) {
                    ctx.stroke(Path(roundedRect: rect, cornerRadius: 4),
                               with: .color(.yellow), lineWidth: 3)
                    ctx.draw(Text("C").font(.system(size: 12, weight: .bold)).foregroundColor(.yellow),
                             at: CGPoint(x: rect.midX, y: rect.midY))
                }
            }
        }
    }

    private func convertRect(_ bbox: CGRect, layer: AVCaptureVideoPreviewLayer, canvasSize: CGSize) -> CGRect? {
        let corners = [CGPoint(x: bbox.minX, y: bbox.minY),
                       CGPoint(x: bbox.minX, y: bbox.maxY),
                       CGPoint(x: bbox.maxX, y: bbox.minY),
                       CGPoint(x: bbox.maxX, y: bbox.maxY)]
        var pts: [CGPoint] = []
        for p in corners {
            let lp = layer.layerPointConverted(fromCaptureDevicePoint: p)
            guard !lp.x.isNaN, !lp.y.isNaN else { return nil }
            pts.append(lp)
        }
        let minX = pts.map(\.x).min()!
        let maxX = pts.map(\.x).max()!
        let minY = pts.map(\.y).min()!
        let maxY = pts.map(\.y).max()!
        let scaleX = canvasSize.width / layer.bounds.width
        let scaleY = canvasSize.height / layer.bounds.height
        let x = minX * scaleX
        let y = minY * scaleY
        let w = (maxX - minX) * scaleX
        let h = (maxY - minY) * scaleY
        guard w > 0, h > 0 else { return nil }
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
