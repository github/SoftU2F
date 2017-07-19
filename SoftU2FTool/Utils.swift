//
//  Utils.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/31/17.
//

import Foundation

typealias CFDictionaryMember = (CFString, CFTypeRef)

// Helper for making CFDictionary.
func makeCFDictionary(_ members: [CFDictionaryMember]) -> CFDictionary {
    var dict = [String: AnyObject]()

    members.forEach { elt in
        dict[elt.0 as String] = elt.1
    }

    return dict as CFDictionary
}

// Helper for making CFDictionary.
func makeCFDictionary(_ members: CFDictionaryMember...) -> CFDictionary {
    return makeCFDictionary(members)
}

let FifyZeros = Data(repeating: 0x00, count: 50)

// Conformance test fails if key handle is less than 64 bytes...
func padKeyHandle(_ kh: Data) -> Data {
    var new = kh
    new.append(FifyZeros)
    return new
}

// Conformance test fails if key handle is less than 64 bytes...
func unpadKeyHandle(_ kh: Data) -> Data {
    let padIdx = kh.count - FifyZeros.count

    if padIdx <= 0 {
        return kh
    }

    return kh.subdata(in: 0..<padIdx)
}

func handlingKeyChainError<T>(closure: () throws -> T) -> T? {
    do {
        return try closure()
    } catch {
        return nil
    }
}
