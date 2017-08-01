//
//  AppDelegate.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/24/17.
//

import Cocoa

let listKeysArgument = "--list"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if CommandLine.arguments.contains(listKeysArgument) {
            listKeys()
            quit()
            return
        }
      
      
        if !U2FAuthenticator.start() {
            print("Error starting authenticator")
            quit()
            return
        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if U2FAuthenticator.running && !U2FAuthenticator.stop() {
            print("Error stopping authenticator")
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // Chrome gives ignores our U2F responses if it isn't active when we send them.
        // This hack should give focus back to Chrome immediately after the user interacts
        // with our notification.
        NSApplication.shared().hide(nil)
    }
    
    private func quit() {
        NSApplication.shared().terminate(self)
    }
  
    private func listKeys() {
        if let numRegs = U2FRegistration.count {
            print("Registrations: ", numRegs)
        }
        
        U2FRegistration.all.forEach { reg in
            print("base64(key handle): ", reg.keyHandle.base64EncodedString())
            print("base64(sha256(appid)): ", reg.applicationParameter.base64EncodedString())
            
            if let kf = KnownFacets[reg.applicationParameter] {
                print("site: ", kf)
            } else {
                print("site: unknown")
            }
            
            print("counter: ", reg.counter)
            print("")
        }
    }
}
