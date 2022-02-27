//
//  KeychainWrapper.swift
//  CookBook
//
//  Created by Michael Abir on 2/20/22.
//

import Foundation

class KeychainWrapper {
    static let main = KeychainWrapper()
    
    static let service = "com.cookbook"
    
    static let accesssTokenService = KeychainWrapper.service + "-access-token"
    static let refreshTokenService = KeychainWrapper.service + "-refresh-token"

    func saveAccessToken(accessToken: String) {
        let accessData = accessToken.data(using: String.Encoding.utf8)!
        save(accessData, tag: KeychainWrapper.accesssTokenService)
    }

    func saveRefreshToken(refreshToken: String) {
        let refreshData = refreshToken.data(using: String.Encoding.utf8)!
        save(refreshData, tag: KeychainWrapper.refreshTokenService)
    }
    
    func getAccessToken() -> String {
        let accessData = read(tag: KeychainWrapper.accesssTokenService)
        return String(data: accessData ?? Data(), encoding: .utf8) ?? ""
    }

    func getRefreshToken() -> String {
        let refreshData = read(tag: KeychainWrapper.refreshTokenService)
        return String(data: refreshData ?? Data(), encoding: .utf8) ?? ""
    }
    
    func deleteTokens() {
        delete(tag: KeychainWrapper.accesssTokenService)
        delete(tag: KeychainWrapper.refreshTokenService)
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
