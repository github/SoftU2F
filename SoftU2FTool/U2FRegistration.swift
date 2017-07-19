//
//  U2FRegistration.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/30/17.
//

import Foundation

class U2FRegistration {
    // Allow using separate keychain namespace for tests.
    static var namespace = "SoftU2F Security Key"

    // The number of key pairs (keys/2) in the keychain.
    static var count: Int? {
        return KeyPair.count(label: namespace)
    }

    // Delete all SoftU2F keys from keychain.
    static func deleteAll() -> Bool {
        return KeyPair.delete(label: namespace)
    }

    let keyPair: KeyPair
    let applicationParameter: Data
    var counter: UInt32

    // Key handle is application label plus 50 bytes of padding. Conformance tests require key handle to be >64 bytes.
    var keyHandle: Data {
        return padKeyHandle(keyPair.applicationLabel)
    }

    // Generate a new registration.
    init?(applicationParameter ap: Data) {
        applicationParameter = ap

        guard let kp = KeyPair(label: U2FRegistration.namespace) else { return nil }
        keyPair = kp

        counter = 1
        writeApplicationTag()
    }

    // Find a registration with the given key handle.
    init?(keyHandle kh: Data, applicationParameter ap: Data) {
        let appLabel = unpadKeyHandle(kh)
        guard let kp = KeyPair(label: U2FRegistration.namespace, appLabel: appLabel) else { return nil }
        keyPair = kp

        // Read our application parameter from the keychain and make sure it matches.
        guard let appTag = keyPair.applicationTag else { return nil }

        let counterSize = MemoryLayout<UInt32>.size
        let appTagSize = Int(U2F_APPID_SIZE)

        if appTag.count != counterSize + appTagSize {
            return nil
        }

        counter = appTag.withUnsafeBytes { (ptr:UnsafePointer<UInt32>) -> UInt32 in
            return ptr.pointee.bigEndian
        }

        applicationParameter = appTag.subdata(in: counterSize..<(counterSize + appTagSize))

        if applicationParameter != ap {
            print("Bad applicationParameter")
            return nil
        }
    }

    // Sign some data with the private key and increment our counter.
    func sign(_ data: Data) -> Data? {
        guard let sig = keyPair.sign(data) else { return nil }

        incrementCounter()

        return sig
    }

    func incrementCounter() {
        counter += 1
        writeApplicationTag()
    }

    func readApplicationTag(appTag: Data?) {
    }

    // Persist the applicationParameter and counter in the keychain.
    func writeApplicationTag() {
        let counterSize = MemoryLayout<UInt32>.size
        let appTagSize = Int(U2F_APPID_SIZE)
        var data = Data(capacity: counterSize + appTagSize)
        var ctrBigEndian = counter.bigEndian

        data.append(Data(bytes: &ctrBigEndian, count: counterSize))
        data.append(applicationParameter)

        keyPair.applicationTag = data
    }
}
