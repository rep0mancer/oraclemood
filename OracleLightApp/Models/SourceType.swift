import Foundation
import GRDB

/// Indicates how a `MoodEntry` was captured. Live Activities originate from
/// Dynamic Island interactions while in-app entries come from UI flows.
/// Indicates how a `MoodEntry` was captured. Live Activities originate from
/// Dynamic Island interactions while in-app entries come from UI flows.
public enum SourceType: String, Codable, CaseIterable, DatabaseValueConvertible {
    case liveActivity
    case inApp
}