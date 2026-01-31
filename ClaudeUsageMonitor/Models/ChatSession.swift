import Foundation

struct ChatSession: Identifiable {
    let sessionId: String
    let firstPrompt: String
    let summary: String?
    let messageCount: Int
    let created: Date
    let modified: Date
    let gitBranch: String?
    let projectPath: String

    var id: String { sessionId }

    var displayTitle: String {
        if let summary = summary, !summary.isEmpty {
            return summary
        }
        let truncated = String(firstPrompt.prefix(50))
        return firstPrompt.count > 50 ? truncated + "..." : truncated
    }
}

// For decoding sessions-index.json
struct SessionsIndex: Codable {
    let version: Int
    let entries: [SessionEntry]
    let originalPath: String
}

struct SessionEntry: Codable {
    let sessionId: String
    let firstPrompt: String
    let summary: String?
    let messageCount: Int
    let created: String
    let modified: String
    let gitBranch: String?
    let projectPath: String

    // Custom keys to handle missing optional fields
    enum CodingKeys: String, CodingKey {
        case sessionId, firstPrompt, summary, messageCount, created, modified, gitBranch, projectPath
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionId = try container.decode(String.self, forKey: .sessionId)
        firstPrompt = try container.decode(String.self, forKey: .firstPrompt)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        messageCount = try container.decode(Int.self, forKey: .messageCount)
        created = try container.decode(String.self, forKey: .created)
        modified = try container.decode(String.self, forKey: .modified)
        gitBranch = try container.decodeIfPresent(String.self, forKey: .gitBranch)
        projectPath = try container.decode(String.self, forKey: .projectPath)
    }

    func toChatSession() -> ChatSession {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return ChatSession(
            sessionId: sessionId,
            firstPrompt: firstPrompt,
            summary: summary,
            messageCount: messageCount,
            created: dateFormatter.date(from: created) ?? Date(),
            modified: dateFormatter.date(from: modified) ?? Date(),
            gitBranch: gitBranch,
            projectPath: projectPath
        )
    }
}
