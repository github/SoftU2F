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
        // Fix up legacy keychain items.
        U2FRegistration.repair()

        if CLI(CommandLine.arguments).run() {
            quit()
        } else if !U2FAuthenticator.start(){
            print("Error starting authenticator")
            quit()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if U2FAuthenticator.running && !U2FAuthenticator.stop() {
            print("Error stopping authenticator")
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // Chrome ignores our U2F responses if it isn't active when we send them.
        // This hack should give focus back to Chrome immediately after the user interacts
        // with our notification.
        NSApplication.shared.hide(nil)
    }

    private func quit() {
        NSApplication.shared.terminate(self)
    }
}
