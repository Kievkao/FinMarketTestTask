//
//  KeychainManager.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import Foundation
import Security

final class KeychainManager {
    
    enum KeychainError: Error {
        case duplicateItem
        case itemNotFound
        case unexpectedDataFormat
        case unknown(OSStatus)
    }
    
    static func storeValue(_ value: String, account: String) throws {
        let valueData = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: valueData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            throw KeychainError.duplicateItem
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
    
    static func updateValue(_ value: String, account: String) throws {
        let valueData = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: account,
        ]
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: valueData
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
    
    static func retrieveValue(account: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
        
        guard let data = item as? Data, let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedDataFormat
        }
        
        return string
    }
}
