//
//  AppDelegate.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/24/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Cocoa

//@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let ghkh = Data(base64Encoded: "cGF9/tBlhjr0fBVVbJF5iICCjMQH/fcK6FARVpRloHU=")!
    let yckh = Data(base64Encoded: "VWc7UTjMkNO38yv9rWo4qO3Xs1W3erl5IZbxBtFsoxI=")!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let ghreg = U2FRegistration.find(keyHandle: ghkh) {
            let _ = ghreg.deleteKeyPair()
        }

        if let ycreg = U2FRegistration.find(keyHandle: yckh) {
            let _ = ycreg.deleteKeyPair()
        }

        if !U2FAuthenticator.start() {
            print("Error starting authenticator")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if !U2FAuthenticator.stop() {
            print("Error stopping authenticator")
        }
    }
}
