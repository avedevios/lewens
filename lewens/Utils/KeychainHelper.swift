//
//  KeychainHelper.swift
//  lewens
//
//  Created by AI Assistant on 2025-11-23.
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as [CFString : Any]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            let searchQuery = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword
            ] as [CFString : Any]
            
            let attributesToUpdate = [kSecValueData: data] as [CFString : Any]
            
            let updateStatus = SecItemUpdate(searchQuery as CFDictionary, attributesToUpdate as CFDictionary)
            if updateStatus != errSecSuccess {
                #if DEBUG
                print("⚠️ Keychain update failed for \(account): \(updateStatus)")
                #endif
            }
        } else if status != errSecSuccess {
            #if DEBUG
            print("⚠️ Keychain save failed for \(account): \(status)")
            #endif
        }
    }
    
    func read(service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as [CFString : Any]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            #if DEBUG
            print("⚠️ Keychain read failed for \(account): \(status)")
            #endif
        }
        
        return result as? Data
    }
    
    func delete(service: String, account: String) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as [CFString : Any]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            #if DEBUG
            print("⚠️ Keychain delete failed for \(account): \(status)")
            #endif
        }
    }
}
