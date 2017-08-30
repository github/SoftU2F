//
//  U2FAuthenticator.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/25/17.
//

import Foundation
import APDU
import SelfSignedCertificate

class U2FAuthenticator {
    static let shared = U2FAuthenticator()
    private static var hasShared = false

    var running: Bool

    private let u2fhid: U2FHID

    static var running: Bool {
        guard let ua: U2FAuthenticator = shared else { return false }
        return ua.running
    }

    static func start() -> Bool {
        guard let ua: U2FAuthenticator = shared else { return false }
        return ua.start()
    }

    static func stop() -> Bool {
        guard let ua: U2FAuthenticator = shared else { return false }
        return ua.stop()
    }

    private var laptopIsOpen: Bool {
        guard let screens = NSScreen.screens() else { return true }

        return screens.contains { screen in
            guard let screenID = screen.deviceDescription["NSScreenNumber"] as? uint32 else { return true }
            return CGDisplayIsBuiltin(screenID) == 1
        }
    }

    init?() {
        guard let uh: U2FHID = U2FHID.shared else { return nil }

        running = false
        u2fhid = uh
        installMsgHandler()
    }

    func start() -> Bool {
        if u2fhid.run() {
            running = true
            return true
        }

        return false
    }

    func stop() -> Bool {
        if u2fhid.stop() {
            running = false
            return true
        }

        return false
    }

    func installMsgHandler() {
        u2fhid.handle(.Msg) { (_ msg: softu2f_hid_message) -> Bool in
            let data = msg.data.takeUnretainedValue() as Data

            do {
                let ins = try APDU.commandType(raw: data)

                switch ins {
                case .Register:
                    try self.handleRegisterRequest(data, cid: msg.cid)
                case .Authenticate:
                    try self.handleAuthenticationRequest(data, cid: msg.cid)
                case .Version:
                    try self.handleVersionRequest(data, cid: msg.cid)
                default:
                    self.sendError(status: .InsNotSupported, cid: msg.cid)
                }
            } catch let err as APDU.ResponseStatus {
                self.sendError(status: err, cid: msg.cid)
            } catch {
                self.sendError(status: .OtherError, cid: msg.cid)
            }

            return true
        }
    }

    func handleRegisterRequest(_ raw: Data, cid: UInt32) throws {
        let req = try APDU.RegisterRequest(raw: raw)

        let facet = KnownFacets[req.applicationParameter]
        let notification = UserPresence.Notification.Register(facet: facet)

        UserPresence.test(notification) { tupSuccess in
            if !tupSuccess {
                // Send no response. Otherwise Chrome will re-prompt immediately.
                return
            }

            guard let reg = U2FRegistration(applicationParameter: req.applicationParameter, inSEP: Settings.sepEnabled) else {
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

            guard let sig = SelfSignedCertificate.sign(sigPayload) else {
                print("Error signing with certificate")
                self.sendError(status: .OtherError, cid: cid)
                return
            }

            let resp = RegisterResponse(publicKey: publicKey, keyHandle: reg.keyHandle, certificate: SelfSignedCertificate.toDer(), signature: sig)

            self.sendMsg(msg: resp, cid: cid)
        }
    }

    func handleAuthenticationRequest(_ raw: Data, cid: UInt32) throws {
        let req = try APDU.AuthenticationRequest(raw: raw)

        guard let reg = U2FRegistration(keyHandle: req.keyHandle, applicationParameter: req.applicationParameter) else {
            sendError(status: .WrongData, cid: cid)
            return
        }

        if req.control == .CheckOnly {
            // success -> error response. It's weird...
            sendError(status: .ConditionsNotSatisfied, cid: cid)
            return
        }

        if reg.inSEP && !laptopIsOpen {
            // Can't use SEP/TouchID if laptop is closed.
            sendError(status: .OtherError, cid: cid)
            return
        }

        let facet = KnownFacets[req.applicationParameter]
        let notification = UserPresence.Notification.Authenticate(facet: facet)
        let skipTUP = reg.inSEP

        UserPresence.test(notification, skip: skipTUP) { tupSuccess in
            if !tupSuccess {
                // Send no response. Otherwise Chrome will re-prompt immediately.
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

    func handleVersionRequest(_ raw: Data, cid: UInt32) throws {
        let _ = try APDU.VersionRequest(raw: raw)
        let resp = APDU.VersionResponse(version: "U2F_V2")
        sendMsg(msg: resp, cid: cid)
    }

    func sendError(status: APDU.ResponseStatus, cid: UInt32) {
        let resp = APDU.ErrorResponse(status: status)
        sendMsg(msg: resp, cid: cid)
    }

    func sendMsg(msg: APDU.RawConvertible, cid: UInt32) {
        let _ = u2fhid.sendMsg(cid: cid, data: msg.raw)
    }
}
