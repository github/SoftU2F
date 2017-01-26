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
