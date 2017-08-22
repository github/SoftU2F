//
//  Keychain.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 2/2/17.
//

import Foundation

class Keychain {
    // Get the number of keychain items with a given kSecAttrLabel.
    static func count(attrLabel: CFString) -> Int? {
        let query = makeCFDictionary(
                                     (kSecClass, kSecClassKey),
                                     (kSecAttrKeyType, kSecAttrKeyTypeEC),
                                     (kSecAttrLabel, attrLabel),
                                     (kSecReturnRef, kCFBooleanTrue),
                                     (kSecMatchLimit, 100 as CFNumber)
        )

        var optionalOpaqueResult: CFTypeRef? = nil
        let err = SecItemCopyMatching(query, &optionalOpaqueResult)

        if err == errSecItemNotFound {
            return 0
        }

        if err != errSecSuccess {
            print("Error from keychain: \(err)")
            return nil
        }

        guard let opaqueResult = optionalOpaqueResult else {
            print("Unexpected nil returned from keychain")
            return nil
        }

        let result = opaqueResult as! CFArray as [AnyObject]

        return result.count
    }

    // Delete all keychain items matching the given query.
    static func delete(_ query: CFDictionaryMember...) -> Bool {
        let queryDict = makeCFDictionary(query)

        let err = SecItemDelete(queryDict)

        switch err {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            print("Error from keychain: \(err)")
            return false
        }
    }

    // Get the given attribute for the given SecKey.
    static func getSecKeyAttr<T:AnyObject>(key: SecKey, attr name: CFString) -> T? {
        guard let attrs = SecKeyCopyAttributes(key) as? [String: AnyObject] else {
            return nil
        }

        guard let ret = attrs[name as String] as? T else {
            return nil
        }

        return ret
    }

    // Get the given attribute for the SecItem with the given kSecAttrApplicationLabel.
    static func getSecItemAttr<T>(attrAppLabel: CFData, name: CFString) -> T? {
        let query = makeCFDictionary(
                                     (kSecClass, kSecClassKey),
                                     (kSecAttrKeyType, kSecAttrKeyTypeEC),
                                     (kSecAttrKeyClass, kSecAttrKeyClassPrivate),
                                     (kSecAttrApplicationLabel, attrAppLabel),
                                     (kSecReturnAttributes, kCFBooleanTrue)
        )

        var optionalOpaqueDict: CFTypeRef? = nil
        let err = SecItemCopyMatching(query, &optionalOpaqueDict)

        if err != errSecSuccess {
            print("Error from keychain: \(err)")
            return nil
        }

        guard let opaqueDict = optionalOpaqueDict else {
            print("Unexpected nil returned from keychain")
            return nil
        }

        guard let dict = opaqueDict as! CFDictionary as? [String: AnyObject] else {
            print("Error downcasting CFDictionary")
            return nil
        }

        guard let opaqueResult = dict[name as String] else {
            return nil
        }

        return opaqueResult as? T
    }

    // Get the given attribute for the SecItem with the given kSecAttrApplicationLabel.
    static func setSecItemAttr<T:CFTypeRef>(attrAppLabel: CFData, name: CFString, value: T) -> Bool {
        let query = makeCFDictionary(
                                     (kSecClass, kSecClassKey),
                                     (kSecAttrKeyType, kSecAttrKeyTypeEC),
                                     (kSecAttrKeyClass, kSecAttrKeyClassPrivate),
                                     (kSecAttrApplicationLabel, attrAppLabel)
        )

        let newAttrs = makeCFDictionary(
                                        (name, value)
        )

        let err = SecItemUpdate(query, newAttrs)

        if err != errSecSuccess {
            print("Error from keychain: \(err)")
            return false
        }
        
        return true
    }
    
    // Get the raw data from the key.
    static func exportSecKey(_ key: SecKey) -> Data? {
        var err: Unmanaged<CFError>? = nil
        let data = SecKeyCopyExternalRepresentation(key, &err)
        
        if err != nil {
            print("Error exporting key")
            return nil
        }
        
        return data as Data?
    }
    
    // Lookup all private keys with the given label.
    static func getPrivateSecKeys(attrLabel: CFString) -> [SecKey] {
        let query = makeCFDictionary(
            (kSecClass, kSecClassKey),
            (kSecAttrKeyType, kSecAttrKeyTypeEC),
            (kSecAttrKeyClass, kSecAttrKeyClassPrivate),
            (kSecAttrLabel, attrLabel),
            (kSecReturnRef, kCFBooleanTrue),
            (kSecMatchLimit, 1000 as CFNumber)
        )
        
        var optionalOpaqueResult: CFTypeRef? = nil
        let err = SecItemCopyMatching(query, &optionalOpaqueResult)
        
        if err != errSecSuccess {
            print("Error from keychain: \(err)")
            return []
        }
        
        guard let opaqueResult = optionalOpaqueResult else {
            print("Unexpected nil returned from keychain")
            return []
        }
        
        let result = opaqueResult as! [SecKey]
        
        return result
    }

    static func getPrivateSecKey(attrAppLabel: CFData, signPrompt: CFString) -> SecKey? {
        let query = makeCFDictionary(
            (kSecClass, kSecClassKey),
            (kSecAttrKeyType, kSecAttrKeyTypeEC),
            (kSecAttrKeyClass, kSecAttrKeyClassPrivate),
            (kSecAttrApplicationLabel, attrAppLabel),
            (kSecReturnRef, kCFBooleanTrue),
            (kSecUseOperationPrompt, signPrompt as CFString)
        )

        var optionalOpaqueResult: CFTypeRef? = nil
        let err = SecItemCopyMatching(query, &optionalOpaqueResult)

        if err != errSecSuccess {
            print("Error from keychain: \(err)")
            return nil
        }

        guard let opaqueResult = optionalOpaqueResult else {
            print("Unexpected nil returned from keychain")
            return nil
        }

        let result = opaqueResult as! SecKey

        return result
    }

