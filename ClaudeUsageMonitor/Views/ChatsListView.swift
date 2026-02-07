import SwiftUI

struct ChatWithProject: Identifiable {
    let chat: ChatSession
    let project: Project

    var id: String { chat.id }
}

struct ChatsListView: View {
    var hideHeader: Bool = false
    let chats: [ChatWithProject]
    let onChatSelect: (ChatSession, Project) -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            if !hideHeader {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundStyle(.orange)
                    Text("recent_chats")
                        .font(.system(size: 12, weight: .semibold))
                    Spacer()
                    Text("\(chats.count)")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 8)
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

                Divider()
            }

            // Chats list
            if chats.isEmpty {
                emptyView
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(chats.prefix(10)) { item in
                            ChatItemRow(
                                chat: item.chat,
                                projectName: item.project.name,
                                onSelect: { onChatSelect(item.chat, item.project) }
                            )
                        }
                    }
                }
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 24))
                .foregroundStyle(.secondary)
            Text("no_chats")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

struct ChatItemRow: View {
    let chat: ChatSession
    let projectName: String
    let onSelect: () -> Void

    @State private var isHovered = false
    @State private var showCopied = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bubble.left.fill")
                .font(.system(size: 10))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(chat.displayTitle)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .foregroundColor(.primary)

                HStack(spacing: 4) {
                    Text(projectName)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Color.orange.opacity(0.8))
                        .clipShape(Capsule())

                    Text(TimeFormatter.timeAgo(from: chat.modified))
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
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
                        .font(.system(size: 9))
                        .foregroundColor(showCopied ? .green : .secondary)
                }
                .buttonStyle(.plain)
                .help("Copy resume command")
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isHovered ? Color.gray.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .onHover { isHovered = $0 }
    }
}

#Preview {
    ChatsListView(
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
