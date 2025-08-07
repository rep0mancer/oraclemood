// Generated via SwiftGen — DO NOT EDIT MANUALLY
// swiftlint:disable all

import Foundation

/// Provides type‑safe accessors for localized strings used throughout the app.
internal enum L10n {
    // Mood names
    internal static let moodAngry = NSLocalizedString("mood.angry", comment: "Angry mood")
    internal static let moodSad = NSLocalizedString("mood.sad", comment: "Sad mood")
    internal static let moodNeutral = NSLocalizedString("mood.neutral", comment: "Neutral mood")
    internal static let moodContent = NSLocalizedString("mood.content", comment: "Content mood")
    internal static let moodHappy = NSLocalizedString("mood.happy", comment: "Happy mood")
    internal static let moodJoyful = NSLocalizedString("mood.joyful", comment: "Joyful mood")
    internal static let moodEcstatic = NSLocalizedString("mood.ecstatic", comment: "Ecstatic mood")

    // Palette names
    internal static let paletteVivid = NSLocalizedString("palette.vivid", comment: "Vivid palette")
    internal static let palettePastel = NSLocalizedString("palette.pastel", comment: "Pastel palette")
    internal static let paletteDark = NSLocalizedString("palette.dark", comment: "Dark palette")

    // Notifications
    internal static let notificationPraiseTitle = NSLocalizedString("notification.praise.title", comment: "Praise rule title")
    internal static let notificationPraiseBody = NSLocalizedString("notification.praise.body", comment: "Praise rule body")
    internal static let notificationAdvisoryTitle = NSLocalizedString("notification.advisory.title", comment: "Advisory rule title")
    internal static let notificationAdvisoryBody = NSLocalizedString("notification.advisory.body", comment: "Advisory rule body")
    internal static let notificationPromptTitle = NSLocalizedString("notification.prompt.title", comment: "Mood prompt title")
    internal static let notificationPromptBody = NSLocalizedString("notification.prompt.body", comment: "Mood prompt body")

    // Onboarding
    internal static let onboardingPrivacyTitle = NSLocalizedString("onboarding.privacy.title", comment: "Privacy oath title")
    internal static let onboardingPrivacyBody = NSLocalizedString("onboarding.privacy.body", comment: "Privacy oath body")
    internal static let onboardingPromptsTitle = NSLocalizedString("onboarding.prompts.title", comment: "Prompt schedule title")
    internal static func onboardingPromptsInterval(_ p0: Int) -> String {
        return String(format: NSLocalizedString("onboarding.prompts.interval", comment: "Minimum interval"), p0)
    }
    internal static let onboardingPaletteTitle = NSLocalizedString("onboarding.palette.title", comment: "Palette selection title")
    internal static let onboardingFinish = NSLocalizedString("onboarding.finish", comment: "Finish button")

    // General buttons
    internal static let generalContinue = NSLocalizedString("general.continue", comment: "Continue button")
    internal static let generalDone = NSLocalizedString("general.done", comment: "Done button")
    internal static let generalOk = NSLocalizedString("general.ok", comment: "OK button")

    // Errors
    internal static let errorTitle = NSLocalizedString("error.title", comment: "Generic error title")

    // Home tabs
    internal static let homeTabDaily = NSLocalizedString("home.tab.daily", comment: "Daily")
    internal static let homeTabWeekly = NSLocalizedString("home.tab.weekly", comment: "Weekly")
    internal static let homeTabMonthly = NSLocalizedString("home.tab.monthly", comment: "Monthly")
    internal static let homeTitle = NSLocalizedString("home.title", comment: "Home title")

    // Charts
    internal static let chartYAxisMood = NSLocalizedString("chart.yaxis.mood", comment: "Mood axis")
    internal static let chartXAxisTime = NSLocalizedString("chart.xaxis.time", comment: "Time axis")
    internal static let chartXAxisDayOfWeek = NSLocalizedString("chart.xaxis.dayofweek", comment: "Day of week axis")
    internal static let chartXAxisDay = NSLocalizedString("chart.xaxis.day", comment: "Day axis")
    internal static let chartYAxisHour = NSLocalizedString("chart.yaxis.hour", comment: "Hour axis")

    // Settings
    internal static let settingsTitle = NSLocalizedString("settings.title", comment: "Settings title")
    internal static let settingsPromptsSection = NSLocalizedString("settings.prompts.section", comment: "Prompt settings section")
    internal static let settingsPromptsAdd = NSLocalizedString("settings.prompts.add", comment: "Add prompt time")
    internal static func settingsPromptsInterval(_ p0: Int) -> String {
        return String(format: NSLocalizedString("settings.prompts.interval", comment: "Minimum interval label"), p0)
    }
    internal static let settingsPaletteSection = NSLocalizedString("settings.palette.section", comment: "Palette section")
    internal static let settingsPaletteLabel = NSLocalizedString("settings.palette.label", comment: "Palette picker label")
    internal static let settingsExportSection = NSLocalizedString("settings.export.section", comment: "Export section")
    internal static let settingsExportButton = NSLocalizedString("settings.export.button", comment: "Export DB")
    internal static let settingsLegalSection = NSLocalizedString("settings.legal.section", comment: "Legal section")
    internal static let settingsLicenses = NSLocalizedString("settings.licenses", comment: "Licences")
    internal static let settingsLegal = NSLocalizedString("settings.legal", comment: "Legal")
    internal static let settingsPurchaseSection = NSLocalizedString("settings.purchase.section", comment: "Purchase section")
    internal static func settingsPurchasePrice(_ p0: String) -> String {
        return String(format: NSLocalizedString("settings.purchase.price", comment: "Purchase price"), p0)
    }
    internal static let settingsPurchaseThanks = NSLocalizedString("settings.purchase.thanks", comment: "Thank you text")

    // Legal & licences
    internal static let legalContent = NSLocalizedString("legal.content", comment: "Legal content")
    internal static let licensesContent = NSLocalizedString("licenses.content", comment: "Licences content")
}