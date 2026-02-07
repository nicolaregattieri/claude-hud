import SwiftUI

struct ProgressBarView: View {
    let value: Double // 0-1

    private var barColor: Color {
        let percentage = value * 100
        if percentage >= 90 {
            return .red
        } else if percentage >= 80 {
            return Color(red: 1.0, green: 0.4, blue: 0.0) // deep orange
        } else if percentage >= 60 {
            return .yellow
        } else {
            return .green
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background - adapts to light/dark mode
                Capsule()
                    .fill(.quaternary)

                // Progress bar with gradient
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [barColor, barColor.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(geometry.size.width, geometry.size.width * value)))
                    .animation(.easeInOut(duration: 0.3), value: value)
            }
        }
        .frame(height: 8)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBarView(value: 0.15)
        ProgressBarView(value: 0.50)
        ProgressBarView(value: 0.85)
        ProgressBarView(value: 1.0)
    }
    .padding()
    .background(.regularMaterial)
}
