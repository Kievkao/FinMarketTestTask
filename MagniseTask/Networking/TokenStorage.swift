//
//  TokenStorage.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import Foundation

final class TokenStorage {    
    private static let account = "fintacharts"
    
    static func storeToken(_ token: String) {
        do {
            try KeychainManager.storeValue(token, account: account)
        } catch KeychainManager.KeychainError.duplicateItem {
            updateToken(token)
        } catch {
            return
        }
    }
    
    static func getToken() -> String? {
        return try? KeychainManager.retrieveValue(account: account)
    }
}

private extension TokenStorage {
    static func updateToken(_ token: String) {
        try? KeychainManager.updateValue(token, account: account)
    }
}
