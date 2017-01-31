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

    // Singleton instance.
    static let shared:UserPresence = UserPresence()

    // Display a notification, wait for the user to click it, and call the callback with `true`.
    // Calls callback with `false` if another test is done while we're waiting for this one.
    static func test(_ type:Notification, with cb: @escaping Callback) {
        shared.test(type, with: cb)
    }

    var skip = false

    private var callback:Callback?
    private var notification:NSUserNotification?
    private var timer:Timer?
    private var delegateBackup:NSUserNotificationCenterDelegate?

    // Helper for accessing user notification center singleton.
    private var center:NSUserNotificationCenter { return NSUserNotificationCenter.default }

    // Display a notification, wait for the user to click it, and call the callback with `true`.
    // Calls callback with `false` if another test is done while we're waiting for this one.
    func test(_ type:Notification, with cb: @escaping Callback) {
        if skip {
            // Skip sending an actual notification for tests.
            cb(true)
            return
        }

        // If there was an outstanding test, fail it.
        fail()

        callback = cb
        backupDelegate()
        sendNotification(type)
    }

    // Call the callback closure with our result and reset everything.
    func complete(_ result:Bool) {
        callback?(result)
        callback = nil

        timer?.invalidate()
        timer = nil

        restoreDelegate()
    }
    func fail()    { complete(false) }
    func succeed() { complete(true) }

    // Send a notification popup to the user.
    func sendNotification(_ type:Notification) {
        let notification = NSUserNotification()
        notification.title = "Security Key Request"
        notification.actionButtonTitle = "Approve"
        notification.otherButtonTitle = "Reject"

        switch type {
        case let .Register(facet):
            notification.informativeText = "Register with " + (facet ?? "site")
        case let .Authenticate(facet):
            notification.informativeText = "Authenticate with " + (facet ?? "site")
        }

        NSUserNotificationCenter.default.deliver(notification)
    }

    func installTimer() {
    }

    func clearTimer() {
        timer?.invalidate()
        timer = nil
    }

    func backupDelegate() {
        delegateBackup = center.delegate
        center.delegate = self
    }

    func restoreDelegate() {
        center.delegate = delegateBackup
        delegateBackup = nil
    }
}

extension UserPresence: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        // User clicked our notification.
        NSUserNotificationCenter.default.removeDeliveredNotification(notification)
        succeed()
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        // Present notification even if we're in foreground.
        return true
    }
}
