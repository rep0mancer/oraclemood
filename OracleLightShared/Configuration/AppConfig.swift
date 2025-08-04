import Foundation

public enum AppConfig {
    // MARK: - App Group
    public static let appGroupIdentifier = "group.com.yourcompany.oraclelight"

    // MARK: - Keychain
    public static let keychainService = "com.yourcompany.oraclelight.dbkey"
    public static let keychainAccount = "oraclelight_encryption_key"
    public static let keychainAccessGroup = "group.com.yourcompany.oraclelight"

    // MARK: - StoreKit
    public static let proProductID = "oraclelight.pro"

    // MARK: - Database
    public static let databaseFilename = "oracledb.sqlite"

    // MARK: - Fastlane/Contact
    public static let contactEmail = "support@yourcompany.com"
    public static let bundleIdentifier = "com.yourcompany.oraclelight"
}
