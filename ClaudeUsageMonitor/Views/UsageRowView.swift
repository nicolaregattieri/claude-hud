import SwiftUI

struct UsageRowView: View {
    let title: String
    let percentage: Double
    let resetTime: Date?

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
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
            }

            ProgressBarView(value: percentage / 100.0)

            if let resetTime = resetTime {
                Text(String(format: NSLocalizedString("resets_in", comment: "Resets in time"), TimeFormatter.timeUntil(from: resetTime)))
                    .font(.system(size: 11))
                    .foregroundStyle(.orange)
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
