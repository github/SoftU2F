//
//  MessagePart.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 2/7/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

// Part of a APDU message (header/trailer).
protocol MessagePart {
    init(reader: DataReader) throws
}

// Implement RawConvertible
extension MessagePart {
    init(raw: Data) throws {
        let reader = DataReader(data: raw)
        try self.init(reader: reader)
    }
}
