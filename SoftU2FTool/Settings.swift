//
//  Settings.swift
//  SoftU2F
//
//  Created by Ben Toews on 8/2/17.
//

import Foundation
import LocalAuthentication

class Settings {
    private static let touchidDisabledKey = "touchidDisabled"

    static var touchidDisabled: Bool {
        return touchidAvailable && UserDefaults.standard.bool(forKey: touchidDisabledKey)
    }

    static func enableTouchid() -> Bool {
        if touchidAvailable {
            UserDefaults.standard.set(true, forKey: touchidDisabledKey)
            return true
        } else {
            return false
        }
    }

    static func disableTouchid() {
        UserDefaults.standard.set(false, forKey: touchidDisabledKey)
    }

    private static var touchidAvailable: Bool {
        if #available(OSX 10.12.2, *) {
            return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        } else {
            return false
        }
    }
}
