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

    static var all: [U2FRegistration] {
        let kps = KeyPair.all(label: namespace)
        var regs: [U2FRegistration] = []

        kps.forEach { kp in
            guard let reg = U2FRegistration(keyPair: kp) else {
                print("Error initializing U2FRegistration")
                return
            }

            regs.append(reg)
        }

        return regs
    }

    // The number of key pairs (keys/2) in the keychain.
    static var count: Int? {
        return KeyPair.count(label: namespace)
    }

    // Fix up legacy keychain items.
    static func repair() {
        KeyPair.repair(label: namespace)

        let legacyCounterSize = MemoryLayout<UInt32>.size
        let appTagSize = Int(U2F_APPID_SIZE)
        var maxCtr = Counter.current ?? 0

        for kp in KeyPair.all(label: namespace) {
            guard let appTag = kp.applicationTag else { continue }

            switch appTag.count {
            case appTagSize:
                continue
            case legacyCounterSize + appTagSize:
                // Find the maximum legacy counter.
                let ctr = appTag.withUnsafeBytes { (ptr:UnsafePointer<UInt32>) -> UInt32 in
                    return ptr.pointee.bigEndian
                }
                if ctr > maxCtr {
                    maxCtr = ctr
                }

                // remove legacy counter from the application tag.
                kp.applicationTag = appTag.subdata(in: legacyCounterSize..<(legacyCounterSize + appTagSize))
            default:
                print("bad applicationTag size")
                continue
            }
        }

        // Use the highest per-registration counter value as our global counter value.
        if maxCtr > 0 {
            Counter.current = maxCtr
        }
    }

    // Delete all SoftU2F keys from keychain.
    static func deleteAll() -> Bool {
        return KeyPair.delete(label: namespace)
    }

    let keyPair: KeyPair
    let applicationParameter: Data

    // Key handle is application label plus 50 bytes of padding. Conformance tests require key handle to be >64 bytes.
    var keyHandle: Data {
        return padKeyHandle(keyPair.applicationLabel)
    }

    var inSEP: Bool {
        return keyPair.inSEP
    }

    // Generate a new registration.
    init?(applicationParameter ap: Data, inSEP sep: Bool) {
        // TODO Specify applicationTag during creation. Alternatively, detect if setting tag fails.
        guard let kp = KeyPair(label: U2FRegistration.namespace, inSEP: sep) else { return nil }
        kp.applicationTag = ap

        applicationParameter = ap
        keyPair = kp
    }

    // Find a registration with the given key handle.
    init?(keyHandle kh: Data, applicationParameter ap: Data) {
        let appLabel = unpadKeyHandle(kh)

        let kf = KnownFacets[ap] ?? "site"
        let prompt = "authenticate with \(kf)"

        guard let kp = KeyPair(label: U2FRegistration.namespace, appLabel: appLabel, signPrompt: prompt) else { return nil }
        keyPair = kp

        // Read our application parameter from the keychain and make sure it matches.
        guard let appTag = keyPair.applicationTag else { return nil }
        applicationParameter = appTag

        if applicationParameter != ap {
            print("Bad applicationParameter")
            return nil
        }
    }

    // Initialize a registration with all the necessary data.
    init?(keyPair kp: KeyPair) {
        keyPair = kp

        guard let appTag = keyPair.applicationTag else { return nil }
        applicationParameter = appTag
    }

    // Sign some data with the private key and increment our counter.
    func sign(_ data: Data) -> Data? {
        return keyPair.sign(data)
    }
}
