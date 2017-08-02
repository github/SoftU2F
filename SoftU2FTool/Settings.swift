//
//  Settings.swift
//  SoftU2F
//
//  Created by Ben Toews on 8/2/17.
//

import Foundation

class Settings {
    private static let sepEnabledKey = "sepEnabled"

    static var sepEnabled: Bool {
        return UserDefaults.standard.bool(forKey: sepEnabledKey)
    }

    static func enableSEP() {
        return UserDefaults.standard.set(true, forKey: sepEnabledKey)
    }

    static func disableSEP() {
        return UserDefaults.standard.set(false, forKey: sepEnabledKey)
    }
}
