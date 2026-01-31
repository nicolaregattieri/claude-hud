import Foundation

struct CredentialsData {
    let accessToken: String
    let subscriptionType: String?
    let rateLimitTier: String?

    var tierMultiplier: String? {
        guard let tier = rateLimitTier?.lowercased() else { return nil }
        
        // Extract number followed by 'x' (e.g., 5x, 20x)
        if let range = tier.range(of: #"\d+x"#, options: .regularExpression) {
            return String(tier[range]).uppercased()
        }
        
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
