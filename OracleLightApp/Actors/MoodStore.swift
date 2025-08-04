import Foundation
import Combine
import os.log
// Import the shared module so that RuleEngine resolves to the shared
// implementation rather than the (disabled) application copy. This avoids
// duplicate symbol conflicts when linking.
import OracleLightShared

/// Stores mood entries and publishes updates to subscribers. All interactions
/// occur on a background actor to avoid blocking the main thread. Consumers
/// receive updates on the main queue via Combine.
@MainActor
final class MoodStore: ObservableObject {
    static let shared = MoodStore()

    @Published private(set) var entries: [MoodEntry] = []
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Load initial entries from the database
        Task {
            await refresh()
        }
    }

    /// Inserts a new mood and publishes the updated list. Also triggers rule
    /// evaluation via the RuleEngine.
    func insert(mood: Mood, source: SourceType) async {
        do {
            try await DatabaseService.shared.insertMood(mood, source: source)
            await refresh()
            await RuleEngine.shared.evaluateRules()
        } catch {
            os_log("Failed to insert mood: %{public}@", log: .default, type: .error, String(describing: error))
        }
    }

    /// Reloads entries from the database and publishes them.
    func refresh() async {
        do {
            let fetched = try await DatabaseService.shared.fetchMoodEntries()
            self.entries = fetched
        } catch {
            os_log("Failed to fetch mood entries: %{public}@", log: .default, type: .error, String(describing: error))
        }
    }
}