    static func generateKeyPair(attrLabel: CFString, inSEP: Bool) -> (SecKey, SecKey)? {
        // Make ACL controlling access to generated keys.
        let acl: SecAccessControl?
        var err: Unmanaged<CFError>? = nil
        defer { err?.release() }

        if inSEP {
            if #available(OSX 10.12.1, *) {
                acl = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, [.privateKeyUsage, .touchIDAny], &err)
            } else {
                print("Cannot generate keys in SEP on macOS<10.12.1")
                return nil
            }
        } else {
            acl = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, [], &err)
        }

        if acl == nil || err != nil {
            print("Error generating ACL for key generation")
            return nil
        }

        // Make parameters for generating keys.
        let params: CFDictionary

        if inSEP {
            params = makeCFDictionary(
                (kSecAttrKeyType, kSecAttrKeyTypeEC),
                (kSecAttrKeySizeInBits, 256 as CFNumber),
                (kSecAttrTokenID, kSecAttrTokenIDSecureEnclave),
                (kSecPrivateKeyAttrs, makeCFDictionary(
                    (kSecAttrAccessControl, acl!),
                    (kSecAttrLabel, attrLabel),
                    (kSecAttrIsPermanent, kCFBooleanTrue),
                    (kSecAttrSynchronizable, kCFBooleanFalse)
                ))
            )
        } else {
            params = makeCFDictionary(
                (kSecAttrKeyType, kSecAttrKeyTypeEC),
                (kSecAttrKeySizeInBits, 256 as CFNumber),
                (kSecPrivateKeyAttrs, makeCFDictionary(
                    (kSecAttrAccessControl, acl!),
                    (kSecAttrLabel, attrLabel),
                    (kSecAttrIsPermanent, kCFBooleanTrue)
                ))
            )
        }

        // Generate key pair.
        var pub: SecKey? = nil
        var priv: SecKey? = nil
        let status = SecKeyGeneratePair(params, &pub, &priv)

        if status != errSecSuccess {
            print("Error calling SecKeyGeneratePair: \(status)")
            return nil
        }

        if pub == nil || priv == nil {
            print("Keys not returned from SecKeyGeneratePair")
            return nil
        }

        return (pub!, priv!)
    }

    // Sign some data with the private key.
    static func sign(key: SecKey, data: Data) -> Data? {
        var err: Unmanaged<CFError>? = nil
        defer { err?.release() }

        let sig = SecKeyCreateSignature(key, .ecdsaSignatureMessageX962SHA256, data as CFData, &err) as Data?

        if err != nil {
            print("Error creating signature: \(err!.takeUnretainedValue().localizedDescription)")
            return nil
        }

        return sig
    }

    // Verify some signature over some data with the public key.
    static func verify(key: SecKey, data: Data, signature: Data) -> Bool {
        var err: Unmanaged<CFError>? = nil
        defer { err?.release() }

        let ret = SecKeyVerifySignature(key, .ecdsaSignatureMessageX962SHA256, data as CFData, signature as CFData, &err)

        if err != nil {
            print("Error verifying signature: \(err!.takeUnretainedValue().localizedDescription)")
            return false
        }

        return ret
    }
    
    static func repair(attrLabel: CFString) {
        // Lookup public keys
        let query = makeCFDictionary(
            (kSecClass, kSecClassKey),
            (kSecAttrKeyType, kSecAttrKeyTypeEC),
            (kSecAttrKeyClass, kSecAttrKeyClassPublic),
            (kSecAttrLabel, attrLabel),
            (kSecReturnAttributes, kCFBooleanTrue),
            (kSecMatchLimit, 100 as CFNumber)
        )
        
        var optionalOpaqueResult: CFTypeRef? = nil
        let err = SecItemCopyMatching(query, &optionalOpaqueResult)
        
        if err != errSecSuccess {
            print("Error from keychain: \(err)")
            return
        }
        
        guard let opaqueResult = optionalOpaqueResult else {
            print("Unexpected nil returned from keychain")
            return
        }
        
        let publicKeys = opaqueResult as! [[String:AnyObject]]

        publicKeys.forEach { publicKey in
            print("Repairing one keypair")

            guard let attrAppTag = publicKey[kSecAttrApplicationTag as String] as? Data else {
                print("error getting kSecAttrApplicationTag for public key")
                return
            }
            
            guard let attrAppLabel = publicKey[kSecAttrApplicationLabel as String] as? Data else {
                print("error getting kSecAttrApplicationLabel for public key")
                return
            }
            
            guard let _ = getPrivateSecKey(attrAppLabel: attrAppLabel as CFData, signPrompt: "" as CFString) else {
                print("error getting private key for public key")
                return
            }

            if !setSecItemAttr(attrAppLabel: attrAppLabel as CFData, name: kSecAttrApplicationTag, value: attrAppTag as CFData) {
                print("Error copying kSecAttrApplicationTag to private key")
                return
            }
            
            let ok = delete(
                (kSecClass, kSecClassKey),
                (kSecAttrKeyClass, kSecAttrKeyClassPublic),
                (kSecAttrApplicationLabel, attrAppLabel as CFData)
            )
            
            if !ok {
                print("Error deleting public keys")
                return
            }
            
            print("Success")
        }
    }
}
