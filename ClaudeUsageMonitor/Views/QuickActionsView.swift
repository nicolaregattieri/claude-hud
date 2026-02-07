import SwiftUI

struct QuickActionsView: View {
    var onProjectsTap: () -> Void
    var onActivityTap: () -> Void
    var onTerminalTap: () -> Void
    var onSettingsTap: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            QuickActionButton(
                icon: "folder.fill",
                label: "projects",
                isEnabled: true,
                action: onProjectsTap
            )
            QuickActionButton(
                icon: "bolt.fill",
                label: "activity",
                isEnabled: true,
                action: onActivityTap
            )
            QuickActionButton(
                icon: "terminal.fill",
                label: "terminal",
                isEnabled: true,
                action: onTerminalTap
            )
            QuickActionButton(
                icon: "gearshape.fill",
                label: "settings",
                isEnabled: true,
                action: onSettingsTap
            )
        }
        .padding(.horizontal, 4)
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let isEnabled: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            ZStack {
                backgroundView
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }
            .frame(height: 36)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .help(isEnabled ? LocalizedStringKey(label) : "Coming soon")
    }

    private var iconColor: Color {
        if !isEnabled {
            return Color.gray.opacity(0.5)
        }
        return isHovered ? .orange : .secondary
    }

    @ViewBuilder
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(isHovered && isEnabled ? Color.gray.opacity(0.1) : Color.clear)
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
