//
//  WebSafeBase64.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/13/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

class WebSafeBase64 {
    static func encode(_ data: Data) -> String {
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    static func decode(_ string: String) -> Data? {
        var b64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let padding: Int

        switch b64.characters.count % 4 {
        case 0:
            padding = 0
        case 2:
            padding = 2
        case 3:
            padding = 1
        default:
            return nil
        }

        b64 += String(repeating: "=", count: padding)

        return Data(base64Encoded: b64)
    }

    static func random(_ size: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0x00, count: size)
        let _ = SecRandomCopyBytes(kSecRandomDefault, size, &bytes)
        let data = Data(bytes: bytes)
        return encode(data)
    }
}
