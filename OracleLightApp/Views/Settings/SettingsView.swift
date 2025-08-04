import SwiftUI
import StoreKit
import OracleLightShared

/// Displays user settings including prompt times, minimum interval, colour palette,
/// and purchase options. Includes an export database button and legal
/// information.
struct SettingsView: View {
    @State private var settings: Settings = Settings.default
    @State private var isPresentingExporter = false
    @StateObject private var purchaseController = PurchaseController()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var errorState: ErrorState

    var body: some View {
        Form {
            Section(header: Text(L10n.settingsPromptsSection)) {
                ForEach(settings.promptTimes, id: \ .self) { time in
                    Text(time)
                }
                .onDelete { offsets in
                    settings.promptTimes.remove(atOffsets: offsets)
                }
                Button(action: addTime) {
                    Label(L10n.settingsPromptsAdd, systemImage: "plus")
                }
                Stepper(value: $settings.minimumIntervalMinutes, in: 30...120, step: 15) {
                    Text(L10n.settingsPromptsInterval(settings.minimumIntervalMinutes))
                }
            }
            Section(header: Text(L10n.settingsPaletteSection)) {
                Picker(L10n.settingsPaletteLabel, selection: $settings.palette) {
                    ForEach(Palette.allCases) { palette in
                        Text(palette.localizedName).tag(palette)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text(L10n.settingsExportSection)) {
                Button(action: { isPresentingExporter = true }) {
                    Label(L10n.settingsExportButton, systemImage: "square.and.arrow.up")
                }
                // Lock export behind the purchase. Users without the pro
                // entitlement will see the button disabled.
                .disabled(!purchaseController.isPurchased)
            }
            Section(header: Text(L10n.settingsLegalSection)) {
                NavigationLink(destination: LicensesView()) {
                    Text(L10n.settingsLicenses)
                }
                NavigationLink(destination: LegalView()) {
                    Text(L10n.settingsLegal)
                }
            }
            Section(header: Text(L10n.settingsPurchaseSection)) {
                if purchaseController.isPurchased {
                    Text(L10n.settingsPurchaseThanks)
                } else if let product = purchaseController.product {
                    Button(action: {
                        Task { await purchaseController.purchase(errorHandler: errorState) }
                    }) {
                        Text(L10n.settingsPurchasePrice(product.displayPrice))
                    }
                } else {
                    // Product information is not yet available.
                    ProgressView("Loading store information...")
                }
            }
        }
        .navigationTitle(L10n.settingsTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(L10n.generalDone, action: save)
            }
        }
        .onAppear {
            Task {
                do {
                    settings = try await DatabaseService.shared.fetchSettings()
                    // The purchase controller loads its state automatically on init
                } catch {
                    await errorState.present(error: error)
                }
            }
        }
        .fileExporter(isPresented: $isPresentingExporter, document: DBExportDocument()) { _ in }
    }

    private func addTime() {
        // Add current time (rounded to next half hour) as new prompt
        let calendar = Calendar.current
        let date = Date()
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        var hour = comps.hour ?? 0
        var minute = comps.minute ?? 0
        // Round up to nearest 30 minutes
        if minute > 30 { hour += 1; minute = 0 } else if minute > 0 { minute = 30 }
        let timeString = String(format: "%02d:%02d", hour, minute)
        if !settings.promptTimes.contains(timeString) {
            settings.promptTimes.append(timeString)
            settings.promptTimes.sort()
        }
    }

    private func save() {
        Task {
            try? await DatabaseService.shared.updateSettings(settings)
            await PromptScheduler.shared.recompute()
            dismiss()
        }
    }

}

/// Represents a document for exporting the encrypted database. It compresses the
/// SQLite file using ZIP with a password supplied by the user. The actual
/// zipping logic is simplified here.
struct DBExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.data] }
    let data: Data

    init() {
        // Read the database file from the shared App Group into memory. In a real
        // implementation you would compress and password‑protect the file.
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConfig.appGroupIdentifier)
        let dbURL = container?.appendingPathComponent(AppConfig.databaseFilename)
        self.data = (try? Data(contentsOf: dbURL ?? URL(fileURLWithPath: "/dev/null"))) ?? Data()
    }
    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(regularFileWithContents: data)
    }
}

/// Placeholder view for displaying legal documents.
struct LegalView: View {
    var body: some View {
        ScrollView {
            Text(L10n.legalContent)
                .padding()
        }
        .navigationTitle(L10n.settingsLegal)
    }
}

/// Placeholder view for displaying third‑party licences. In a production app
/// this would be generated automatically via LicensePlist.
struct LicensesView: View {
    var body: some View {
        List {
            Text(L10n.licensesContent)
        }
        .navigationTitle(L10n.settingsLicenses)
    }
}