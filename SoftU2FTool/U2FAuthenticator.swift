//
//  U2FAuthenticator.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

class U2FAuthenticator {
    static let shared = U2FAuthenticator()
    private static var hasShared = false

    private let u2fhid:U2FHID

    static func start() -> Bool {
        guard let ua:U2FAuthenticator = shared else { return false }
        return ua.start()
    }

    static func stop() -> Bool {
        guard let ua:U2FAuthenticator = shared else { return false }
        return ua.stop()
    }

    let certificate = SelfSignedCertificate()!

    init?() {
        guard let uh:U2FHID = U2FHID.shared else { return nil }

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
        u2fhid.handle(.Msg) { (_ msg:softu2f_hid_message) -> Bool in
            let data = msg.data.takeUnretainedValue() as Data
            let cmd:APDUCommand

            do {
                cmd = try APDUCommand(raw: data)
            } catch APDUError.BadCode {
                print("Unknown APDU command code")
                self.sendError(status: .InsNotSupported, cid: msg.cid)
                return true
            } catch APDUError.BadSize {
                print("Bad request size")
                self.sendError(status: .WrongLength, cid: msg.cid)
                return true
            } catch APDUError.BadClass {
                print("Bad request size")
                self.sendError(status: .ClassNotSupported, cid: msg.cid)
                return true
            } catch let err {
                print("Error reading APDU command: \(err.localizedDescription)")
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
                if let control = AuthenticationRequest.Control(rawValue: cmd.header.p1) {
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

    func handleRegisterRequest(_ req:RegisterRequest, cid:UInt32) {
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

            let sigPayload = DataWriter()
            sigPayload.write(UInt8(0x00)) // reserved
            sigPayload.writeData(req.applicationParameter)
            sigPayload.writeData(req.challengeParameter)
            sigPayload.writeData(reg.keyHandle)
            sigPayload.writeData(publicKey)

            guard let sig = self.certificate.sign(sigPayload.buffer) else {
                print("Error signing with certificate")
                self.sendError(status: .OtherError, cid: cid)
                return
            }

            let resp = RegisterResponse(publicKey: publicKey, keyHandle: reg.keyHandle, certificate: self.certificate.toDer(), signature: sig)
            
            self.sendMsg(msg: resp, cid: cid)
        }
    }

    func handleAuthenticationRequest(_ req:AuthenticationRequest, control: AuthenticationRequest.Control, cid:UInt32) {
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

            let sigPayload = DataWriter()
            sigPayload.writeData(req.applicationParameter)
            sigPayload.write(UInt8(0x01))        // user present
            sigPayload.write(counter)
            sigPayload.writeData(req.challengeParameter)

            guard let sig = reg.sign(sigPayload.buffer) else {
                self.sendError(status: .OtherError, cid: cid)
                return
            }

            let resp = AuthenticationResponse(userPresence: 0x01, counter: counter, signature: sig)
            self.sendMsg(msg: resp, cid: cid)
            return
        }
    }

    func handleVersionRequest(_ req:VersionRequest, cid:UInt32) {
        let resp = VersionResponse(version: "U2F_V2")
        sendMsg(msg: resp, cid: cid)
    }

    func sendError(status:APDUResponseStatus, cid: UInt32) {
        let resp = ErrorResponse(status: status)
        sendMsg(msg: resp, cid: cid)
    }

    func sendMsg(msg:APDUMessageProtocol, cid:UInt32) {
        if u2fhid.sendMsg(cid: cid, data: msg.raw) {
            print("↓↓↓↓↓ Sent message ↓↓↓↓↓")
        } else {
            print("↓↓↓↓↓ Error sending message ↓↓↓↓↓")
        }

        msg.debug()
        print("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\n")
    }
}
