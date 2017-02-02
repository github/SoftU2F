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
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // TODO: Remove this.
        if U2FRegistration.deleteAll() {
            print("Deleted all registrations")
        } else {
            print("Error deleting registrations")
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
