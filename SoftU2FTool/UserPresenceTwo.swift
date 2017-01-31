//
//  UserPresenceTwo.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/30/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

class UserPresenceTwo {
    typealias Callback = (_ success:Bool) -> Void

    public static var skip = false
    private static var current:UserPresenceTwo?

    static func test(callback cb: @escaping Callback) {
        if skip {
            cb(true)
        } else {
            current = UserPresenceTwo(callback: cb)
        }
    }

    private let callback:Callback
    private let delegateBackup:NSUserNotificationCenterDelegate?
    private let timer:Timer
    private let notification:NSUserNotification
    private var received = false

    init(callback cb: @escaping Callback) {
        callback = cb

        // Store previous delegate to restore on deinit.
        delegateBackup = NSUserNotificationCenter.default.delegate

        // Use self as delegate to receive notification events.
        NSUserNotificationCenter.default.delegate = self

        // Install timer to check if alert has been dismissed.
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UserPresenceTwo.checkAlert), userInfo: nil, repeats: true)

        // Create a notification to send to the user.
        notification = NSUserNotification()
    }

    func complete(_ result:Bool) {
        // Let caller know that we're finished.
        callback(result)

        // Stop our timer.
        timer.invalidate()

        // Restore previous delegate.
        NSUserNotificationCenter.default.delegate = delegateBackup

        UserPresenceTwo.current = nil
    }

    // Check that the alert hasn't been dismissed.
    @objc
    func checkAlert() {
        if received {
        }
    }
}

extension UserPresenceTwo: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        // User has been shown notification.
        received = true
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        // User clicked our notification.
        NSUserNotificationCenter.default.removeDeliveredNotification(notification)
        complete(true)
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        // Present notification even if we're in foreground.
        return true
    }
}
