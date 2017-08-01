//
//  AppDelegate.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/24/17.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if !U2FAuthenticator.start() {
            print("Error starting authenticator")
            NSApplication.shared().terminate(self)
        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if U2FAuthenticator.shared != nil && !U2FAuthenticator.stop() {
            print("Error stopping authenticator")
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // Chrome gives ignores our U2F responses if it isn't active when we send them.
        // This hack should give focus back to Chrome immediately after the user interacts
        // with our notification.
        NSApplication.shared().hide(nil)
    }
}
