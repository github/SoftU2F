//
//  U2FAuthenticator.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation
import APDU
import SelfSignedCertificate

class U2FAuthenticator {
    static let shared = U2FAuthenticator()
    private static var hasShared = false

    private let u2fhid: U2FHID

    static func start() -> Bool {
        guard let ua: U2FAuthenticator = shared else { return false }
        return ua.start()
    }

    static func stop() -> Bool {
        guard let ua: U2FAuthenticator = shared else { return false }
        return ua.stop()
    }

    let certificate = SelfSignedCertificate()!

    init?() {
        guard let uh: U2FHID = U2FHID.shared else { return nil }

        u2fhid = uh
        installMsgHandler()
    }

    func start() -> Bool {
        return u2fhid.run()
    }

    func stop() -> Bool {
        return u2fhid.stop()
    }

    func installMsgHandler() {
        u2fhid.handle(.Msg) { (_ msg: softu2f_hid_message) -> Bool in
            let data = msg.data.takeUnretainedValue() as Data
            let cmd: APDU.Command

            do {
                cmd = try APDU.Command(raw: data)
            } catch let err as APDU.ResponseStatus {
                self.sendError(status: err, cid: msg.cid)
                return true
            } catch {
                self.sendError(status: .OtherError, cid: msg.cid)
                return true
            }

            print("↓↓↓↓↓ Received message ↓↓↓↓↓")
            cmd.debug()
            print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\n")

            if let req = cmd.registerRequest {
                self.handleRegisterRequest(req, cid: msg.cid)
                return true
            }

            if let req = cmd.authenticationRequest {
                if let control = APDU.Control(rawValue: cmd.header.p1) {
                    self.handleAuthenticationRequest(req, control: control, cid: msg.cid)
                    return true
                }
            }

            if let req = cmd.versionRequest {
                self.handleVersionRequest(req, cid: msg.cid)
                return true
            }

            self.sendError(status: .OtherError, cid: msg.cid)
            return true
        }
    }

    func handleRegisterRequest(_ req: APDU.RegisterRequest, cid: UInt32) {
        let facet = KnownFacets[req.applicationParameter]
        let notification = UserPresence.Notification.Register(facet: facet)

        UserPresence.test(notification) { success in
            if !success {
                self.sendError(status: .ConditionsNotSatisfied, cid: cid)
                return
            }

            guard let reg = U2FRegistration(applicationParameter: req.applicationParameter) else {
                print("Error creating registration.")
                self.sendError(status: .OtherError, cid: cid)
                return
            }

            guard let publicKey = reg.keyPair.publicKeyData else {
                print("Error getting public key")
                self.sendError(status: .OtherError, cid: cid)
                return
            }

            let payloadSize = 1 + req.applicationParameter.count + req.challengeParameter.count + reg.keyHandle.count + publicKey.count
            var sigPayload = Data(capacity: payloadSize)
            
            sigPayload.append(UInt8(0x00)) // reserved
            sigPayload.append(req.applicationParameter)
            sigPayload.append(req.challengeParameter)
            sigPayload.append(reg.keyHandle)
            sigPayload.append(publicKey)

            guard let sig = self.certificate.sign(sigPayload) else {
                print("Error signing with certificate")
                self.sendError(status: .OtherError, cid: cid)
                return
            }

            let resp = RegisterResponse(publicKey: publicKey, keyHandle: reg.keyHandle, certificate: self.certificate.toDer(), signature: sig)

            self.sendMsg(msg: resp, cid: cid)
        }
    }

    func handleAuthenticationRequest(_ req: APDU.AuthenticationRequest, control: APDU.Control, cid: UInt32) {
        guard let reg = U2FRegistration(keyHandle: req.keyHandle, applicationParameter: req.applicationParameter) else {
            sendError(status: .WrongData, cid: cid)
            return
        }

        if control == .CheckOnly {
            // success -> error response. It's weird...
            sendError(status: .ConditionsNotSatisfied, cid: cid)
            return
        }

        let facet = KnownFacets[req.applicationParameter]
        let notification = UserPresence.Notification.Authenticate(facet: facet)

        UserPresence.test(notification) { success in
            if !success {
                self.sendError(status: .ConditionsNotSatisfied, cid: cid)
                return
            }

            let counter = reg.counter
            var ctrBigEndian = counter.bigEndian
            
            let payloadSize = req.applicationParameter.count + 1 + MemoryLayout<UInt32>.size + req.challengeParameter.count
            var sigPayload = Data(capacity: payloadSize)

            sigPayload.append(req.applicationParameter)
            sigPayload.append(UInt8(0x01)) // user present
            sigPayload.append(Data(bytes: &ctrBigEndian, count: MemoryLayout<UInt32>.size))
            sigPayload.append(req.challengeParameter)

            guard let sig = reg.sign(sigPayload) else {
                self.sendError(status: .OtherError, cid: cid)
                return
            }

            let resp = AuthenticationResponse(userPresence: 0x01, counter: counter, signature: sig)
            self.sendMsg(msg: resp, cid: cid)
            return
        }
    }

    func handleVersionRequest(_ req: APDU.VersionRequest, cid: UInt32) {
        let resp = APDU.VersionResponse(version: "U2F_V2")
        sendMsg(msg: resp, cid: cid)
    }

    func sendError(status: APDU.ResponseStatus, cid: UInt32) {
        let resp = APDU.ErrorResponse(status: status)
        sendMsg(msg: resp, cid: cid)
    }

    func sendMsg(msg: APDU.MessageProtocol, cid: UInt32) {
        if u2fhid.sendMsg(cid: cid, data: msg.raw) {
            print("↓↓↓↓↓ Sent message ↓↓↓↓↓")
        } else {
            print("↓↓↓↓↓ Error sending message ↓↓↓↓↓")
        }

        msg.debug()
        print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\n")
    }
}
