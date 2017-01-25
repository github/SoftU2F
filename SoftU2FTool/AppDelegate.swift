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
            print("received message!")
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
