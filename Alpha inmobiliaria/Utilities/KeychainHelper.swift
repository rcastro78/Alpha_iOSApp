import Foundation
import Security

enum KeychainHelper {
    private static let service = Bundle.main.bundleIdentifier ?? "com.tec101.app"

    static func save(_ value: String, for key: String) {
        let data = Data(value.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        // Elimina el valor anterior (si existe) y guarda el nuevo
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        SecItemAdd(attributes as CFDictionary, nil)
    }

    static func read(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else { return nil }
        return value
    }

    static func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

/// Claves y operaciones para las credenciales recordadas
enum RememberedCredentials {
    private static let emailKey = "remembered_email"
    private static let passwordKey = "remembered_password"
    private static let flagKey = "rememberMeEnabled"

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: flagKey)
    }

    static func load() -> (email: String, password: String)? {
        guard isEnabled,
              let email = KeychainHelper.read(emailKey),
              let password = KeychainHelper.read(passwordKey) else { return nil }
        return (email, password)
    }

    static func save(email: String, password: String) {
        KeychainHelper.save(email, for: emailKey)
        KeychainHelper.save(password, for: passwordKey)
        UserDefaults.standard.set(true, forKey: flagKey)
    }

    static func clear() {
        KeychainHelper.delete(emailKey)
        KeychainHelper.delete(passwordKey)
        UserDefaults.standard.set(false, forKey: flagKey)
    }
}