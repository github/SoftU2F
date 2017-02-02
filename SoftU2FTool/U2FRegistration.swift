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

    // Application label is a hash of the public key.
    var applicationLabel:Data? {
        return publicKeyAttrs?[String(kSecAttrApplicationLabel)] as? Data
    }

    // Application tag is an attribute we use to smuggle data (counter).
    var applicationTag:Data? {
        get {
            guard let appLabel = applicationLabel else {
                print("Error getting key handle")
                return nil
            }

            let query = makeCFDictionary(
                (kSecClass,                kSecClassKey),
                (kSecAttrKeyType,          kSecAttrKeyTypeEC),
                (kSecAttrKeyClass,         kSecAttrKeyClassPublic),
                (kSecAttrApplicationLabel, appLabel as CFData),
                (kSecReturnAttributes,     kCFBooleanTrue)
            )

            var opaqueDict:CFTypeRef? = nil
            let err = SecItemCopyMatching(query, &opaqueDict)

            if err != errSecSuccess {
                print("Error calling SecItemCopyMatching: \(err)")
                return nil
            }

            if opaqueDict == nil {
                print("No result from SecItemCopyMatching")
                return nil
            }

            let dict = opaqueDict! as! CFDictionary as NSDictionary

            guard let opaqueResult = dict[kSecAttrApplicationTag] else {
                return nil
            }

            let result = opaqueResult as! CFData
            
            return result as Data
        }

        set(newValue) {
            guard let appLabel = applicationLabel else {
                print("Can't update applicationTag. No applicationLabel.")
                return
            }

            guard let nv = newValue else {
                print("Can't update applicationTag. No new value.")
                return
            }

            let query = makeCFDictionary(
                (kSecClass,                kSecClassKey),
                (kSecAttrKeyType,          kSecAttrKeyTypeEC),
                (kSecAttrKeyClass,         kSecAttrKeyClassPublic),
                (kSecAttrApplicationLabel, appLabel as CFData)
            )

            let newAttrs = makeCFDictionary(
                (kSecAttrApplicationTag, nv as CFData)
            )

            let err = SecItemUpdate(query, newAttrs)
            if err != errSecSuccess {
                print("Error updating applicationTag: \(err)")
            }
        }
    }

    // Key handle is application label plus 50 bytes of padding. Conformance tests require key handle to be >64 bytes.
    var handle:Data? {
        guard let h = applicationLabel else {
            return nil
        }

        return padKeyHandle(h)
    }

    // How many times this authenticator has been used. We smuggle this data in the application tag.
    var counter:UInt32? {
        get {
            guard let raw = applicationTag else {
                return nil
            }

            return DataReader(data: raw).read()
        }

        set(newValue) {
            guard let nv = newValue else {
                print("Can;t update counter. No new value.")
                return
            }

            let writer = DataWriter()
            writer.write(nv)

            applicationTag = writer.buffer
        }
    }

    // Raw public key bytes.
    var publicKeyData:Data? {
        guard let appLabel = applicationLabel else {
            print("Error getting key handle")
            return nil
        }

        let query = makeCFDictionary(
            (kSecClass,                kSecClassKey),
            (kSecAttrKeyType,          kSecAttrKeyTypeEC),
            (kSecAttrKeyClass,         kSecAttrKeyClassPublic),
            (kSecAttrApplicationLabel, appLabel as CFData),
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

        counter = 1
    }

    init?(keyHandle kh:Data) {
        let appLabel = unpadKeyHandle(kh) as CFData

        // Lookup public key.
        var query = makeCFDictionary(
            (kSecClass,                kSecClassKey),
            (kSecAttrKeyType,          kSecAttrKeyTypeEC),
            (kSecAttrKeyClass,         kSecAttrKeyClassPublic),
            (kSecAttrApplicationLabel, appLabel),
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
            (kSecAttrApplicationLabel, appLabel),
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
        guard let appLabel = applicationLabel else {
            print("Error getting key handle")
            return false
        }

        let query = makeCFDictionary(
            (kSecClass,                kSecClassKey),
            (kSecAttrApplicationLabel, appLabel as CFData)
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

        if let current = counter {
            counter = current + 1
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
