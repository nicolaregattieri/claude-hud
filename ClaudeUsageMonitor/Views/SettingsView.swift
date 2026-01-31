import SwiftUI
import ServiceManagement
import AppKit

struct SettingsView: View {
    @AppStorage("refreshInterval") private var refreshInterval = 60
    @AppStorage("showPercentageInMenuBar") private var showPercentage = true
    @AppStorage("defaultTerminalFolder") private var defaultTerminalFolder: String = ""
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .system
    @State private var launchAtLogin = false

    var hideHeader: Bool = false
    var onAboutTap: () -> Void
    let onClose: () -> Void
    var onRefreshIntervalChange: ((Int) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (Main Settings Header)
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
        VStack(alignment: .leading, spacing: 16) {
            // Refresh interval
            VStack(alignment: .leading, spacing: 6) {
                Text("refresh_interval")
                    .font(.system(size: 11, weight: .medium))
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

            Divider()

            // Display options
            VStack(alignment: .leading, spacing: 10) {
                Text("display")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)

                // Theme Picker
                HStack {
                    Image(systemName: "paintpalette")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                    Text("theme")
                        .font(.system(size: 11))
                    Spacer()
                    Picker("", selection: $selectedTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(LocalizedStringKey(theme.rawValue.lowercased())).tag(theme)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 80)
                    .controlSize(.small)
                }

                Toggle(isOn: $showPercentage) {
                    HStack {
                        Image(systemName: "percent")
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                        Text("show_percentage")
                            .font(.system(size: 11))
                    }
                }
                .toggleStyle(.switch)
                .controlSize(.small)
            }

            Divider()

            // Terminal options
            VStack(alignment: .leading, spacing: 10) {
                Text("terminal")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Image(systemName: "folder")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)

                    Text(defaultTerminalFolder.isEmpty ? NSLocalizedString("home", value: "Home (~)", comment: "Home dir") : defaultTerminalFolder)
                        .font(.system(size: 11))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(defaultTerminalFolder.isEmpty ? .secondary : .primary)

                    Spacer()

                    if !defaultTerminalFolder.isEmpty {
                        Button(action: { defaultTerminalFolder = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
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
            }

            Divider()

            // Claude options
            VStack(alignment: .leading, spacing: 10) {
                Text("Claude")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)

                Button(action: openSkillsFolder) {
                    HStack {
                        Image(systemName: "folder.badge.gear")
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                        Text("open_skills_folder")
                            .font(.system(size: 11))
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Divider()

            // System options
            VStack(alignment: .leading, spacing: 10) {
                Text("system")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)

                Toggle(isOn: $launchAtLogin) {
                    HStack {
                        Image(systemName: "power")
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                            Text("launch_at_login")
                                .font(.system(size: 11))
                        }
                    }
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .onChange(of: launchAtLogin) { newValue in
                        setLaunchAtLogin(newValue)
                    }
                }

            Divider()

            // About row
            Button(action: {
                withAnimation {
                    onAboutTap()
                }
            }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("about")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)

                    HStack {
                        Text("claude_usage")
                            .font(.system(size: 11))
                        Spacer()
                        Text("v1.0")
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(12)
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

#Preview {
    SettingsView(onAboutTap: {}, onClose: {})
        .frame(width: 320)
        .background(.regularMaterial)
}

struct AboutView: View {
    let onBack: () -> Void
    
    var body: some View {
                    // Content
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image("LogoIcon")
                            .resizable()
                            .frame(width: 80, height: 80)
                        
                        VStack(spacing: 4) {                Text(LocalizedStringKey("claude_usage"))
                    .font(.system(size: 16, weight: .bold))
                
                Text("\(NSLocalizedString("version", comment: "")) 1.0")
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
            
            Text("Copyright © 2026")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(20)
    }
}
