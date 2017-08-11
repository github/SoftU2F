//
//  CLI.swift
//  SoftU2F
//
//  Created by Ben Toews on 8/1/17.
//

import Foundation

// Command line flags
fileprivate let listFlag = "--list"
fileprivate let deleteAllFlag = "--delete-all"
fileprivate let showTouchidFlag = "--show-touchid"
fileprivate let enableTouchidFlag = "--enable-touchid"
fileprivate let disableTouchidFlag = "--disable-touchid"

class CLI {
    private let args: [String]

    init(_ arguments: [String]) {
        args = arguments
    }

    func run() -> Bool {
        if args.contains(listFlag) {
            listRegistrations()
            return true
        } else if args.contains(deleteAllFlag) {
            deleteAll()
            return true
        } else if args.contains(showTouchidFlag) {
            showTouchid()
            return true
        } else if args.contains(enableTouchidFlag) {
            enableTouchid()
            return true
        } else if args.contains(disableTouchidFlag) {
            disableTouchid()
            return true
        }

        return false
    }

    private func listRegistrations() {
        print("The following is a list of U2F registrations stored in your keychain. Each key contains several fields:")
        print("  - Key handle: This is the key handle that we registered with a website. For Soft U2F, the key handle is simply a hash of the public key.")
        print("  - Application parameter: This is the sha256 of the app-id of the site.")
        print("  - Known facet: For some sites we know the application parameter → site name mapping.")
        print("  - Counter: How many times this registration has been used.")
        print("")

        U2FRegistration.all.forEach { reg in
            print("Key handle: ", reg.keyHandle.base64EncodedString())
            print("Application parameter: ", reg.applicationParameter.base64EncodedString())

            if let kf = KnownFacets[reg.applicationParameter] {
                print("Known facet: ", kf)
            } else {
                print("Known facet: N/A")
            }

            print("Counter: ", reg.counter)
            print("")
        }
    }

    private func deleteAll() {
        guard let initialCount = U2FRegistration.count else {
            print("Error getting registration count from keychain.")
            return
        }

        if !U2FRegistration.deleteAll() {
            print("Error deleting registrations from keychain.")
            return
        }

        print("Deleted ", initialCount, " registrations")
    }

    private func showTouchid() {
        if Settings.touchidDisabled {
            print("TouchID is disabled")
        } else {
            print("TouchID is enabled")
        }
    }

    private func enableTouchid() {
        if Settings.enableTouchid() {
            print("TouchID is now enabled")
        } else {
            print("Error enabling TouchID. Does your system support it?")
        }
    }

    private func disableTouchid() {
        Settings.disableTouchid()
        print("TouchID is now disabled")
    }
}
