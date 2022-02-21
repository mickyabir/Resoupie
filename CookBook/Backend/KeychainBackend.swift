//
//  KeychainBackend.swift
//  CookBook
//
//  Created by Michael Abir on 2/20/22.
//

import Foundation

class KeychainBackend {
    static let main = KeychainBackend()
    
    static let service = "com.resoupie"
    
    static let accesssTokenService = KeychainBackend.service + "-access-token"
    static let refreshTokenService = KeychainBackend.service + "-refresh-token"

    func saveAccessToken(accessToken: String) {
        let accessData = accessToken.data(using: String.Encoding.utf8)!
        save(accessData, tag: KeychainBackend.accesssTokenService)
    }

    func saveRefreshToken(refreshToken: String) {
        let refreshData = refreshToken.data(using: String.Encoding.utf8)!
        save(refreshData, tag: KeychainBackend.refreshTokenService)
    }
    
    func getAccessToken() -> String {
        let accessData = read(tag: KeychainBackend.accesssTokenService)
        return String(data: accessData ?? Data(), encoding: .utf8) ?? ""
    }

    func getRefreshToken() -> String {
        let refreshData = read(tag: KeychainBackend.refreshTokenService)
        return String(data: refreshData ?? Data(), encoding: .utf8) ?? ""
    }
    
    func deleteTokens() {
        delete(tag: KeychainBackend.accesssTokenService)
        delete(tag: KeychainBackend.refreshTokenService)
    }
    
    private func save(_ data: Data, tag: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: tag,
                                    kSecValueData as String: data]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            let query = [kSecClass as String: kSecClassKey,
                         kSecAttrApplicationTag as String: tag] as CFDictionary
            

            let attributesToUpdate = [kSecValueData: data] as CFDictionary

            SecItemUpdate(query, attributesToUpdate)
        }
    }
    
    private func read(tag: String) -> Data? {
        let query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        return result as? Data
    }
    
    private func delete(tag: String) {
        let query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        
        print(status)
    }
}
