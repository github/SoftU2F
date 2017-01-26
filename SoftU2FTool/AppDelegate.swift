//
//  AppDelegate.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/24/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var u2fThread: Thread?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        U2FHID.shared?.handle(.Msg) { (_ msg:softu2f_hid_message) -> Bool in
            let data = msg.data.takeUnretainedValue() as Data
            let cmd:APDUCommand

            do {
                cmd = try APDUCommand(raw: data)
            } catch let err {
                print("Error reading APDU command: \(err.localizedDescription)")
                return true
            }

            if let _ = cmd.registerRequest {
                print("Received register request!")
            }

            if let _ = cmd.authenticationRequest {
                print("Received authentication request!")
            }

            if let _ = cmd.versionRequest {
                print("Received version request!")
            }

            return true
        }

        if !(U2FHID.shared?.run() ?? false) {
            print("Error starting U2FHID thread")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if !(U2FHID.shared?.stop() ?? false) {
            print("Error stopping U2FHID thread")
        }
    }
}
