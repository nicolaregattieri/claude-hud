import Foundation

class ProjectsService {
    static let shared = ProjectsService()

    private let projectsPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".claude/projects")

    private init() {}

    func loadProjects() -> [Project] {
        var projects: [Project] = []

        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: projectsPath,
            includingPropertiesForKeys: nil
        ) else {
            print("[ProjectsService] Could not read projects directory")
            return []
        }

        for folder in contents where folder.hasDirectoryPath {
            let folderName = folder.lastPathComponent
            guard folderName.hasPrefix("-") else { continue }

            // Load sessions index to get the real path
            let sessionsIndexURL = folder.appendingPathComponent("sessions-index.json")

            guard let data = try? Data(contentsOf: sessionsIndexURL),
                  let index = try? JSONDecoder().decode(SessionsIndex.self, from: data) else {
                print("[ProjectsService] Could not decode sessions-index.json for \(folderName)")
                continue
            }

            // Use originalPath from JSON (more reliable than decoding folder name)
            let projectPath = index.originalPath
            let projectName = URL(fileURLWithPath: projectPath).lastPathComponent

            let sessions = index.entries
                .map { $0.toChatSession() }
                .sorted { $0.modified > $1.modified }

            // Only include projects that have sessions
            guard !sessions.isEmpty else { continue }

            let project = Project(
                id: folderName,
                name: projectName,
                path: projectPath,
                sessions: sessions
            )
            projects.append(project)
        }

        // Sort by last modified
        return projects.sorted { ($0.lastModified ?? .distantPast) > ($1.lastModified ?? .distantPast) }
    }
}
