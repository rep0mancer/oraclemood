import Foundation
import UserNotifications
import os.log

/// Computes and schedules mood prompt notifications based on user settings and
/// existing mood entries. Prompts are scheduled in batches for the next week
/// whenever settings change, onboarding completes or the app becomes active.
/// This avoids relying on an unreliable nightly timer and ensures prompts
/// respect minimum spacing and skip times near manual entries.
actor PromptScheduler {
    static let shared = PromptScheduler()

    private let calendar = Calendar.current

    init() {
        // When the scheduler is first created, compute the upcoming prompts for
        // the next week. Subsequent recomputations occur when settings change
        // or when the app enters foreground. iOS will persist pending
        // notifications across launches so there is no need for a nightly timer.
        Task { await recompute() }
    }

    /// Computes and schedules mood prompts for the next seven days. Existing
    /// notifications prefixed with `mood-prompt-` are removed before new
    /// triggers are registered. For each day, all user‑configured prompt times
    /// are considered, then filtered to respect the minimum interval and
    /// proximity to manual mood entries. Prompts beyond one week are not
    /// scheduled to avoid a proliferation of pending requests.
    func recompute() async {
        do {
            let settings = try await DatabaseService.shared.fetchSettings()
            let entries = try await DatabaseService.shared.fetchMoodEntries()

            let center = UNUserNotificationCenter.current()
            // Remove existing prompt notifications
            let pending = await center.pendingNotificationRequests()
            let prefix = "mood-prompt-"
            let idsToRemove = pending.filter { $0.identifier.hasPrefix(prefix) }.map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: idsToRemove)

            // Build a list of candidate dates spanning the next seven days
            let now = Date()
            var candidateDates: [Date] = []
            let formatter = ISO8601DateFormatter()
            for dayOffset in 0..<7 {
                for timeString in settings.promptTimes {
                    let comps = timeString.split(separator: ":").map(String.init)
                    guard comps.count == 2,
                          let hour = Int(comps[0]),
                          let minute = Int(comps[1]) else { continue }
                    var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
                    dateComponents.day = (dateComponents.day ?? 1) + dayOffset
                    dateComponents.hour = hour
                    dateComponents.minute = minute
                    if let date = calendar.date(from: dateComponents) {
                        // Only schedule prompts in the future
                        if date > now {
                            candidateDates.append(date)
                        }
                    }
                }
            }
            // Sort chronological
            candidateDates.sort()
            // Enforce minimum interval and skip near manual entries
            var scheduled: [Date] = []
            for date in candidateDates {
                if let last = scheduled.last, date.timeIntervalSince(last) < Double(settings.minimumIntervalMinutes * 60) {
                    continue
                }
                // Skip if there is a manual entry within ±45 minutes
                let nearManual = entries.contains { entry in
                    entry.source == .inApp && abs(date.timeIntervalSince(entry.timestamp)) < 45 * 60
                }
                if nearManual { continue }
                scheduled.append(date)
            }
            // Schedule notifications
            for date in scheduled {
                var triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                triggerDate.timeZone = .current
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                let content = UNMutableNotificationContent()
                content.title = NSLocalizedString("notification.prompt.title", comment: "Mood prompt title")
                content.body = NSLocalizedString("notification.prompt.body", comment: "Mood prompt body")
                content.sound = .default
                let identifier = prefix + formatter.string(from: date)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                center.add(request) { error in
                    if let error = error {
                        os_log("Failed to schedule prompt: %{public}@", log: .default, type: .error, String(describing: error))
                    }
                }
            }
        } catch {
            os_log("Failed to recompute schedule: %{public}@", log: .default, type: .error, String(describing: error))
        }
    }
}