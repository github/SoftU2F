//
//  SHA256.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/10/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

class SHA256 {
    typealias TupleDigest = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

    enum SError: Error {
        case BadEncoding
    }
    
    static var DigestLength = Int(CC_SHA256_DIGEST_LENGTH)
    
    static func digest(_ data: Data) -> Data {
        return SHA256(data: data).digest
    }

    static func digest(_ string: String) -> Data {
        return SHA256(data: string.data(using: .utf8)!).digest
    }

    static func tupleDigest(_ data: Data) -> TupleDigest {
        return SHA256(data: data).tupleDigest
    }

    static func tupleDigest(str: String) throws -> TupleDigest {
        guard let data = str.data(using: .utf8) else { throw SError.BadEncoding }
        return SHA256(data: data).tupleDigest
    }
    
    static func b64Digest(_ data: Data) -> Data {
        return SHA256(data: data).b64Digest
    }
    
    static func webSafeB64Digest(_ data: Data) -> String {
        return SHA256(data: data).webSafeB64Digest
    }
    
    let digest: Data
    
    var tupleDigest: TupleDigest {
        return digest.withUnsafeBytes { digestPtr in
            return digestPtr.pointee
        }
    }
    
    var b64Digest: Data {
        return digest.base64EncodedData()
    }
    
    var webSafeB64Digest: String {
        return WebSafeBase64.encode(digest)
    }

    
    init(data: Data) {
        digest = Data(repeating: 0x00, count: SHA256.DigestLength)

        digest.withUnsafeMutableBytes { (_ digestPtr: UnsafeMutablePointer<UInt8>) -> Void in
            data.withUnsafeBytes { (_ dataPtr: UnsafePointer<UInt8>) -> Void in
                CC_SHA256(dataPtr, CC_LONG(data.count), digestPtr)
            }
        }
    }
}
