//
//  UserPresence.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/27/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

class UserPresence: NSObject {
    enum Notification {
        case Register(facet:String?)
        case Authenticate(facet:String?)
    }

    typealias Callback = (_ success:Bool) -> Void

    static let shared:UserPresence = UserPresence()

    // Display a notification, wait for the user to click it, and call the callback with `true`.
    // Calls callback with `false` if another test is done while we're waiting for this one.
    static func test(_ type:Notification, with cb: @escaping Callback) {
        shared.test(type, with: cb)
    }

    var callback:Callback?
    var delegateWas:NSUserNotificationCenterDelegate?

    // Display a notification, wait for the user to click it, and call the callback with `true`.
    // Calls callback with `false` if another test is done while we're waiting for this one.
    func test(_ type:Notification, with cb: @escaping Callback) {
        // If there was an outstanding test, fail it.
        fireCallback(false)

        callback = cb
        delegateWas = NSUserNotificationCenter.default.delegate
        NSUserNotificationCenter.default.delegate = self
        sendNotification(type)
    }

    // Call the callback closure with our result and reset everything.
    func fireCallback(_ result:Bool) {
        guard let cb = callback else { return }
        cb(result)
        callback = nil

        NSUserNotificationCenter.default.delegate = delegateWas
        delegateWas = nil
    }

    // Send a notification popup to the user.
    func sendNotification(_ type:Notification) {
        let notification = NSUserNotification()
        notification.title = "Security Key Request"
        notification.soundName = NSUserNotificationDefaultSoundName

        switch type {
        case let .Register(facet):
            notification.informativeText = "Register with " + (facet ?? "site")
        case let .Authenticate(facet):
            notification.informativeText = "Authenticate with " + (facet ?? "site")
        }

        NSUserNotificationCenter.default.deliver(notification)
        }
    }

    extension UserPresence: NSUserNotificationCenterDelegate {
        func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        print("TestOfUserPresence.didDeliver")
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        print("TestOfUserPresence.didActivate")
        fireCallback(true)
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        print("TestOfUserPresence.shouldPresent")
        return true
    }
}
