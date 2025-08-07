import SwiftUI
import UserNotifications
import OracleLightShared

@main
struct OracleLightApp: App {
    @StateObject private var moodStore = MoodStore.shared
    @StateObject private var errorState = ErrorState()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Respect UI test override for onboarding state if provided
        let args = ProcessInfo.processInfo.arguments
        if let idx = args.firstIndex(of: "-hasSeenOnboarding"), idx + 1 < args.count {
            let raw = args[idx + 1].uppercased()
            let seen = (raw == "YES" || raw == "TRUE" || raw == "1")
            UserDefaults.standard.set(seen, forKey: "hasSeenOnboarding")
        }
        // Kick off database setup and scheduler
        Task {
            do {
                try await DatabaseService.shared.setup()
            } catch {
                await errorState.present(message: "A critical error occurred while initializing the database. Please restart the app. Error: \(error.localizedDescription)")
                return
            }
            await requestNotificationAuthorization()
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await PromptScheduler.shared.recompute() }
            }
        }
    }

    private func requestNotificationAuthorization() async {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.provisional, .sound, .badge, .alert]
        do {
            let granted = try await center.requestAuthorization(options: options)
            if !granted {
                try await center.requestAuthorization(options: [.sound, .badge, .alert])
            }
        } catch {
            // Ignore errors and continue; prompts will fail silently
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}