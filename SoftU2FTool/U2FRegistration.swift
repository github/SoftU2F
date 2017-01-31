//
//  U2FRegistration.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/30/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

class U2FRegistration {
    // Allow using separate keychain namespace for tests.
    static var namespace = "SoftU2F Security Key"
    static var applicationLabel:CFString { return namespace as CFString }

    // Get count of our keys (public and private) in the keychain.
    static func count() -> Int? {
        var opaqueResult:CFTypeRef? = nil

        let query = makeCFDictionary(
            (kSecClass,       kSecClassKey),
            (kSecAttrKeyType, kSecAttrKeyTypeEC),
            (kSecAttrLabel,   U2FRegistration.applicationLabel),
            (kSecReturnRef,   kCFBooleanTrue),
            (kSecMatchLimit,  100 as CFNumber)
        )

        let err = SecItemCopyMatching(query, &opaqueResult)

        if err == errSecItemNotFound {
            return 0
        }

        if err != errSecSuccess {
            print("Error querying keychain: \(err)")
            return nil
        }

        if opaqueResult == nil {
            print("No results from querying keychain.")
            return nil
        }

        let result = opaqueResult! as! CFArray
        return CFArrayGetCount(result)
    }

    // Delete all SoftU2F keys from keychain.
    static func deleteAll() -> Bool {
        let query = makeCFDictionary(
            (kSecClass,     kSecClassKey),
            (kSecAttrLabel, U2FRegistration.applicationLabel)
        )

        let err = SecItemDelete(query)

        if err != errSecSuccess && err != errSecItemNotFound {
            print("Error deleting keys: \(err)")
            return false
        }
        
        return true
    }

    let publicKey:SecKey
    let privateKey:SecKey

    // Dictionary of keychain attributes.
    var publicKeyAttrs:[String:AnyObject]? {
        return SecKeyCopyAttributes(publicKey) as? [String:AnyObject]
    }

    // Key handle is a hash of the public key.
    var handle:Data? {
        return publicKeyAttrs?[String(kSecAttrApplicationLabel)] as? Data
    }

    // Raw public key bytes.
    var publicKeyData:Data? {
        guard let h = handle else {
            print("Error getting key handle")
            return nil
        }

        let query = makeCFDictionary(
            (kSecClass,                kSecClassKey),
            (kSecAttrKeyType,          kSecAttrKeyTypeEC),
            (kSecAttrKeyClass,         kSecAttrKeyClassPublic),
            (kSecAttrApplicationLabel, h as CFData),
            (kSecReturnData,           kCFBooleanTrue)
        )

        var opaqueResult:CFTypeRef? = nil
        let err = SecItemCopyMatching(query, &opaqueResult)

        if err != errSecSuccess {
            print("Error calling SecItemCopyMatching: \(err)")
            return nil
        }

        if opaqueResult == nil {
            print("No result from SecItemCopyMatching")
            return nil
        }

        return opaqueResult! as! CFData as Data
    }

    init?() {
        var err:Unmanaged<CFError>? = nil
        defer { err?.release() }

        // Make ACL controlling access to generated keys.
        let acl = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, SecAccessControlCreateFlags(rawValue: 0), &err)
        if acl == nil || err != nil {
            print("Error generating ACL for key generation")
            return nil
        }

        // Make parameters for generating keys.
        let params = makeCFDictionary(
            (kSecAttrKeyType,        kSecAttrKeyTypeEC),
            (kSecAttrKeySizeInBits,  256 as CFNumber),
            (kSecAttrAccessControl,  acl!),
            (kSecAttrIsPermanent,    kCFBooleanTrue),
            (kSecAttrLabel,          U2FRegistration.applicationLabel)
        )

        // Generate key pair.
        var pub:SecKey? = nil
        var priv:SecKey? = nil
        let status = SecKeyGeneratePair(params, &pub, &priv)

        if status != errSecSuccess {
            print("Error calling SecKeyGeneratePair: \(status)")
            return nil
        }

        if pub == nil || priv == nil {
            print("Keys not returned from SecKeyGeneratePair")
            return nil
        }

        publicKey = pub!
        privateKey = priv!
    }

    init?(keyHandle kh:Data) {
        // Lookup public key.
        var query = makeCFDictionary(
            (kSecClass,                kSecClassKey),
            (kSecAttrKeyType,          kSecAttrKeyTypeEC),
            (kSecAttrKeyClass,         kSecAttrKeyClassPublic),
            (kSecAttrApplicationLabel, kh as CFData),
            (kSecReturnRef,            kCFBooleanTrue)
        )

        var opaqueResult:CFTypeRef? = nil
        var err = SecItemCopyMatching(query, &opaqueResult)

        if err != errSecSuccess {
            print("Error calling SecItemCopyMatching: \(err)")
            return nil
        }

        if opaqueResult == nil {
            print("No result from SecItemCopyMatching")
            return nil
        }

        publicKey = opaqueResult as! SecKey

        // Lookup private key.
        query = makeCFDictionary(
            (kSecClass,                kSecClassKey),
            (kSecAttrKeyType,          kSecAttrKeyTypeEC),
            (kSecAttrKeyClass,         kSecAttrKeyClassPrivate),
            (kSecAttrApplicationLabel, kh as CFData),
            (kSecReturnRef,            kCFBooleanTrue)
        )

        opaqueResult = nil
        err = SecItemCopyMatching(query, &opaqueResult)

        if err != errSecSuccess {
            print("Error calling SecItemCopyMatching: \(err)")
            return nil
        }

        if opaqueResult == nil {
            print("No result from SecItemCopyMatching")
            return nil
        }

        privateKey = opaqueResult as! SecKey
    }

    // Delete the keypair from the keychain.
    func delete() -> Bool {
        guard let h = handle else {
            print("Error getting key handle")
            return false
        }

        let query = makeCFDictionary(
            (kSecClass,                kSecClassKey),
            (kSecAttrApplicationLabel, h as CFData)
        )

        let err = SecItemDelete(query)

        if err != errSecSuccess {
            print("Error deleting keys: \(err)")
            return false
        }

        return true
    }

    // Sign some data with the private key.
    func sign(_ data:Data) -> Data? {
        var err:Unmanaged<CFError>? = nil
        defer { err?.release() }

        let sig = SecKeyCreateSignature(privateKey, .ecdsaSignatureMessageX962SHA256, data as CFData, &err) as? Data

        if err != nil {
            print("Error creating signature: \(err!.takeUnretainedValue().localizedDescription)")
            return nil
        }

        return sig
    }

    // Verify some signature over some data with the public key.
    func verify(data:Data, signature:Data) -> Bool {
        var err:Unmanaged<CFError>? = nil
        defer { err?.release() }

        let ret = SecKeyVerifySignature(publicKey, .ecdsaSignatureMessageX962SHA256, data as CFData, signature as CFData, &err)

        if err != nil {
            print("Error verifying signature: \(err!.takeUnretainedValue().localizedDescription)")
            return false
        }

        return ret
    }
}
