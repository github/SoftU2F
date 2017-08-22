//
//  KeyPair.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 2/2/17.
//

import Foundation

class KeyPair {
    // Fix up legacy keychain items.
    static func repair(label: String) {
        Keychain.repair(attrLabel: label as CFString)
    }
    
    /// Get all KeyPairs with the given label.
    static func all(label: String) -> [KeyPair] {
        let secKeys = Keychain.getPrivateSecKeys(attrLabel: label as CFString)
        var keyPairs: [KeyPair] = []

        secKeys.forEach { priv in
            guard let pub = SecKeyCopyPublicKey(priv) else { return }
            guard let appLabel: CFData = Keychain.getSecKeyAttr(key: priv, attr: kSecAttrApplicationLabel) else { return }
            
            let kp = KeyPair(label: label, appLabel: appLabel as Data, publicKey: pub, privateKey: priv)
            
            keyPairs.append(kp)
        }

        return keyPairs
    }

    // The number of private keys in the keychain.
    static func count(label: String) -> Int? {
        return Keychain.count(attrLabel: label as CFString)
    }

    // Delete all keys with the given label from the keychain.
    static func delete(label: String) -> Bool {
        return Keychain.delete(
                               (kSecClass, kSecClassKey),
                               (kSecAttrLabel, label as CFString)
        )
    }

    let label: String
    let applicationLabel: Data
    let publicKey: SecKey
    let privateKey: SecKey

    // Application tag is an attribute we use to smuggle data.
    var applicationTag: Data? {
        get {
            return Keychain.getSecItemAttr(attrAppLabel: applicationLabel as CFData, name: kSecAttrApplicationTag)
        }

        set {
            let value = (newValue ?? Data())
            _ = Keychain.setSecItemAttr(attrAppLabel: applicationLabel as CFData, name: kSecAttrApplicationTag, value: value as CFData)
        }
    }

    var publicKeyData: Data? {
        return Keychain.exportSecKey(publicKey)
    }

    var inSEP: Bool {
        let tokenID: String = Keychain.getSecItemAttr(attrAppLabel: applicationLabel as CFData, name: kSecAttrTokenID) ?? "nope"

        return tokenID == kSecAttrTokenIDSecureEnclave as String
    }

    // Generate a new key pair.
    init?(label l: String, inSEP sep: Bool) {
        label = l

        guard let (pub, priv) = Keychain.generateKeyPair(attrLabel: label as CFString, inSEP: sep) else { return nil }
        publicKey = pub
        privateKey = priv

        guard let appLabel: CFData = Keychain.getSecKeyAttr(key: pub, attr: kSecAttrApplicationLabel) else { return nil }
        applicationLabel = appLabel as Data
    }

    // Find a key pair with the given label and application label.
    init?(label l: String, appLabel al: Data, signPrompt sp: String) {
        label = l
        applicationLabel = al

        // Lookup private key.
        guard let priv = Keychain.getPrivateSecKey(attrAppLabel: applicationLabel as CFData, signPrompt: sp as CFString) else { return nil }
        privateKey = priv
        
        // Generate public key from private key
        guard let pub = SecKeyCopyPublicKey(priv) else { return nil }
        publicKey = pub
    }

    // Initialize a key pair with all the necessary data.
    init(label l: String, appLabel al: Data, publicKey pub: SecKey, privateKey priv: SecKey) {
        label = l
        applicationLabel = al
        publicKey = pub
        privateKey = priv
    }

    // Delete this key pair.
    func delete() -> Bool {
        return Keychain.delete(
                               (kSecClass, kSecClassKey),
                               (kSecAttrApplicationLabel, applicationLabel as CFData)
        )
    }

    // Sign some data with the private key.
    func sign(_ data: Data) -> Data? {
        return Keychain.sign(key: privateKey, data: data)
    }

    // Verify some signature over some data with the public key.
    func verify(data: Data, signature: Data) -> Bool {
        return Keychain.verify(key: publicKey, data: data, signature: signature)
    }
}
