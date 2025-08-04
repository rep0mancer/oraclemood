import Foundation

/// Represents the user's mood on an ordinal scale from 0–6.
/// Lower values indicate negative moods while higher values represent positive moods.
/// The enumeration conforms to `Int` raw values for easy persistence.
import GRDB

public enum Mood: Int, CaseIterable, Codable, Identifiable, DatabaseValueConvertible {
    case angry = 0
    case sad = 1
    case neutral = 2
    case content = 3
    case happy = 4
    case joyful = 5
    case ecstatic = 6

    public var id: Int { rawValue }

    /// Returns a localized descriptive string for the mood. The keys are stored in
    /// Localizable.strings and will fallback to English if missing.
    public var localizedDescription: String {
        switch self {
        case .angry: return NSLocalizedString("mood.angry", comment: "Angry mood")
        case .sad: return NSLocalizedString("mood.sad", comment: "Sad mood")
        case .neutral: return NSLocalizedString("mood.neutral", comment: "Neutral mood")
        case .content: return NSLocalizedString("mood.content", comment: "Content mood")
        case .happy: return NSLocalizedString("mood.happy", comment: "Happy mood")
        case .joyful: return NSLocalizedString("mood.joyful", comment: "Joyful mood")
        case .ecstatic: return NSLocalizedString("mood.ecstatic", comment: "Ecstatic mood")
        }
    }
}