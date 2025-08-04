import Foundation
import AppIntents
import ActivityKit
import OracleLightShared

/// An `AppIntent` that records a mood entry when invoked from the live
/// activity. Using an intent allows the widget/Live Activity extension to
/// perform data writes through the shared database service without directly
/// referencing the app singleton. After inserting the entry, the intent
/// evaluates any rules and dismisses the active mood selection activity.
@available(iOS 17.0, *)
struct LogMoodIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Mood"

    /// The mood selected by the user. The parameter label is localised via
    /// the default `Mood` description.
    @Parameter(title: "Mood") var mood: Mood

    func perform() async throws -> some IntentResult {
        // Ensure the database is prepared for use in the extension
        try await DatabaseService.shared.prepareIfNeeded()
        // Write the mood to the shared database. Use the liveActivity source.
        try await DatabaseService.shared.insertMood(mood, source: .liveActivity)
        // Reevaluate rules which may trigger a praise/advisory notification.
        await RuleEngine.shared.evaluateRules()
        // Dismiss any ongoing mood selection activity.
        for activity in Activity<MoodSelectionAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        return .result()
    }
}