import Foundation
import AppKit

enum TerminalApp: String, CaseIterable, Identifiable {
    case terminal = "Terminal"
    case iterm2 = "iTerm2"
    case warp = "Warp"

    var id: String { rawValue }

    var bundleIdentifier: String {
        switch self {
        case .terminal: return "com.apple.Terminal"
        case .iterm2: return "com.googlecode.iterm2"
        case .warp: return "dev.warp.Warp-Stable"
        }
    }

    var isInstalled: Bool {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) != nil
    }
}

class TerminalService {
    static let shared = TerminalService()
    private init() {}

    func runCommand(folder: String, command: String, app: TerminalApp) {
        switch app {
        case .terminal:
            runInTerminal(folder: folder, command: command)
        case .iterm2:
            runInITerm(folder: folder, command: command)
        case .warp:
            runInWarp(folder: folder, command: command)
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

    private func runInWarp(folder: String, command: String) {
        let safePath = folder.replacingOccurrences(of: "'", with: "'\\''")
        let fullCommand = "cd '\(safePath)' && \(command)"
        let applescriptCommand = fullCommand
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        // Warp supports AppleScript similar to Terminal
        let script = """
        tell application "Warp"
            activate
        end tell
        delay 0.5
        tell application "System Events"
            tell process "Warp"
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
