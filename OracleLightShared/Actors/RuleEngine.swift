import Foundation
import UserNotifications
import os.log

/// Evaluates patterns in mood entries and creates rule events when conditions
/// are met. The engine schedules local notifications to inform the user about
/// praise or advisory messages. All methods run off the main thread.
actor RuleEngine {
    static let shared = RuleEngine()

    /// Evaluates rules based on the most recent mood entries. This should be
    /// called after every mood insertion.
    func evaluateRules() async {
        do {
            let entries = try await DatabaseService.shared.fetchMoodEntries()
            try await evaluatePraiseRule(entries: entries)
            try await evaluateAdvisoryRule(entries: entries)
        } catch {
            os_log("Rule evaluation failed: %{public}@", log: .default, type: .error, String(describing: error))
        }
    }

    /// Rule: ≥3 consecutive moods in (Happy|Ecstatic). If triggered, create
    /// a `RuleEvent` of type `.praise`. Rate limited to once per 24h.
    private func evaluatePraiseRule(entries: [MoodEntry]) async throws {
        guard entries.count >= 3 else { return }
        let lastThree = entries.prefix(3)
        let positiveMoods: Set<Mood> = [.happy, .ecstatic]
        let allPositive = lastThree.allSatisfy { positiveMoods.contains($0.mood) }
        guard allPositive else { return }
        let events = try await DatabaseService.shared.fetchRuleEvents()
        let now = Date()
        // Rate limit across both praise and advisory events: if any rule
        // notification occurred in the last 24 hours, skip. This prevents
        // back-to-back praise and advisory banners when moods change quickly.
        if let lastEvent = events.last {
            if now.timeIntervalSince(lastEvent.triggeredAt) < 24 * 60 * 60 {
                return
            }
        }
        try await DatabaseService.shared.insertRuleEvent(type: .praise)
        scheduleLocalNotification(for: .praise)
    }

    /// Rule: ≥5 moods in (Sad|Angry) within rolling 48 h window. If triggered,
    /// create a `RuleEvent` of type `.advisory`. Rate limited to once per 24h.
    private func evaluateAdvisoryRule(entries: [MoodEntry]) async throws {
        guard !entries.isEmpty else { return }
        let now = Date()
        let windowStart = now.addingTimeInterval(-48 * 60 * 60)
        let negativeMoods: Set<Mood> = [.angry, .sad]
        let count = entries.filter { $0.timestamp >= windowStart && negativeMoods.contains($0.mood) }.count
        guard count >= 5 else { return }
        let events = try await DatabaseService.shared.fetchRuleEvents()
        // Rate limit across both rule types. Skip if any event happened less than
        // 24 hours ago.
        if let lastEvent = events.last {
            if now.timeIntervalSince(lastEvent.triggeredAt) < 24 * 60 * 60 {
                return
            }
        }
        try await DatabaseService.shared.insertRuleEvent(type: .advisory)
        scheduleLocalNotification(for: .advisory)
    }

    /// Schedules a local banner notification to be delivered at next unlock.
    private func scheduleLocalNotification(for type: RuleType) {
        let content = UNMutableNotificationContent()
        switch type {
        case .praise:
            content.title = NSLocalizedString("notification.praise.title", comment: "Praise rule title")
            content.body = NSLocalizedString("notification.praise.body", comment: "Praise rule body")
        case .advisory:
            content.title = NSLocalizedString("notification.advisory.title", comment: "Advisory rule title")
            content.body = NSLocalizedString("notification.advisory.body", comment: "Advisory rule body")
        }
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                os_log("Failed to schedule rule notification: %{public}@", log: .default, type: .error, String(describing: error))
            }
        }
    }
}