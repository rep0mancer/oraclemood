import Foundation
import GRDB

/// Represents the type of rule triggered by the `RuleEngine`.
/// A praise encourages the user when they are consistently positive.
/// An advisory notifies the user when negative moods accumulate.
public enum RuleType: String, Codable, DatabaseValueConvertible {
    case praise
    case advisory
}