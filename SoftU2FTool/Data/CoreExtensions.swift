//
//  UIntData.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

extension Data {
    init<T:EndianProtocol>(int val:T, endian:Endian = .Big) {
        var eval:T
        
        switch endian {
        case .Big:
            eval = val.bigEndian
        case .Little:
            eval = val.littleEndian
        }
        
        self.init(bytes: &eval, count: MemoryLayout<T>.size)
    }
}
