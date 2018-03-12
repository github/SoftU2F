//
//  Counter.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 3/12/18.
//

import Foundation

class Counter {

    private static let service = "Soft U2F"
    private static let serviceLen = UInt32(service.utf8.count)
    private static let account = "counter"
    private static let accountLen = UInt32(account.utf8.count)
    private static let mtx = Mutex()

    static var next: UInt32 {
        mtx.lock()
        defer { mtx.unlock() }

        let c = current ?? 0
        current = c + 1
        return c
    }

    // assumes mtx is already locked
    static var current: UInt32? {
        get {
            var valLen: UInt32 = 0
            var val: UnsafeMutableRawPointer? = nil

            let err = SecKeychainFindGenericPassword(nil, serviceLen, service, accountLen, account, &valLen, &val, nil)
            if err != errSecSuccess {
                if err != errSecItemNotFound {
                    print("Error from keychain: \(err)")
                }
                return nil
            }
            if val == nil { return nil }
            defer { SecKeychainItemFreeContent(nil, val) }

            guard let strVal = NSString(bytes: val!, length: Int(valLen), encoding: String.Encoding.utf8.rawValue) as String? else {
                return nil
            }

            return UInt32(strVal)
        }

        set {
            let err: OSStatus
            if let val: UInt32 = newValue {
                let strVal = String(val)
                let strValLen = UInt32(strVal.utf8.count)
                if let it = item {
                    err = SecKeychainItemModifyContent(it, nil, strValLen, strVal)
                } else {
                    err = SecKeychainAddGenericPassword(nil, serviceLen, service, accountLen, account, strValLen, strVal, nil)
                }
            } else {
                if let it = item {
                    err = SecKeychainItemDelete(it)
                } else {
                    return
                }
            }

            if err != errSecSuccess {
                print("Error from keychain: \(err)")
            }
        }
    }

    // assumes mtx is already locked
    private static var item: SecKeychainItem? {
        var it: SecKeychainItem? = nil

        let err = SecKeychainFindGenericPassword(nil, serviceLen, service, accountLen, account, nil, nil, &it)
        if err != errSecSuccess {
            if err != errSecItemNotFound {
                print("Error from keychain: \(err)")
            }
            return nil
        }

        return it
    }
}
