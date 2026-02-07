import SwiftUI
import ServiceManagement
import AppKit

struct SettingsView: View {
    @AppStorage("refreshInterval") private var refreshInterval = 60
    @AppStorage("showPercentageInMenuBar") private var showPercentage = true
    @AppStorage("defaultTerminalFolder") private var defaultTerminalFolder: String = ""
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .system
    @AppStorage("usageAlertsEnabled") private var usageAlertsEnabled = true
    @AppStorage("selectedTerminalApp") private var selectedTerminalApp: TerminalApp = .terminal
    @State private var launchAtLogin = false

    var hideHeader: Bool = false
    var onAboutTap: () -> Void
    let onClose: () -> Void
    var onRefreshIntervalChange: ((Int) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !hideHeader {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.orange)
                    Text("settings_title")
                        .font(.system(size: 12, weight: .semibold))
                    Spacer()
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

            ScrollView {
                settingsContent
            }
        }
        .onAppear {
            loadLaunchAtLoginStatus()
        }
    }

    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            // MARK: - Refresh Interval
            SettingsSection(title: "Refresh") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("refresh_interval")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    Picker("", selection: $refreshInterval) {
                        Text("30s").tag(30)
                        Text("1 min").tag(60)
                        Text("2 min").tag(120)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: refreshInterval) { newValue in
                        onRefreshIntervalChange?(newValue)
                    }
                }
                .padding(.vertical, 2)
            }

            // MARK: - Display
            SettingsSection(title: "Display") {
                VStack(spacing: 0) {
                    SettingsRow(icon: "paintpalette.fill", iconColor: .purple) {
                        Text("theme")
                            .font(.system(size: 12))
                        Spacer()
                        Picker("", selection: $selectedTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(LocalizedStringKey(theme.rawValue.lowercased())).tag(theme)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 90)
                        .controlSize(.small)
                    }
                    .padding(.vertical, 6)

                    Divider()
                        .padding(.leading, 34)

                    SettingsRow(icon: "chart.bar.fill", iconColor: .blue) {
                        Text("show_percentage")
                            .font(.system(size: 12))
                        Spacer()
                        Toggle("", isOn: $showPercentage)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    .padding(.vertical, 6)

                    Divider()
                        .padding(.leading, 34)

                    SettingsRow(icon: "bell.badge.fill", iconColor: .red) {
                        Text("Usage alerts (80%/90%)")
                            .font(.system(size: 12))
                        Spacer()
                        Toggle("", isOn: $usageAlertsEnabled)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    .padding(.vertical, 6)
                }
            }

            // MARK: - Terminal
            SettingsSection(title: "Terminal") {
                VStack(spacing: 0) {
                    SettingsRow(icon: "apple.terminal.fill", iconColor: .green) {
                        Text("Terminal app")
                            .font(.system(size: 12))
                        Spacer()
                        Picker("", selection: $selectedTerminalApp) {
                            ForEach(TerminalApp.allCases.filter { $0.isInstalled }) { app in
                                Text(app.rawValue).tag(app)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 100)
                        .controlSize(.small)
                    }
                    .padding(.vertical, 6)

                    Divider()
                        .padding(.leading, 34)

                    SettingsRow(icon: "folder.fill", iconColor: .orange) {
                        Text(defaultTerminalFolder.isEmpty ? NSLocalizedString("home", value: "Home (~)", comment: "Home dir") : abbreviatePath(defaultTerminalFolder))
                            .font(.system(size: 12))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(defaultTerminalFolder.isEmpty ? .secondary : .primary)

                        Spacer()

                        if !defaultTerminalFolder.isEmpty {
                            Button(action: { defaultTerminalFolder = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }

                        Button("choose") {
                            selectDefaultFolder()
                        }
                        .font(.system(size: 11))
                        .controlSize(.small)
                    }
                    .padding(.vertical, 6)
                }
            }

            // MARK: - Claude
            SettingsSection(title: "Claude") {
                Button(action: openSkillsFolder) {
                    SettingsRow(icon: "wand.and.stars", iconColor: .indigo) {
                        Text("open_skills_folder")
                            .font(.system(size: 12))
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(.plain)
            }

            // MARK: - System
            SettingsSection(title: "System") {
                VStack(spacing: 0) {
                    SettingsRow(icon: "sunrise.fill", iconColor: .orange) {
                        Text("launch_at_login")
                            .font(.system(size: 12))
                        Spacer()
                        Toggle("", isOn: $launchAtLogin)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .controlSize(.small)
                            .onChange(of: launchAtLogin) { newValue in
                                setLaunchAtLogin(newValue)
                            }
                    }
                    .padding(.vertical, 6)

                    Divider()
                        .padding(.leading, 34)

                    // About
                    Button(action: {
                        withAnimation { onAboutTap() }
                    }) {
                        HStack(spacing: 10) {
                            Image("LogoIcon")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .clipShape(RoundedRectangle(cornerRadius: 6))

                            Text("about")
                                .font(.system(size: 12))

                            Spacer()

                            Text("v1.1")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
    }

    private func abbreviatePath(_ path: String) -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }

    private func selectDefaultFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select"
        panel.message = "Choose default folder for Terminal"
        if panel.runModal() == .OK, let url = panel.url {
            defaultTerminalFolder = url.path
        }
    }

    private func openSkillsFolder() {
        let skillsPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/skills")
        try? FileManager.default.createDirectory(at: skillsPath, withIntermediateDirectories: true)
        NSWorkspace.shared.open(skillsPath)
    }

    private func loadLaunchAtLoginStatus() {
        if #available(macOS 13.0, *) {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to set launch at login: \(error)")
            }
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.leading, 4)

            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.06))
            )
        }
    }
}

// MARK: - Settings Row

struct SettingsRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(iconColor.gradient)
                )

            content
        }
    }
}

#Preview {
    SettingsView(onAboutTap: {}, onClose: {})
        .frame(width: 320)
        .background(.regularMaterial)
}

struct AboutView: View {
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image("LogoIcon")
                .resizable()
                .frame(width: 80, height: 80)

            VStack(spacing: 4) {
                Text(LocalizedStringKey("claude_usage"))
                    .font(.system(size: 16, weight: .bold))

                Text("\(NSLocalizedString("version", comment: "")) 1.1")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 4) {
                Text(LocalizedStringKey("created_by"))
                    .font(.system(size: 11))

                Text(LocalizedStringKey("powered_by"))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Text("Copyright \u{00A9} 2026")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(20)
    }
}
