import Foundation
import Security

/// Provides a thin wrapper around the iOS Keychain for storing and retrieving
/// the database encryption key. Keys are stored with
/// `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` so they never leave the
/// device and are available after the first unlock. This service is shared
/// between the main app and extensions via a keychain access group.
final class KeychainService {
    static let shared = KeychainService()
    private init() {}

    private let service = "com.yourcompany.oraclelight.dbkey"
    private let account = "oraclelight_encryption_key"
    private let accessGroup = "group.com.yourcompany.oraclelight"

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
            kSecAttrAccessGroup: accessGroup,
            kSecValueData: key
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to store key in keychain"])
        }
    }
}