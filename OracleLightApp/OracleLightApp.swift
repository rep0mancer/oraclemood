import SwiftUI
import UserNotifications

@main
struct OracleLightApp: App {
    @StateObject private var moodStore = MoodStore.shared
    @StateObject private var errorState = ErrorState()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        // Kick off database setup and scheduler
        Task {
            try? await DatabaseService.shared.setup()
            // Request notification authorization early so prompts can be scheduled
            await requestNotificationAuthorization()
            // Kick off scheduler recomputation for today
            await PromptScheduler.shared.recompute()
        }
    }

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomeView()
                    .environmentObject(moodStore)
                    .environmentObject(errorState)
            } else {
                OnboardingFlowView(hasSeenOnboarding: $hasSeenOnboarding)
                    .environmentObject(moodStore)
                    .environmentObject(errorState)
            }
        }
    }

    /// Requests provisional notification authorization. If the user later
    /// explicitly denies provisional auth we can re-request with an alert.
    private func requestNotificationAuthorization() async {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.provisional, .sound, .badge, .alert]
        do {
            let granted = try await center.requestAuthorization(options: options)
            if !granted {
                // Provisional denied; re‑request full auth on the main queue
                try await center.requestAuthorization(options: [.sound, .badge, .alert])
            }
        } catch {
            // Ignore errors and continue; prompts will fail silently
        }
    }
}

/// App delegate used to set the UNUserNotificationCenter delegate and handle
/// notifications while the app is in the foreground.
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    // Present notifications even when app is in foreground (banner style)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}