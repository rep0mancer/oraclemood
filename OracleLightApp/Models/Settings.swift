import Foundation
import GRDB

/// Persistent user settings. There should only ever be one row in this table
/// with a fixed primary key of 0.
struct Settings: Codable, FetchableRecord, MutablePersistableRecord, Identifiable {
    var id: Int64
    var promptTimes: [String] // ISO 8601 times such as "07:30"
    var minimumIntervalMinutes: Int
    var palette: Palette

    static let databaseTableName = "settings"

    /// Explicitly specify the columns selected by GRDB. When using `CodingKeys`
    /// as the column names the `Column` initializer that takes a `CodingKey`
    /// sometimes fails to resolve the correct key on Swift 5.9. To avoid
    /// ambiguity define a `Columns` namespace and reference the raw strings.
    enum Columns {
        static let id = Column("id")
        static let promptTimes = Column("promptTimes")
        static let minimumIntervalMinutes = Column("minimumIntervalMinutes")
        static let palette = Column("palette")
    }

    static var databaseSelection: [any SQLSelectable] {
        [Columns.id, Columns.promptTimes, Columns.minimumIntervalMinutes, Columns.palette]
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        // nothing
    }

    /// Default settings used when no row exists in the database. The prompt times
    /// mirror those defined in the specification.
    static var `default`: Settings {
        Settings(
            id: 0,
            promptTimes: ["07:30", "12:30", "17:30", "22:00"],
            minimumIntervalMinutes: 60,
            palette: .vivid
        )
    }
}