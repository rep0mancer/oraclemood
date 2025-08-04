import Foundation
import GRDB

/// Records that a rule has been triggered. Used to avoid repeatedly notifying
/// the user about the same rule within a short timeframe and to show badges.
struct RuleEvent: Codable, FetchableRecord, MutablePersistableRecord, Identifiable {
    var id: UUID
    var type: RuleType
    var triggeredAt: Date

    static let databaseTableName = "ruleEvent"

    static var databaseSelection: [any SQLSelectable] {
        [Column(CodingKeys.id), Column(CodingKeys.type), Column(CodingKeys.triggeredAt)]
    }
}