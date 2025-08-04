import SwiftUI

/// Provides programmatic definitions for mood colours across different
/// palettes. In a production app these would be defined in `Assets.xcassets`
/// and generated via SwiftGen. Here we hard‑code the values for brevity.
struct ColorPalette {
    static func color(for mood: Mood, palette: Palette) -> Color {
        switch palette {
        case .vivid:
            return vividColors[mood.rawValue]
        case .pastel:
            return pastelColors[mood.rawValue]
        case .dark:
            return darkColors[mood.rawValue]
        }
    }

    private static let vividColors: [Color] = [
        Color(red: 0.85, green: 0.15, blue: 0.20), // angry
        Color(red: 0.93, green: 0.44, blue: 0.13), // sad
        Color(red: 0.98, green: 0.77, blue: 0.03), // neutral
        Color(red: 0.34, green: 0.77, blue: 0.16), // content
        Color(red: 0.12, green: 0.61, blue: 0.99), // happy
        Color(red: 0.54, green: 0.35, blue: 0.94), // joyful
        Color(red: 0.87, green: 0.14, blue: 0.68)  // ecstatic
    ]
    private static let pastelColors: [Color] = [
        Color(red: 0.97, green: 0.71, blue: 0.72),
        Color(red: 0.99, green: 0.83, blue: 0.70),
        Color(red: 1.00, green: 0.95, blue: 0.70),
        Color(red: 0.78, green: 0.91, blue: 0.77),
        Color(red: 0.74, green: 0.86, blue: 0.96),
        Color(red: 0.86, green: 0.80, blue: 0.96),
        Color(red: 0.96, green: 0.74, blue: 0.90)
    ]
    private static let darkColors: [Color] = [
        Color(red: 0.40, green: 0.00, blue: 0.10),
        Color(red: 0.46, green: 0.18, blue: 0.00),
        Color(red: 0.48, green: 0.38, blue: 0.00),
        Color(red: 0.10, green: 0.36, blue: 0.00),
        Color(red: 0.00, green: 0.28, blue: 0.55),
        Color(red: 0.24, green: 0.10, blue: 0.42),
        Color(red: 0.40, green: 0.00, blue: 0.25)
    ]
}