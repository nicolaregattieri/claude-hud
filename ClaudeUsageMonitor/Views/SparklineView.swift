import SwiftUI

struct SparklineView: View {
    let data: [Double]
    let color: Color

    var body: some View {
        Canvas { context, size in
            guard data.count >= 2 else { return }

            let maxVal = max(data.max() ?? 100, 1)
            let step = size.width / CGFloat(data.count - 1)

            var path = Path()
            for (index, value) in data.enumerated() {
                let x = CGFloat(index) * step
                let y = size.height - (CGFloat(value / maxVal) * size.height)
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }

            context.stroke(path, with: .color(color), lineWidth: 1.5)

            // Fill area under the line
            var fillPath = path
            fillPath.addLine(to: CGPoint(x: size.width, y: size.height))
            fillPath.addLine(to: CGPoint(x: 0, y: size.height))
            fillPath.closeSubpath()

            context.fill(fillPath, with: .linearGradient(
                Gradient(colors: [color.opacity(0.2), color.opacity(0.02)]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: size.height)
            ))
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SparklineView(
            data: [5, 12, 8, 25, 30, 28, 45, 60, 55, 70, 65, 80],
            color: .orange
        )
        .frame(height: 30)

        SparklineView(
            data: [10, 12, 11, 13, 14, 13, 15, 14, 16, 15],
            color: .green
        )
        .frame(height: 30)
    }
    .padding()
    .background(.regularMaterial)
}
