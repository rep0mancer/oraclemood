import Foundation
import Security
import OracleLightShared

/// Provides a thin wrapper around the iOS Keychain for storing and retrieving
/// the database encryption key. Keys are stored with
/// `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` so they never leave the
/// device and are available after the first unlock.
final class KeychainService {
    static let shared = KeychainService()
    private init() {}

    private let service = AppConfig.keychainService
    private let account = AppConfig.keychainAccount

    /// Keychain access group. When both the app and its extensions specify the
    /// same keychain access group entitlement, items stored under this group
    /// become available to all targets. This allows the live activity
    /// extension to retrieve the same SQLCipher key as the main app. Ensure
    /// that this string matches the value configured in your entitlements.
    private let accessGroup = AppConfig.keychainAccessGroup

    /// Retrieves an existing 256‑bit key from the keychain or generates and
    /// persists a new key if none exists. The returned key is used to
    /// initialise SQLCipher via GRDB.
    func fetchOrCreateKey() throws -> Data {
        if let existing = try loadKey() {
            return existing
        }
        let key = try generateRandomKey(length: 32) // 256 bits
        try storeKey(key)
        return key
    }

    private func generateRandomKey(length: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Unable to generate random key"])
        }
        return Data(bytes)
    }

    private func loadKey() throws -> Data? {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
            // Restrict to the shared access group so that both the app and
            // extensions can retrieve the key.
            kSecAttrAccessGroup: accessGroup
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to load key from keychain"])
        }
        return result as? Data
    }

    private func storeKey(_ key: Data) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            // Set the access group so that extensions can retrieve the key.
            kSecAttrAccessGroup: accessGroup,
            kSecValueData: key
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to store key in keychain"])
        }
    }
}