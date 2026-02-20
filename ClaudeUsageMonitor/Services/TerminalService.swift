import Foundation
import AppKit

enum TerminalApp: String, CaseIterable, Identifiable {
    case terminal = "Terminal"
    case iterm2 = "iTerm2"
    case warp = "Warp"
    case ghostty = "Ghostty"
    case custom = "Custom"

    var id: String { rawValue }

    var bundleIdentifier: String? {
        switch self {
        case .terminal: return "com.apple.Terminal"
        case .iterm2: return "com.googlecode.iterm2"
        case .warp: return "dev.warp.Warp-Stable"
        case .ghostty: return "com.mitchellh.ghostty"
        case .custom: return nil
        }
    }

    var isInstalled: Bool {
        switch self {
        case .custom: return true
        default:
            guard let id = bundleIdentifier else { return false }
            return NSWorkspace.shared.urlForApplication(withBundleIdentifier: id) != nil
        }
    }
}

class TerminalService {
    static let shared = TerminalService()
    private init() {}

    func runCommand(folder: String, command: String, app: TerminalApp, customAppName: String? = nil) {
        switch app {
        case .terminal:
            runInTerminal(folder: folder, command: command)
        case .iterm2:
            runInITerm(folder: folder, command: command)
        case .warp:
            runViaKeystroke(appName: "Warp", folder: folder, command: command)
        case .ghostty:
            runViaKeystroke(appName: "Ghostty", folder: folder, command: command)
        case .custom:
            let name = customAppName ?? "Terminal"
            runViaKeystroke(appName: name, folder: folder, command: command)
        }
    }

    private func runInTerminal(folder: String, command: String) {
        let safePath = folder.replacingOccurrences(of: "'", with: "'\\''")
        let fullCommand = "cd '\(safePath)' && \(command)"
        let applescriptCommand = fullCommand
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "Terminal"
            activate
            do script "\(applescriptCommand)"
        end tell
        """

        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
        }
    }

    private func runInITerm(folder: String, command: String) {
        let safePath = folder.replacingOccurrences(of: "\"", with: "\\\"")
        let safeCommand = command.replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "iTerm"
            activate
            create window with default profile
            tell current session of current window
                write text "cd \\"\(safePath)\\" && \(safeCommand)"
            end tell
        end tell
        """

        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
        }
    }

    /// Generic approach: open the app, create a new tab, type the command via System Events.
    /// Works with Warp, Ghostty, Alacritty, kitty, Hyper, and most terminal emulators.
    private func runViaKeystroke(appName: String, folder: String, command: String) {
        let safePath = folder.replacingOccurrences(of: "'", with: "'\\''")
        let fullCommand = "cd '\(safePath)' && \(command)"
        let applescriptCommand = fullCommand
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "\(appName)"
            activate
        end tell
        delay 0.5
        tell application "System Events"
            tell process "\(appName)"
                keystroke "t" using command down
                delay 0.3
                keystroke "\(applescriptCommand)"
                key code 36
            end tell
        end tell
        """

        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
        }
    }
}
