//
//  Keychain.swift
//  my-quotes
//
//  Created by Daniel Avram on 13/04/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import Foundation
import Security

class Keychain {
    
    private static let kSecClassValue = NSString(format: kSecClass)
    private static let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
    private static let kSecValueDataValue = NSString(format: kSecValueData)
    private static let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
    private static let kSecAttrServiceValue = NSString(format: kSecAttrService)
    private static let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
    private static let kSecReturnDataValue = NSString(format: kSecReturnData)
    private static let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
    
    enum Key: String {
        case email = "email"
        case token = "token"
    }
    
    static func set(_ key: Key, value: String) {
        
        let dataFromString = value.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        let objects: [Any] = [
            kSecClassGenericPasswordValue,
            key.rawValue,
            dataFromString
        ]
        
        let keys = [
            kSecClassValue,
            kSecAttrServiceValue,
            kSecValueDataValue
        ]
        
        let keychainQuery: CFDictionary = NSMutableDictionary(objects: objects, forKeys: keys)
        
        SecItemDelete(keychainQuery)
        
        SecItemAdd(keychainQuery, nil)
        
    }
    
    static func get(_ key: Key) -> String? {
        
        let objects: [Any] = [
            kSecClassGenericPasswordValue,
            key.rawValue,
            kCFBooleanTrue,
            kSecMatchLimitOneValue
        ]
        
        let keys = [
            kSecClassValue,
            kSecAttrServiceValue,
            kSecReturnDataValue,
            kSecMatchLimitValue
        ]
        
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: objects, forKeys: keys)
        
        var dataTypeRef: AnyObject?
        
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: String? = nil
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = String(data: retrievedData, encoding: String.Encoding.utf8)
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
    
    static func delete(_ key: Key? = nil) {
        
        let objects: [Any]!
        let keys: [NSCopying]!
        
        if let key = key {
            objects = [
                kSecClassGenericPasswordValue,
                key.rawValue
            ]
            
            keys = [
                kSecClassValue,
                kSecAttrServiceValue
            ]
        } else {
            objects = [
                kSecClassGenericPasswordValue
            ]
            
            keys = [
                kSecClassValue
            ]
        }
        
        let keychainQuery: CFDictionary = NSMutableDictionary(objects: objects, forKeys: keys)
        
        SecItemDelete(keychainQuery)
        
    }
    
}
