import Foundation

class UsageAPI {
    static let endpoint = "https://api.anthropic.com/api/oauth/usage"

    static func fetchUsage() async throws -> UsageData {
        print("DEBUG: Starting fetchUsage...")
        guard let token = KeychainService.getClaudeToken() else {
            print("DEBUG: No token found in Keychain")
            throw APIError.noToken
        }
        print("DEBUG: Token found (length: \(token.count))")

        guard let url = URL(string: endpoint) else {
            print("DEBUG: Invalid URL: \(endpoint)")
            throw APIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.timeoutInterval = 30

        print("DEBUG: Sending request to \(url.absoluteString)")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw APIError.tokenExpired
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                print("API returned status code: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                throw APIError.invalidResponse
            }

            let decoder = JSONDecoder()
            return try decoder.decode(UsageData.self, from: data)
        } catch let error as APIError {
            print("DEBUG: APIError caught: \(error)")
            throw error
        } catch let error as DecodingError {
            print("DEBUG: DecodingError: \(error)")
            throw APIError.decodingError(error)
        } catch {
            print("DEBUG: Network/Other Error: \(error)")
            throw APIError.networkError(error)
        }
    }
}
