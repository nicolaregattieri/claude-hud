import Foundation

class UsageAPI {
    static let endpoint = "https://api.anthropic.com/api/oauth/usage"

    static func fetchUsage() async throws -> UsageData {
        guard let token = KeychainService.getClaudeToken() else {
            throw APIError.noToken
        }

        guard let url = URL(string: endpoint) else {
            throw APIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.timeoutInterval = 30

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw APIError.tokenExpired
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }

            let decoder = JSONDecoder()
            return try decoder.decode(UsageData.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
