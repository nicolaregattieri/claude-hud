import Foundation

struct UsageData: Codable {
    let fiveHour: UsageMetric?
    let sevenDay: UsageMetric?
    let sevenDayOpus: UsageMetric?
    let sevenDaySonnet: UsageMetric?

    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
        case sevenDayOpus = "seven_day_opus"
        case sevenDaySonnet = "seven_day_sonnet"
    }
}

struct UsageMetric: Codable {
    let utilization: Double
    let resetsAt: String?

    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }

    var resetsAtDate: Date? {
        guard let resetsAt = resetsAt else { return nil }

        // Try ISO8601 with fractional seconds and timezone
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: resetsAt) {
            return date
        }

        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: resetsAt) {
            return date
        }

        // Try DateFormatter for custom formats
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        if let date = dateFormatter.date(from: resetsAt) {
            return date
        }

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return dateFormatter.date(from: resetsAt)
    }
}

enum APIError: Error, LocalizedError {
    case noToken
    case tokenExpired
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .noToken:
            return NSLocalizedString("no_token", value: "No Claude token found in Keychain", comment: "Error when token is missing")
        case .tokenExpired:
            return NSLocalizedString("token_expired", value: "Session expired", comment: "Error when token is expired")
        case .invalidResponse:
            return NSLocalizedString("invalid_response", value: "Invalid response from API", comment: "Error when API response is invalid")
        case .networkError(let error):
            return String(format: NSLocalizedString("network_error", value: "Network error: %@", comment: "Network error"), error.localizedDescription)
        case .decodingError(let error):
            return String(format: NSLocalizedString("decoding_error", value: "Decoding error: %@", comment: "Decoding error"), error.localizedDescription)
        }
    }
}
