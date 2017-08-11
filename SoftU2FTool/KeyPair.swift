//
//  KeyPair.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 2/2/17.
//

import Foundation

fileprivate class tmpKeyPair {
    var label: String
    var applicationLabel: Data
    var publicKey: SecKey?
    var privateKey: SecKey?

    var keyPair: KeyPair? {
        guard let pub = publicKey else { return nil }
        guard let priv = privateKey else { return nil }

        return KeyPair(label: label, appLabel: applicationLabel, publicKey: pub, privateKey: priv)
    }

    init(label l: String, applicationLabel al: Data) {
        label = l
        applicationLabel = al
    }
}

class KeyPair {
    /// Get all KeyPairs with the given label.
    static func all(label: String) -> [KeyPair] {
        let secKeys = Keychain.getSecKeys(attrLabel: label as CFString)
        var tmpKeyPairs: [tmpKeyPair] = []
        var keyPairs: [KeyPair] = []

        secKeys.forEach { secKey in
            guard let appLabel: CFData = Keychain.getSecKeyAttr(key: secKey, attr: kSecAttrApplicationLabel) else { return }

            let applicationLabel = appLabel as Data
            var tmpKP: tmpKeyPair

            if let kp = tmpKeyPairs.first(where: { $0.applicationLabel == applicationLabel }) {
                tmpKP = kp
            } else {
                tmpKP = tmpKeyPair.init(label: label, applicationLabel: applicationLabel)
                tmpKeyPairs.append(tmpKP)
            }

            guard let klass: CFString = Keychain.getSecKeyAttr(key: secKey, attr: kSecAttrKeyClass) else { return }

            if klass == kSecAttrKeyClassPublic {
                tmpKP.publicKey = secKey
            } else {
                tmpKP.privateKey = secKey
            }
        }

        tmpKeyPairs.forEach { tmpKP in
            guard let kp = tmpKP.keyPair else { return }

            keyPairs.append(kp)
        }

        return keyPairs
    }

    // The number of key pairs (keys/2) in the keychain.
    static func count(label: String) -> Int? {
        guard let c = Keychain.count(attrLabel: label as CFString) else { return nil }

        if c % 2 != 0 {
            print("Uneven number of keys in the keychain.")
            return nil
        }

        return c / 2
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
            Keychain.setSecItemAttr(attrAppLabel: applicationLabel as CFData, name: kSecAttrApplicationTag, value: value as CFData)
        }
    }

    var publicKeyData: Data? {
        return Keychain.getSecItemData(attrAppLabel: applicationLabel)
    }

    // Generate a new key pair.
    init?(label l: String) {
        label = l

        guard let (pub, priv) = Keychain.generateKeyPair(attrLabel: label as CFString) else { return nil }
        publicKey = pub
        privateKey = priv

        guard let appLabel: CFData = Keychain.getSecKeyAttr(key: pub, attr: kSecAttrApplicationLabel) else { return nil }
        applicationLabel = appLabel as Data
    }

    // Find a key pair with the given label and application label.
    init?(label l: String, appLabel al: Data) {
        label = l
        applicationLabel = al

        // Lookup public key.
        guard let pub = Keychain.getSecKey(attrAppLabel: applicationLabel as CFData, keyClass: kSecAttrKeyClassPublic) else { return nil }
        publicKey = pub

        // Lookup private key.
        guard let priv = Keychain.getSecKey(attrAppLabel: applicationLabel as CFData, keyClass: kSecAttrKeyClassPrivate) else { return nil }
        privateKey = priv
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
