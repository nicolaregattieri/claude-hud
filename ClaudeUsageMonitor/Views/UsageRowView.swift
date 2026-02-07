import SwiftUI

struct UsageRowView: View {
    let title: String
    let percentage: Double
    let resetTime: Date?

    private var percentageColor: Color {
        if percentage >= 90 {
            return .red
        } else if percentage >= 80 {
            return Color(red: 1.0, green: 0.4, blue: 0.0)
        } else if percentage >= 60 {
            return .yellow
        } else {
            return .primary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Spacer()

                Text("\(Int(percentage))%")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(percentageColor)
                    .contentTransition(.numericText())
            }

            ProgressBarView(value: percentage / 100.0)

            if let resetTime = resetTime {
                Text(String(format: NSLocalizedString("resets_in", comment: "Resets in time"), TimeFormatter.timeUntil(from: resetTime)))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        UsageRowView(
            title: "SESSION",
            percentage: 15,
            resetTime: Date().addingTimeInterval(7200) // 2 hours
        )

        UsageRowView(
            title: "WEEKLY",
            percentage: 13,
            resetTime: Date().addingTimeInterval(345600) // 4 days
        )

        UsageRowView(
            title: "SONNET",
            percentage: 3,
            resetTime: Date().addingTimeInterval(432000) // 5 days
        )
    }
    .padding()
    .background(.regularMaterial)
}
