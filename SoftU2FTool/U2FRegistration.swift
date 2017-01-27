//
//  U2FRegistration.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/26/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

enum U2FRegistrationError: Error {
    case CertificateGenerationError
    case KeyGenerationError
    case DuplicateKeyHandleError
}

class U2FRegistration {
    typealias SignCallback = (Data?, Error?) -> Void

    let keyHandle:Data
    let certificate:SelfSignedCertificate

    var keyHandleString:String {
        return keyHandle.base64EncodedString()
    }

    var publicKey:Data {
        return KeyInterface.publicKeyBits(keyHandleString)
    }

    // Has a key been made for this registration and persisted in the keychain?
    var doesExist:Bool {
        return KeyInterface.publicKeyExists(keyHandleString)
    }

    // Find the registration if it exists.
    static func find(keyHandle: Data) -> U2FRegistration? {
        let reg:U2FRegistration

        do {
            reg = try U2FRegistration(keyHandle: keyHandle)
        } catch {
            return nil
        }

        if reg.doesExist {
            return reg
        } else {
            return nil
        }
    }

    // Create a new registration with the given keyhandle.
    static func create(keyHandle: Data) throws -> U2FRegistration {
        let reg = try U2FRegistration(keyHandle: keyHandle)
        try reg.generateKeyPair()
        return reg
    }

    init(keyHandle kh: Data) throws {
        guard let c = SelfSignedCertificate() else {
            throw U2FRegistrationError.CertificateGenerationError
        }

        certificate = c
        keyHandle = kh
    }

    // Generate a keypair for this registration and store them in the keychain.
    func generateKeyPair() throws {
        if doesExist {
            throw U2FRegistrationError.DuplicateKeyHandleError
        }

        if !KeyInterface.generateKeyPair(keyHandleString) {
            throw U2FRegistrationError.KeyGenerationError
        }
    }

    // Delete our key pair from the keychain.
    func deleteKeyPair() -> Bool {
        if !KeyInterface.deletePrivateKey(keyHandleString) {
            print("Error deleting private key.")
            return false
        }

        if !KeyInterface.deletePubKey(keyHandleString) {
            print("Error deleting public key.")
            return false
        }

        print("Deleted keys.")
        return true
    }

    // Sign some data with the private key associated with our certificate.
    func signWithCertificateKey(_ data:Data) -> Data {
        return certificate.sign(data)
    }

    // Sign some data with the registration's privat key.
    func signWithPrivateKey(_ data:Data, with callback: @escaping SignCallback) {
        KeyInterface.generateSignature(for: data, withKeyName: keyHandleString, withCompletion: callback)
    }
}
