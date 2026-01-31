import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@main
struct ClaudeUsageMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .system

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
                .preferredColorScheme(selectedTheme.colorScheme)
                .onAppear {
                    applyTheme(selectedTheme)
                }
                .onChange(of: selectedTheme) { newValue in
                    applyTheme(newValue)
                }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "flame")
                if let percentage = appState.currentUsagePercentage {
                    Text("\(percentage)%")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                }
            }
        }
        .menuBarExtraStyle(.window)
    }

    private func applyTheme(_ theme: AppTheme) {
        switch theme {
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        case .system:
            NSApp.appearance = nil
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        if !hasSeenOnboarding {
            WindowManager.shared.openOnboarding()
        }
    }
}

class AppState: ObservableObject {
    @Published var currentUsagePercentage: Int?

    init() {
        fetchUsage()

        // Refresh every 60 seconds
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.fetchUsage()
        }
    }

    func fetchUsage() {
        Task {
            do {
                let data = try await UsageAPI.fetchUsage()
                await MainActor.run {
                    if let fiveHour = data.fiveHour {
                        self.currentUsagePercentage = Int(fiveHour.utilization)
                    }
                }
            } catch {
                print("Failed to fetch usage: \(error)")
            }
        }
    }
}

// MARK: - Window Manager
class WindowManager: NSObject {
    static let shared = WindowManager()
    
    var onboardingWindow: NSWindow?
    
    private override init() {}
    
    func openOnboarding() {
        print("DEBUG: WindowManager.openOnboarding called")
        
        NSApp.activate(ignoringOtherApps: true)
        
        if let window = onboardingWindow {
            window.makeKeyAndOrderFront(nil)
            return
        }

        let hostingController = NSHostingController(rootView: OnboardingView())
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 450),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.contentViewController = hostingController
        window.title = ""
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isReleasedWhenClosed = false
        window.level = .floating
        
        self.onboardingWindow = window
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @Environment(\.dismiss) var dismiss
    
    @State private var hasToken: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon & Title
            VStack(spacing: 16) {
                if let appIcon = NSImage(named: "AppIcon") {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 80, height: 80)
                } else {
                    Image(systemName: "flame.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.orange)
                }
                
                Text(LocalizedStringKey("welcome_title"))
                    .font(.system(size: 24, weight: .bold))
                
                Text(LocalizedStringKey("welcome_subtitle"))
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
            }
            
            Divider()
            
            // Status Checks
            VStack(alignment: .leading, spacing: 12) {
                StatusRow(
                    icon: "terminal.fill",
                    text: "status_cli",
                    isValid: true
                )
                
                StatusRow(
                    icon: "key.fill",
                    text: "status_token",
                    isValid: hasToken
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Action
            VStack(spacing: 12) {
                Text(LocalizedStringKey("privacy_disclaimer"))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true) // Prevents truncation
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)

                if !hasToken {
                    Text(LocalizedStringKey("token_missing_hint"))
                        .font(.system(size: 11))
                        .foregroundStyle(.red)
                }
                
                Button(action: {
                    hasSeenOnboarding = true
                    if let window = NSApp.windows.first(where: { $0.contentViewController is NSHostingController<OnboardingView> }) {
                        window.close()
                    }
                }) {
                    Text(LocalizedStringKey("get_started"))
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.blue)
            }
            .padding(.bottom, 20)
        }
        .padding(30)
        .frame(width: 400, height: 470)
        .onAppear {
            checkStatus()
        }
    }
    
    private func checkStatus() {
        hasToken = KeychainService.getClaudeToken() != nil
    }
}

struct StatusRow: View {
    let icon: String
    let text: String
    let isValid: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            Text(LocalizedStringKey(text))
                .font(.system(size: 13))
            
            Spacer()
            
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
        }
        .padding(10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
