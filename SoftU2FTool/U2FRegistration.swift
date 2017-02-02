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

    // The number of key pairs (keys/2) in the keychain.
    static var count:Int? {
        return KeyPair.count(label: namespace)
    }

    // Delete all SoftU2F keys from keychain.
    static func deleteAll() -> Bool {
        return KeyPair.delete(label: namespace)
    }

    let keyPair:KeyPair

    // Key handle is application label plus 50 bytes of padding. Conformance tests require key handle to be >64 bytes.
    var keyHandle:Data {
        return padKeyHandle(keyPair.applicationLabel)
    }

    // How many times this authenticator has been used. We smuggle this data in the application tag.
    var counter:UInt32? {
        get {
            guard let raw = keyPair.applicationTag else { return nil }
            return DataReader(data: raw).read()
        }

        set {
            let value = newValue ?? 0
            let writer = DataWriter()
            writer.write(value)
            keyPair.applicationTag = writer.buffer
        }
    }

    // Generate a new registration.
    init?() {
        guard let kp = KeyPair(label: U2FRegistration.namespace) else {
            return nil
        }

        keyPair = kp
        counter = 1
    }

    // Find a registration with the given key handle.
    init?(keyHandle kh:Data) {
        let appLabel = unpadKeyHandle(kh)
        guard let kp = KeyPair(label: U2FRegistration.namespace, appLabel: appLabel) else {
            return nil
        }

        keyPair = kp
    }

    // Sign some data with the private key and increment our counter.
    func sign(_ data:Data) -> Data? {
        guard let sig = keyPair.sign(data) else { return nil }

        if let current = counter {
            counter = current + 1
        }

        return sig
    }
}
