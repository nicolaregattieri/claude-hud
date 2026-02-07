import SwiftUI

struct MenuBarView: View {
    @State private var usageData: UsageData?
    @State private var credentials: CredentialsData?
    @State private var lastUpdated = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showProjects = false
    @State private var showActivity = false
    @State private var showSettings = false
    @State private var showAbout = false // New state
    @State private var projects: [Project] = []
    @State private var allChats: [ChatWithProject] = []

    @AppStorage("defaultTerminalFolder") private var defaultTerminalFolder: String = ""
    @AppStorage("selectedTerminalApp") private var selectedTerminalApp: TerminalApp = .terminal

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)

            Divider()

            // Content
            Group {
                if showAbout {
                    AboutView(onBack: {
                        withAnimation {
                            showAbout = false
                        }
                    })
                    .transition(.move(edge: .trailing))
                } else if showSettings {
                    SettingsView(
                        hideHeader: true,
                        onAboutTap: {
                            withAnimation {
                                showAbout = true
                            }
                        },
                        onClose: {
                            withAnimation {
                                showSettings = false
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))
                } else if showProjects {
// ...
                    ProjectsListView(
                        hideHeader: true,
                        projects: projects,
                        onChatSelect: { chat, project in
                            openChat(chat, in: project)
                        },
                        onProjectOpen: { project in
                            openProject(project)
                        },
                        onClose: {
                            withAnimation {
                                showProjects = false
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))
                } else if showActivity {
                    ActivityView(
                        hideHeader: true,
                        chats: allChats,
                        onChatSelect: { chat, project in
                            openChat(chat, in: project)
                        },
                        onClose: {
                            withAnimation {
                                showActivity = false
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))
                } else {
                    mainContentView
                        .transition(.move(edge: .leading))
                }
            }
            // Force a consistent width but allow height to adapt
            .frame(width: 320)
            
            if !showSettings && !showProjects && !showActivity {
                Divider()
                // Footer
                footerView
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
            }
        }
        .background(.regularMaterial)
        .onAppear {
            loadCredentials()
            refresh()
        }
        .onReceive(timer) { _ in
            refresh()
        }
    }

    private var mainContentView: some View {
        VStack(spacing: 0) {
            Group {
                if let error = errorMessage {
                    errorView(message: error)
                } else if let data = usageData {
                    contentView(data: data)
                } else if isLoading {
                    loadingView
                } else {
                    emptyView
                }
            }
            .padding(16)
        }
    }

    private var headerView: some View {
        HStack {
            if showSettings || showProjects || showActivity || showAbout {
                Button(action: {
                    withAnimation {
                        if showAbout {
                            showAbout = false
                        } else {
                            showSettings = false
                            showProjects = false
                            showActivity = false
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                let title: String = {
                    if showAbout { return "about" }
                    if showSettings { return "settings_title" }
                    if showProjects { return "projects" }
                    if showActivity { return "activity" }
                    return ""
                }()
                
                Text(LocalizedStringKey(title))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.leading, 4)
            } else {
                Image("LogoIcon")
                    .resizable()
                    .frame(width: 16, height: 16)

                Text(credentials?.subscriptionLabel ?? NSLocalizedString("claude_usage", value: "Claude Usage", comment: "App Title"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)

                if let tier = credentials?.tierMultiplier {
                    Text(tier)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.orange.gradient)
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
    }

    @ViewBuilder
    private func contentView(data: UsageData) -> some View {
        VStack(spacing: 20) {
            if let fiveHour = data.fiveHour {
                UsageRowView(
                    title: NSLocalizedString("session", value: "SESSION", comment: "Session Usage"),
                    percentage: fiveHour.utilization,
                    resetTime: fiveHour.resetsAtDate
                )
            }

            if let sevenDay = data.sevenDay {
                UsageRowView(
                    title: NSLocalizedString("weekly", value: "WEEKLY", comment: "Weekly Usage"),
                    percentage: sevenDay.utilization,
                    resetTime: sevenDay.resetsAtDate
                )
            }

            if let sevenDaySonnet = data.sevenDaySonnet {
                UsageRowView(
                    title: NSLocalizedString("sonnet", value: "SONNET", comment: "Sonnet Model"),
                    percentage: sevenDaySonnet.utilization,
                    resetTime: sevenDaySonnet.resetsAtDate
                )
            } else if let sevenDayOpus = data.sevenDayOpus {
                UsageRowView(
                    title: NSLocalizedString("opus", value: "OPUS", comment: "Opus Model"),
                    percentage: sevenDayOpus.utilization,
                    resetTime: sevenDayOpus.resetsAtDate
                )
            }

            // Sparkline - 24h usage trend
            let sessionHistory = UsageHistoryService.shared.sessionHistory()
            if sessionHistory.count >= 2 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("24H TREND")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                    SparklineView(data: sessionHistory, color: .orange)
                        .frame(height: 28)
                }
            }

            Divider()
                .padding(.top, 4)

            QuickActionsView(
                onProjectsTap: {
                    loadProjectsIfNeeded()
                    withAnimation {
                        showProjects = true
                        showActivity = false
                        showSettings = false
                    }
                },
                onActivityTap: {
                    loadChatsIfNeeded()
                    withAnimation {
                        showActivity = true
                        showProjects = false
                        showSettings = false
                    }
                },
                onTerminalTap: { openTerminal() },
                onSettingsTap: {
                    withAnimation {
                        showSettings = true
                        showProjects = false
                        showActivity = false
                    }
                }
            )
        }
    }

    private func openTerminal() {
        let folder = defaultTerminalFolder.isEmpty
            ? FileManager.default.homeDirectoryForCurrentUser.path
            : defaultTerminalFolder

        runTerminalCommand(folder: folder, command: "claude")
    }

    private func openProject(_ project: Project) {
        runTerminalCommand(folder: project.path, command: "claude")
    }

    private func openChat(_ chat: ChatSession, in project: Project) {
        runTerminalCommand(folder: project.path, command: "claude --resume \(chat.sessionId)")
    }

    private func runTerminalCommand(folder: String, command: String) {
        TerminalService.shared.runCommand(folder: folder, command: command, app: selectedTerminalApp)
    }

    private func loadProjectsIfNeeded() {
        if projects.isEmpty {
            projects = ProjectsService.shared.loadProjects()
        }
    }

    private func loadChatsIfNeeded() {
        loadProjectsIfNeeded()
        if allChats.isEmpty {
            // Coletar todos os chats de todos os projetos e ordenar por data
            allChats = projects.flatMap { project in
                project.sessions.map { ChatWithProject(chat: $0, project: project) }
            }
            .sorted { $0.chat.modified > $1.chat.modified }
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            if message == APIError.tokenExpired.localizedDescription {
                // Session Expired / Inactive State
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.indigo)
                
                Text("session_inactive")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text("session_inactive_desc")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let lastChat = allChats.first {
                    Button(action: {
                        openChat(lastChat.chat, in: lastChat.project)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 11))
                            Text("open_last_chat")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.indigo.opacity(0.1))
                        .foregroundStyle(.indigo)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                } else {
                    Button(action: { openTerminal() }) {
                        Text("open_terminal")
                            .font(.system(size: 11))
                            .underline()
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
            } else {
                // Generic Error
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.orange)

                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .onAppear {
            if message == APIError.tokenExpired.localizedDescription {
                loadChatsIfNeeded()
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                .scaleEffect(1.2)

            Text("loading")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)

            Text("no_data")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var footerView: some View {
        HStack {
            Text("\(TimeFormatter.timeAgo(from: lastUpdated)) \(NSLocalizedString("ago", value: "ago", comment: "Time ago"))")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 16) {
                Button(action: { refresh() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isLoading ? .tertiary : .secondary)
                }
                .buttonStyle(.plain)
                .disabled(isLoading)

                Button(action: { NSApp.terminate(nil) }) {
                    Image(systemName: "power")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func loadCredentials() {
        credentials = KeychainService.getCredentials()
    }

    private func refresh() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let data = try await UsageAPI.fetchUsage()
                await MainActor.run {
                    self.usageData = data
                    self.lastUpdated = Date()
                    self.isLoading = false
                    self.errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    MenuBarView()
}
