//
//  RawConvertible.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 2/7/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public protocol RawConvertible {
    var raw: Data { get }

    init(raw: Data) throws
}
