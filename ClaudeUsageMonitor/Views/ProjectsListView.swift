import SwiftUI

struct ProjectsListView: View {
    var hideHeader: Bool = false
    let projects: [Project]
    let onChatSelect: (ChatSession, Project) -> Void
    let onProjectOpen: (Project) -> Void
    let onClose: () -> Void

    @State private var expandedProjects: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            if !hideHeader {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundStyle(.orange)
                    Text("projects")
                        .font(.system(size: 12, weight: .semibold))
                    Spacer()
                    Text("\(projects.count)")
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

            // Projects list
            if projects.isEmpty {
                emptyView
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(projects) { project in
                            // Project header
                            ProjectHeader(
                                project: project,
                                isExpanded: expandedProjects.contains(project.id),
                                onToggle: { toggleProject(project.id) },
                                onTerminalTap: { onProjectOpen(project) }
                            )

                            // Chats (flat, not nested)
                            if expandedProjects.contains(project.id) {
                                ForEach(project.sessions.prefix(5)) { session in
                                    ChatRow(session: session, onSelect: { onChatSelect(session, project) })
                                }

                                if project.sessions.count > 5 {
                                    HStack {
                                        Spacer()
                                        Text("+ \(project.sessions.count - 5) ")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color.gray)
                                        + Text("more")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color.gray)
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 24))
                .foregroundStyle(.secondary)
            Text("no_projects")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private func toggleProject(_ id: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if expandedProjects.contains(id) {
                expandedProjects.remove(id)
            } else {
                expandedProjects.insert(id)
            }
        }
    }
}

struct ProjectHeader: View {
    let project: Project
    let isExpanded: Bool
    let onToggle: () -> Void
    let onTerminalTap: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack {
            Image(systemName: isExpanded ? "folder.fill" : "folder")
                .font(.system(size: 12))
                .foregroundStyle(.orange)
            Text(project.name)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
            Spacer()

            // Terminal button
            Button(action: onTerminalTap) {
                Image(systemName: "terminal.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Text("\(project.sessionCount)")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isHovered ? Color.gray.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
        .onHover { isHovered = $0 }
    }
}

struct ChatRow: View {
    let session: ChatSession
    let onSelect: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bubble.left.fill")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Text(session.displayTitle)
                .font(.system(size: 11))
                .lineLimit(1)
                .foregroundColor(.primary)
            Spacer()
            Text(TimeFormatter.timeAgo(from: session.modified))
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .padding(.leading, 32)
        .padding(.trailing, 12)
        .padding(.vertical, 6)
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
    ProjectsListView(
        projects: [
            Project(
                id: "-test",
                name: "TestProject",
                path: "/test",
                sessions: [
                    ChatSession(
                        sessionId: "1",
                        firstPrompt: "Test prompt",
                        summary: "Test Chat",
                        messageCount: 5,
                        created: Date(),
                        modified: Date(),
                        gitBranch: "main",
                        projectPath: "/test"
                    )
                ]
            )
        ],
        onChatSelect: { _, _ in },
        onProjectOpen: { _ in },
        onClose: {}
    )
    .frame(width: 320)
    .background(.regularMaterial)
}
