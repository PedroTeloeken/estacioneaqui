//
//  TokenStore.swift
//  EstacioneAqui
//


import Foundation
import Security

struct TokenStore {

    static let shared = TokenStore()

    private let service = "teloeken.EstacioneAqui.auth"
    private let accessKey = "accessToken"
    private let refreshKey = "refreshToken"

    var accessToken: String? { read(accessKey) }
    var refreshToken: String? { read(refreshKey) }
    var hasSession: Bool { accessToken != nil }

    func save(accessToken: String, refreshToken: String) {
        write(accessToken, for: accessKey)
        write(refreshToken, for: refreshKey)
    }

    func updateAccessToken(_ accessToken: String, refreshToken: String) {
        write(accessToken, for: accessKey)
        write(refreshToken, for: refreshKey)
    }

    func clear() {
        delete(accessKey)
        delete(refreshKey)
    }


    private func write(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(attributes as CFDictionary, nil)
    }

    private func read(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }

    private func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
