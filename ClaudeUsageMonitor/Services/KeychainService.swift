import Foundation
import Security

class KeychainService {
    private static let serviceName = "Claude Code-credentials"

    static func getClaudeToken() -> String? {
        // First try using security command (more reliable for CLI-created entries)
        if let token = getTokenViaSecurityCommand() {
            return token
        }
        // Fallback to Security framework
        return getTokenViaSecurityFramework()
    }

    private static func getTokenViaSecurityCommand() -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = ["find-generic-password", "-s", serviceName, "-w"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                return nil
            }

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let jsonString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return nil
            }

            return parseAccessToken(from: jsonString)
        } catch {
            print("Security command failed: \(error)")
            return nil
        }
    }

    private static func getTokenViaSecurityFramework() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }

        return parseAccessToken(from: jsonString)
    }

    private static func parseAccessToken(from jsonString: String) -> String? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // Try claudeAiOauth.accessToken first (new format)
                if let claudeAiOauth = json["claudeAiOauth"] as? [String: Any],
                   let accessToken = claudeAiOauth["accessToken"] as? String {
                    return accessToken
                }
                // Fallback to direct accessToken (old format)
                if let accessToken = json["accessToken"] as? String {
                    return accessToken
                }
            }
        } catch {
            print("JSON parsing failed: \(error)")
        }

        return nil
    }

    // MARK: - Get Full Credentials (with tier info)

    static func getCredentials() -> CredentialsData? {
        // First try using security command (more reliable for CLI-created entries)
        if let credentials = getCredentialsViaSecurityCommand() {
            return credentials
        }
        // Fallback to Security framework
        return getCredentialsViaSecurityFramework()
    }

    private static func getCredentialsViaSecurityCommand() -> CredentialsData? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = ["find-generic-password", "-s", serviceName, "-w"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                return nil
            }

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let jsonString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return nil
            }

            return parseCredentials(from: jsonString)
        } catch {
            print("Security command failed: \(error)")
            return nil
        }
    }

    private static func getCredentialsViaSecurityFramework() -> CredentialsData? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }

        return parseCredentials(from: jsonString)
    }

    private static func parseCredentials(from jsonString: String) -> CredentialsData? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // Try claudeAiOauth first (new format)
                if let claudeAiOauth = json["claudeAiOauth"] as? [String: Any],
                   let accessToken = claudeAiOauth["accessToken"] as? String {
                    return CredentialsData(
                        accessToken: accessToken,
                        subscriptionType: claudeAiOauth["subscriptionType"] as? String,
                        rateLimitTier: claudeAiOauth["rateLimitTier"] as? String
                    )
                }
                // Fallback to direct accessToken (old format)
                if let accessToken = json["accessToken"] as? String {
                    return CredentialsData(
                        accessToken: accessToken,
                        subscriptionType: nil,
                        rateLimitTier: nil
                    )
                }
            }
        } catch {
            print("JSON parsing failed: \(error)")
        }

        return nil
    }
}
