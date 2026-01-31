import Foundation

struct CredentialsData {
    let accessToken: String
    let subscriptionType: String?
    let rateLimitTier: String?

    var tierMultiplier: String? {
        guard let tier = rateLimitTier else { return nil }
        if tier.contains("20x") { return "20X" }
        if tier.contains("5x") { return "5X" }
        return nil
    }

    var subscriptionLabel: String {
        switch subscriptionType?.lowercased() {
        case "max": return "Claude Max"
        case "pro": return "Claude Pro"
        default: return "Claude"
        }
    }
}
