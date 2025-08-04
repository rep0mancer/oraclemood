import Foundation
import Combine
// Import the shared module so that RuleEngine resolves to the shared
// implementation rather than the (disabled) application copy. This avoids
// duplicate symbol conflicts when linking.
import OracleLightShared

/// Stores mood entries and publishes updates to subscribers. All interactions
/// occur on a background actor to avoid blocking the main thread. Consumers
/// receive updates on the main queue via Combine.
final class MoodStore: ObservableObject {
    static let shared = MoodStore()

    @Published private(set) var entries: [MoodEntry] = []
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Load initial entries from the database
        Task {
            await refresh(errorHandler: ErrorState())
        }
    }

    /// Inserts a new mood and publishes the updated list. Also triggers rule
    /// evaluation via the RuleEngine.
    func insert(mood: Mood, source: SourceType, errorHandler: ErrorState) async {
        do {
            try await DatabaseService.shared.insertMood(mood, source: source)
            await refresh(errorHandler: errorHandler)
            await RuleEngine.shared.evaluateRules()
        } catch {
            await errorHandler.present(error: error)
        }
    }

    /// Reloads entries from the database and publishes them.
    func refresh(errorHandler: ErrorState) async {
        do {
            let fetched = try await DatabaseService.shared.fetchMoodEntries()
            await MainActor.run { self.entries = fetched }
        } catch {
            await errorHandler.present(error: error)
        }
    }
}