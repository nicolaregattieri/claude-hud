import SwiftUI

struct QuickActionsView: View {
    var onProjectsTap: () -> Void
    var onActivityTap: () -> Void
    var onTerminalTap: () -> Void
    var onSettingsTap: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            QuickActionButton(
                icon: "folder.fill",
                label: "Projects",
                action: onProjectsTap
            )
            QuickActionButton(
                icon: "bolt.fill",
                label: "Activity",
                action: onActivityTap
            )
            QuickActionButton(
                icon: "terminal.fill",
                label: "Terminal",
                action: onTerminalTap
            )
            QuickActionButton(
                icon: "gearshape.fill",
                label: "Settings",
                action: onSettingsTap
            )
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isHovered ? .orange : .secondary)

                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(isHovered ? .orange : Color.gray)
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? Color.orange.opacity(0.08) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    QuickActionsView(
        onProjectsTap: {},
        onActivityTap: {},
        onTerminalTap: {},
        onSettingsTap: {}
    )
    .padding()
    .background(.regularMaterial)
}
