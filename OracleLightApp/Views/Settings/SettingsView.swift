import SwiftUI
import StoreKit

/// Displays user settings including prompt times, minimum interval, colour palette,
/// and purchase options. Includes an export database button and legal
/// information.
struct SettingsView: View {
    @State private var settings: Settings = Settings.default
    @State private var isPresentingExporter = false
    @StateObject private var purchaseController = PurchaseController()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(header: Text(NSLocalizedString("settings.prompts.section", comment: "Prompt settings section"))) {
                ForEach(settings.promptTimes, id: \ .self) { time in
                    Text(time)
                }
                .onDelete { offsets in
                    settings.promptTimes.remove(atOffsets: offsets)
                }
                Button(action: addTime) {
                    Label(NSLocalizedString("settings.prompts.add", comment: "Add prompt time"), systemImage: "plus")
                }
                Stepper(value: $settings.minimumIntervalMinutes, in: 30...120, step: 15) {
                    Text(String(format: NSLocalizedString("settings.prompts.interval", comment: "Minimum interval label"), settings.minimumIntervalMinutes))
                }
            }
            Section(header: Text(NSLocalizedString("settings.palette.section", comment: "Palette section"))) {
                Picker(NSLocalizedString("settings.palette.label", comment: "Palette picker label"), selection: $settings.palette) {
                    ForEach(Palette.allCases) { palette in
                        Text(palette.rawValue.capitalized).tag(palette)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text(NSLocalizedString("settings.export.section", comment: "Export section"))) {
                Button(action: { isPresentingExporter = true }) {
                    Label(NSLocalizedString("settings.export.button", comment: "Export DB"), systemImage: "square.and.arrow.up")
                }
                // Lock export behind the purchase. Users without the pro
                // entitlement will see the button disabled.
                .disabled(!purchaseController.isPurchased)
            }
            Section(header: Text(NSLocalizedString("settings.legal.section", comment: "Legal section"))) {
                NavigationLink(destination: LicensesView()) {
                    Text(NSLocalizedString("settings.licenses", comment: "Licences"))
                }
                NavigationLink(destination: LegalView()) {
                    Text(NSLocalizedString("settings.legal", comment: "Legal"))
                }
            }
            Section(header: Text(NSLocalizedString("settings.purchase.section", comment: "Purchase section"))) {
                if purchaseController.isPurchased {
                    Text(NSLocalizedString("settings.purchase.thanks", comment: "Thank you text"))
                } else {
                    Button(action: {
                        Task { await purchaseController.purchase() }
                    }) {
                        Text(String(format: NSLocalizedString("settings.purchase.price", comment: "Purchase price"), purchaseController.product?.displayPrice ?? "€7.99"))
                    }
                }
            }
        }
        .navigationTitle(NSLocalizedString("settings.title", comment: "Settings title"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("general.done", comment: "Done button"), action: save)
            }
        }
        .onAppear {
            Task {
                settings = (try? await DatabaseService.shared.fetchSettings()) ?? Settings.default
                // The purchase controller loads its state automatically on init
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
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourcompany.oraclelight")
        let dbURL = container?.appendingPathComponent("oracledb.sqlite")
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
            Text(NSLocalizedString("legal.content", comment: "Legal content"))
                .padding()
        }
        .navigationTitle(NSLocalizedString("settings.legal", comment: "Legal"))
    }
}

/// Placeholder view for displaying third‑party licences. In a production app
/// this would be generated automatically via LicensePlist.
struct LicensesView: View {
    var body: some View {
        List {
            Text(NSLocalizedString("licenses.content", comment: "Licences content"))
        }
        .navigationTitle(NSLocalizedString("settings.licenses", comment: "Licences"))
    }
}