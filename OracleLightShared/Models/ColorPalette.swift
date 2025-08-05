import SwiftUI

/// Provides programmatic definitions for mood colours across different
/// palettes by referencing color assets from `Assets.xcassets`.
public struct ColorPalette {
    public static func color(for mood: Mood, palette: Palette) -> Color {
        // Constructs asset names like "VividAngry", "PastelHappy", etc.
        // Note: String(describing:) is used for simple enum-to-string conversion.
        let moodName = String(describing: mood).capitalized
        let paletteName = palette.rawValue.capitalized

        let colorAssetName = "\(paletteName)\(moodName)"

        // This will now load the color from the Asset Catalog. If the asset
        // is not found, it will default to black and print a warning in the console.
        return Color(colorAssetName)
    }
}

