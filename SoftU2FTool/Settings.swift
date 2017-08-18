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
    private static let sepEnabledKey = "sepEnabled"

    static var touchidDisabled: Bool {
        return !touchidAvailable || UserDefaults.standard.bool(forKey: touchidDisabledKey)
    }

    static var sepEnabled: Bool {
        return touchidAvailable && UserDefaults.standard.bool(forKey: sepEnabledKey)
    }

    private static var touchidAvailable: Bool {
        if #available(OSX 10.12.2, *) {
            return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        } else {
            return false
        }
    }

    static func enableTouchid() -> Bool {
        if touchidAvailable {
            UserDefaults.standard.set(false, forKey: touchidDisabledKey)
            return true
        } else {
            return false
        }
    }

    static func disableTouchid() {
        UserDefaults.standard.set(true, forKey: touchidDisabledKey)
    }

    static func enableSEP() -> Bool {
        if touchidAvailable {
            UserDefaults.standard.set(true, forKey: sepEnabledKey)
            return true
        } else {
            return false
        }
    }

    static func disableSEP() {
        UserDefaults.standard.set(false, forKey: sepEnabledKey)
    }
}
