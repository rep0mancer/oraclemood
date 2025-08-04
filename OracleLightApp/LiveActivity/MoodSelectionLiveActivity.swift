//
// NOTE: The Live Activity widget and its supporting views are defined in
// OracleLightWidget. This stub is intentionally disabled so that the main
// application does not include duplicate widget definitions. See the widget
// target for the real MoodSelectionLiveActivity implementation.
//
#if false
import WidgetKit
import SwiftUI
import ActivityKit
import AppIntents

/// A live activity displayed in the Dynamic Island and on the Lock Screen. It
/// allows quick mood selection via compact or expanded UI. When the user taps
/// a mood glyph, the activity terminates and records the mood.
@available(iOSApplicationExtension 17.0, *)
struct MoodSelectionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MoodSelectionAttributes.self) { context in
            // Lock screen / banner UI
            MoodSelectionView()
                .activityBackgroundTint(Color(UIColor.systemBackground))
                .activitySystemActionForegroundColor(Color.accentColor)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded region: show up to seven moods horizontally
                DynamicIslandExpandedRegion(.center) {
                    MoodSelectionView(maxGlyphs: 7)
                }
            } compactLeading: {
                MoodSelectionView(maxGlyphs: 1)
            } compactTrailing: {
                EmptyView()
            } minimal: {
                MoodSelectionView(maxGlyphs: 1)
            }
        }
    }
}

/// A helper view that displays a list of mood glyph buttons. When tapped,
/// inserts the mood via MoodStore and ends the activity. The number of
/// displayed glyphs depends on the context (1 for compact or minimal, 7 for
/// expanded). Hidden glyphs are not shown.
@available(iOSApplicationExtension 17.0, *)
struct MoodSelectionView: View {
    /// Maximum number of mood glyphs to display. The Dynamic Island limits the
    /// space available in compact and minimal regions; in expanded mode up to
    /// seven glyphs are shown.
    var maxGlyphs: Int = 1

    private let moods: [Mood] = Mood.allCases

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(moods.prefix(maxGlyphs)), id: \.self) { mood in
                // Use an AppIntent to record the mood and dismiss the activity.
                if #available(iOS 17.0, *) {
                    Button(intent: LogMoodIntent(mood: mood)) {
                        Image(systemName: glyphName(for: mood))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(color(for: mood))
                            .accessibilityLabel(mood.localizedDescription)
                    }
                } else {
                    // Fallback for earlier OS versions – should never be used on
                    // platforms that don't support Live Activities. Do nothing.
                    EmptyView()
                }
            }
        }
        .padding()
    }

    private func glyphName(for mood: Mood) -> String {
        switch mood {
        case .angry: return "flame.fill"
        case .sad: return "cloud.rain.fill"
        case .neutral: return "circle.fill"
        case .content: return "sun.min.fill"
        case .happy: return "smiley.fill"
        case .joyful: return "face.smiling.fill"
        case .ecstatic: return "star.fill"
        }
    }

    private func color(for mood: Mood) -> Color {
        // Colour mapping will be looked up via the selected palette. For now
        // return accent colour as placeholder.
        return Color.accentColor
    }
}
#endif