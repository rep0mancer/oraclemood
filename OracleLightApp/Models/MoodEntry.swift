import Foundation
import GRDB

/// A persistent representation of a mood entry stored in the encrypted database.
/// Each entry records the moment in time a mood was captured, the mood itself,
/// and the context in which it was created (live activity vs in-app).
struct MoodEntry: Codable, FetchableRecord, MutablePersistableRecord, Identifiable {
    var id: UUID
    var timestamp: Date
    var mood: Mood
    var source: SourceType

    // Define database table name
    static let databaseTableName = "moodEntry"

    /// Primary key configuration for GRDB. Use `.UUID` so GRDB inserts a UUID
    /// automatically when the record is inserted without an id.
    static var databaseSelection: [any SQLSelectable] {
        [Column(CodingKeys.id), Column(CodingKeys.timestamp), Column(CodingKeys.mood), Column(CodingKeys.source)]
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        // nothing to do. primary key is UUID
    }
}