import SwiftUI

struct ChatWithProject: Identifiable {
    let chat: ChatSession
    let project: Project

    var id: String { chat.id }
}

struct ActivityView: View {
    var hideHeader: Bool = false
    let chats: [ChatWithProject]
    let onChatSelect: (ChatSession, Project) -> Void
    let onClose: () -> Void

    private var recentChats: [ChatWithProject] {
        Array(chats.prefix(8))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Recent Activity Section
                    recentSection

                    if !recentChats.isEmpty {
                        Divider()
                            .padding(.horizontal, 4)
                    }

                    // Quick Tips Section
                    tipsSection
                }
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Recent Activity

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 13))
                    .foregroundStyle(.orange)
                Text("Recent Activity")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 14)

            if recentChats.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "tray")
                            .font(.system(size: 20))
                            .foregroundStyle(.tertiary)
                        Text("No recent sessions")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 16)
                    Spacer()
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(recentChats) { item in
                        ActivityChatRow(
                            chat: item.chat,
                            projectName: item.project.name,
                            onSelect: { onChatSelect(item.chat, item.project) }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Quick Tips

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.yellow)
                Text("Quick Tips")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 14)

            VStack(spacing: 6) {
                TipRow(
                    shortcut: "claude --resume",
                    description: "Resume a previous chat session"
                )
                TipRow(
                    shortcut: "/compact",
                    description: "Compact context when running long"
                )
                TipRow(
                    shortcut: "Shift+Tab",
                    description: "Toggle plan mode on/off"
                )
                TipRow(
                    shortcut: "Esc",
                    description: "Cancel current generation"
                )
            }
            .padding(.horizontal, 14)
        }
    }
}

// MARK: - Activity Chat Row

struct ActivityChatRow: View {
    let chat: ChatSession
    let projectName: String
    let onSelect: () -> Void

    @State private var isHovered = false
    @State private var showCopied = false

    var body: some View {
        HStack(spacing: 10) {
            // Time indicator
            Circle()
                .fill(Color.orange.opacity(isHovered ? 1.0 : 0.6))
                .frame(width: 6, height: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(chat.displayTitle)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    Text(projectName)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Color.orange.opacity(0.7))
                        .clipShape(Capsule())

                    Text(TimeFormatter.timeAgo(from: chat.modified))
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            if isHovered {
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString("claude --resume \(chat.sessionId)", forType: .string)
                    showCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showCopied = false
                    }
                }) {
                    Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 10))
                        .foregroundStyle(showCopied ? .green : .secondary)
                }
                .buttonStyle(.plain)
                .help("Copy resume command")
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 9))
                .foregroundStyle(.quaternary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(isHovered ? Color.gray.opacity(0.08) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
        .onHover { isHovered = $0 }
    }
}

// MARK: - Tip Row

struct TipRow: View {
    let shortcut: String
    let description: String

    var body: some View {
        HStack(spacing: 8) {
            Text(shortcut)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(.orange)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 4))

            Text(description)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()
        }
    }
}

#Preview {
    ActivityView(
        chats: [
            ChatWithProject(
                chat: ChatSession(
                    sessionId: "1",
                    firstPrompt: "Test prompt",
                    summary: "Test Chat",
                    messageCount: 5,
                    created: Date(),
                    modified: Date(),
                    gitBranch: "main",
                    projectPath: "/test"
                ),
                project: Project(
                    id: "-test",
                    name: "TestProject",
                    path: "/test",
                    sessions: []
                )
            )
        ],
        onChatSelect: { _, _ in },
        onClose: {}
    )
    .frame(width: 320)
    .background(.regularMaterial)
}
