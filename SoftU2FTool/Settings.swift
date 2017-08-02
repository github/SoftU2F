//
//  Settings.swift
//  SoftU2F
//
//  Created by Ben Toews on 8/2/17.
//

import Foundation
import LocalAuthentication

class Settings {
    private static let sepEnabledKey = "sepEnabled"

    static var sepEnabled: Bool {
        return sepAvailable && UserDefaults.standard.bool(forKey: sepEnabledKey)
    }

    static func enableSEP() -> Bool {
        if sepAvailable {
            UserDefaults.standard.set(true, forKey: sepEnabledKey)
            return true
        } else {
            return false
        }
    }

    static func disableSEP() {
        UserDefaults.standard.set(false, forKey: sepEnabledKey)
    }

    private static var sepAvailable: Bool {
        if #available(OSX 10.12.2, *) {
            return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        } else {
            return false
        }
    }
}
