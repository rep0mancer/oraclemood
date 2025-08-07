import SwiftUI
import OracleLightShared

/// Root view that orchestrates the onboarding flow. It presents a sequence of
/// screens for the privacy oath, prompt scheduling, and palette selection. Once
/// the flow is completed the binding `hasSeenOnboarding` is set and the app
/// transitions to the home screen.
struct OnboardingFlowView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var step: Step = .privacy
    @State private var settings: Settings = Settings.default
    @EnvironmentObject var errorState: ErrorState

    enum Step {
        case privacy
        case prompts
        case palette
    }

    var body: some View {
        VStack {
            switch step {
            case .privacy:
                PrivacyOathView(onContinue: {
                    step = .prompts
                })
            case .prompts:
                PromptSchedulerEditView(settings: $settings, onContinue: {
                    step = .palette
                })
            case .palette:
                PaletteSelectionView(selected: $settings.palette, onFinish: finish)
            }
        }
        .onAppear {
            Task {
                do {
                    // Load existing settings from the database to prefill prompt times
                    settings = try await DatabaseService.shared.fetchSettings()
                } catch {
                    await errorState.present(error: error)
                }
            }
        }
    }

    private func finish() {
        Task {
            // Save settings to database
            try? await DatabaseService.shared.updateSettings(settings)
            // Reschedule prompts
            await PromptScheduler.shared.recompute()
            // Mark onboarding as complete
            hasSeenOnboarding = true
        }
    }
}

struct PrivacyOathView: View {
    let onContinue: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text(L10n.onboardingPrivacyTitle)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            Text(L10n.onboardingPrivacyBody)
                .multilineTextAlignment(.leading)
            Spacer()
            Button(action: onContinue) {
                Text(L10n.generalContinue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .accessibilityIdentifier("PrivacyContinueButton")
        }
        .padding()
    }
}

struct PromptSchedulerEditView: View {
    @Binding var settings: Settings
    let onContinue: () -> Void
    @State private var newTime: Date = Date()

    var body: some View {
        VStack {
            Text(L10n.onboardingPromptsTitle)
                .font(.title2)
                .padding(.top)
            List {
                ForEach(settings.promptTimes, id: \.self) { time in
                    HStack {
                        Text(time)
                        Spacer()
                    }
                }
                .onDelete { indices in
                    settings.promptTimes.remove(atOffsets: indices)
                }
                HStack {
                    DatePicker("", selection: $newTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    Button(action: addTime) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .disabled(!canAddTime)
                }
            }
            .listStyle(.plain)
            Stepper(value: $settings.minimumIntervalMinutes, in: 30...120, step: 15) {
                Text(L10n.onboardingPromptsInterval(settings.minimumIntervalMinutes))
            }
            .padding()
            Button(action: onContinue) {
                Text(L10n.generalContinue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
    }

    private var canAddTime: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: newTime)
        return !settings.promptTimes.contains(timeString)
    }

    private func addTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: newTime)
        settings.promptTimes.append(timeString)
        settings.promptTimes.sort()
    }
}

struct PaletteSelectionView: View {
    @Binding var selected: Palette
    let onFinish: () -> Void
    var body: some View {
        VStack {
            Text(L10n.onboardingPaletteTitle)
                .font(.title2)
                .padding()
            HStack(spacing: 20) {
                ForEach(Palette.allCases) { palette in
                    Button(action: { selected = palette }) {
                        Text(palette.localizedName)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selected == palette ? Color.accentColor : Color.secondary.opacity(0.2))
                            .foregroundColor(selected == palette ? .white : .primary)
                            .cornerRadius(8)
                    }
                    .accessibilityLabel(Text(palette.localizedName))
                }
            }
            .padding()
            Spacer()
            Button(action: onFinish) {
                Text(L10n.onboardingFinish)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
}

extension Palette {
    var localizedName: String {
        switch self {
        case .vivid: return L10n.paletteVivid
        case .pastel: return L10n.palettePastel
        case .dark: return L10n.paletteDark
        }
    }
}
