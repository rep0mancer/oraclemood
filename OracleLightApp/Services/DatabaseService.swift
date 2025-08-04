import Foundation
import GRDB
import OracleLightShared

/// Responsible for initialising and providing access to the encrypted GRDB
/// database. All database writes should occur on a background actor to avoid
/// blocking the main thread. This service performs migrations and exposes
/// convenience methods for retrieving and updating data.
final class DatabaseService {
    /// Shared singleton instance. All reads and writes should go through this
    /// actor-safe service. The database is opened lazily on the first call to
    /// `setup()`.
    static let shared = DatabaseService()
    private var dbPool: DatabasePool!

    private init() {
        // Private initialiser to enforce singleton usage
    }

    /// Initializes the encrypted database. Should be invoked during app start up.
    /// Computes the URL of the encrypted database. The file is stored inside an
    /// App Group container so that the main app and any extensions (widgets,
    /// live activities, intents) can access the same data. The App Group
    /// identifier must also be declared in the targets' entitlements.
    private func databaseURL() throws -> URL {
        // Use an App Group named `AppConfig.appGroupIdentifier`. The
        // string must match the identifier configured in your Xcode project.
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConfig.appGroupIdentifier
        ) else {
            throw NSError(domain: "DatabaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "App Group container not found"])
        }
        return containerURL.appendingPathComponent(AppConfig.databaseFilename)
    }

    /// Initializes and migrates the encrypted database. Should be invoked once
    /// at app startup and before any reads/writes occur. Subsequent calls are
    /// ignored. The database lives in the App Group container and is
    /// encrypted using SQLCipher with a key derived from the keychain.
    func setup() async throws {
        // Prevent double initialisation
        guard dbPool == nil else { return }

        let url = try databaseURL()
        let fileManager = FileManager.default
        // Ensure the directory exists
        let directory = url.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)

        // Obtain or generate the encryption key
        let key = try KeychainService.shared.fetchOrCreateKey()
        let passphrase = key.map { String(format: "%02x", $0) }.joined()

        // Configure GRDB for SQLCipher
        var configuration = Configuration()
        configuration.label = "OracleLightDatabasePool"
        configuration.prepareDatabase { db in
            // Set passphrase and enable memory security
            try db.usePassphrase(passphrase)
            try db.execute(sql: "PRAGMA cipher_memory_security = ON")
        }

        // Open the database pool
        self.dbPool = try DatabasePool(path: url.path, configuration: configuration)

        // Apply migrations. The schema defines primary keys and types for
        // MoodEntry, Settings and RuleEvent. When making changes to the schema,
        // register a new migration with an incremented identifier.
        var migrator = DatabaseMigrator()
        migrator.registerMigration("createMoodEntry") { db in
            try db.create(table: MoodEntry.databaseTableName) { t in
                // Use TEXT primary key for UUIDs. The caller supplies the id.
                t.column("id", .text).primaryKey()
                t.column("timestamp", .datetime).notNull().indexed()
                t.column("mood", .integer).notNull()
                t.column("source", .text).notNull()
            }
        }
        migrator.registerMigration("createSettings") { db in
            try db.create(table: Settings.databaseTableName) { t in
                t.column("id", .integer).primaryKey()
                t.column("promptTimes", .text).notNull()
                t.column("minimumIntervalMinutes", .integer).notNull()
                t.column("palette", .text).notNull()
            }
        }
        migrator.registerMigration("createRuleEvent") { db in
            try db.create(table: RuleEvent.databaseTableName) { t in
                t.column("id", .text).primaryKey()
                t.column("type", .text).notNull()
                t.column("triggeredAt", .datetime).notNull()
            }
        }
        try migrator.migrate(self.dbPool)

        // Insert default settings row if missing
        try await dbPool.write { db in
            if try Settings.fetchOne(db) == nil {
                var settings = Settings.default
                try settings.insert(db)
            }
        }
    }

    // MARK: - Mood Entries

    /// Inserts a mood entry into the database.
    func insertMood(_ mood: Mood, source: SourceType) async throws {
        try await dbPool.write { db in
            var entry = MoodEntry(id: UUID(), timestamp: Date(), mood: mood, source: source)
            try entry.insert(db)
        }
    }

    /// Retrieves all mood entries ordered by timestamp descending.
    func fetchMoodEntries() async throws -> [MoodEntry] {
        try await dbPool.read { db in
            try MoodEntry
                .order(Column("timestamp").desc)
                .fetchAll(db)
        }
    }

    // MARK: - Settings

    func fetchSettings() async throws -> Settings {
        try await dbPool.read { db in
            guard let settings = try Settings.fetchOne(db) else {
                return Settings.default
            }
            return settings
        }
    }

    func updateSettings(_ settings: Settings) async throws {
        try await dbPool.write { db in
            var mutable = settings
            try mutable.update(db)
        }
    }

    // MARK: - Rule Events

    func insertRuleEvent(type: RuleType) async throws {
        try await dbPool.write { db in
            var event = RuleEvent(id: UUID(), type: type, triggeredAt: Date())
            try event.insert(db)
        }
    }

    func fetchRuleEvents() async throws -> [RuleEvent] {
        try await dbPool.read { db in
            try RuleEvent.fetchAll(db)
        }
    }
}