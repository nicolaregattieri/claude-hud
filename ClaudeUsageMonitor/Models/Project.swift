import Foundation

struct Project: Identifiable {
    let id: String           // Folder name encoded
    let name: String         // Last path component (e.g., "aimetric")
    let path: String         // Full decoded path
    let sessions: [ChatSession]

    var sessionCount: Int { sessions.count }
    var lastModified: Date? {
        sessions.map { $0.modified }.max()
    }
}
