import Foundation

/// Defines colour palettes used throughout the app. Each palette corresponds to a
/// set of colours defined in the asset catalogue. For accessibility the asset
/// catalogue defines light and dark variants as well as high contrast variants.
public enum Palette: String, Codable, CaseIterable, Identifiable {
    case vivid
    case pastel
    case dark

    public var id: String { rawValue }

    /// Returns the name of the colour set in the asset catalogue corresponding
    /// to the palette. These names are used via SwiftGen to generate strongly
    /// typed colours.
    public var assetName: String {
        switch self {
        case .vivid: return "MoodPaletteVivid"
        case .pastel: return "MoodPalettePastel"
        case .dark: return "MoodPaletteDark"
        }
    }
}