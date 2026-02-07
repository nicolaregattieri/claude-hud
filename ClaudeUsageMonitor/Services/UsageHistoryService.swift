import Foundation

struct UsageSnapshot: Codable {
    let timestamp: Date
    let sessionUtilization: Double
    let weeklyUtilization: Double
}

class UsageHistoryService {
    static let shared = UsageHistoryService()
    private let maxEntries = 288 // 24h at 5-min intervals
    private let historyURL: URL

    private init() {
        historyURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/usage-history.json")
    }

    func record(session: Double, weekly: Double) {
        var history = load()
        let snapshot = UsageSnapshot(
            timestamp: Date(),
            sessionUtilization: session,
            weeklyUtilization: weekly
        )
        history.append(snapshot)

        // Keep only last 24h
        let cutoff = Date().addingTimeInterval(-86400)
        history = history.filter { $0.timestamp > cutoff }

        // Cap entries
        if history.count > maxEntries {
            history = Array(history.suffix(maxEntries))
        }

        save(history)
    }

    func load() -> [UsageSnapshot] {
        guard let data = try? Data(contentsOf: historyURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([UsageSnapshot].self, from: data)) ?? []
    }

    func sessionHistory() -> [Double] {
        load().map { $0.sessionUtilization }
    }

    func weeklyHistory() -> [Double] {
        load().map { $0.weeklyUtilization }
    }

    private func save(_ history: [UsageSnapshot]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(history) else { return }
        try? data.write(to: historyURL, options: .atomic)
    }
}
